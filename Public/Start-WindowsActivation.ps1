<#PSScriptInfo

.VERSION 1.0.3

.GUID 625c264b-e5ec-4c6a-8478-39ec90518250

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
.DESCRIPTION
Activate windows using the spesified key, or fall back to the key in the BIOS.
#>

param (
    [string]$ProductKey
)

Function ActivationStatus { return (Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" |  Where-Object { $_.PartialProductKey })[0].LicenseStatus }
function ActivateWindows {
    param ([Parameter(ValueFromPipeline = $true)][ValidatePattern('^([A-Z0-9]{5}-){4}[A-Z0-9]{5}$')][string]$ProductKey)
    $Service = Get-WmiObject -query "select * from SoftwareLicensingService"
    $Service.InstallProductKey($ProductKey)
    $Service.RefreshLicenseStatus()
    return ActivationStatus
}

$Status = ActivationStatus | Out-Null
if ($Status -eq 1) { return "Windows is already activated." }

if ($ProductKey) {
    ActivateWindows $ProductKey
    $Status = ActivationStatus | Out-Null
    if ($Status -eq 1) { return "Windows was activated using the specified key." }
    Write-Error "Windows could not be activated using the specified key."
}

$BiosProductKey = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey 
if ($BiosProductKey) {
    ActivateWindows $BiosProductKey | Out-Null
    $Status = ActivationStatus | Out-Null
    if ($Status -eq 1) { return "Windows was activated using the BIOS key." }
    Write-Error "Windows could not be activated BIOS key."
}

Write-Error "Windows could not be activated."