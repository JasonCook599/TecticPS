<#PSScriptInfo

.VERSION 1.0.3

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
      $ConfigScript += "
      edit 0
        set ip $($Ip.Ip)
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
