# These are the base applications I like to install regardless of the machine I'm working on.
# Other optional applications can be installed based on the machine's purpose.
# Menu's to the optional programs will be added in the future via optional tools scripts. Check InstallOptionalTools.ps1 for more information.

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
winget install -e --accept-source-agreements --accept-package-agreements --id VideoLAN.VLC 
winget install -e --accept-source-agreements --accept-package-agreements --id WinMerge.WinMerge
winget install -e --accept-source-agreements --accept-package-agreements --id dotPDN.PaintDotNet
winget install -e --accept-source-agreements --accept-package-agreements --id Notepad++.Notepad++
winget install -e --accept-source-agreements --accept-package-agreements -h --name "Notepads App"
winget install -e --accept-source-agreements --accept-package-agreements -h --id AntibodySoftware.WizTree
winget install -e --accept-source-agreements --accept-package-agreements -h --id WinSCP.WinSCP

# Install FileZilla using Chocolatey because it's not available via winget
choco install -y filezilla

# Install ChatCPT using winget
winget install -e --accept-source-agreements --accept-package-agreements --accept-package-agreements --id 9nt1r1c2hh7j

# ---------------------------------------------- #
# Windows Terminal ----------------------------- #
# ---------------------------------------------- #
# Windows Terminal (stable)
winget install -e --accept-source-agreements --accept-package-agreements -h --id Microsoft.WindowsTerminal -s msstore

# ---------------------------------------------- #
# PowerShell  ---------------------------------- #
# ---------------------------------------------- #
winget install -e --accept-source-agreements --accept-package-agreements -h --id Microsoft.PowerShell


# ---------------------------------------------- #
# Dev tools  ----------------------------------- #
# ---------------------------------------------- #

#winget install -e -h --id GitHub.cli
winget install -e --accept-source-agreements --accept-package-agreements --id GitHub.GitHubDesktop

# Chocolatey version is more up-to-date than winget version
#choco install -y vscode
winget install -e --accept-source-agreements --accept-package-agreements --id Microsoft.VisualStudioCode