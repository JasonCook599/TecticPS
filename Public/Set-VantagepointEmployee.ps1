<#PSScriptInfo

.VERSION 1.0.4

.GUID 4ff2c812-f868-4856-b9ac-38b2da89c582

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
Update a Vantagepoint employee.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
  $Body,
  [string]$Employee,
  [string]$Company,
  [string]$EmployeeKey,
  $BaseUri = $global:Vantagepoint.BaseUri,
  $Headers = $global:Vantagepoint.Headers
)
if (-not $EmployeeKey -and $Employee -and $Company) { $EmployeeKey = $Employee + "|" + $Company }
elseif (-not $EmployeeKey -and $Employee) { $EmployeeKey = $Employee }

If ($PSCmdlet.ShouldProcess($EmployeeKey, "Updating Vantagepoint")) {
  return Invoke-RestMethod "$BaseUri/employee/$EmployeeKey" -Method PUT -Headers $Headers -Body ($Body | ConvertTo-Json)
}
else { return $Body }
