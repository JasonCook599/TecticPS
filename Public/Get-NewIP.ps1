<#PSScriptInfo

.VERSION 1.1.4

.GUID 9eea8e22-18f9-4cf7-b019-602c7d71dcf8

.AUTHOR Jason Cook Aman Dhally - amandhally@gmail.com

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
.SYNOPSIS
This powershell script will renew DHCP leaces on all network interfaces with DHCP enabled.

.DESCRIPTION
This powershell script will renew DHCP leaces on all network interfaces with DHCP enabled. Based off of a script by Aman Dhally located here https://newdelhipowershellusergroup.blogspot.ca/2012/04/ip-address-release-renew-using.html

.LINK
https://newdelhipowershellusergroup.blogspot.ca/2012/04/ip-address-release-renew-using.html

.EXAMPLE
.\Get-NewIP.ps1
Get-NewIP: Flushing IP addresses for Intel(R) Dual Band Wireless-AC 8260
Get-NewIP: Renewing IP Addresses
Get-NewIP: Lease on 192.168.2.18 fe80::24b7:e4ab:2901:6688 expires in 21 hours 2935 minutes on May 2, 2017 9:44:03 AM

.LINK
http://www.amandhally.net/blog

.LINK
https://newdelhipowershellusergroup.blogspot.com/2012/04/ip-address-release-renew-using.html
#>

$Ethernet = Get-CimInstance -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IpEnabled -eq $true -and $_.DhcpEnabled -eq $true }
foreach ($lan in $ethernet) {
  $lanDescription = $lan.Description
  Write-Output "Flushing IP addresses for $lanDescription"
  Start-Sleep 2
  $lan | Invoke-CimMethod -MethodName ReleaseDHCPLease | Out-Null
  Write-Output "Renewing IP Addresses"
  $lan | Invoke-CimMethod -MethodName RenewDHCPLease | Out-Null
  #$lan | select Description, ServiceName, IPAddress,  IPSubnet, DefaultIPGateway, DNSServerSearchOrder, DNSDomain, DHCPLeaseExpires, DHCPServer, MACAddress

  #$expireTime = [datetime]::ParseExact($lan.DHCPLeaseExpires,'yyyyMMddHHmmss.000000-300',$null)
  $expireTime = $lan.DHCPLeaseExpires
  $expireTimeFormated = Get-Date -Date $expireTime -Format F
  $expireTimeUntil = New-TimeSpan -Start (Get-Date) -End $expireTime
  $days = [Math]::Floor($expireTimeUntil.TotalDays)
  $hours = [Math]::Floor($expireTimeUntil.TotalHours) - $days * 24
  $minutes = [Math]::Floor($expireTimeUntil.TotalMinutes) - $hours * 60
  $expireTimeUntilFormated = $null
  If ( $days -gt 1 ) { $expireTimeUntilFormated = $days + ' days ' } ElseIf ( $days -gt 0 ) { $expireTimeUntilFormated = $days + ' day ' }
  If ( $hours -gt 1 ) { $expireTimeUntilFormated = -join ($expireTimeUntilFormated, $hours) + ' hours ' } ElseIf ( $hours -gt 0 ) { $expireTimeUntilFormated = -join ($expireTimeUntilFormated, $hours) + ' hour ' }
  If ( $minutes -gt 1 ) { $expireTimeUntilFormated = -join ($expireTimeUntilFormated, $minutes) + ' minutes' } ElseIf ( $minutes -gt 0 ) { $expireTimeUntilFormated = -join ($expireTimeUntilFormated, $minutes) + ' minute' }
  $Ip = $lan.IPAddress
  Write-Output "Lease on $Ip expires in $expireTimeUntilFormated on $expireTimeFormated"
}
