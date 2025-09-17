<#PSScriptInfo

.VERSION 1.0.8

.GUID e16d5930-dc98-4b09-9ef0-f94b8e117483

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
Get all reservations for a given managed service.

.PARAMETER ComputerName
The computer hosting the IPAM service.

.PARAMETER ManagedByService
The service to choose.
#>
param(
  [string][Parameter(Position = 0, Mandatory = $true)]$ComputerName,
  [string]$ManagedByService,
  [string]$AssignmentType = "Reserved",
  $ServiceInstance,
  [ValidateSet("IPv4", "IPv6")][string]$AddressFamily = "IPv4"
)

$Addresses = Get-IpamAddress -CimSession (CimSession $ComputerName) -AddressFamily $AddressFamily | Where-Object AssignmentType -like Reserved | Sort-Object @{e = { $_.IpAddress.Address } }
if ($ServiceInstance) { $Addresses = $Addresses | Where-Object ServiceInstance -in $ServiceInstance }

$Ranges = Get-IpamRange -Session (CimSession $ComputerName) -AddressFamily $AddressFamily | Where-Object ManagedByService -eq $ManagedByService
if ($ServiceInstance) { $Ranges = $Ranges | Where-Object ServiceInstance -in $ServiceInstance }

$Subnets = Get-IpamSubnet -Session (CimSession $ComputerName) -AddressFamily $AddressFamily
$Return = @()
Foreach ($Address in $Addresses) {
  if ($null -eq $Address.MacAddress) {
    Write-Warning "$($Address.IPAddress.IPAddressToString) does not have a MAC address set."
    continue
  }
  $IPRange = $Address.IPRange -Split "-"
  $Range = $null
  try { $Range = ($Ranges | Where-Object StartIPAddress -eq $IPRange[0] | Where-Object EndIPAddress -eq $IPRange[1])[0] }
  catch { Write-Warning "$($Address.IPAddress.IPAddressToString) does not belong to a range." }

  if ($Address.DeviceName -and $Address.Description ) { $Description = $Address.DeviceName + " " + $Address.Description }
  elseif ($Address.DeviceName) { $Description = $Address.DeviceName }
  elseif ($Address.Description ) { $Description = $Address.Description }
  else { $Description = $null }

  if ( $null -eq $Address.IpAddress.Address ) {
    $Bytes = ((Get-IpamAddress -CimSession (CimSession $ComputerName) -AddressFamily IPv6 | Sort-Object @{e = { $_.IpAddress.Address } })[0].IpAddress).GetAddressBytes()[12..15]
    if ([System.BitConverter]::IsLittleEndian) { [Array]::Reverse($Bytes) }
    $ipInt = [System.BitConverter]::ToUInt32($Bytes, 0)
  }
  else { $ipInt = $Address.IPAddress.Address }

  $Subnet = ($Subnets | Where-Object NetworkID -eq $Range.NetworkID)[0]
  $Return += [PSCustomObject]@{
    name        = $Range.ServiceInstance
    vlan        = [int]($Subnet.VlanID)[0]
    ip          = $Address.IPAddress.IPAddressToString
    ipInt       = $ipInt
    ipBytes     = $Address.IPAddress.GetAddressBytes()
    mac         = $Address.MacAddress -replace "-", ":"
    macInt      = [UInt32]("0x$(($Address.MacAddress -replace '-','').Substring(4,8))")
    macBytes    = [byte[]] -split ($Address.MacAddress -replace '-', '' -replace '..', '0x$& ')
    description = $Description
  }
}
return $Return
