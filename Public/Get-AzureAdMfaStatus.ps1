<#PSScriptInfo

.VERSION 1.0.10

.GUID 036c4b38-9023-4f7b-9254-e8d7683f56e2

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
The script will get information about MFA setup from Azure Active Directory.

.PARAMETER Filter
Filters the AAD query based on the specified parameters.

.PARAMETER WhereObject
Filters the returned results based on the specified parameters.

.PARAMETER Properties
The properties to return from the search.

.PARAMETER SortKey
The sort key to use when sorting the results. By default, this is the first property selected.
#>

param(
  [string]$Filter,
  $Properties = @("UserPrincipalName", "DisplayName", "FirstName", "LastName", "UserType", "BlockCredential", "IsLicensed", @{N = "MFA Status"; E = { if ( $null -ne $_.StrongAuthenticationRequirements.State) { $_.StrongAuthenticationRequirements.State } else { "Disabled" } } }),
  $SortKey = $Properties[0]
)

return Get-MsolUser -All  | Sort-Object $SortKey | Select-Object $Properties
