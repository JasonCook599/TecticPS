<#PSScriptInfo

.VERSION 1.0.5

.GUID cb98c8e9-cb35-4db2-9fe8-33afb9eb2272

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
This script will trim the specified folder to the number of items specified.

.DESCRIPTION
This script will trim the specified folder to the number of items specified.

.PARAMETER Path
This can be used to select a folder in which to run these commands on. If unspecified, it will run in the current folder.

.PARAMETER Keep
This is the number of files to keep in the folder. If unspecified, it will keep 10 copies.

.EXAMPLE
Remove-OldFolders -Folder C:\Backups\ -Keep 10
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript( { Test-Path $_ })][string]$Path = (Get-Location),
  [ValidateRange(1, [int]::MaxValue)][int]$Keep = 10
)

Get-ChildItem $Path -Directory | Sort-Object CreationTime -Descending | Select-Object -Skip $Keep | ForEach-Object {
  If ($PSCmdlet.ShouldProcess("$_", "Trim-Folder -Keep $Keep")) {
    Remove-Item -Path $_ -Recurse -Force
  }
}
