# scripts/ToolboxSetup.ps1
# Populates the toolbox folder with Sysinternals Suite, PuTTY portable, and OpenSSL.
# Dot-source this file, then call Initialize-Toolbox.

function Initialize-Toolbox {
    param(
        [Parameter(Mandatory)] [string] $Path
    )

    function Write-Step { param([string]$msg) Write-Host ""; Write-Host "  >> $msg" -ForegroundColor Cyan }
    function Write-OK   { param([string]$msg) Write-Host "     OK  $msg" -ForegroundColor Green }
    function Write-Fail { param([string]$msg) Write-Host "     !!  $msg" -ForegroundColor Red }
    function Write-Info { param([string]$msg) Write-Host "         $msg" -ForegroundColor DarkGray }

    function Add-FolderToPath {
        param([string]$Folder)
        $current = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
        if ($current -notlike "*$Folder*") {
            [Environment]::SetEnvironmentVariable('PATH', "$current;$Folder", 'Machine')
            $env:PATH = "$env:PATH;$Folder"
            Write-Info "Added to system PATH: $Folder"
        } else {
            Write-Info "Already in PATH: $Folder"
        }
    }

    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host "  TOOLBOX POPULATION" -ForegroundColor Yellow
    Write-Host "  ================================================================" -ForegroundColor DarkGray

    $wc = [System.Net.WebClient]::new()

    # ── Sysinternals Suite ────────────────────────────────────────────────────

    Write-Step "Sysinternals Suite..."
    $sysDest = Join-Path $Path 'Sysinternals'
    try {
        if (-not (Test-Path $sysDest)) { New-Item -ItemType Directory -Path $sysDest -Force | Out-Null }
        $sysZip = Join-Path $env:TEMP 'SysinternalsSuite.zip'
        Write-Info "Downloading (~160 MB)..."
        $wc.DownloadFile('https://download.sysinternals.com/files/SysinternalsSuite.zip', $sysZip)
        Write-Info "Extracting..."
        Expand-Archive -Path $sysZip -DestinationPath $sysDest -Force
        Remove-Item $sysZip -Force -ErrorAction SilentlyContinue
        Add-FolderToPath $sysDest
        Write-OK "Sysinternals Suite  →  $sysDest"
    } catch {
        Write-Fail "Sysinternals - $_"
    }

    # ── PuTTY portable ────────────────────────────────────────────────────────

    Write-Step "PuTTY (portable .exe files)..."
    $puttyDest = Join-Path $Path 'PuTTY'
    $puttyExes = @(
        'putty.exe',      # SSH/Telnet client
        'puttygen.exe',   # Key generator
        'pageant.exe',    # SSH agent
        'plink.exe',      # CLI SSH client
        'pscp.exe',       # SCP file transfer
        'psftp.exe',      # SFTP client
        'puttytel.exe'    # Telnet-only client
    )
    try {
        if (-not (Test-Path $puttyDest)) { New-Item -ItemType Directory -Path $puttyDest -Force | Out-Null }
        foreach ($exe in $puttyExes) {
            $url  = "https://the.earth.li/~sgtatham/putty/latest/w64/$exe"
            $dest = Join-Path $puttyDest $exe
            Write-Info "Downloading $exe..."
            $wc.DownloadFile($url, $dest)
        }
        Add-FolderToPath $puttyDest
        Write-OK "PuTTY  →  $puttyDest"
    } catch {
        Write-Fail "PuTTY - $_"
    }

    # ── OpenSSL ───────────────────────────────────────────────────────────────
    # Uses the Shining Light Productions (slproweb) Win64 Light installer.
    # Version URL is resolved dynamically from slproweb's own hashes manifest
    # (the same source the official Chocolatey openssl package uses), so this
    # always pulls the current release without hardcoding a version number.

    Write-Step "OpenSSL..."
    $opensslDest = Join-Path $Path 'OpenSSL'
    try {
        Write-Info "Resolving latest OpenSSL version..."
        $hashesJson = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/slproweb/opensslhashes/master/win32_openssl_hashes.json' -ErrorAction Stop

        $entry = $hashesJson.files.PSObject.Properties |
            Where-Object { $_.Name -match 'Win64OpenSSL_Light-.*\.exe$' -and $_.Name -notmatch 'legacy' } |
            Sort-Object Name -Descending |
            Select-Object -First 1

        if (-not $entry) { throw 'Could not find Win64 Light installer in slproweb hashes manifest.' }

        $opensslUrl = $entry.Value.url
        Write-Info "Installer: $($entry.Name)"

        $installerPath = Join-Path $env:TEMP 'openssl-setup.exe'
        Write-Info "Downloading..."
        $wc.DownloadFile($opensslUrl, $installerPath)

        if (-not (Test-Path $opensslDest)) { New-Item -ItemType Directory -Path $opensslDest -Force | Out-Null }
        Write-Info "Installing silently to $opensslDest..."
        $proc = Start-Process -FilePath $installerPath `
            -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /DIR=`"$opensslDest`"" `
            -Wait -PassThru
        Remove-Item $installerPath -Force -ErrorAction SilentlyContinue

        if ($proc.ExitCode -ne 0) { throw "Installer exited with code $($proc.ExitCode)" }

        # Binaries land in <dir>\bin\; add that to PATH so openssl.exe is on the command line.
        $opensslBin = Join-Path $opensslDest 'bin'
        Add-FolderToPath $opensslBin
        Write-OK "OpenSSL  →  $opensslBin"
    } catch {
        Write-Fail "OpenSSL - $_"
    }
}
