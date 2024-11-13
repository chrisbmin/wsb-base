## Test if winget command can run from CMD/PS, if it can't, install prerequisites (if needed) and update to latest version
try {
	winget --version
	Write-host "Winget command present"
	Stop-Transcript
	Exit 0
} catch {
	Write-Host "Checking prerequisites and installing/updating winget..."
	
## Test if Microsoft.UI.Xaml.2.7 is present, if not then install
try {
	$package = Get-AppxPackage -Name "Microsoft.UI.Xaml.2.7"
	if ($package) {
		Write-Host "Microsoft.UI.Xaml.2.7 is installed."
	} else {
		Write-Host "Installing Microsoft.UI.Xaml.2.7..."
		Invoke-WebRequest `
			-URI https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.3 `
			-OutFile xaml.zip -UseBasicParsing
		New-Item -ItemType Directory -Path xaml
		Expand-Archive -Path xaml.zip -DestinationPath xaml
		Add-AppxPackage -Path "xaml\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx"
		Remove-Item xaml.zip
		Remove-Item xaml -Recurse
	}
} catch {
	Write-Host "An error occurred: $($_.Exception.Message)"
}

## Update Microsoft.VCLibs.140.00.UWPDesktop
		Write-Host "Updating Microsoft.VCLibs.140.00.UWPDesktop..."
		Invoke-WebRequest `
			-URI https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx `
			-OutFile UWPDesktop.appx -UseBasicParsing
		Add-AppxPackage UWPDesktop.appx
		Remove-Item UWPDesktop.appx

## Install latest version of Winget
$API_URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$DOWNLOAD_URL = $(Invoke-RestMethod $API_URL).assets.browser_download_url |
	Where-Object {$_.EndsWith(".msixbundle")}
	Invoke-WebRequest -URI $DOWNLOAD_URL -OutFile winget.msixbundle -UseBasicParsing
	Add-AppxPackage winget.msixbundle
	Remove-Item winget.msixbundle
}



#$progressPreference = 'silentlyContinue'
#$latestWingetMsixBundleUri = $(Invoke-RestMethod https://api.github.com/repos/microsoft/winget-cli/releases/latest).assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
#$latestWingetMsixBundle = $latestWingetMsixBundleUri.Split("/")[-1]
#Write-Information "Downloading winget to artifacts directory..."
#Invoke-WebRequest -Uri $latestWingetMsixBundleUri -OutFile "./$latestWingetMsixBundle"
#Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
#Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
#Add-AppxPackage $latestWingetMsixBundle