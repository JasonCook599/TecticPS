<#PSScriptInfo

.VERSION 1.0.6

.GUID 870d014f-f16e-4f30-9166-7885e5aa8106

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
Get all DHCP reservations in Netbox.

.PARAMETER baseUrl
The base URL for the netbox API

.PARAMETER token
The API token used for authentication.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  $baseUrl,
  $token
)

Write-Verbose "Getting prefixes configured for DHCP."
$DhcpPrefixes = Get-NetboxResult -baseUrl $baseUrl -token $Token -Endpoint "ipam/prefixes" -Body @{
  cf_dhcpserver__empty = $false
  fields               = "id,prefix,vlan,custom_fields"
} | Select-Object id, prefix, @{Name = "vid"; Expression = { $_.vlan.vid } }, @{Name = "dhcpserver"; Expression = { $_.custom_fields.dhcpserver.name } }
 
Write-Verbose "Getting addresses configured for DHCP."
$DhcpAddresses = Get-NetboxResult -baseUrl $baseUrl -token $Token -Endpoint "ipam/ip-addresses" -Body @{
  status = "dhcp"
  fields = "address,assigned_object,dns_name,assigned_object"
} | Select-Object address, dns_name, @{Name = "interfaceId"; Expression = { $_.assigned_object.id } }, @{Name = "ip"; Expression = { [ipaddress]($_.address -split "/")[0] } }, @{Name = "assigned_object_url"; Expression = { $_.assigned_object.url } }

Write-Verbose "Get device interfaces."
$DhcpMacAddressesDevices = Get-NetboxResult -baseUrl $baseUrl -token $Token -Endpoint "dcim/interfaces" -Body @{
  mac_address__n = ""
  fields         = "id,url,mac_address,url"
} | Where-Object mac_address -ne $null

Write-Verbose "Get VM interfaces."
$DhcpMacAddressesVMs = Get-NetboxResult -baseUrl $baseUrl -token $Token -Endpoint "virtualization/interfaces" -Body @{
  mac_address__n = ""
  fields         = "id,url,mac_address,url"
} | Where-Object mac_address -ne $null

$DhcpMacAddresses = $DhcpMacAddressesDevices + $DhcpMacAddressesVMs



$Results = @()
foreach ($Prefix in $DhcpPrefixes ) {
  Write-Verbose "[$($Prefix.prefix)] Getting addresses configured for DHCP."
  $PrefixDhcpAddresses = $DhcpAddresses | Where-Object { Test-IpAddressInSubnet -IpAddresses $_.ip -Subnets $Prefix.prefix }

  foreach ($Address in $PrefixDhcpAddresses) {
    Write-Verbose "[$($Address.ip)] Checking for assigned interface."
    if ($null -eq $Address.interfaceId) {
      Write-Warning "[$($Address.ip)] No interface assigned."
      continue
    }
    else {
      Write-Verbose "[$($Address.ip)] Getting assigned MAC address."
      $Mac = ($DhcpMacAddresses | Where-Object url -eq $Address.assigned_object_url).mac_address
      try { if ($Mac -notmatch '^([0-9A-Fa-f]{2}[:-]?){5}([0-9A-Fa-f]{2})$') { $Mac = $null ; throw "Invalid MAC Address" } }
      catch { Write-Warning "[$($Address.ip)] Failed to get MAC address." ; continue }
      
    
      Write-Verbose "[$($Address.ip)] Returning reservation object."
      $Results += [PSCustomObject]@{
        name        = $Prefix.dhcpserver
        vlan        = $Prefix.vid
        ip          = $Address.ip
        ipBytes     = $Address.ip.GetAddressBytes()
        mac         = $Mac
        macBytes    = [byte[]] -split ($Mac -replace ':', '' -replace '..', '0x$& ')
        description = $Address.dns_name
      }
    }
  }
}
return $Results
