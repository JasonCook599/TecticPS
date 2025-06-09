<#PSScriptInfo

.VERSION 1.1.7

.GUID 674855a4-1cd1-43b7-8e41-fea3bc501f61

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
This commands checks the Bitlocker status and returns it in a human readable format.

.DESCRIPTION
This commands checks the Bitlocker status and returns it in a human readable format.

.PARAMETER Drive
The drive to check for protection on. If unspecified, the System Drive will be used.
#>
param(
  [ValidateScript( { Test-Path $_ })][string]$Drive = $env:SystemDrive
)

If (!(Test-Path $Drive)) {
  Write-Error "$Drive is not valid. Please choose a valid path."
  Break
}

switch ((Get-WmiObject -Namespace ROOT\CIMV2\Security\Microsoftvolumeencryption -Class Win32_encryptablevolume -Filter "DriveLetter = `'$( Split-Path -Path $Drive -Qualifier)`'" -ErrorAction Stop).protectionStatus) {
  ("0") { $protectans = "Unprotected" }
  ("1") { $protectans = "Protected" }
  ("2") { $protectans = "Unknown" }
  default { $protectans = "NoReturn" }
}
$protectans
