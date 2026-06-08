# scripts/Install.ps1
# Install dispatcher — routes each selected tool to the right package manager.
# Dot-source this file, then call Install-SelectedTools.

function Install-SelectedTools {
    param(
        [Parameter(Mandatory)] [array]  $SelectedTools,
        [string] $ToolboxPath  = '',
        [array]  $ScoopBuckets = @()
    )

    $results = [PSCustomObject]@{
        Success = [System.Collections.Generic.List[string]]::new()
        Failed  = [System.Collections.Generic.List[string]]::new()
        Manual  = [System.Collections.Generic.List[PSCustomObject]]::new()
    }

    # ── Helpers ──────────────────────────────────────────────────────────────

    function Write-Step {
        param([string]$msg)
        Write-Host ""
        Write-Host "  >> $msg" -ForegroundColor Cyan
    }

    function Write-OK   { param([string]$msg) Write-Host "     OK  $msg" -ForegroundColor Green }
    function Write-Fail { param([string]$msg) Write-Host "     !!  $msg" -ForegroundColor Red }
    function Write-Info { param([string]$msg) Write-Host "         $msg" -ForegroundColor DarkGray }

    # ── Winget ───────────────────────────────────────────────────────────────

    $wingetTools = $SelectedTools | Where-Object { $_.Manager -eq 'winget' }
    if ($wingetTools) {
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkGray
        Write-Host "  WINGET PACKAGES" -ForegroundColor Yellow
        Write-Host "  ============================================================" -ForegroundColor DarkGray

        foreach ($tool in $wingetTools) {
            Write-Step "Installing $($tool.Name)..."
            try {
                $proc = Start-Process -FilePath 'winget' `
                    -ArgumentList "install -e --accept-source-agreements --accept-package-agreements --id $($tool.PackageId)" `
                    -Wait -PassThru -NoNewWindow
                if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq -1978335189) {
                    # -1978335189 = APPINSTALLER_ERROR_ALREADY_INSTALLED
                    Write-OK $tool.Name
                    $results.Success.Add($tool.Name)
                } else {
                    Write-Fail "$($tool.Name) (exit code $($proc.ExitCode))"
                    $results.Failed.Add($tool.Name)
                }
            } catch {
                Write-Fail "$($tool.Name) - $_"
                $results.Failed.Add($tool.Name)
            }
        }
    }

    # ── Chocolatey ───────────────────────────────────────────────────────────

    $chocoTools = $SelectedTools | Where-Object { $_.Manager -eq 'choco' }
    if ($chocoTools) {
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkGray
        Write-Host "  CHOCOLATEY PACKAGES" -ForegroundColor Yellow
        Write-Host "  ============================================================" -ForegroundColor DarkGray

        foreach ($tool in $chocoTools) {
            Write-Step "Installing $($tool.Name)..."
            try {
                $proc = Start-Process -FilePath 'choco' `
                    -ArgumentList "install $($tool.PackageId) -y --no-progress" `
                    -Wait -PassThru -NoNewWindow
                if ($proc.ExitCode -eq 0) {
                    Write-OK $tool.Name
                    $results.Success.Add($tool.Name)
                } else {
                    Write-Fail "$($tool.Name) (exit code $($proc.ExitCode))"
                    $results.Failed.Add($tool.Name)
                }
            } catch {
                Write-Fail "$($tool.Name) - $_"
                $results.Failed.Add($tool.Name)
            }
        }
    }

    # ── Scoop ────────────────────────────────────────────────────────────────
    # Scoop is opt-in. Bootstrap it (plus its git dependency) if the user picked
    # it directly, or picked any tool that installs via Scoop.

    $scoopBootstrap = $SelectedTools | Where-Object { $_.Manager -eq 'scoop-bootstrap' }
    $scoopTools     = $SelectedTools | Where-Object { $_.Manager -eq 'scoop' }

    if ($scoopBootstrap -or $scoopTools) {
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkGray
        Write-Host "  SCOOP" -ForegroundColor Yellow
        Write-Host "  ============================================================" -ForegroundColor DarkGray

        if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
            Write-Step "Installing Scoop..."
            try {
                Set-ExecutionPolicy RemoteSigned -Scope Process -Force
                # Fetch installer first, then invoke as a scriptblock to avoid nested-IEX parse issues.
                # -RunAsAdmin bypasses Scoop's elevated-session guard (officially supported).
                $scoopScript = Invoke-RestMethod -Uri 'https://get.scoop.sh'
                & ([scriptblock]::Create($scoopScript)) -RunAsAdmin
                Write-OK 'Scoop'
                $results.Success.Add('Scoop')
            } catch {
                Write-Fail "Scoop - $_"
                $results.Failed.Add('Scoop')
            }
        } elseif ($scoopBootstrap) {
            Write-OK 'Scoop (already present)'
            $results.Success.Add('Scoop')
        }

        # Scoop requires git to add buckets — install it as a dependency if missing
        if ((Get-Command scoop -ErrorAction SilentlyContinue) -and -not (Get-Command git -ErrorAction SilentlyContinue)) {
            Write-Step "Installing git (Scoop dependency)..."
            try {
                scoop install git | Out-Null
                Write-OK 'Git'
            } catch {
                Write-Fail "Git - $_"
            }
        }

        # Add buckets — the standard set plus anything specific tools require (deduplicated)
        $requiredBuckets = @($ScoopBuckets) + @(
            $scoopTools | Where-Object { $_.ScoopBucket } | Select-Object -ExpandProperty ScoopBucket
        ) | Select-Object -Unique

        foreach ($bucket in $requiredBuckets) {
            Write-Info "Ensuring scoop bucket: $bucket"
            scoop bucket add $bucket 2>&1 | Out-Null
        }
    }

    if ($scoopTools) {
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkGray
        Write-Host "  SCOOP PACKAGES" -ForegroundColor Yellow
        Write-Host "  ============================================================" -ForegroundColor DarkGray

        foreach ($tool in $scoopTools) {
            Write-Step "Installing $($tool.Name)..."
            try {
                scoop install $tool.PackageId
                Write-OK $tool.Name
                $results.Success.Add($tool.Name)
            } catch {
                Write-Fail "$($tool.Name) - $_"
                $results.Failed.Add($tool.Name)
            }
        }
    }

    # ── PowerShell Gallery ───────────────────────────────────────────────────

    $psTools = $SelectedTools | Where-Object { $_.Manager -eq 'psgallery' }
    if ($psTools) {
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkGray
        Write-Host "  POWERSHELL GALLERY MODULES" -ForegroundColor Yellow
        Write-Host "  ============================================================" -ForegroundColor DarkGray

        # Ensure NuGet provider is available
        Write-Info "Ensuring NuGet provider..."
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

        foreach ($tool in $psTools) {
            Write-Step "Installing module: $($tool.Name)..."
            if ($tool.Notes -and $tool.Notes -match '500 MB|large') {
                Write-Info "Note: $($tool.Notes)"
                Write-Info "This may take several minutes..."
            }
            try {
                Install-Module -Name $tool.PackageId -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
                Write-OK $tool.Name
                $results.Success.Add($tool.Name)
            } catch {
                Write-Fail "$($tool.Name) - $_"
                $results.Failed.Add($tool.Name)
            }
        }
    }

    # ── Windows Features (RSAT) ──────────────────────────────────────────────

    $featureTools  = $SelectedTools | Where-Object { $_.Manager -eq 'feature' }
    $featureGroups = $SelectedTools | Where-Object { $_.Manager -eq 'feature-group' }

    if ($featureTools -or $featureGroups) {
        Write-Host ""
        Write-Host "  ============================================================" -ForegroundColor DarkGray
        Write-Host "  WINDOWS FEATURES (RSAT)" -ForegroundColor Yellow
        Write-Host "  ============================================================" -ForegroundColor DarkGray

        foreach ($tool in $featureTools) {
            Write-Step "Enabling: $($tool.Name)..."
            try {
                $cap = Get-WindowsCapability -Online -Name $tool.PackageId -ErrorAction Stop
                if ($cap.State -eq 'Installed') {
                    Write-OK "$($tool.Name) (already installed)"
                    $results.Success.Add($tool.Name)
                } else {
                    Add-WindowsCapability -Online -Name $tool.PackageId -ErrorAction Stop | Out-Null
                    Write-OK $tool.Name
                    $results.Success.Add($tool.Name)
                }
            } catch {
                Write-Fail "$($tool.Name) - $_"
                $results.Failed.Add($tool.Name)
            }
        }

        # Group entries (e.g. "RSAT: All Tools") — PackageId is a wildcard pattern;
        # enable every matching capability that isn't already installed.
        foreach ($group in $featureGroups) {
            Write-Step "Enabling: $($group.Name)..."
            try {
                $caps = Get-WindowsCapability -Online -Name $group.PackageId -ErrorAction Stop |
                    Where-Object { $_.State -ne 'Installed' }

                if (-not $caps) {
                    Write-OK "$($group.Name) (already installed)"
                    $results.Success.Add($group.Name)
                } else {
                    foreach ($cap in $caps) {
                        Write-Info "Enabling $($cap.Name)..."
                        Add-WindowsCapability -Online -Name $cap.Name -ErrorAction Stop | Out-Null
                    }
                    Write-OK "$($group.Name) ($($caps.Count) capabilities enabled)"
                    $results.Success.Add($group.Name)
                }
            } catch {
                Write-Fail "$($group.Name) - $_"
                $results.Failed.Add($group.Name)
            }
        }
    }

    # ── Manual tools — collect for summary ───────────────────────────────────

    $manualTools = $SelectedTools | Where-Object { $_.Manager -eq 'manual' }
    foreach ($tool in $manualTools) {
        $results.Manual.Add($tool)
    }

    # ── Post-install: MobaXterm license ──────────────────────────────────────

    $mobaxInstalled = $results.Success -contains 'MobaXterm'
    if ($mobaxInstalled -and $ToolboxPath -ne '') {
        $licSrc  = Join-Path $ToolboxPath 'MobaXterm.mlic'
        $licDest = Join-Path $env:APPDATA 'Mobatek\MobaXterm\MobaXterm.mlic'
        if (Test-Path $licSrc) {
            Write-Step "Applying MobaXterm license..."
            try {
                $destDir = Split-Path $licDest
                if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                Copy-Item -Path $licSrc -Destination $licDest -Force
                Write-OK "MobaXterm license applied from toolbox"
            } catch {
                Write-Fail "Could not copy MobaXterm license - $_"
                Write-Info "Copy manually: $licSrc  ->  $licDest"
            }
        } else {
            Write-Info "MobaXterm installed. No license file found at: $licSrc"
            Write-Info "Copy MobaXterm.mlic to your toolbox folder to auto-apply on future runs."
        }
    }

    # ── Post-install: toolbox PATH ────────────────────────────────────────────

    if ($ToolboxPath -ne '' -and (Test-Path $ToolboxPath)) {
        $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
        if ($currentPath -notlike "*$ToolboxPath*") {
            Write-Step "Adding toolbox folder to user PATH..."
            try {
                [Environment]::SetEnvironmentVariable('PATH', "$currentPath;$ToolboxPath", 'User')
                Write-OK "Toolbox path added: $ToolboxPath"
                Write-Info "Restart your terminal for PATH changes to take effect."
            } catch {
                Write-Fail "Could not update PATH - $_"
                Write-Info "Add manually: $ToolboxPath"
            }
        } else {
            Write-Info "Toolbox path already in PATH: $ToolboxPath"
        }
    }

    # ── Summary ───────────────────────────────────────────────────────────────

    Write-Host ""
    Write-Host "  ============================================================" -ForegroundColor DarkGray
    Write-Host "  INSTALL SUMMARY" -ForegroundColor Yellow
    Write-Host "  ============================================================" -ForegroundColor DarkGray
    Write-Host ""

    if ($results.Success.Count -gt 0) {
        Write-Host "  Installed ($($results.Success.Count)):" -ForegroundColor Green
        foreach ($name in $results.Success) {
            Write-Host "    + $name" -ForegroundColor Green
        }
        Write-Host ""
    }

    if ($results.Failed.Count -gt 0) {
        Write-Host "  Failed ($($results.Failed.Count)):" -ForegroundColor Red
        foreach ($name in $results.Failed) {
            Write-Host "    x $name" -ForegroundColor Red
        }
        Write-Host ""
    }

    if ($results.Manual.Count -gt 0) {
        Write-Host "  Manual installs required ($($results.Manual.Count)):" -ForegroundColor Yellow
        foreach ($tool in $results.Manual) {
            Write-Host "    ! $($tool.Name)" -ForegroundColor Yellow
            Write-Host "      $($tool.PackageId)" -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    return $results
}
