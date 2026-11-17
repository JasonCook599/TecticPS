<#PSScriptInfo

.VERSION 1.0.2

.GUID 9be46009-4b7b-408f-bcce-083b93893bfa

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
Select a FortiManager ADOM.

.
.PARAMETER ADOM
The ADOM to select.

#>

param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ADOM
)

[string]$FmgConfig.ADOM = [string]$ADOM
return $FmgConfig
