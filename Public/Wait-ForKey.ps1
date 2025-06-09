<#PSScriptInfo

.VERSION 1.0.5

.GUID 3642a129-3370-44a1-94ad-85fb88de7a6b

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
This will continue if the specified key it press. Otherwise, it will break.

.PARAMETER Key
The key that this will listen for.

.EXAMPLE
Wait-ForKey -Key c
Press c to continue, any other key to abort.: c
#>
param(
  [string]$Key = "y",
  [string]$Message = "Press $Key to continue, any other key to abort."
)

$Response = Read-Host $Message
# this is a comment
#this is also a comment
If ($Response -ne $Key) { Break }
