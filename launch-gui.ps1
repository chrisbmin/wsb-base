# WorkStation Builder (WSB) - standalone tool installer GUI.
# Opens the app chooser and installer without running Windows Update, settings,
# or debloat. Use this on an existing machine to add or manage tools any time.
#
# USAGE (irm | iex):
#   irm "https://github.com/chrisbmin/wsb-base/raw/main/launch-gui.ps1" | iex
#
# USAGE (with parameters):
#   & ([scriptblock]::Create((irm "https://github.com/chrisbmin/wsb-base/raw/main/launch-gui.ps1"))) -ToolboxPath D:\toolbox
#
# PARAMETERS:
#   -ToolboxPath : path to portable tools folder — used for MobaXterm license copy
#                  and toolbox PATH post-install step. Defaults to auto-detect.
param(
    [string] $ToolboxPath = ''
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
Write-Host '    GUI Tool Installer' -ForegroundColor DarkGray
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

$buildRoot   = "$env:SystemDrive\build"
$buildFolder = Join-Path $buildRoot 'wsb-base-main'

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
    Write-Host "  Repository ready." -ForegroundColor Green
} catch {
    Write-Host "  [!] Failed to download repository: $_" -ForegroundColor Red
    exit 1
}

# ── Package manager readiness ─────────────────────────────────────────────────
# Ensure Chocolatey and Winget are available before the GUI opens so tools
# install cleanly when selected. Scoop is bootstrapped on demand by Install.ps1
# the first time any Scoop-managed tool is chosen.

Write-Host ""
Write-Host "  ================================================================" -ForegroundColor DarkGray
Write-Host "  CHECKING PACKAGE MANAGERS" -ForegroundColor Yellow
Write-Host "  ================================================================" -ForegroundColor DarkGray

# — Chocolatey —
Write-Host ""
Write-Host "  Chocolatey..." -ForegroundColor DarkGray
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "  Not found — installing..." -ForegroundColor DarkGray
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) *>&1 | Out-Null
        $chocoInstallDir = if ($env:ChocolateyInstall) { $env:ChocolateyInstall } else { "$env:ProgramData\chocolatey" }
        $chocoProfile    = Join-Path $chocoInstallDir 'helpers\chocolateyProfile.psm1'
        if (Test-Path $chocoProfile) { Import-Module $chocoProfile -Force; Update-SessionEnvironment }
        Write-Host "  Chocolatey installed." -ForegroundColor Green
    } catch {
        Write-Host "  [!] Chocolatey install failed — choco-managed tools may not install: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Chocolatey present." -ForegroundColor DarkGray
}

# — Winget —
Write-Host ""
Write-Host "  Winget..." -ForegroundColor DarkGray
try {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    if (-not (Get-Module -ListAvailable -Name Microsoft.WinGet.Client)) {
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -Scope CurrentUser | Out-Null
    }
    Repair-WinGetPackageManager -ErrorAction SilentlyContinue
    Write-Host "  Winget ready." -ForegroundColor Green
} catch {
    Write-Host "  [!] Winget setup issue — winget-managed tools may not install: $_" -ForegroundColor Yellow
}

# ── Toolbox path resolution ───────────────────────────────────────────────────
# If -ToolboxPath was not passed, auto-detect the default location. Used for
# the MobaXterm license copy and the toolbox PATH post-install step; safe to
# leave empty if no toolbox was ever set up on this machine.

if ($ToolboxPath -eq '') {
    $defaultToolbox = "$env:USERPROFILE\toolbox"
    if (Test-Path $defaultToolbox) {
        $ToolboxPath = $defaultToolbox
        Write-Host ""
        Write-Host "  Toolbox detected: $ToolboxPath" -ForegroundColor DarkGray
    }
}

# ── Load catalog and launch GUI ───────────────────────────────────────────────

. "$buildFolder\config\tools.ps1"
. "$buildFolder\scripts\Menu.ps1"
. "$buildFolder\scripts\Install.ps1"

Write-Host ""
Write-Host "  Opening tool selection window..." -ForegroundColor DarkGray

Show-ToolMenu -Catalog $ToolCatalog -ToolboxPath $ToolboxPath -ScoopBuckets $ScoopBuckets -BuildFolder $buildFolder

# ── Done ──────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host ("=" * 111) -ForegroundColor White -BackgroundColor Black
Write-Host "  WSB Tool Installer done. " -ForegroundColor Black -BackgroundColor Green -NoNewline
Write-Host "" -ForegroundColor White -BackgroundColor Black
Write-Host ("=" * 111) -ForegroundColor White -BackgroundColor Black
Write-Host ""

Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
