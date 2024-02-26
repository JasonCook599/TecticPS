<#PSScriptInfo

.VERSION 1.0.2

.GUID a1800752-6b26-44fe-8056-573c7434ff1d

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
This script will find all empty organizational units.
#>
Get-ADOrganizationalUnit -filter * -Properties Description -PipelineVariable pv |
Select-Object DistinguishedName, Name, Description,
@{Name = "Children"; Expression = {
        Get-ADObject -filter * -SearchBase $pv.distinguishedname |
        Where-Object { $_.objectclass -ne "organizationalunit" } |
        Measure-Object | Select-Object -ExpandProperty Count }
} | Where-Object { $_.children -eq 0 } |
ForEach-Object {
    Set-ADOrganizationalUnit -Identity $_.distinguishedname -ProtectedFromAccidentalDeletion $False -PassThru -whatif |
    Remove-ADOrganizationalUnit -Recursive -whatif
}
