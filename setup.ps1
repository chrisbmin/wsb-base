# WorkStation Builder (WSB) - automated Windows workstation setup.
# Installs package managers, presents a tool selection menu, applies settings.
#
# USAGE (irm | iex):
#   irm "https://github.com/chrisbmin/wsb-base/raw/main/setup.ps1" | iex
#
# USAGE (with parameters):
#   & ([scriptblock]::Create((irm "https://github.com/chrisbmin/wsb-base/raw/main/setup.ps1"))) -WsbProfile work
#
# PARAMETERS:
#   -WsbProfile   : work | personal  (pre-selects tool defaults; prompted if omitted)
#   -ToolboxPath  : path to portable tools folder (default: $env:USERPROFILE\toolbox)
#   -SkipSettings : skip Windows privacy/UI tweaks
#   -SkipDebloat  : skip removal of default Windows apps
#   -SkipUpdate   : skip Windows Update at the end
param(
    [string] $WsbProfile   = '',
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

# ── Internet check ────────────────────────────────────────────────────────────

Write-Host "  Checking internet connectivity..." -ForegroundColor DarkGray
try {
    $null = Test-Connection -ComputerName 8.8.8.8 -Count 1 -ErrorAction Stop
    Write-Host "  Connected." -ForegroundColor Green
} catch {
    Write-Host "  [!] No internet connection detected. Please connect and re-run." -ForegroundColor Red
    exit 1
}

# ── Profile selection ─────────────────────────────────────────────────────────

if ($WsbProfile -ne '' -and $WsbProfile -notin @('work','personal')) {
    Write-Host "  [!] Invalid -WsbProfile '$WsbProfile'. Must be 'work' or 'personal'." -ForegroundColor Red
    exit 1
}

# Support env var fallback for irm | iex usage (can't pass params to piped scripts)
if ($WsbProfile -eq '' -and $env:WSB_PROFILE -in 'work','personal') {
    $WsbProfile = $env:WSB_PROFILE
}

if ($WsbProfile -eq '') {
    Write-Host ""
    Write-Host "  Select a profile to pre-populate tool defaults:" -ForegroundColor Yellow
    Write-Host "    1  Work       (sysadmin stack: RSAT, Azure, Nutanix tools, admin utilities)" -ForegroundColor White
    Write-Host "    2  Personal   (everyday tools: browsers, media, productivity)" -ForegroundColor White
    Write-Host ""
    do {
        $choice = Read-Host "  Enter 1 or 2"
    } until ($choice -in '1','2')
    $WsbProfile = if ($choice -eq '1') { 'work' } else { 'personal' }
}

Write-Host ""
Write-Host "  Profile: " -ForegroundColor DarkGray -NoNewline
Write-Host $WsbProfile.ToUpper() -ForegroundColor Cyan

# ── Toolbox path ──────────────────────────────────────────────────────────────

Write-Host ""
if ($ToolboxPath -ne '') {
    Write-Host "  Toolbox folder: " -ForegroundColor DarkGray -NoNewline
    Write-Host $ToolboxPath -ForegroundColor Cyan
    Write-Host "  (Press Enter to accept, type a new path, or type SKIP to skip toolbox setup)" -ForegroundColor DarkGray
    $tbInput = Read-Host "  >"
    if ($tbInput.Trim().ToUpper() -eq 'SKIP') {
        $ToolboxPath = ''
        Write-Host "  Toolbox setup skipped." -ForegroundColor DarkGray
    } elseif ($tbInput.Trim() -ne '') {
        $ToolboxPath = $tbInput.Trim()
    }
}

if ($ToolboxPath -ne '' -and -not (Test-Path $ToolboxPath)) {
    Write-Host "  Creating toolbox folder: $ToolboxPath" -ForegroundColor DarkGray
    New-Item -ItemType Directory -Path $ToolboxPath -Force | Out-Null
}

# ── Download / refresh build archive ─────────────────────────────────────────

Write-Host ""
Write-Host "  Downloading WSB repository..." -ForegroundColor DarkGray

$buildRoot   = "$env:SystemDrive\build"
$zipPath     = "$env:TEMP\wsb-base.zip"
$repoUrl     = 'https://github.com/chrisbmin/wsb-base/archive/refs/heads/main.zip'
$buildFolder = Join-Path $buildRoot 'wsb-base-main'

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
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
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

# — Scoop —
Write-Host ""
Write-Host "  Scoop..." -ForegroundColor DarkGray
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    try {
        Set-ExecutionPolicy RemoteSigned -Scope Process -Force
        # Fetch installer first, then invoke as a scriptblock to avoid nested-IEX parse issues.
        # -RunAsAdmin bypasses Scoop's elevated-session guard (officially supported).
        $scoopScript = Invoke-RestMethod -Uri 'https://get.scoop.sh'
        & ([scriptblock]::Create($scoopScript)) -RunAsAdmin
        Write-Host "  Scoop installed." -ForegroundColor Green
    } catch {
        Write-Host "  [!] Scoop install failed: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  Scoop already present." -ForegroundColor DarkGray
}

# Add standard Scoop buckets
. "$buildFolder\config\tools.ps1"
foreach ($bucket in $ScoopBuckets) {
    scoop bucket add $bucket 2>&1 | Out-Null
}

# ── Tool selection menu ───────────────────────────────────────────────────────

. "$buildFolder\scripts\Menu.ps1"
. "$buildFolder\scripts\Install.ps1"

Write-Host ""
Write-Host "  Press any key to open the tool selection menu..." -ForegroundColor Black -BackgroundColor Yellow
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

$selectedTools = Show-ToolMenu -Catalog $ToolCatalog -Profile $WsbProfile

if ($selectedTools.Count -eq 0) {
    Write-Host ""
    Write-Host "  No tools selected. Skipping installs." -ForegroundColor DarkYellow
} else {
    Write-Host ""
    Write-Host "  Installing $($selectedTools.Count) selected tools..." -ForegroundColor Cyan
    $installResults = Install-SelectedTools -SelectedTools $selectedTools -ToolboxPath $ToolboxPath
}

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

# ── Windows Update ────────────────────────────────────────────────────────────

if (-not $SkipUpdate) {
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host "  WINDOWS UPDATE" -ForegroundColor Yellow
    Write-Host "  ================================================================" -ForegroundColor DarkGray

    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser | Out-Null
    }
    Import-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue

    Write-Host "  Checking for updates (this may take a few minutes)..." -ForegroundColor DarkGray
    $updates = Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -ErrorAction SilentlyContinue

    if ($updates -and $updates.Count -gt 0) {
        Write-Host "  $($updates.Count) update(s) installed." -ForegroundColor Green
    } else {
        Write-Host "  No updates available or already up to date." -ForegroundColor DarkGray
    }
}

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
