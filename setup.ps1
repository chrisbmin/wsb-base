Write-Host "===========================================================================================================================" -ForegroundColor White -BackgroundColor Black
$text = "
__        __         _    ____  _        _   _               ____        _ _     _              ___        ______  ______  
\ \      / ___  _ __| | _/ ___|| |_ __ _| |_(_) ___  _ __   | __ ) _   _(_| | __| | ___ _ __   / \ \      / / ___|| __ \ \ 
 \ \ /\ / / _ \| '__| |/ \___ \| __/ _` | __| |/ _ \| '_ \  |  _ \| | | | | |/ _` |/ _ | '__| | | \ \ /\ / /\___ \|  _ \| |
  \ V  V | (_) | |  |   < ___) | || (_| | |_| | (_) | | | | | |_) | |_| | | | (_| |  __| |    | |  \ V  V /  ___) | |_) | |
   \_/\_/ \___/|_|  |_|\_|____/ \__\__,_|\__|_|\___/|_| |_| |____/ \__,_|_|_|\__,_|\___|_|    | |   \_/\_/  |____/|____/| |
                                                                                               \_\                     /_/ "
for ($i=0; $i -lt $text.length; $i++) {
    switch ($i % 6) {
        0 { $c = "Yellow" }
        2 { $c = "green" }
        4 { $c = "blue" }
        default { $c = "cyan" }
    }
write-host $text[$i] -NoNewline -ForegroundColor $c
}
Write-Host "`n"
Write-Host "===========================================================================================================================" -ForegroundColor White -BackgroundColor Black
Write-Host "`n" -ForegroundColor White -BackgroundColor Black
Write-Host "Welcome to the WorkStation Builder (WSB) script." -ForegroundColor Black -BackgroundColor Yellow
Write-Host "This script will automatically install Chocolatey and Winget along with a set of base applications." -ForegroundColor Black -BackgroundColor Yellow
Write-Host "It will then debloat Windows and provide a few customizations." -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Finally, it will run Windows Update and inquire if you'd like to restart the system." -ForegroundColor Black -BackgroundColor Yellow
Write-Host "`n"
Write-Host "Press any key to continue building your system - or close this window to skip..." -ForegroundColor Black -BackgroundColor Yellow
Write-Host "If you skip, you may rerun this script from the original URL " -ForegroundColor Black -BackgroundColor Yellow -NoNewline; Write-Host "'https://" -ForegroundColor Blue -BackgroundColor Yellow -NoNewline; Write-Host "cbmn.link" -ForegroundColor Blue -BackgroundColor Yellow -NoNewline; Write-Host "/wsb'. " -ForegroundColor DarkGray -BackgroundColor Yellow -NoNewline;
Write-Host "`n" -ForegroundColor White -BackgroundColor Black
Write-Host "===========================================================================================================================" -ForegroundColor White -BackgroundColor Black
$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "`n"
Write-Host "`n"
Write-Host "Yay! Starting the workstation build..." -ForegroundColor White -BackgroundColor Green
Write-Host "`n"
Write-Host "`n"

# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    break
}

Write-Host "Setting Powershell Execution Policy to 'RemoteSigned'."
Set-ExecutionPolicy remotesigned

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        $testConnection = Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop
        return $true
    }
    catch {
        Write-Warning "Internet connection is required but not available. Please check your connection."
        return $false
    }
}

# Check for internet connectivity before proceeding
if (-not (Test-InternetConnection)) {
    Write-Host "No internet detected. Exiting script."
    break
}

# Download/Install Build Archive / Unpack into build folder.  
try {
    # Check if the source file exists
    $builderUrl = "https://github.com/chrisrbmn/wsb-base/archive/refs/heads/main.zip"
    $buildfolder = "$env:systemdrive\build"
    $zipFilePath = "$env:TEMP\main.zip"
    $extractPath = "$env:systemdrive\build"
    if (Test-Path -Path $buildfolder) {
        # If the file exists, delete the folder and start over.
        Write-Host "Build folder '$buildfolder' is present. Deleting the folder and starting fresh..." -ForegroundColor White
        Remove-Item -Path $buildfolder -Recurse -Force
        Write-Host "Build folder deleted successfully."
        Write-Host "Downloading and unzipping archive to '$zipFilePath'." -ForegroundColor White
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFileAsync((New-Object System.Uri($builderUrl)), $zipFilePath)

            while ($webClient.IsBusy) {
                Start-Sleep -Seconds 2
            } 
            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
            Remove-Item -Path $zipFilePath -Force
        }
        catch {
            Write-Error "Failed to download archive. Error: $_"
        }
        Write-Host "Archive Downloaded successfully!"
    } else {
        Write-Host "Build Folder does not exist @ [$buildfolder]. Downloading Files..."
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFileAsync((New-Object System.Uri($builderUrl)), $zipFilePath)

            while ($webClient.IsBusy) {
                Start-Sleep -Seconds 2
            } 
            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
            Remove-Item -Path $zipFilePath -Force
        }
        catch {
            Write-Error "Failed to download archive. Error: $_"
        }
        Write-Host "Archive Downloaded successfully!"
    }
    
}
catch {
    Write-Error "Failed to download archive. Error: $_"
}

###
# Choco install
# Check to see if directories are already in place, and if yes, delete everything, and reinstall.
try {
    # Check if the source file exists
    $chocofolder = "C:\ProgramData\chocolatey"
    $chococachefolder = "C:\ProgramData\ChocolateyHttpCache"
    if (Test-Path -Path $chocofolder) {
        # If the file exists, delete the folder
        
        Remove-Item -Path $chocofolder -Recurse -Force
        Remove-Item -Path $chococachefolder -Recurse -Force
        Write-Host "Chocolately deleted successfully."
        Write-Host "Reinstalling Chocolately..."
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        }
        catch {
            Write-Error "Failed to install Chocolatey. Error: $_"
        }
        Write-Host "Chocolately installed successfully!"
    } else {
        Write-Host "Chocolately Profile does not exist @ [$chocofolder]. Installing..."
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        }
        catch {
            Write-Error "Failed to install Chocolatey. Error: $_"
        }
        Write-Host "Chocolately installed successfully!"
    }
    
    }
    catch {
        Write-Error "Failed to install Chocolatey. Error: $_"
    }
###

# Winget install
try {
    Install-PackageProvider -Name NuGet -Force | Out-Null
    Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
  } catch {
    throw "Microsoft.Winget.Client was not installed successfully"
  } finally {
    # Check to be sure it acutally installed
    if (-not(Get-Module -ListAvailable -Name Microsoft.Winget.Client)) {
      throw "Microsoft.Winget.Client was not found. Check that the Windows Package Manager PowerShell module was installed correctly."
    } else {
        Write-Host "Winget Client was installed successfully!" -ForegroundColor White
    }
  }
  Repair-WinGetPackageManager


  #--- Let Set up Windows ---
. "$env:systemdrive\build\wsb-base-main\scripts\RemoveDefaultApps.ps1"
. "$env:systemdrive\build\wsb-base-main\scripts\SystemSettings.ps1"
. "$env:systemdrive\build\wsb-base-main\scripts\InstallBaseTools.ps1"

## WINDOWS UPDATES ##
# Install the PSWindowsUpdate module if not already installed
if (-not (Get-Module -Name PSWindowsUpdate -ListAvailable)) {
    Install-Module -Name PSWindowsUpdate -Force
}

# Import the PSWindowsUpdate module
Import-Module -Name PSWindowsUpdate -Force -ErrorAction Stop

# Check for available Windows updates
$updates = Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot

# Check if any updates were installed
if ($updates.Count -gt 0) {
    Write-Output "Installed Windows Updates:"
    foreach ($update in $updates) {
        Write-Output "$($update.Title) - $($update.Description)"
    }
    $InstalledUpdates = Get-WUList
    Write-Output "List of Installed Updates:"
    foreach ($installedUpdate in $InstalledUpdates) {
        Write-Output "$($installedUpdate.Title)"
    }
} else {
    Write-Output "No updates were installed."
}

Write-Host "Almost Complete - Should we reboot?" -ForegroundColor White

function Restart-PC{
    ##########
    # Restart
    ##########
    Write-Host
    Write-Host "Press any key to restart your system - or close this window to skip..." -ForegroundColor Black -BackgroundColor White
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host "Restarting..."
    Restart-Computer
}
Restart-PC
