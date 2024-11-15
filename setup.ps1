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
    $builderUrl = "https://github.com/chrisrbmn/wsb-v2/archive/refs/heads/main.zip"
    $downloadfolder = "$env:systemdrive\build"
    $zipFilePath = "$env:TEMP\main.zip"
    $extractPath = "$env:systemdrive\build"
    Write-Host "Downloading and unzipping archive to '$zipFilePath'." -ForegroundColor White
    $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFileAsync((New-Object System.Uri($builderUrl)), $zipFilePath)

            while ($webClient.IsBusy) {
                Start-Sleep -Seconds 2
            } 
    #Invoke-WebRequest -Uri "https://github.com/chrisrbmn/wsb-v2/archive/refs/heads/main.zip" -OutFile "$downloadfolder\main.zip"
    #Expand-Archive -Path "$downloadfolder\main.zip" -DestinationPath $downloadfolder -Force
    Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
    Remove-Item -Path $zipFilePath -Force
}
catch {
    Write-Error "Failed to download archive. Error: $_"
}

# Choco install
# Check to see if directories are already in place, and if yes, delete everything, and reinstall everything
try {
    # Check if the source file exists
    $chocofolder = "C:\ProgramData\chocolatey"
    if (Test-Path -Path $chocofolder) {
        # If the file exists, delete the folder
        $userKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment',$true)
        $userPath = $userKey.GetValue('PATH', [string]::Empty, 'DoNotExpandEnvironmentNames').ToString()

        $machineKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\ControlSet001\Control\Session Manager\Environment\',$true)
        $machinePath = $machineKey.GetValue('PATH', [string]::Empty, 'DoNotExpandEnvironmentNames').ToString()

        $backupPATHs = @(
            "User PATH: $userPath"
            "Machine PATH: $machinePath"
        )
        $backupFile = "C:\PATH_backups_ChocolateyUninstall.txt"
        $backupPATHs | Set-Content -Path $backupFile -Encoding UTF8 -Force

        $warningMessage = "
            This could cause issues after reboot where nothing is found if something goes wrong.
            In that case, look at the backup file for the original PATH values in '$backupFile'.
        "
        if ($userPath -like "*$env:ChocolateyInstall*") {
            Write-Verbose "Chocolatey Install location found in User Path. Removing..."
            Write-Warning $warningMessage

            $newUserPATH = @(
                $userPath -split [System.IO.Path]::PathSeparator |
                    Where-Object { $_ -and $_ -ne "$env:ChocolateyInstall\bin" }
            ) -join [System.IO.Path]::PathSeparator

            # NEVER use [Environment]::SetEnvironmentVariable() for PATH values; see https://github.com/dotnet/corefx/issues/36449
            # This issue exists in ALL released versions of .NET and .NET Core as of 12/19/2019
            $userKey.SetValue('PATH', $newUserPATH, 'ExpandString')
        }

        if ($machinePath -like "*$env:ChocolateyInstall*") {
            Write-Verbose "Chocolatey Install location found in Machine Path. Removing..."
            Write-Warning $warningMessage

            $newMachinePATH = @(
                $machinePath -split [System.IO.Path]::PathSeparator |
                    Where-Object { $_ -and $_ -ne "$env:ChocolateyInstall\bin" }
            ) -join [System.IO.Path]::PathSeparator

            # NEVER use [Environment]::SetEnvironmentVariable() for PATH values; see https://github.com/dotnet/corefx/issues/36449
            # This issue exists in ALL released versions of .NET and .NET Core as of 12/19/2019
            $machineKey.SetValue('PATH', $newMachinePATH, 'ExpandString')
        }

        # Adapt for any services running in subfolders of ChocolateyInstall
        $agentService = Get-Service -Name chocolatey-agent -ErrorAction SilentlyContinue
        if ($agentService -and $agentService.Status -eq 'Running') {
            $agentService.Stop()
        }
        # TODO: add other services here

        Remove-Item -Path $env:ChocolateyInstall -Recurse -Force -WhatIf

        'ChocolateyInstall', 'ChocolateyLastPathUpdate' | ForEach-Object {
            foreach ($scope in 'User', 'Machine') {
                [Environment]::SetEnvironmentVariable($_, [string]::Empty, $scope)
            }
        }

        $machineKey.Close()
        $userKey.Close()

        Remove-Item -Path $chocofolder -Force
        Write-Host "Chocolately deleted successfully."
    } else {
        Write-Host "Chocolately Profile does not exist @ [$PROFILE]. Installing..."
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        }
        catch {
            Write-Error "Failed to install Chocolatey. Error: $_"
        }
    }
    
    }
    catch {
        Write-Error "Failed to remove Chocolately or not installed. Error: $_"
    }


#try {
#    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
#}
#catch {
#    Write-Error "Failed to install Chocolatey. Error: $_"
#}

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


  #--- Setting up Windows ---
#. "$env:systemdrive\build\wsb-v2-main\scripts\InstallWinget.ps1"
#. "$env:systemdrive\build\wsb-v2-main\scripts\FileExplorerSettings.ps1"
. "$env:systemdrive\build\wsb-v2-main\scripts\RemoveDefaultApps.ps1"
#. "$env:systemdrive\build\wsb-v2-main\scripts\IDEs.ps1"
. "$env:systemdrive\build\wsb-v2-main\scripts\Tools.ps1"
. "$env:systemdrive\build\wsb-v2-main\scripts\SystemSettings.ps1"


# TODO: install WSL2 / Ubuntu
# choco install -y Microsoft-Windows-Subsystem-Linux -source windowsfeatures
# choco install -y VirtualMachinePlatform -source windowsfeatures
# wsl --set-default-version 2
# choco install wsl2 --params "/Version:2 /Retry:true"

# TODO: Docker
# winget install -e -h --id suse.RancherDesktop

# // windowsfeatures (Windows Sandbox, .NET Framework)
# // Taskbar (Set-BoxstarterTaskbarOptions)

Install-Module PSWindowsUpdate
Add-WUServiceManager -MicrosoftUpdate
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
