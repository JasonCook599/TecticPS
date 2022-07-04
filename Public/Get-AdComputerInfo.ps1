<#PSScriptInfo

.VERSION 1.0.4

.GUID fc558d38-77a0-4b50-bd45-9f81aaf54984

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
The script will get information about computers from Active Directory.

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
    $Properties = @("CN", "Enabled", "LastLogonDate", "Created", "Modified", "OperatingSystem", "OperatingSystemVersion", "OperatingSystemServicePack", "PasswordLastSet"),
    $SortKey = $Properties[0],
    [string]$SearchBase
)

Test-Admin -Warn -Message "You are not running as an admin. Results may be incomplete."

if ($SearchBase) {
    $Computers = Get-ADComputer -Filter $Filter -SearchBase $SearchBase -Properties $Properties
}
else {
    $Computers = Get-ADComputer -Filter $Filter -Properties $Properties
}

return $Computers # | Sort-Object $SortKey | Select-Object $Properties
