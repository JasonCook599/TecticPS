<#PSScriptInfo

.VERSION 1.0.5

.GUID 0fef518a-4c3a-40e1-ad0c-95c442574793

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

function Test-IpAddressInSubnet {
  <#
.SYNOPSIS
    Determine if an IP address exists in the specified subnet.
.EXAMPLE
    PS C:\>Test-IpAddressInSubnet 192.168.1.10 -Subnet '192.168.1.1/32','192.168.1.0/24'
    Determine if the IP address exists in the specified subnet.
.INPUTS
    System.Net.IPAddress
.LINK
  https://www.powershellgallery.com/packages/Utility.PS/1.0.3/Content/Test-IpAddressInSubnet.ps1
#>
  [CmdletBinding()]
  [OutputType([bool], [string[]])]
  param (
    # IP Address to test against provided subnets.
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
    [ipaddress[]] $IpAddresses,
    # List of subnets.
    [Parameter(Mandatory = $true)]
    [string[]] $Subnets,
    # Return list of matching subnets rather than a boolean result.
    [Parameter(Mandatory = $false)]
    [switch] $ReturnMatchingSubnets
  )

  process {
    foreach ($IpAddress in $IpAddresses) {
      [System.Collections.Generic.List[string]] $listSubnets = New-Object System.Collections.Generic.List[string]
      [bool] $Result = $false
      foreach ($Subnet in $Subnets) {
        [string[]] $SubnetComponents = $Subnet.Split('/')

        [int] $bitIpAddress = [BitConverter]::ToInt32($IpAddress.GetAddressBytes(), 0)
        [int] $bitSubnetAddress = [BitConverter]::ToInt32(([ipaddress]$SubnetComponents[0]).GetAddressBytes(), 0)
        [int] $bitSubnetMaskHostOrder = 0
        if ($SubnetComponents[1] -gt 0) {
          $bitSubnetMaskHostOrder = -1 -shl (32 - [int]$SubnetComponents[1])
        }
        [int] $bitSubnetMask = [ipaddress]::HostToNetworkOrder($bitSubnetMaskHostOrder)

        if (($bitIpAddress -band $bitSubnetMask) -eq ($bitSubnetAddress -band $bitSubnetMask)) {
          if ($ReturnMatchingSubnets) {
            $listSubnets.Add($Subnet)
          }
          else {
            $Result = $true
            continue
          }
        }
      }

      ## Return list of matches or boolean result
      if ($ReturnMatchingSubnets) {
        if ($listSubnets.Count -gt 1) { Write-Output $listSubnets.ToArray() -NoEnumerate }
        elseif ($listSubnets.Count -eq 1) { Write-Output $listSubnets.ToArray() }
        else {
          $Exception = New-Object ArgumentException -ArgumentList ('The IP address {0} does not belong to any of the provided subnets.' -f $IpAddress)
          Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::ObjectNotFound) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'TestIpAddressInSubnetNoMatch' -TargetObject $IpAddress
        }
      }
      else {
        Write-Output $Result
      }
    }
  }
}

function Get-NetboxResult {
  param ( $Endpoint, 
    $Headers = @{
      "Accept"        = "application/json"
      "Authorization" = "Token $Token"
    },
    $Body,
    $Method = "Get",
    $Uri = "$baseUrl/api/$Endpoint/",
    [int]$limit = 1000
  )

  
  if ($null -eq $Body.limit) {
    if ($null -eq $Body) { 
      Write-Verbose "[$Endpoint] Empty body. Setting result limit."
      $Body = @{limit = $limit } 
    } 
    else { 
      Write-Verbose "[$Endpoint] Empty limit in body. Setting result limit."
      $Body.limit = $limit 
    }
  }
  
  Write-Verbose "[$Endpoint] Getting all results."
  do {
    $Response = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method $Method -Body $Body
    if ($Response.results) {
      $Results += $Response.results
    }
    $Uri = $Response.next
  } while ($null -ne $Uri)
  return $Results
}

Write-Verbose "Getting prefixes configured for DHCP."
$DhcpPrefixes = Get-NetboxResult -Endpoint "ipam/prefixes" -Body @{
  cf_dhcpserver__empty = $false
  fields               = "id,prefix,vlan,custom_fields"
} | Select-Object id, prefix, @{Name = "vid"; Expression = { $_.vlan.vid } }, @{Name = "dhcpserver"; Expression = { $_.custom_fields.dhcpserver.name } }
 
Write-Verbose "Getting addresses configured for DHCP."
$DhcpAddresses = Get-NetboxResult -Endpoint "ipam/ip-addresses" -Body @{
  status = "dhcp"
  fields = "address,assigned_object,dns_name,assigned_object"
} | Select-Object address, dns_name, @{Name = "interfaceId"; Expression = { $_.assigned_object.id } }, @{Name = "ip"; Expression = { [ipaddress]($_.address -split "/")[0] } }, @{Name = "assigned_object_url"; Expression = { $_.assigned_object.url } }

Write-Verbose "Get device interfaces."
$DhcpMacAddressesDevices = Get-NetboxResult -Endpoint "dcim/interfaces" -Body @{
  mac_address__n = ""
  fields         = "id,url,mac_address,url"
} | Where-Object mac_address -ne $null

Write-Verbose "Get VM interfaces."
$DhcpMacAddressesVMs = Get-NetboxResult -Endpoint "virtualization/interfaces" -Body @{
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
