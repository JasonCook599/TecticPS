<#PSScriptInfo

.VERSION 1.0.3

.GUID a2d15653-e7ac-4246-b3a4-adf73af11a06

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2024

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
This is used to test which DMA devices are blocking automatic BitLocker encryption.

.PARAMETER File
The text file where the list of devices will be saved.

.PARAMETER LastDeviceFile
The text file where the last modified device will be saved.

.PARAMETER Action
An array of actions to run.
    RemoveFirst: Remove the first entry from the list of allowed buses.
    AddLast: Re-add the most recently removed device to the list of allowed buses.
    AddAll: Add all devices to the list of allowed buses.
    Export: Export the list of all device to $File
    Reset: Remove all devices from the list of allowed buses.

.PARAMETER Path
The registry path for allowed buses.

.PARAMETER Parent
The parent of $Path

.EXAMPLE
Test-DmaDevices -Action Export,AddAll

.EXAMPLE
Test-DmaDevices -Action RemoveFirst

.EXAMPLE
Test-DmaDevices -Action AddLast

.EXAMPLE
Test-DmaDevices -Action Reset
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  $File = "DmaDevices.txt",
  $LastDeviceFile = ("$([System.IO.Path]::GetFileNameWithoutExtension($File))-last.txt"),
  [ValidateSet("RemoveFirst", "AddLast", "AddAll", "Export", "Reset")][array]$Action,
  $Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DmaSecurity\AllowedBuses",
  $Parent = (Split-Path $Path -Parent)
)
If ($(Test-Path -Path $Parent) -eq $False) { New-Item $Parent }
If ($(Test-Path -Path $Path) -eq $False) { New-Item $Path }
function ParseInstanceId {
  param([Parameter(Mandatory = $true, ValueFromPipeline = $true)][string[]]$Id)
  return ($Id -replace '&SUBSYS.*', '' -replace '\s+PCI\\', '"="PCI\\')
}

if ($Action -contains "AddAll" -or $Action -contains "Export") {
  Get-PnpDevice -InstanceId PCI\* | ForEach-Object {
    $i++
    $Name = $_.FriendlyName + " " + $i
    if ($Action -contains "AddAll") { New-ItemProperty $Path -PropertyType "String" -Force -Name $Name -Value (ParseInstanceId $_.InstanceId) }
    if ($Action -contains "Export") { Add-Content -Path $File -Value $Name }
  }
}
if ($Action -contains "RemoveFirst") {
  $CurrentDevice = (Get-Content $File -First 1)
  Write-Host $CurrentDevice
  Write-Host $LastDeviceFile
  Remove-ItemProperty $Path -Name $CurrentDevice -Force
  Set-Content -Path $LastDeviceFile -Value $CurrentDevice
  Get-Content $File | Select-Object -Skip 1 | Set-Content $File

}
if ($Action -contains "AddLast") {
  Get-PnpDevice -FriendlyName $([regex]::Match((Get-Content $LastDeviceFile), "^(.*)( \d*)$").captures.groups[1].value) | ForEach-Object {
    $i++
    $Name = $_.FriendlyName + " " + $i
    New-ItemProperty $Path -PropertyType "String" -Force -Name $Name -Value (ParseInstanceId $_.InstanceId)
  }
}
if ($Action -contains "Reset") { Remove-ItemProperty $Path -Name "*" }
