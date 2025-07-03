<#PSScriptInfo

.VERSION 1.0.1

.GUID b5d41174-c403-4a6b-8750-901549c7e7ad

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
Get the photo for a Vantagepoint employee.
#>

param(
  [string]$Employee,
  $BaseUri = $global:Vantagepoint.BaseUri,
  $Headers = $global:Vantagepoint.Headers
)
return Invoke-RestMethod "$BaseUri/employee/$Employee" -Method "GET" -Headers $Headers
