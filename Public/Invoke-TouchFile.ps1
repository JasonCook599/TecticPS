<#PSScriptInfo

.VERSION 1.0.1

.GUID edfc8010-fc8d-4eba-8934-4c3a75725d33

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
This will update the LastWriteTime of the specifeid file to the current time.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$Path
)

if (Test-Path $Path) { (Get-ChildItem $Path).LastWriteTime = Get-Date }
else { Write-Output $null > $file }
