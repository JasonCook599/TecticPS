<#PSScriptInfo

.VERSION 1.0.10

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

if ((-not ($global:YSApiConnection)) -or $Overwrite) {
  $global:YSApiConnection = @{
    Hostname                  = $null    
    HostScheme                = $null
    HostPort                  = $null

    Credential                = $null

    access_token              = $null
    refresh_token             = $null
    access_token_expire_time  = $null
    refresh_token_expire_time = $null

    Connected                 = $false
  }
}
else {
  Write-Verbose "YSApiConnection hashtable already exists"
}

