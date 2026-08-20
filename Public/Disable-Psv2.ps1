<#PSScriptInfo

.VERSION 1.0.1

.GUID 97d3868c-8043-416b-9708-d6123da1fa21

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
This will disable PowerShell v2. It is available to be run on startup.

.PARAMETER Path
The path of the item to copy.

.LINK
https://github.com/robwillisinfo/Disable-PSv2/blob/master/Disable-PSv2.ps1
#>
param ([string]$LogPath)
if ($LogPath) { Start-Transcript -Path $LogPath }
#

Write-Host "Checking to see if PowerShell v2 is currently enabled..."
$PSv2PreCheck = dism.exe /Online /Get-Featureinfo /FeatureName:"MicrosoftWindowsPowerShellv2" | findstr "State"
If ( -not ($PSv2PreCheck -like "State : Disabled") ) {
  Write-Host "PowerShell v2 appears to be enabled, disabling via dism..."
  dism.exe /Online /Disable-Feature /FeatureName:"MicrosoftWindowsPowerShellv2" /NoRestart
  $PSv2PostCheck = dism.exe /Online /Get-Featureinfo /FeatureName:"MicrosoftWindowsPowerShellv2" | findstr "State"
  If ( $PSv2PostCheck -like "State : Enabled" ) {
    Write-Host "PowerShell v2 still seems to be enabled, check the log for errors: $DefaultLogLocation"
  }
  Else {
    Write-Host "PowerShell v2 disabled successfully."
  }
}
Else {
  Write-Host "PowerShell v2 is already disabled, no changes will be made."
}

if ($LogPath) { Stop-Transcript }
