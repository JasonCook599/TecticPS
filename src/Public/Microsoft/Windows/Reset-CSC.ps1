<#PSScriptInfo

.VERSION 1.0.4

.GUID a4176bef-cf00-42a8-b097-8c9be952931c

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
.DESCRIPTION
This will reset the CSC (offline files) cache.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param()
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\CSC\Parameters\ -Name FormatDatabase -Value 1 -Type DWord
