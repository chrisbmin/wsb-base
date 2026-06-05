# Built from YouTube video : https://www.youtube.com/watch?v=2G4qAP1y5PA
#
function show-menu {
    Param (
        [string]$title = "Main Menu"
        )
    
        Clear-Host
        Write-Host "================ $title ================"
        Write-Host "1: Install AzureCLI"
        Write-Host "2: Install Azure Data Studio"
        Write-Host "3: Install AzureStorageExplorer"
        Write-Host "4: Mozilla Firefox Developer Edition"
        Write-Host "5: Install OhMyPosh"
        Write-Host "6: Install Micorosft PowerToys"
        Write-Host "7: Run ChrisTitus Windows Utility"
        Write-Host "Q: Quit"
        Write-Host "================ $title ================"
}

function main {
while($true){
    show-menu
    $input = Read-Host "Please make a selection"
    switch ($input) {
        '1' {
            winget install -e -h --id Microsoft.AzureCLI
        }
        '2' {
            winget install -e -h --id Microsoft.AzureDataStudio
        }
        '3' {
            winget install -e -h --id Microsoft.AzureStorageExplorer
        }
        '4' {
            winget install -e -h --id Mozilla.FirefoxDeveloperEdition
        }
        '5' {
            winget install -e -h --id Microsoft.PowerToys # settings to sync
        }
        '6' {
            winget install -e -h --id JanDeDobbeleer.OhMyPosh
        }
        '7' {
            irm "https://christitus.com/win" | iex
        }
        'q' {
            Write-Host "Exiting..."
            break
        }
        default {
            Write-Host "Invalid selection. Please try again."
        }
    }
    Write-Host "Press any key to continue..."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}
    
}
main
#
# Combined Notes from other code below - to be merged above.
#
#winget install -e --id Mozilla.Firefox.DeveloperEdition
#winget install -e -h --id Microsoft.BingWallpaper

# https://obsidian.md/
#winget install -e -h --id Obsidian.Obsidian

# https://pandoc.org/index.html
#winget install -e -h --id JohnMacFarlane.Pandoc

# https://www.microsoft.com/en-us/microsoft-365/microsoft-whiteboard/digital-whiteboard-app
#winget install -e -h --id Microsoft.Whiteboard -s msstore

# Moved to Optional Programs
# winget install -e -h --id Microsoft.PowerToys # settings to sync

# Move the below to optional installed programs
# winget install -e -h --id Microsoft.Teams
# winget install -e -h --id Microsoft.Office
#winget install -e -h --id Logitech.Options
#winget install -e -h --id Dell.DisplayManager

# Adding here - this might be installed via PowerShell Profile Repo
# Add to optional programs
# choco install -y cascadia-code-nerd-font

# https://github.com/awaescher/RepoZ
#winget install -e -h --id AndreasWascher.RepoZ

#iwr https://get.pnpm.io/install.ps1 -useb | iex

# ---------------------------------------------- #
# Prompt  -------------------------------------- #
# ---------------------------------------------- #
#pwsh -Command { Install-Module posh-git -Scope CurrentUser -Force}
#winget install -e -h --id JanDeDobbeleer.OhMyPosh


# ---------------------------------------------- #
# Azure tools  --------------------------------- #
# ---------------------------------------------- #
#winget install -e -h --id Microsoft.AzureCLI
#winget install -e -h --id Microsoft.AzureCosmosEmulator
#winget install -e -h --id Microsoft.AzureDataStudio
#winget install -e -h --id Microsoft.azure-iot-explorer
#winget install -e -h --id Microsoft.AzureStorageExplorer
#winget install -e -h --id Pulumi.Pulumi
#winget install -e -h --id Microsoft.AzureFunctionsCoreTools
# Azurite can be installed through vscode extension or as a global npm package
# pnpm add -g azurite