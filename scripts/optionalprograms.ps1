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
        Write-Host "6: Run Windows Utility"
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
            winget install -e -h --id JanDeDobbeleer.OhMyPosh
        }
        '6' {
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