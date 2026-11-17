<#PSScriptInfo

.VERSION 1.0.2

.GUID 6d987617-11a0-487b-b55a-085230c41a9a

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
Get FortiManager Switch Template

.PARAMETER Name
The name of a specific template to request. Optional.
#>
param ([string]$Name)

return Invoke-FmgJsonApi -url "pm/config/adom/$($FmgConfig.ADOM)/obj/switch-controller/managed-switch/$Name"
