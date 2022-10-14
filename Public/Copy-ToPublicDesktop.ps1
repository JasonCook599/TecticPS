<#PSScriptInfo

.VERSION 1.0.1

.GUID f54d5874-3851-47a7-87f5-7841980e0c7a

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
This script will copy the specified file to the public desktop.

.PARAMETER Path
The path of the item to copy.
#>
param(
    $Path
)
$Path | ForEach-Object { Copy-Item -Path $_ -Destination "$env:PUBLIC\Desktop" }
