<#PSScriptInfo

.VERSION 1.0.25

.GUID d201566e-c0d9-4dc4-9d3f-5f846c16c2a9

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2024

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
Export AD user for Asset Panda

.PARAMETER ActiveEmployeeType
The default type for enabled users if not set for an employee.

.PARAMETER InctiveEmployeeType
The default type for disabled users if not set for an employee.

.PARAMETER SearchBase
The AD search base to pull users from.

.PARAMETER Filter
The filter when querying for AD users.

.PARAMETER Properties
An array of properties to query from AD.

.PARAMETER Server
The AD server to query.

.LINK
https://help.assetpanda.com/Importing.html
#>

param(
  [string]$ActiveEmployeeType = "Full Time",
  [string]$InactiveEmployeeType = "Inactive",
  [string]$SearchBase,
  [string]$Filter = "*",
  [array]$Properties = ("DisplayName", "GivenName", "Surname", "EmailAddress", "Office", "Title", "Department", "telephoneNumber", "ipPhone", "MobilePhone", "Created", "Enabled", "employeeHireDate", "employeeType"),
  [string]$Server
)

$Arguments = @{}
if ($SearchBase) { $Arguments.SearchBase = $SearchBase }
if ($Filter) { $Arguments.Filter = $Filter }
if ($Properties) { $Arguments.Properties = $Properties }
if ($Server) { $Arguments.Server = $Server }

Get-ADUser @Arguments | ForEach-Object {
  if ($_.employeeHireDate) { $HireDate = $_.employeeHireDate } else { $HireDate = $_.Created }
  if (-not $_.enabled) { $EmployeeType = $InactiveEmployeeType }
  elseif ($_.employeeType) { $EmployeeType = $_.employeeType }
  else { $EmployeeType = $ActiveEmployeeType }

  return [PSCustomObject]@{
    "Display Name"   = $_.DisplayName
    "E-mail"         = $_.EmailAddress -replace "`'"
    "First Name"     = $_.GivenName
    "Last Name"      = $_.Surname
    "Office"         = ($_.Office -split ",")[0]
    "Type"           = $EmployeeType
    "Title"          = $_.Title
    "Department"     = $_.Department
    "Work Phone"     = ([regex]::Match($_.telephoneNumber, "^((?:\+1)? ?(?:\d{10}|\d{7}))(?:.*)$")).Groups[1].Value
    "Work Extension" = $_.ipPhone
    "Cell Phone"     = $_.MobilePhone
    "Hire Date"      = $HireDate.ToString("MM\/dd\/yyyy")
  }
}
