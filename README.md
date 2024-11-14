# My personal WorkStation Builder

Contains everything to setup my Windows Engineer desktop environment.

> Inpired by [Microsoft/windows-dev-box-setup-scripts](https://github.com/Microsoft/windows-dev-box-setup-scripts) and other repositories to setup their developer machine.

## ⚡ One Line Install (Elevated PowerShell Recommended)

Execute the following command in an elevated PowerShell window to Download and Install everything needed:

```
irm "https://github.com/chrisrbmn/wsb-v2/raw/main/setup.ps1" | iex
```


## How does this work?

The setup is automated using [PowerShell](https://docs.microsoft.com/en-us/powershell/) scripts.

Software is installed using 2 different package managers for Windows: 
- [Chocolatey](https://chocolatey.org/)
- [Windows Package Manager](https://docs.microsoft.com/en-us/windows/package-manager/) aka winget

Both package managers are installed as part of the script.

I have chosen to mainly use 'winget' to install tools, except when packages were only available on Chocolatey or more up-to-date on Chocolatey.

One of the firsts steps of the setup.ps1 script is to create a build folder on the C:\ drive and download this repository to it. It then uses the downloaded scripts in the repository and retrieve and configure the system.


## Limitations

The script does check if the build folder exists, and just continue's if detected. Essentially the tools will be simply re-installed.
May explore deleting the folder if it already exists, and recreating it. Also may create a removal script to delete all the implemented changes.

## Using this repository 

This repository contains the tools I like to use, my config files, my preferences... so you should not use it as-is. You can use it as it, take inspiration from it, fork this repository, modify the scripts and settings files with your needs, and use it to set up your development machine.  Just be aware that if you use it as it, you get everything I want.

Click on the **Install** link below is needed to launch the installation. If you forked this, please make sure you have updated the link with the corresponding path to your forked version.

[Install](https://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/chrisrbmn/wsb-v2/refs/heads/main/boxstarter.ps1)

## Disclaimer

The code in this repository is provided as-is, without any warranties of any kind. Use it at your own risk.