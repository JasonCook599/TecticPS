<#PSScriptInfo

.VERSION 1.0.5

.GUID 94788e2a-23d9-4aaf-89e0-668c62bc27e6

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
Build a DHCP reservation script for the given service. Currently, only FortiGate is supported.

.PARAMETER ComputerName
The computer hosting the IPAM service.

.PARAMETER ManagedByService
The service to choose.
#>
param(
  [string][Parameter(Position = 0, Mandatory = $true)]$ComputerName,
  $ServiceInstance,
  [ValidateSet("MAC", "IP", "MAC+IP", IgnoreCase = $true)][string]$Hash = "MAC",
  [ValidateSet("FortiGate", IgnoreCase = $true)]$ManagedByService = "FortiGate"
)

$ConfigScript = ""
$Reservations = Get-IpamReservations -ManagedByService $ManagedByService -ComputerName $ComputerName -ServiceInstance $ServiceInstance
foreach ($Firewall in $Reservations.name | Sort-Object | Get-Unique ) {
  $FirewallIps = $Reservations | Where-Object name -eq $Firewall
  $ConfigScript += "
{% if DVMDB.name == '$Firewall' %}
config system dhcp server"
  foreach ($Vlan in $FirewallIps.vlan | Sort-Object | Get-Unique) {
    $ConfigScript += "
  edit $VLAN
    config reserved-address
      purge
    end
    config reserved-address"
    foreach ($Ip in $FirewallIps | Where-Object Vlan -eq $Vlan) {
      $MD5 = [System.Security.Cryptography.MD5]::Create()
      $MD5 = switch ($Hash) {
        "MAC" { $MD5.ComputeHash($Ip.macBytes) }
        "IP" { $MD5.ComputeHash($Ip.ipBytes) }
        "MAC+IP" { $MD5.ComputeHash($Ip.macBytes + $Ip.ipBytes) }
        Default { 0 }
      }
      $ID = [System.BitConverter]::ToUInt32($MD5[12..15], 0)
      $ConfigScript += "
      edit $ID
        set ip $($Ip.ip)
        set mac $($Ip.mac)
        set description '$($Ip.description)'
      next"
    }
    $ConfigScript += "
    end
  next"
  }
  $ConfigScript += "
end
{% endif %}"
}
return $ConfigScript
