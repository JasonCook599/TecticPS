<#PSScriptInfo

.VERSION 1.0.7

.GUID 3af068df-1f2d-4e6b-b1a7-e18e09311471

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
The script will get information about users from Azure Active Directory.

.PARAMETER Filter
Filters the AAD query based on the spesified parameters.

.PARAMETER WhereObject
Filters the returned results based on the spesified parameters.

.PARAMETER Properties
The properties to return from the search.

.PARAMETER SortKey
The sort key to use when sorting the results. By default, this is the first property selected.
#>

param(
    [string]$Filter,
    $Properties = @("UserPrincipalName", "DisplayName", "GivenName", "Surname", "UserType", "AccountEnabled", "PhysicalDeliveryOfficeName", "TelephoneNumber", "Mobile", "Mail", "MailNickName"),
    $WhereObject = { $_.DirSyncEnabled -ne $true },
    $SortKey = $Properties[0]
)

return Get-AzureADUser -Filter $Filter | Where-Object $WhereObject | Sort-Object $SortKey | Select-Object $Properties
