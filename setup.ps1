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
        New-Item -ItemType Directory -Path $buildfolder
        Write-Host "Build Folder '$buildfolder' does not exist." -f Yellow; Write-Host "`n Creating it..." -f Green;
    } else {
        Write-Host "Build folder '$buildfolder' existed. Continuing..." -ForegroundColor White 
        #Remove-Item -Path $buildfolder -Recurse -Force
    }
function downloadbuilder {
    $downloadfolder = "$env:systemdrive\build"
    Write-Host "Downloading and unzipping archive to '$downloadfolder'. Continuing..." -ForegroundColor White 
    Invoke-WebRequest -Uri "https://github.com/chrisrbmn/wsb-v2/archive/refs/heads/main.zip" -OutFile "$downloadfolder\main.zip"
    Expand-Archive "$downloadfolder\main.zip" -DestinationPath $downloadfolder
}

# Choco install
#try {
#    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
#}
#catch {
#    Write-Error "Failed to install Chocolatey. Error: $_"
#}


#function Download-Builder {
#    param (
        #[string]$FontName = "CascadiaCode",
        #[string]$FontDisplayName = "CaskaydiaCove NF",
        #[string]$Version = "3.2.1"
#    )

#    try {
        #[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        #$fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
#        $folderPath = "$env:systemdrive\build"
        #if ($fontFamilies -notcontains "${FontDisplayName}") {
#        if (Test-Path -Path $folderPath) {
            #$fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${Version}/${FontName}.zip"
            #$zipFilePath = "$env:TEMP\${FontName}.zip"
            #$extractPath = "$env:TEMP\${FontName}"
#            $builderZipUrl = "https://github.com/chrisrbmn/wsb-v2/archive/refs/heads/main.zip"
#            $zipFilePath = "$env:TEMP\main.zip"
#            $extractPath = "$env:systemdrive\build"

#            $webClient = New-Object System.Net.WebClient
#            $webClient.DownloadFileAsync((New-Object System.Uri($builderZipUrl)), $zipFilePath)

#            while ($webClient.IsBusy) {
#                Start-Sleep -Seconds 2
#            }

#            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
            #$destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
            #Get-ChildItem -Path $extractPath -Recurse -Filter "*.ttf" | ForEach-Object {
            #    If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {
            #        $destination.CopyHere($_.FullName, 0x10)
            #    }
            #}

            #Remove-Item -Path $extractPath -Recurse -Force
#            Remove-Item -Path $zipFilePath -Force
#        } else {
#            Write-Host "Builder archive is already deployed"
#       }
#    }
#    catch {
#        Write-Error "Failed to download or deploy workstation builder. Error: $_"
#    }
#}