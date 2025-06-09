<#PSScriptInfo

.VERSION 1.1.5

.GUID 460f5844-8755-46df-8fb5-a12fa88bf413

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
This script will disable Netbios TCP/IP on all interfaces.

.DESCRIPTION
This script will disable Netbios TCP/IP on all interfaces.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param()

function ParseGuid {
  param(
    [string]$String,
    [ValidateSet("N", "D", "B", "P")][string]$Format = "B"
  )
  $Guid = [System.Guid]::empty
  If ([System.Guid]::TryParse($String, [System.Management.Automation.PSReference]$Guid)) {
    $Guid = [System.Guid]::Parse($String)
  }
  Else {
    $Guid = $null
  }
  return $Guid.ToString($Format)
}
If (!(Test-Admin -Warn)) { Break }
$Interfaces = Get-ChildItem "HKLM:SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces"
$Interfaces | ForEach-Object {
  $Path = $_.PSPath
  $Guid = ParseGuid $Path.Substring($Path.Length - 38)
  $count++ ; Progress -Index $count -Total $Interfaces.count -Activity "Disabling Netbios TCP/IP" -Name (Get-NetAdapter | Where-Object InterfaceGuid -eq ($Guid)).name
  Set-ItemProperty -Path $Path -Name NetbiosOptions -Value 2
}
