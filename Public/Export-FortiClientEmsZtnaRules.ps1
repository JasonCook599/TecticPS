<#PSScriptInfo

.VERSION 1.0.1

.GUID b0940c36-a968-4b62-bd39-be7e24d30c3c

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
This will generate a CSV for ZTNA rules.

.PARAMETER Path
CSV file containing the rule templates.

.PARAMETER ImportRules
A PS object containing the rules. By default, this will use the file specified by -Path.

.PARAMETER Encryption
If set, encryption with be enabled when not specified in the import.

.PARAMETER Services
A hastable of services and corrosponding ports.
#>
param(
  $SourcePath,
  $ImportRules = (Import-Csv -Path $SourcePath),
  $Encryption = "false",
  $Services = @{
    SMB        = @(139, 445)
    HTTP       = 80
    HTTPS      = 443

    AD         = @(9389, 3269, 3268, 389, 636, 500, 4500, 135, 445)
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#active-directory-local-security-authority

    CA         = @(135, 445, 139)
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#certificate-services

    DFSN       = @(138, 139, 389, 445, 135)
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#distributed-file-system-namespaces

    DNS        = 53
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#dns-server

    GP         = @(389, 445, 135)
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#group-policy

    KDC        = @(88, 464, 389 )
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#kerberos-key-distribution-center

    NetLogon   = @(138, 137, 139, 445, 389, 135)
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#net-logon

    Print      = @(135, 138, 137, 139, 445)
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#print-spooler

    RPC        = @(135, 593, 138, 137, 139, 445)
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#remote-procedure-call-rpc

    RPCL       = @(138, 137, 139, 445)
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#remote-procedure-call-rpc-locator

    TCPIPPrint = 515
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#tcpip-print-server

    RDS        = 3389
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#remote-desktop-services-rds

    RDSL       = @(135, 138, 137, 139, 445)
    # https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/service-overview-and-network-port-requirements#rds-licensing-rdsl

  }
)

foreach ($Hostname in $ImportRules) {
  Write-Verbose "Enable rules, unless disabled set."
  if (($false -ne $Hostname.enabled) -or ("FALSE" -ne $Hostname.enabled)) { $Hostname.enabled = "true" }

  Write-Verbose "Setting encryption to default value, if unset."
  if ("FALSE" -eq $Hostname.encryption) { $Hostname.encryption = "false" }
  elseif ("TRUE" -eq $Hostname.encryption) { $Hostname.encryption = "true" }
  elseif (($null -eq $Hostname.encryption) -or "" -eq $Hostname.encryption) { $Hostname.encryption = $Encryption }

  Write-Verbose "Splitting import at seperators."
  $Hostname.Services = $Hostname.Services.Split(",")
  $Hostname.Ports = $Hostname.Ports.Split(";")

  Write-Verbose "Collect all ports."
  $Ports = @()
  Write-Debug "Collecting explcit ports"
  if ($Hostname.Ports) { $Ports += $Hostname.Ports }

  Write-Debug "Collecting ports by service."
  if ($Hostname.Services -ne "") {
    $Hostname.Services | ForEach-Object {
      $Ports += $Services["$_"]
    }
  }

  Write-Verbose "Return object for each port"
  $Ports | ForEach-Object { ([int]::parse($_)) } | Sort-Object | Select-Object -Unique | ForEach-Object {
    return [PSCustomObject]@{
      "name"        = $Hostname.name + ":$_"
      "encryption"  = $Hostname.encryption
      "destination" = $Hostname.destination + ":$_"
      "enabled"     = $Hostname.enabled
    }
  }
}
