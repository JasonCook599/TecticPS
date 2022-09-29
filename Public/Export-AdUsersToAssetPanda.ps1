<#PSScriptInfo

.VERSION 1.0.8

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
#>

param(
    [string]$SearchBase,
    [string]$Filter = "*",
    [array]$Properties = ("Surname", "GivenName", "EmailAddress", "Department", "telephoneNumber", "ipPhone", "MobilePhone", "Office", "Created", "employeeHireDate", "employeeType"),
    [string]$Server
)

$Arguments = @{}
if ($SearchBase) { $Arguments.SearchBase = $SearchBase }
if ($Filter) { $Arguments.Filter = $Filter }
if ($Filter) { $Arguments.Filter = $Filter }
if ($Properties) { $Arguments.Properties = $Properties }
if ($Server) { $Arguments.Server = $Server }

[System.Collections.ArrayList]$Results = @()

Get-ADUser @Arguments | ForEach-Object {
    $Result = [PSCustomObject]@{
        "Last Name"      = $_.Surname
        "First Name"     = $_.GivenName
        "Email"          = $_.EmailAddress
        "Department"     = $_.Department
        "Work Phone"     = ([regex]::Match($_.telephoneNumber, "^((?:\+1)? ?(?:\d{10}|\d{7}))(?:.*)$")).Groups[1].Value
        "Work Extension" = $_.ipPhone
        "Cell Phone"     = $_.MobilePhone
        "Office"         = ($_.Office -split ",")[0]
        "Hire Date"      =	$_.Created
        "Status"         = "Full Time"
    }
    if ($null -ne $_.employeeHireDate) { $Result."Hire Date" = $_.employeeHireDate }
    if ($null -ne $_.employeeType) { $Result.Status = $_.employeeType }
    $Results += $Result
}
return $Results
