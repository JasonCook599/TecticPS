<#PSScriptInfo

.VERSION 1.0.12

.GUID 6e7a4d29-1b73-490f-91aa-fc074a886716

.AUTHOR Joseph Moody & Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) TectTectic

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
Network Policy Server Synchronization Script
This script copies the configuration from the NPS Master Server and imports it on this server.
The Account that this script runs under must have Local Administrator rights to the NPS Master.
This was designed to be run as a scheduled task on the NPS Secondary Servers on an hourly,daily, or as-needed basis.
Last Modified 01 Dec 2009 by JGrote <jgrote AT enpointe NOSPAM-DOTCOM>

.PARAMETER Source
Your Primary Network Policy Server you want to copy the config from.

.PARAMETER Path
A temporary location to store the XML config. Use a UNC path so that the primary can save the XML file across the network. Be sure to set secure permissions on this folder, as the configuration including pre-shared keys is temporarily stored here during the import process.

.LINK
https://deployhappiness.com/two-network-policy-server-tricks-subnets-and-syncing/

.LINK
https://gist.github.com/Jamesits/6c742087bca908327d51ad1b3bbed5dc

.LINK
http://directoryadmin.blogspot.com/2018/04/syncing-nps-settings-between-two-servers.html

#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true)]$Source,
    $Path = "\\$Source\C$\NPSConfig-$Source.xml"
)

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

Write-Debug "Write an error and exit the script if an exception is ever thrown"
trap {
    Write-EventLog -LogName "System" -eventID 1 -Source "NPS-Sync" -EntryType "Error" -Message "An Error occured during NPS Sync: $_. Script run from $($MyInvocation.MyCommand.Definition)"
    $_
    exit
}

Write-Debug "Create an NPS Sync Event Source if it doesn't already exist"
if (-not [System.Diagnostics.EventLog]::SourceExists("NPS-Sync")) { New-Eventlog -LogName "System" -Source "NPS-Sync" }

If ($PSCmdlet.ShouldProcess("$Source", "Export NPS Config")) {
    Write-Debug "Connect to NPS Master and export configuration"
    $ExportResult = Invoke-Command -ComputerName $Source -ArgumentList $Path -ScriptBlock { param ($Path) netsh nps export filename = $Path exportPSK = yes }
    Write-Debug "Verify that the import XML file was created. If it is not there, it will throw an exception caught by the trap above that will exit the script."
    Get-Item $Path -ErrorAction Stop | Out-Null
}

If ($PSCmdlet.ShouldProcess("$Source", "Reset NPS Config")) {
    Write-Debug "Clear existing configuration and import new NPS config"
    netsh nps reset config | Out-Null
}

If ($PSCmdlet.ShouldProcess("$Source", "Import NPS Config")) {
    Get-Item -Path $Path -ErrorAction Stop
    netsh nps import filename = $Path | Out-Null
    Write-Debug "Delete Temporary File"
    Remove-Item -path $Path

    Write-Debug "Compose and Write Success Event"
    Write-EventLog -LogName "System" -eventID 1 -Source "NPS-Sync" -EntryType "Information" -Message "Network Policy Server configuration successfully synchronized from $Source.

Export Results: $ExportResult

Import Results: $ImportResult

Script was run from $($MyInvocation.MyCommand.Definition)"

}
