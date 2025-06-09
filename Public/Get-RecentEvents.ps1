<#PSScriptInfo

.VERSION 1.0.4

.GUID 05dad3a6-57cf-4747-b3bd-57bc12b7628e

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
.SYNOPSIS
This script will search the event log for events a specified number of minutes before or after a given time.

.DESCRIPTION
This script will search the event log for events a specified number of minutes before or after a given time.

.PARAMETER Before
To search before -Time. Either -Before or -After must be specified. -Before will take precedence if both are set.

.PARAMETER After
To search after -Time. Either -Before or -After must be specified. -Before will take precedence if both are set.

.PARAMETER Time
The number of minutes from now to begin the search. This parameter is required.

.EXAMPLE
.\Get-RecentEvents.ps1 -After -Time -1

   Index Time          EntryType   Source                 InstanceID Message
   ----- ----          ---------   ------                 ---------- -------
   31568 Sep 05 12:18  Information Service Control M...   1073748864 The start type of the Background Intelligent Transfer Service service was changed from auto start to demand start.
#>
param(
  [Parameter(Mandatory = $true)][string]$Time,
  [switch]$Before,
  [switch]$After
)

Test-Admin -Message "You are not running this script with Administrator rights. Some events may be missing." | Out-Null

If ($Before -eq $True) { Get-EventLog System -Before (Get-Date).AddMinutes($Time) }
ElseIf ($After -eq $True) { Get-EventLog System -After (Get-Date).AddMinutes($Time) }
Else { Write-Error "You must specify either -Before or -After" }
