<#PSScriptInfo

.VERSION 1.0.1

.GUID af4b08fb-f7ab-4e9c-a200-efe99f2ac411

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
This runs a one-time import of into Windows IPAM. This script will only add new entries.

.PARAMETER ComputerName
The computer hosting the IPAM service.

.PARAMETER Path
The location the configuration will be imported from.

.PARAMETER Actions
The type of data to be imported, either Subnet, Range, Addresses. Subnet & Range can be specified in the same command using the same file.
#>
param (
  [string]$ComputerName,
  [string]$Path,
  [ValidateSet("Subnet", "Range", "Addresses", IgnoreCase = $true)][array][Parameter(Position = 0, Mandatory = $true)]$Actions
)

if ($Actions -contains "Subnet" -or $Actions -contains "Range") {
    (Import-Csv -Path $Path) | Foreach-object {

    if ($Actions -contains "Subnet") {
      Write-Output "$($_.Name): Creating Subnet"
      Add-IpamSubnet -CimSession (CimSession $ComputerName) -Name $_.Name -CustomConfiguration $_.CustomConfiguration -NetworkId $_.NetworkId -VlanId $_.VlanId
    }
    if ($Actions -contains "Range") {
      Write-Output "$($_.Name): Creating Range"
      Add-IpamRange -CimSession (CimSession $ComputerName) -AssignmentType $_.AssignmentType -AssociatedReverseLookupZone $_.AssociatedReverseLookupZone -ConnectionSpecificDnsSuffix $_.ConnectionSpecificDnsSuffix -CustomConfiguration $_.CustomConfiguration -Description $_.Name -DnsServer ($_.DnsServer -split ",") -DnsSuffix ($_.DnsSuffix -split ",") -Gateway "$($_.Gateway)/Automatic"  -NetworkId $_.NetworkId -ManagedByService $_.ManagedByService -ServiceInstance $_.ServiceInstance
    }

  }
}

if ($Actions -contains "Addresses") {
    (Import-Csv $Path) | ForEach-Object {
    Write-Output "$($_.IpAddress): Adding IP $($_.DeviceName)"
    Add-IpamAddress  -CimSession (CimSession $ComputerName) -IpAddress $_.IpAddress -MacAddress $_.MacAddress -DeviceType $_.DeviceType -IpAddressState $_.AddressState -AssignmentType $_.AssignmentType -Description $_.Description -DeviceName $_.DeviceName -ForwardLookupZone $_.ForwardLookupZone -ForwardLookupPrimaryServer $_.ForwardLookupPrimaryServer -ReverseLookupZone $_.ReverseLookupZone -ReverseLookupPrimaryServer $_.ReverseLookupPrimaryServer -ManagedByService $_.ManagedByService -ServiceInstance $_.ServiceInstance -CustomConfiguration $_.CustomConfiguration
  }
}
