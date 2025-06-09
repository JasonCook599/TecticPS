<#PSScriptInfo

.VERSION 1.0.5

.GUID 9b9dfb07-a7ea-4afd-94ab-74a5bf2ee340

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
.SYNOPSIS
This will break if the specified key it press. Otherwise, it will continue.

.DESCRIPTION
This script will run the PaperCut client. It will first check the network location and fall back to the local cache is that fails.

.PARAMETER Key
The key that this will listen for.

.EXAMPLE
Stop-ForKey -Key q
Press q to abort, any other key to continue.: q
#>
param(
  $Key
)
$Response = Read-Host "Press $Key to abort, any other key to continue."
If ($Response -eq $Key) { Break }
