<#PSScriptInfo

.VERSION 1.0.5

.GUID 2a1c91e6-58fd-4f37-9daf-370b954c31e4

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2025

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#> 





<#
.SYNOPSIS
This script removes the caches wallpaper.

.DESCRIPTION
This script removes the caches wallpaper by deleting %appdata%\Microsoft\Windows\Themes\TranscodedWallpaper

.EXAMPLE
Remove-CachedWallpaper
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param()
Remove-Item "$Env:appdata\Microsoft\Windows\Themes\TranscodedWallpaper" -ErrorAction SilentlyContinue
Remove-Item "$Env:appdata\Microsoft\Windows\Themes\CachedFiles\*.*" -ErrorAction SilentlyContinue
