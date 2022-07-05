<#PSScriptInfo

.VERSION 1.0.2

.GUID 3642a129-3370-44a1-94ad-85fb88de7a6b

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
This will continue if the spesified key it press. Otherwise, it will break.

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
