# These are the base applications I like to install regardless of the machine I'm working on.
# Other optional applications are installed based on the machine's purpose.
# Menu's to the optional programs will be added in the future. Check InstallOptionalTools.ps1 for more information.

# ---------------------------------------------- #
# Browsers  ------------------------------------ #
# ---------------------------------------------- #
# choco install -y googlechrome
winget install -e --id Google.Chrome 

# choco install -y firefox
winget install -e --id Mozilla.Firefox
#winget install -e --id Mozilla.Firefox.DeveloperEdition

# ---------------------------------------------- #
# Common tools  --------------------------------- #
# ---------------------------------------------- #

#choco install -y screentogif
#choco install -y zoomit

# choco install -y 7zip
winget install -e --id 7zip.7zip 

# choco install -y ShareX
winget install -e --id ShareX.ShareX 

#choco install -y paint.net
winget install -e --id dotPDN.PaintDotNet

#winget install -e -h --id WinDirStat.WinDirStat
winget install -e -h --id AntibodySoftware.WizTree
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


# ---------------------------------------------- #
# Windows Terminal ----------------------------- #
# ---------------------------------------------- #
# Windows Terminal (stable + preview) install with Cascadia Code PL font
winget install -e -h --id Microsoft.WindowsTerminal -s msstore
# winget install -e -h --id Microsoft.WindowsTerminalPreview -s msstore

# Windows terminal configuration
#Remove-Item -Path "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Force
#New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Target "$env:USERPROFILE\wsb\config\windowsTerminal\settings.json"
#cp "$env:USERPROFILE\wsb\config\windowsTerminal\icons\*" "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState\"
# Windows terminal preview configuration
#Remove-Item -Path "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json" -Force
#New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json" -Target "$env:USERPROFILE\wsb\config\windowsTerminal\settings.json"
#cp "$env:USERPROFILE\wsb\config\windowsTerminal\icons\*" "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\RoamingState\"


# ---------------------------------------------- #
# PowerShell  ---------------------------------- #
# ---------------------------------------------- #
winget install -e -h --id Microsoft.PowerShell
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#Remove-Item -Path "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force
#New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Target "$env:USERPROFILE\wsb\config\powerShell\Microsoft.PowerShell_profile.ps1"

# Chocolatey version is more up-o-date than winget version
#choco install -y vscode
winget install -e --id Microsoft.VisualStudioCode

# Adding here - this might be installed via PowerShell Profile Repo
# Add to optional programs
# choco install -y cascadia-code-nerd-font



# ---------------------------------------------- #
# Dev tools  ----------------------------------- #
# ---------------------------------------------- #
#winget install -e -h --id AndreasWascher.RepoZ
#winget install -e -h --id CoreyButler.NVMforWindows
#iwr https://get.pnpm.io/install.ps1 -useb | iex
# iwr -useb get.scoop.sh | iex
#winget install -e -h --id GitHub.cli
winget install -e --id GitHub.GitHubDesktop

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


