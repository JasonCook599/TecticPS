<#PSScriptInfo

.VERSION 1.0.6

.GUID c64f1f09-036c-471d-898c-c9b3da6f53a8

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
Shows the percentage of machines which have LAPS configured.

.PARAMETER Details
If set, will show which computers have a password set.

.PARAMETER Filter
Filters the search based on the specified parameters.

.PARAMETER ShowPasswords
Will also output passwords.
#>
param(
  [string]$Filter = "*",
  [switch]$Details,
  [string]$Show
)

function ParseDate {
  param ($Date)
  if ($null -ne $Date -and $Date -ne 0) { return [datetime]::FromFileTime($Date) }
}

$Results = @()
Get-ADUser -Filter * -Properties name, givenName, sn, mail, title, department, company, lastLogonTimestamp, pwdLastSet, whenCreated, whenChanged | `
  Select-Object name, givenName, sn, mail, title, department, company, lastLogonTimestamp, pwdLastSet, whenCreated, whenChanged | `
  Sort-Object lastLogonTimestamp, name | ForEach-Object {

  $Result = [PSCustomObject]@{
    Name            = $_.name
    FirstName       = $_.givenName
    LastName        = $_.sn
    Email           = $_.mail
    Title           = $_.title
    Department      = $_.department
    Company         = $_.company
    LastLogon       = ParseDate $_.lastLogonTimestamp
    PasswordLastSet = ParseDate $_.pwdLastSet
    Created         = $_.whenCreated
    Changed         = $_.whenChanged
  }
  $Results += $Result
}
return $Results
