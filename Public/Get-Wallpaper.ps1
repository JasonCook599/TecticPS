<#PSScriptInfo

.VERSION 1.0.3

.GUID b30e98ad-cd0c-4f83-a10d-d5d976221b66

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
Download the latest wallpaper and add to the system wallpaper folder.

.PARAMETER Path
The location the file will be downloaded to.

.PARAMETER Uri
The location from from which to download the wallpaper.
#>
param(
    [string]$Path = "C:\Windows\Web\Wallpaper\Windows\CurrentBackground.jpg",
    [Parameter(Mandatory = $true)][uri]$Uri
)

Test-Admin -Warn -Message "You do not have Administrator rights to run this script! This may not work correctly." | Out-Null
Invoke-WebRequest -OutFile $Path -Uri $Uri -ErrorAction SilentlyContinue
