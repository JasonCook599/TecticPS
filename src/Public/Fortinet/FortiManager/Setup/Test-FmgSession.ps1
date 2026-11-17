<#PSScriptInfo

.VERSION 1.0.2

.GUID 23770704-cca9-45a3-a9a8-fdffbd503c4f

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
Check that the existing FortiManager session is active by getting the system status.

.PARAMETER PSCustomObject
Don't check that you are connected for FortiManager before sending the request.

#>
param (
    [switch]$SkipConnectionCheck
)
try {
    $Status = Get-FmgStatus -SkipConnectionCheck:$SkipConnectionCheck -ErrorAction Stop

    if ([string]::IsNullOrWhiteSpace($FmgConfig.Version)) {
        Write-Verbose "FmgConfig version is not set. Setting."
        [string]$FmgConfig.Version = [string]$Status.Version
    }

    if ([string]::IsNullOrWhiteSpace($FmgConfig.ParsedVersion)) {
        Write-Verbose "FmgConfig parsed version is not set. Setting."
        [semver]$FmgConfig.ParsedVersion = [semver]"$($Status.Major).$($Status.Minor).$($Status.Patch)+$($Status.Build)"
    }
    return $true
}
catch {
    return $False
}
