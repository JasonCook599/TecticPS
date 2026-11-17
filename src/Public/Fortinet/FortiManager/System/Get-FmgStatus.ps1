<#PSScriptInfo

.VERSION 1.0.2

.GUID 7dc57e02-b6f1-4127-95f5-029d2bc137e2

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2026

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
Get FortiManager current status.

.PARAMETER PSCustomObject
Don't check that you are connected for FortiManager before sending the request.

#>
[CmdletBinding()]
param (
  [switch]$SkipConnectionCheck
)

Write-Verbose "Getting FortiManager System Status"
return Invoke-FmgJsonApi -url "/sys/status" -SkipConnectionCheck:$SkipConnectionCheck
