<#PSScriptInfo

.VERSION 1.0.1

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
param (
  [string][Parameter(Position = 0, Mandatory = $true)]$ComputerName,
  [string]$ManagedByService,
  [string]$AssignmentType = "Reserved",
  [ValidateSet("IPv4", "IPv6")][string]$AddressFamily = "IPv4"
)

$Addresses = Get-IpamAddress -CimSession (CimSession $ComputerName) -AddressFamily $AddressFamily | Where-Object AssignmentType -like Reserved
$Ranges = Get-IpamRange -Session (CimSession $ComputerName) -AddressFamily $AddressFamily | Where-Object ManagedByService -eq $ManagedByService
$Subnets = Get-IpamSubnet -Session (CimSession $ComputerName) -AddressFamily $AddressFamily
$Return = @()
Foreach ($Address in $Addresses) {
  $IPRange = $Address.IPRange -Split "-"
  $Range = ($Ranges | Where-Object StartIPAddress -eq $IPRange[0] | Where-Object EndIPAddress -eq $IPRange[1])[0]
  $Subnet = ($Subnets | Where-Object NetworkID -eq $Range.NetworkID)[0]
  $Return += [pscustomobject]@{
    name        = $Range.ServiceInstance
    vlan        = ($Subnet.VlanID)[0]
    ip          = $Address.IPAddress.IPAddressToString
    mac         = $Address.MacAddress -replace "-", ":"
    description = $Address.DeviceName
  }
}
return $Return
