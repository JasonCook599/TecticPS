<#PSScriptInfo

.VERSION 1.0.2

.GUID 6caa3796-8c23-44fe-9441-cecfff79f023

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
Enable Hyper-V kerberos-based migration, and configure delegation as appropriate.

.PARAMETER HyperVHosts
A array of Hyper-V hosts that should have mutual delegation permissions.

.PARAMETER SkipCifsDelegation
Do not delegate "cifs" which is used for storage migration.

.PARAMETER SkipMigrationDelegation
Do not delegate "Microsoft Virtual System Migration Service" which is used for the actual VM migration.

.PARAMETER SkipHyperVConfig
Do not update the Hyper-V migration configuration.

.PARAMETER SkipKerberosPurge
Do not purge existing kerberos tickets.

.LINK
https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/deploy/set-up-hosts-for-live-migration-without-failover-clustering

.LINK
https://charbelnemnom.com/configuring-constrained-delegation-with-kerberos-in-windows-server-2016-hyper-v-with-powershell-hyperv-ws2016/
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [array]$HyperVHosts,
  [switch]$SkipCifsDelegation,
  [switch]$SkipMigrationDelegation,
  [switch]$SkipHyperVConfig,
  [switch]$SkipKerberosPurge
)

Import-Module ActiveDirectory

foreach ($SourceHost in $HyperVHosts) {
  if (-not $SkipHyperVConfig) {
    Write-Verbose "[$SourceHost] Enabling kerberos based live migration."
    Enable-VMMigration -ComputerName $SourceHost
    Set-VMHost -ComputerName $SourceHost -VirtualMachineMigrationAuthenticationType Kerberos
  }

  Write-Verbose "[$SourceHost] Building a list of SPNs for other hosts."
  $DelegationSPNs = @()
  foreach ($TargetHost in $HyperVHosts) {
    if ($SourceHost -ne $TargetHost) {
      $TargetFQDN = (Get-ADComputer -Identity $TargetHost).DNSHostName

      if (-not $SkipCifsDelegation) {
        $DelegationSPNs += "cifs/$TargetHost"
        $DelegationSPNs += "cifs/$TargetFQDN"
      }

      if (-not $SkipMigrationDelegation) {
        $DelegationSPNs += "Microsoft Virtual System Migration Service/$TargetHost"
        $DelegationSPNs += "Microsoft Virtual System Migration Service/$TargetFQDN"
      }
    }
  }

  Write-Verbose "[$SourceHost] $($DelegationSPNs -join ";")"

  Write-Verbose "[$SourceHost] Enabling delegation."
  $SourceAD = Get-ADComputer -Identity $SourceHost
  Set-ADAccountControl -Identity $SourceAD -TrustedToAuthForDelegation $true
  Set-ADComputer -Identity $SourceAD -Replace @{"msDS-AllowedToDelegateTo" = $DelegationSPNs }
}

If (-not $SkipKerberosPurge -and $PSCmdlet.ShouldProcess($HyperVHosts, "klist purge -LI 0x3e7")) {
  Write-Verbose "Purging existing kerberos tickets."
  Invoke-Command $HyperVHosts -ScriptBlock { klist purge -LI 0x3e7 }
}
