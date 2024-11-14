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
    Write-Color -Text "Build Folder '$buildfolder' does not exist,", "Creating it." -Color White,Green
} else {
    Write-Host "Build folder '$buildfolder' existed. Continuing..." -ForegroundColor Yellow 
    #Remove-Item -Path $buildfolder -Recurse -Force
}
catch {
    Write-Error "Failed to create build folder '$buildfolder' or folder is not present. Try manually creating the folder? Error: $_"
}


# Check for internet connectivity before proceeding
if (-not (Test-InternetConnection)) {
    break
}
function Download-BuildFiles {
    #param (
        #[string]$FontName = "CascadiaCode",
        #[string]$FontDisplayName = "CaskaydiaCove NF",
        #[string]$Version = "3.2.1"
    #)

    try {
        #[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
        #$fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        $folderPath = "$env:systemdrive\build"
        #if ($fontFamilies -notcontains "${FontDisplayName}") {
        if (Test-Path -Path $folderPath) {
            #$fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${Version}/${FontName}.zip"
            #$zipFilePath = "$env:TEMP\${FontName}.zip"
            #$extractPath = "$env:TEMP\${FontName}"
            $builderZipUrl = "https://github.com/chrisrbmn/PC-Build-Script/archive/refs/heads/master.zip"
            $zipFilePath = "$env:TEMP\master.zip"
            $extractPath = "$env:systemdrive\build"

            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFileAsync((New-Object System.Uri($builderZipUrl)), $zipFilePath)

            while ($webClient.IsBusy) {
                Start-Sleep -Seconds 2
            }

            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
            #$destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
            #Get-ChildItem -Path $extractPath -Recurse -Filter "*.ttf" | ForEach-Object {
            #    If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {
            #        $destination.CopyHere($_.FullName, 0x10)
            #    }
            #}

            #Remove-Item -Path $extractPath -Recurse -Force
            Remove-Item -Path $zipFilePath -Force
        } else {
            Write-Host "Builder archive is already deployed"
        }
    }
    catch {
        Write-Error "Failed to download or deploy workstation builder. Error: $_"
    }
}