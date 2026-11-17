<#PSScriptInfo

.VERSION 1.0.2

.GUID 5805641b-2f85-4aec-87ea-18a87067da0e

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
Disconnect from FortiManager.

#>

try {
    Invoke-FmgJsonApi -url "/sys/logout" -method exec -ErrorAction Stop
    Remove-Variable FmgConfig
} 
catch {
    throw $_
}
