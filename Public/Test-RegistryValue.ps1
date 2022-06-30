<#PSScriptInfo

.VERSION 1.0.1

.GUID 73abfeda-2bad-4f83-a401-e34757afcbc0

.AUTHOR Jonathan Medd

.COMPANYNAME 

.COPYRIGHT Copyright (c) Jonathan Medd 2014

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
Tests is a given registry key exists.

.PARAMETER Path
The registry key to test.

.PARAMETER Value
The registry value withing the key to test.

.LINK
https://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html
#>

param (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Path,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Value
)
    
try {
    Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
    return $true
}
catch { return $false }
