<#PSScriptInfo

.VERSION 1.0.4

.GUID 421f45c1-3a42-4c17-83a8-bb109f412a19

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
.SYNOPSIS
This script with gather information about  Secure Boot from the specified marchines.

.DESCRIPTION
This script with gather information about TPM and Secure Boot from the spesified specified. It can request information from just the local computer or from a list of remote computers. It can also export the results as a CSV file.

.PARAMETER ComputerList
This can be used to select a text file with a list of computers to run this command against. Each device must appear on a new line. If unspesified, it will run againt the local machine.

.PARAMETER ReportFile
This can be used to export the results to a CSV file.

.EXAMPLE
Get-TPMInfo
System Information for: localhost
Secure Boot Status: TRUE
#>
param(
  [string]$ComputerList,
  [string]$ReportFile
)

Function Get-SystemInfo($ComputerSystem) {
  If (-NOT (Test-Connection -ComputerName $ComputerSystem -Count 1 -ErrorAction SilentlyContinue)) {
    Write-Warning "$ComputerSystem is not accessible."
    $script:Report += New-Object psobject -Property @{
      RunAgainst         = $ComputerSystem;
      Satus              = "Offline"
      ComputerSecureBoot = "Offline";
    }
    Return
		}
  $ComputerSecureBoot = Invoke-Command -ComputerName $ComputerSystem -ScriptBlock { Confirm-SecureBootUEFI }
  "System Information for: " + $ComputerSystem
  "Secure Boot Status: " + $ComputerSecureBoot
  ""
  ""
  $script:Report += New-Object psobject -Property @{
    RunAgainst         = $ComputerSystem;
    Satus              = "Online"
    ComputerSecureBoot = $ComputerSecureBoot;
  }
  If ($script:ReportFile) { $script:Report | Export-Csv $script:ReportFile }
}

$script:Report = @()
If ($ComputerList) { foreach ($ComputerSystem in Get-Content $ComputerList) { Get-SystemInfo -ComputerSystem $ComputerSystem } }
Else { Get-SystemInfo -ComputerSystem $env:COMPUTERNAME }
If ($ReportFile) { $Report | Export-Csv $ReportFile }
