# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    break
}

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

    $buildfolder = "$env:systemdrive\build"
    if (!(Test-Path -Path $buildfolder)) {
        Write-Host "Build Folder '$buildfolder' does not exist." -f Yellow; Write-Host "`n Creating it..." -f Green;
        New-Item -ItemType Directory -Path $buildfolder
    } else {
        Write-Host "Build folder '$buildfolder' existed. Continuing..." -ForegroundColor White 
        #Remove-Item -Path $buildfolder -Recurse -Force
    }

# Check for internet connectivity before proceeding
if (-not (Test-InternetConnection)) {
    break
}
  
# Download Install Archive / Unpack into build folder.    
try {
    $downloadfolder = "$env:systemdrive\build"
    $zipFilePath = "$env:systemdrive\build\main.zip"
    Write-Host "Downloading and unzipping archive to '$downloadfolder'." -ForegroundColor White 
    Invoke-WebRequest -Uri "https://github.com/chrisrbmn/wsb-v2/archive/refs/heads/main.zip" -OutFile "$downloadfolder\main.zip"
    Expand-Archive -Path "$downloadfolder\main.zip" -DestinationPath $downloadfolder -Force
    Remove-Item -Path $zipFilePath -Force
}
catch {
    Write-Error "Failed to download archive. Error: $_"
}

# Choco install
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
catch {
    Write-Error "Failed to install Chocolatey. Error: $_"
}

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
    }
  }
  Repair-WinGetPackageManager
  RefreshEnv

  #--- Setting up Windows ---
#. "$env:systemdrive\build\scripts\InstallWinget.ps1"
. "$env:systemdrive\build\scripts\FileExplorerSettings.ps1"
. "$env:systemdrive\build\scripts\RemoveDefaultApps.ps1"
. "$env:systemdrive\build\scripts\Tools.ps1"
. "$env:systemdrive\build\scripts\IDEs.ps1"

# TODO: install WSL2 / Ubuntu
# choco install -y Microsoft-Windows-Subsystem-Linux -source windowsfeatures
# choco install -y VirtualMachinePlatform -source windowsfeatures
# wsl --set-default-version 2
# choco install wsl2 --params "/Version:2 /Retry:true"

# TODO: Docker
# winget install -e -h --id suse.RancherDesktop

# // windowsfeatures (Windows Sandbox, .NET Framework)
# // Taskbar (Set-BoxstarterTaskbarOptions)
