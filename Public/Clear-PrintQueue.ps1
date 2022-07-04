<#PSScriptInfo

.VERSION 1.0.3

.GUID 4656316e-19c9-4d45-a8cb-6c26f6548e22

.AUTHOR Jason Cook

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) ***REMOVED*** 2022

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
This will clear all print jobs in the queue.

.DESCRIPTION
This will delete all *.shd and .spl file in %systemroot%\system32\spool\printers\ and restart the spooler service.

.PARAMETER ComputerName
This can be used to select a computer to clear the print jobs on. This option is required.

.EXAMPLE
Clear-PrintQueue -ComputerName PrintServer
#>
param(
  [string]$ComputerName
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
while (!$ComputerName) { $ComputerName = Read-Host -Prompt "Enter the Computer Name." }

Invoke-Command -ComputerName $ComputerName -ScriptBlock {
  Write-Verbose "Stopping spooler service."
  Stop-Service -Name spooler -Force
  Start-Sleep -Seconds 3
  Write-Verbose "Deleting *.shd"
  Get-ChildItem $env:SystemRoot\system32\spool\printers *.shd | ForEach-Object ($_) { Remove-Item $_.FullName }
  Write-Verbose "Deleting *.spl"
  Get-ChildItem $env:SystemRoot\system32\spool\printers *.spl | ForEach-Object ($_) { Remove-Item $_.FullName }
  Write-Verbose "Starting spooler service."
  Start-Service -Name spooler
  Write-Verbose "Finished."
}
