<#PSScriptInfo

.VERSION 1.0.4

.GUID 214ed066-0271-4c0b-8210-8554f8de4f4a

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
.SYNOPSIS
Remove an email address to an existing Microsoft 365 group.

.DESCRIPTION
Remove an email address to an existing Microsoft 365 group. You can also use this to set the primary address for the group.

.PARAMETER Identity
The identity of the group you wish to change.

.PARAMETER EmailAddress
The email address you whish to Remove.

.PARAMETER SetPrimary
If set, this will set the email adress you specified as the primary address for the group.

.EXAMPLE
Remove-GroupEmail -Identity staff -EmailAddress staff@example.com
#>

param (
  [string]$GroupName,
  [string]$EmailAddress
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
Set-UnifiedGroup -Identity $GroupName -EmailAddresses: @{Remove = $EmailAddress }
