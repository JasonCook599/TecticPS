<#PSScriptInfo

.VERSION 1.0.8

.GUID 85c8702c-7117-4050-8629-51fc36de0cd8

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
Show BitLocker encryption status on a loop. Used to monitor encryption progress.

.PARAMETER Sleep
The length of time to sleep between checks.
#>
param(
  [ValidateRange(0, [Int32]::MaxValue)][Int32]$Sleep = 5
)

Test-Admin -Throw | Out-Null

Get-BitLockerVolume

while (Get-BitLockerVolume | Where-Object  EncryptionPercentage -ne 100) {
  $Result = Get-BitLockerVolume  | Where-Object { $_.VolumeStatus -ne "FullyEncrypted" -and $_.VolumeStatus -ne "FullyDecrypted" } | Format-Table
  Clear-Host
    (Get-Date).DateTime
  $Result
  Start-Sleep -Seconds $Sleep
}
