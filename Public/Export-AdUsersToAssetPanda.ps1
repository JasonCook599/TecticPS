<#PSScriptInfo

.VERSION 1.0.13

.GUID d201566e-c0d9-4dc4-9d3f-5f846c16c2a9

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
Export AD user for Asset Panda

.PARAMETER DefaultEmployeeType
The default type if not set for an employee.

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
    [string]$DefaultEmployeeType = "Inactive",
    [string]$SearchBase,
    [string]$Filter = "*",
    [array]$Properties = ("Surname", "GivenName", "EmailAddress", "Department", "telephoneNumber", "ipPhone", "MobilePhone", "Office", "Created", "employeeHireDate", "employeeType"),
    [string]$Server
)

$Arguments = @{}
if ($SearchBase) { $Arguments.SearchBase = $SearchBase }
if ($Filter) { $Arguments.Filter = $Filter }
if ($Properties) { $Arguments.Properties = $Properties }
if ($Server) { $Arguments.Server = $Server }

Get-ADUser @Arguments | ForEach-Object {
    if ($null -ne $_.employeeHireDate) { $HireDate = $_.employeeHireDate } else { $HireDate = $_.Created }
    if ($null -ne $_.employeeType) { $EmployeeType = $_.employeeType } else { $EmployeeType = $DefaultEmployeeType }

    return [PSCustomObject]@{
        "Last Name"      = $_.Surname
        "First Name"     = $_.GivenName
        "Email"          = $_.EmailAddress
        "Department"     = $_.Department
        "Work Phone"     = ([regex]::Match($_.telephoneNumber, "^((?:\+1)? ?(?:\d{10}|\d{7}))(?:.*)$")).Groups[1].Value
        "Work Extension" = $_.ipPhone
        "Cell Phone"     = $_.MobilePhone
        "Office"         = ($_.Office -split ",")[0]
        "Hire Date"      = $HireDate.ToString("MM\/dd\/yyyy")
        "Status"         = $EmployeeType
    }
}
