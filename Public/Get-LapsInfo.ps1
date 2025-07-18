<#PSScriptInfo

.VERSION 1.0.6

.GUID 2a3f5ec5-e6c3-4a0b-a8ca-67f98b359144

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

$Results = @()
Get-ADComputer -Filter $Filter -Properties ms-Mcs-AdmPwd | Sort-Object ms-Mcs-AdmPwd, Name | ForEach-Object {
  if ($Show) { $Password = $_.'ms-Mcs-AdmPwd' } else { $Password = '********' }
  if ($_.'ms-Mcs-AdmPwd') { $Status = $true } else { $Status = $false }
  $Result = [PSCustomObject]@{
    Name     = $_.Name
    Status   = $Status
    Password = $Password
  }
  $Results += $Result
}
if ($Details) { return $Results } else {

  $EnabledCount = ($Results | Where-Object Status -eq $true).Count
  $DisabledCount = ($Results | Where-Object Status -eq $false).Count
  $TotalCount = $Results.count

  return [PSCustomObject]@{
    Enabled         = $EnabledCount
    Disabed         = $DisabledCount
    Total           = $TotalCount
    PercentComplete = $EnabledCount / $TotalCount * 100
  }
}
