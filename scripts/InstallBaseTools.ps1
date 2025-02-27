# These are the base applications I like to install regardless of the machine I'm working on.
# Other optional applications are installed based on the machine's purpose.
# Menu's to the optional programs will be added in the future. Check InstallOptionalTools.ps1 for more information.

# ---------------------------------------------- #
# Browsers  ------------------------------------ #
# ---------------------------------------------- #
# choco install -y googlechrome
winget install -e --accept-source-agreements --accept-package-agreements --id Google.Chrome 

# choco install -y firefox
winget install -e --accept-source-agreements --accept-package-agreements --id Mozilla.Firefox


# ---------------------------------------------- #
# Common tools  --------------------------------- #
# ---------------------------------------------- #

# choco install -y 7zip
winget install -e --accept-source-agreements --accept-package-agreements --id 7zip.7zip 

# choco install -y ShareX
winget install -e --accept-source-agreements --accept-package-agreements --id ShareX.ShareX 
 
winget install -e --accept-source-agreements --accept-package-agreements --id WinMerge.WinMerge
winget install -e --accept-source-agreements --accept-package-agreements --id dotPDN.PaintDotNet
winget install -e --accept-source-agreements --accept-package-agreements --id Notepad++.Notepad++
winget install -e --accept-source-agreements --accept-package-agreements -h --id JackieLiu.NotepadsApp
winget install -e --accept-source-agreements --accept-package-agreements -h --id AntibodySoftware.WizTree
winget install -e --accept-source-agreements --accept-package-agreements -h --id WinSCP.WinSCP

# Install FileZilla using Chocolatey because it's not available via winget
choco install -y filezilla

#Install ChatCPT using winget
winget install -e --accept-source-agreements --accept-package-agreements --accept-package-agreements --id 9nt1r1c2hh7j

# ---------------------------------------------- #
# Windows Terminal ----------------------------- #
# ---------------------------------------------- #
# Windows Terminal (stable + preview) install with Cascadia Code PL font
winget install -e --accept-source-agreements --accept-package-agreements -h --id Microsoft.WindowsTerminal -s msstore
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
winget install -e --accept-source-agreements --accept-package-agreements -h --id Microsoft.PowerShell
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#Remove-Item -Path "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Force
#New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Target "$env:USERPROFILE\wsb\config\powerShell\Microsoft.PowerShell_profile.ps1"


# ---------------------------------------------- #
# Dev tools  ----------------------------------- #
# ---------------------------------------------- #
# https://scoop.sh/
# iwr -useb get.scoop.sh | iex

#winget install -e -h --id GitHub.cli
winget install -e --accept-source-agreements --accept-package-agreements --id GitHub.GitHubDesktop

# Chocolatey version is more up-to-date than winget version
#choco install -y vscode
winget install -e --accept-source-agreements --accept-package-agreements --id Microsoft.VisualStudioCode


