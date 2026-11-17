<#PSScriptInfo

.VERSION 1.0.2

.GUID de712527-be2d-45f7-a246-992dfb622b32

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
Initialize the configuration variable

.PARAMETER Overwrite
Overwrite this existing variable if it exists.

#>

[CmdletBinding()]
param
(
  [switch]$Overwrite
)

if ((-not ($global:FmgConfig)) -or $Overwrite) {
  $global:FmgConfig = @{
    'Connected'     = $false
    'Hostname'      = $null
    'Token'         = $null
    'HostScheme'    = $null
    'HostPort'      = $null
    'Session'       = $null    
    'Version'       = $null
    'ParsedVersion' = $null
    'ADOM'          = $null
  }
}
else {
  Write-Verbose "FmgConfig hashtable already exists"
}
