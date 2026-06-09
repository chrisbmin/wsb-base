# WorkStation Builder (WSB) - automated Windows workstation setup.
# Installs package managers, presents a tool selection menu, applies settings.
#
# USAGE (irm | iex):
#   irm "https://github.com/chrisbmin/wsb-base/raw/main/setup.ps1" | iex
#
# USAGE (with parameters):
#   & ([scriptblock]::Create((irm "https://github.com/chrisbmin/wsb-base/raw/main/setup.ps1"))) -ToolboxPath D:\toolbox
#
# PARAMETERS:
#   -ToolboxPath  : path to portable tools folder (default: $env:USERPROFILE\toolbox)
#   -SkipSettings : skip Windows privacy/UI tweaks
#   -SkipDebloat  : skip removal of default Windows apps
#   -SkipUpdate   : skip Windows Update at the end
param(
    [string] $ToolboxPath  = "$env:USERPROFILE\toolbox",
    [switch] $SkipSettings,
    [switch] $SkipDebloat,
    [switch] $SkipUpdate
)

# ── Banner ────────────────────────────────────────────────────────────────────

Write-Host ('=' * 30) -ForegroundColor DarkGray
Write-Host ''
Write-Host '  ##     ##  #######  #### ' -ForegroundColor Yellow
Write-Host '  ##     ##  ##       ## ##' -ForegroundColor Cyan
Write-Host '  ##  #  ##  #######  #### ' -ForegroundColor Green
Write-Host '  ## # # ##       ##  ## ##' -ForegroundColor Cyan
Write-Host '  ### # ###  #######  #### ' -ForegroundColor Blue
Write-Host ''
Write-Host '    WorkStation Builder' -ForegroundColor White
Write-Host ''
Write-Host ('=' * 30) -ForegroundColor DarkGray
Write-Host ''

# ── Admin check ───────────────────────────────────────────────────────────────

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host ""
    Write-Host "  [!] This script must be run as Administrator." -ForegroundColor Red
    Write-Host "      Right-click PowerShell and select 'Run as administrator', then try again." -ForegroundColor DarkGray
    Write-Host ""
    exit 1
}

Set-ExecutionPolicy RemoteSigned -Scope Process -Force

# ── Resume detection ──────────────────────────────────────────────────────────
# Windows Update runs first; if it installs updates, WSB schedules itself to
# relaunch at next logon and reboots. On that second pass it picks up here,
# restoring the choices captured before the reboot and skipping straight to
# package managers / settings / debloat / the tool menu.

$buildRoot = "$env:SystemDrive\build"
$stateFile = Join-Path $buildRoot '.wsb-state.json'
$taskName  = 'WSB-Resume'
$isResume  = $false

# Persistent log — survives the build folder being wiped/redownloaded and lets
# you check what happened across the Windows-Update reboot even if the console
# window closes before you can read an error on screen.
$logDir  = "$env:ProgramData\WSB"
$logFile = Join-Path $logDir 'wsb-log.txt'
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
"[$( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' )] WSB run started (resume file present: $(Test-Path $stateFile))" |
    Out-File -FilePath $logFile -Append -Encoding UTF8

if (Test-Path $stateFile) {
    Write-Host ""
    Write-Host "  Resuming WSB after Windows Update restart..." -ForegroundColor Cyan

    $state        = Get-Content $stateFile -Raw | ConvertFrom-Json
    $ToolboxPath  = $state.ToolboxPath
    $SkipSettings = [bool]$state.SkipSettings
    $SkipDebloat  = [bool]$state.SkipDebloat
    $buildFolder  = $state.BuildFolder
    $isResume     = $true

    Remove-Item $stateFile -Force -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
}

if (-not $isResume) {
    $buildFolder = Join-Path $buildRoot 'wsb-base-main'
}

# ── Internet check ────────────────────────────────────────────────────────────

Write-Host "  Checking internet connectivity..." -ForegroundColor DarkGray
try {
    $null = Test-Connection -ComputerName 8.8.8.8 -Count 1 -ErrorAction Stop
    Write-Host "  Connected." -ForegroundColor Green
} catch {
    Write-Host "  [!] No internet connection detected. Please connect and re-run." -ForegroundColor Red
    exit 1
}

# ── Download / refresh build archive ─────────────────────────────────────────
# Downloaded first (before toolbox and Windows Update) so the on-disk copy of
# setup.ps1 exists if a reboot is needed and the resume task must relaunch it.

if (-not $isResume) {
    Write-Host ""
    Write-Host "  Downloading WSB repository..." -ForegroundColor DarkGray

    $zipPath = "$env:TEMP\wsb-base.zip"
    $repoUrl = 'https://github.com/chrisbmin/wsb-base/archive/refs/heads/main.zip'

    if (Test-Path $buildRoot) {
        Remove-Item $buildRoot -Recurse -Force
    }

    try {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($repoUrl, $zipPath)
        Expand-Archive -Path $zipPath -DestinationPath $buildRoot -Force
        Remove-Item $zipPath -Force
        Write-Host "  Repository ready at $buildFolder" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Failed to download repository: $_" -ForegroundColor Red
        exit 1
    }
}

# ── Toolbox setup ─────────────────────────────────────────────────────────────

if (-not $isResume) {
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host "  TOOLBOX SETUP" -ForegroundColor Yellow
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  A toolbox folder holds portable tools (scripts, license files," -ForegroundColor DarkGray
    Write-Host "  portable executables) and gets added to your PATH automatically." -ForegroundColor DarkGray
    Write-Host ""

    $tbChoice = Read-Host "  Set up a toolbox folder? [Y/N]"

    if ($tbChoice.Trim() -match '^[Yy]') {
        Write-Host ""
        Write-Host "  Default path: " -ForegroundColor DarkGray -NoNewline
        Write-Host $ToolboxPath -ForegroundColor Cyan
        $tbInput = Read-Host "  Press Enter to accept or type a custom path"
        if ($tbInput.Trim() -ne '') {
            $ToolboxPath = $tbInput.Trim()
        }

        if (-not (Test-Path $ToolboxPath)) {
            Write-Host "  Creating: $ToolboxPath" -ForegroundColor DarkGray
            New-Item -ItemType Directory -Path $ToolboxPath -Force | Out-Null
        } else {
            Write-Host "  Folder already exists." -ForegroundColor DarkGray
        }

        . "$buildFolder\scripts\ToolboxSetup.ps1"
        Initialize-Toolbox -Path $ToolboxPath
    } else {
        $ToolboxPath = ''
        Write-Host "  Toolbox setup skipped." -ForegroundColor DarkGray
    }
}

# ── Windows Update ────────────────────────────────────────────────────────────
# Runs first so the rest of the build lands on a fully patched system. If
# updates are installed, WSB schedules itself to resume at next logon and
# restarts now — everything below only executes once on an up-to-date machine.

if (-not $isResume -and -not $SkipUpdate) {
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host "  WINDOWS UPDATE" -ForegroundColor Yellow
    Write-Host "  ================================================================" -ForegroundColor DarkGray

    # Pre-install the NuGet provider so Install-Module doesn't stop to prompt
    # "Do you want PowerShellGet to install and import the NuGet provider now?"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser | Out-Null
    }
    Import-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue

    Write-Host "  Checking for updates (this may take a few minutes)..." -ForegroundColor DarkGray
    $updates = Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -ErrorAction SilentlyContinue

    if ($updates -and $updates.Count -gt 0) {
        Write-Host "  $($updates.Count) update(s) installed." -ForegroundColor Green
        Write-Host ""
        Write-Host "  Scheduling WSB to resume automatically after restart..." -ForegroundColor DarkGray

        @{
            ToolboxPath  = $ToolboxPath
            SkipSettings = [bool]$SkipSettings
            SkipDebloat  = [bool]$SkipDebloat
            BuildFolder  = $buildFolder
        } | ConvertTo-Json | Set-Content -Path $stateFile -Encoding UTF8

        $resumeScheduled = $false
        try {
            $userId    = "$env:USERDOMAIN\$env:USERNAME"
            $action    = New-ScheduledTaskAction -Execute 'powershell.exe' `
                -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$buildFolder\setup.ps1`""
            $trigger   = New-ScheduledTaskTrigger -AtLogOn -User $userId
            $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Highest
            $settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force -ErrorAction Stop | Out-Null

            # Confirm it actually landed in Task Scheduler — Register-ScheduledTask
            # can report success but silently fail to persist on some configurations.
            if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
                $resumeScheduled = $true
            } else {
                throw "Task registration reported success but '$taskName' is not present in Task Scheduler."
            }
        } catch {
            Write-Host ""
            Write-Host "  [!] Could not schedule automatic resume: $_" -ForegroundColor Red
            "[$( Get-Date -Format 'yyyy-MM-dd HH:mm:ss' )] Resume scheduling failed: $_" | Out-File -FilePath $logFile -Append -Encoding UTF8
        }

        Write-Host ""
        if ($resumeScheduled) {
            Write-Host "  Restarting to finish installing updates — WSB will continue automatically once you log back in..." -ForegroundColor Yellow
        } else {
            Write-Host "  Restarting to finish installing updates." -ForegroundColor Yellow
            Write-Host "  Automatic resume could not be scheduled — after you log back in, re-run the same setup command." -ForegroundColor Yellow
            Write-Host "  WSB will detect the saved state in $buildRoot and pick up right where it left off." -ForegroundColor DarkGray
        }
        Start-Sleep -Seconds 5
        Restart-Computer -Force
        exit 0
    } else {
        Write-Host "  No updates available or already up to date." -ForegroundColor DarkGray
    }
}

# ── Install package managers ──────────────────────────────────────────────────

Write-Host ""
Write-Host "  ================================================================" -ForegroundColor DarkGray
Write-Host "  INSTALLING PACKAGE MANAGERS" -ForegroundColor Yellow
Write-Host "  ================================================================" -ForegroundColor DarkGray

# — Chocolatey —
Write-Host ""
Write-Host "  Chocolatey..." -ForegroundColor DarkGray
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

        # The official installer is chatty (TLS notes, path setup, shim creation,
        # etc.) — redirect all its streams to null so WSB's own output stays clean.
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) *>&1 | Out-Null

        # Refresh PATH/env vars in this session so `choco` works immediately —
        # otherwise the installer just warns you to close and reopen your shell.
        $chocoInstallDir = if ($env:ChocolateyInstall) { $env:ChocolateyInstall } else { "$env:ProgramData\chocolatey" }
        $chocoProfile    = Join-Path $chocoInstallDir 'helpers\chocolateyProfile.psm1'
        if (Test-Path $chocoProfile) {
            Import-Module $chocoProfile -Force
            Update-SessionEnvironment
        }

        Write-Host "  Chocolatey installed." -ForegroundColor Green
    } catch {
        Write-Host "  [!] Chocolatey install failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  Chocolatey already present." -ForegroundColor DarkGray
}

# — Winget —
Write-Host ""
Write-Host "  Winget..." -ForegroundColor DarkGray
try {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
    if (-not (Get-Module -ListAvailable -Name Microsoft.WinGet.Client)) {
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -Scope CurrentUser | Out-Null
    }
    Repair-WinGetPackageManager -ErrorAction SilentlyContinue
    Write-Host "  Winget ready." -ForegroundColor Green
} catch {
    Write-Host "  [!] Winget setup issue: $_" -ForegroundColor Red
}

# Scoop is opt-in now — selectable (with its git dependency) from the tool menu,
# and bootstrapped on demand by Install-SelectedTools. Just load the catalog here.
. "$buildFolder\config\tools.ps1"

# ── Windows settings & debloat ────────────────────────────────────────────────

if (-not $SkipSettings) {
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host "  APPLYING WINDOWS SETTINGS" -ForegroundColor Yellow
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    . "$buildFolder\scripts\SystemSettings.ps1"
}

if (-not $SkipDebloat) {
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host "  REMOVING DEFAULT APPS" -ForegroundColor Yellow
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    . "$buildFolder\scripts\RemoveDefaultApps.ps1"
}

# ── Tool selection menu ───────────────────────────────────────────────────────
# Shown last — by this point the machine is patched, package managers are
# ready, and Windows settings/debloat are already applied, so the GUI is the
# final interactive step before installing the chosen tools and restarting.

. "$buildFolder\scripts\Menu.ps1"
. "$buildFolder\scripts\Install.ps1"

Write-Host ""
Write-Host "  Opening tool selection window..." -ForegroundColor DarkGray

# Installs are now triggered from inside the GUI (background runspace).
# ShowDialog() blocks here until the user closes the window.
Show-ToolMenu -Catalog $ToolCatalog -ToolboxPath $ToolboxPath -ScoopBuckets $ScoopBuckets -BuildFolder $buildFolder

# ── Done ──────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host ("=" * 111) -ForegroundColor White -BackgroundColor Black
Write-Host "  WSB complete! " -ForegroundColor Black -BackgroundColor Green -NoNewline
Write-Host "" -ForegroundColor White -BackgroundColor Black
Write-Host ("=" * 111) -ForegroundColor White -BackgroundColor Black
Write-Host ""

Write-Host "  Press any key to restart, or close this window to skip..." -ForegroundColor Black -BackgroundColor White
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
Write-Host ""
Write-Host "  Restarting..." -ForegroundColor DarkGray
Restart-Computer
