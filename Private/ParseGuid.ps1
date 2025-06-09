<#PSScriptInfo

.VERSION 1.0.4

.GUID 93f9436d-928a-4cf8-a5a0-e3f3f6bdcf14

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
.DESCRIPTION
Parse a GUID
#>
param(
  [string]$String,
  [ValidateSet("N", "D", "B", "P")][string]$Format = "B"
)
$Guid = [System.Guid]::empty
If ([System.Guid]::TryParse($String, [System.Management.Automation.PSReference]$Guid)) {
  $Guid = [System.Guid]::Parse($String)
}
Else {
  $Guid = $null
}
return $Guid.ToString($Format)
