<#PSScriptInfo

.VERSION 1.0.2

.GUID 5367e6e7-1177-4f3f-a345-1633446ad628

.AUTHOR Jason Cook

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) ***REMOVED*** 2022

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#> 





<#
.DESCRIPTION
Change the default Windows wallpaper for new users and copies wallpapers to system folder.

.PARAMETER SourcePath
The lcoation to search for images in.

.PARAMETER Images
An array of images to use. By default, this will select all *.jpg files in $SourcePath

.PARAMETER Name
The name of the folder to copy the images to. If not specified, this script will use "Defaults" and copy to $env:windir\Web\Wallpaper\$Name

.LINK
https://ccmexec.com/2015/08/replacing-default-wallpaper-in-windows-10-using-scriptmdtsccm/
#><#

.DESCRIPTION
Applies a specified wallpaper to the current user's desktop.

.PARAMETER Image
Provide the exact path to the image. If unspecified, it will use the default system wallpaper from $env:windir\Web\Wallpaper\Windows

.PARAMETER Style
Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span). Default is Fit.

.EXAMPLE
Set-WallPaper -Image "C:\Wallpaper\Default.jpg"
Set-WallPaper -Image "C:\Wallpaper\Background.jpg" -Style Fit

.LINK
https://www.joseespitia.com/2017/09/15/set-wallpaper-powershell-function/

#>

param (
    [ValidateScript({ Test-Path $_ })][string]$Image = ((Get-ChildItem -Path (Join-Path -Path $env:windir -ChildPath "Web\Wallpaper\Windows"))[0].FullName),
    [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')][string]$Style = "Fit"
)

$WallpaperStyle = Switch ($Style) {
    "Fill" { "10" }
    "Fit" { "6" }
    "Stretch" { "2" }
    "Tile" { "0" }
    "Center" { "0" }
    "Span" { "22" }
}

New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
If ($Style -eq "Tile") { New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force }
Else { New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force }

Add-Type -TypeDefinition @" 
using System; 
using System.Runtime.InteropServices;

public class Params
{ 
[DllImport("User32.dll",CharSet=CharSet.Unicode)] 
public static extern int SystemParametersInfo (Int32 uAction, 
Int32 uParam, 
String lpvParam, 
Int32 fuWinIni);
}
"@ 

$SPI_SETDESKWALLPAPER = 0x0014
$UpdateIniFile = 0x01
$SendChangeEvent = 0x02

$fWinIni = $UpdateIniFile -bor $SendChangeEvent

exit [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni) 
