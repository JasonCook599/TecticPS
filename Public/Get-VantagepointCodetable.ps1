<#PSScriptInfo

.VERSION 1.0.4

.GUID a28fc8d6-42ea-43db-9e72-0be30545ddbd

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
Get the specified Vantagepoint codet able.
#>

param (
  [string]$CodeTable,
  $BaseUri = $global:Vantagepoint.BaseUri,
  $Headers = $global:Vantagepoint.Headers
)
if ($All) { return (Invoke-RestMethod "$BaseUri/codeTable/" -Method Get -Headers $Headers) }
else { return (Invoke-RestMethod "$BaseUri/codeTable/$CodeTable" -Method Get -Headers $Headers) }
