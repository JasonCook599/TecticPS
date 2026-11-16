<#PSScriptInfo

.VERSION 1.0.2

.GUID 3b856f02-1f78-48c0-afb8-a0ce75e6d6ff

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
This will move archived event logs to the specified directory.

.PARAMETER Path
The destination folder for the log files. A child folder will be created for the $env:COMPUTERNAME

.PARAMETER Source
The source location of the log files. By default, this will be "C:\Windows\System32\winevt\Logs"

.PARAMETER Destination
The actual destination of the log files, combining Path and $env:COMPUTERNAME.

.EXAMPLE
Move-ArchivedEventLogs -Path \\server\folder
#>

param(
  [ValidateScript( { Test-Path -Path $_ -PathType Container })][string]$Path,
  [ValidateScript( { Test-Path -Path $_ -PathType Container })][string]$Source = "C:\Windows\System32\winevt\Logs",
  $Destination = (Join-Path -Path $Path -ChildPath $env:COMPUTERNAME)
)

if (-not (Test-Path -Path $Destination)) {
  Write-Verbose "Creating a directory for $env:COMPUTERNAME"
  New-Item -Path $Destination -ItemType Directory
}

Get-ChildItem -Path $Source -Filter "Archive-*.evtx" | Move-Item -Destination $Destination
