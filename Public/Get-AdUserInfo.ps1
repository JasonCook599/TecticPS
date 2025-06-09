<#PSScriptInfo

.VERSION 1.0.7

.GUID 2102c95e-5402-43a2-ba4f-356a89fff4ca

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
The script will get information about users from Active Directory.

.PARAMETER Filter
Filters the search based on the spesified parameters.

.PARAMETER Properties
The properties to return from the search.

.PARAMETER SortKey
The sort key to use when sorting the results. By default, this is the first property selected.

.PARAMETER SearchBase
Specifies the search base for the command.
#>

param(
  [string]$Filter = "*",
  $Properties = @("SamAccountName", "DisplayName", "GivenName", "Surname", "Description", "Enabled", "LastLogonDate", "whenCreated" , "PasswordLastSet", "PasswordNeverExpires", "EmailAddress", "Title", "Department", "Company", "Organization", "Manager", "Office", "MobilePhone", "HomeDirectory"),
  $SortKey = $Properties[0],
  [string]$SearchBase
)

Test-Admin -Warn -Message "You are not running as an admin. Results may be incomplete."

if ($SearchBase) {
  $Users = Get-ADUser -Filter $Filter -SearchBase $SearchBase -Properties $Properties
}
else {
  $Users = Get-ADUser -Filter $Filter -Properties $Properties
}

return $Users # | Sort-Object $SortKey | Select-Object $Properties
