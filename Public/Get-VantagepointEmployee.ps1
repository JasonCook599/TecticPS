<#PSScriptInfo

.VERSION 1.0.4

.GUID c6725cf5-57f9-491a-a2b9-941b34039ad2

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
Get Vantagepoint employee(s).
#>

param(
  [string]$Employee,
  [string]$Company,
  [string]$EmployeeKey,
  $BaseUri = $global:Vantagepoint.BaseUri,
  $Headers = $global:Vantagepoint.Headers
)
if (-not $EmployeeKey -and $Employee -and $Company) { $EmployeeKey = $Employee + "|" + $Company }
elseif (-not $EmployeeKey -and $Employee) { $EmployeeKey = $Employee }

Write-Verbose "$BaseUri/employee/$EmployeeKey"
return Invoke-RestMethod "$BaseUri/employee/$EmployeeKey" -Method GET -Headers $Headers
