<#PSScriptInfo

.VERSION 1.0.3

.GUID eb35ecd5-48d9-4b6d-97d9-ad4b5893fb6a

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) TectTectic

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
Returns true if a reboot is pending.

.LINK
https://stackoverflow.com/questions/47867949/how-can-i-check-for-a-pending-reboot/68627581#68627581

.LINK
https://gist.github.com/altrive/5329377

.LINK
http://gallery.technet.microsoft.com/scriptcenter/Get-PendingReboot-Query-bdb79542

#>

if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return "Component Based Servicing\RebootPending" }
if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return "WindowsUpdate\Auto Update\RebootRequired" }
if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return "PendingFileRenameOperations" }
try {
  $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
  $status = $util.DetermineIfRebootPending()
  if (($null -ne $status) -and $status.RebootPending) {
    return "CCM_ClientUtilities"
  }
}
catch { }

return $false
