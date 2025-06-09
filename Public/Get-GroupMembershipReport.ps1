<#PSScriptInfo

.VERSION 1.0.5

.GUID b2ff192c-1106-4c52-ab8c-b7cab4524cc9

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
Gets group membership information for the specified groups.

.PARAMETER Filter
Filters the search based on the specified parameters.

.PARAMETER SearchBase
The LDAP search base.
#>

param (
  $Filter = "*",
  $SearchBase
)
$Results = @()
Get-ADGroup -SearchBase $SearchBase -Filter * -Properties Description | ForEach-Object {
  $MembersString = (Get-ADGroupMember -Identity $_.DistinguishedName).Name -join ";"
  $Result = [PSCustomObject]@{
    Name          = $_.Name
    Description   = $_.Description
    MembersString = $MembersString
    Members       = (Get-ADGroupMember -Identity $_.DistinguishedName).Name
  }
  $Results += $Result
}
return $Results
