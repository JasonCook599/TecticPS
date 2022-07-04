<#PSScriptInfo

.VERSION 1.0.2

.GUID 0e4e3ea4-6fe3-4b89-98f0-a09f40baafed

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
Find the user matching the given SID.

.PARAMETER Sid
The SID to search for.
#>

param(
    [Parameter(Mandatory = $true)][string]$Sid
)

return [ADSI]"LDAP://<SID=$Sid>"
