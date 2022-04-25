<#PSScriptInfo

.VERSION 1.0.3

.GUID f12cad80-f34f-402f-aa4a-e92d80f725a9

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


.PRIVATEDATA

#> 







<#
.DESCRIPTION
Archive Windows Event logs.

.PARAMETER Path
The location log files should be moved to.

.PARAMETER EventPath
The location log files should be moved from.

.PARAMETER IgnoreHostname
Exclude the hostname from the path when moving the log files.

.EXAMPLE
Move-ArchiveEventLogs -Path \\server\logs
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateScript({ Test-Path $_ })][string]$Path,
    [ValidateScript({ Test-Path $_ })][string]$EventPath = (Join-Path -Path $Env:windir -ChildPath "\System32\winevt\Logs"),
    [switch]$IgnoreHostname
)

if (-not $IgnoreHostname) {
    $NewPath = (Join-Path -Path $Path -ChildPath $Env:computername)
    New-Item -Path $NewPath -ItemType Directory -Force | Out-Null
    $Path = $NewPath
}

Write-Verbose "Moving log files to $Path"
$Files = Get-ChildItem -Path $EventPath -Filter "Archive-*.evtx" -File | Sort-Object -Property LastWriteTime
$Files | ForEach-Object { 
    $count++ ; Progress -Index $count -Total $Files.count -Activity "Moving archive event logs." -Name $_.Name
    Move-Item -Path $_.FullName -Destination $Path -ErrorAction Stop
}

