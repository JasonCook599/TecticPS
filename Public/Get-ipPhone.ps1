<#PSScriptInfo

.VERSION 1.0.5

.GUID 51e2066f-785d-4ab1-b889-904c387fb2f9

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
Export all ipPhone information.

.PARAMETER Path
The location to export to.

.PARAMETER Filter
How to filter the AD query. By default, it will filter out any user which doesn't have the ipPhone attribute set.

.LINK
https://docs.microsoft.com/en-us/windows/win32/adschema/a-admincount
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateScript( { Test-Path ((Get-Item $_).parent) })][string]$Path,
  $Filter = "ipphone -like `"*`""
)

$Results = Get-ADUser -Properties name, ipPhone, Company, Title, Department, DistinguishedName -Filter $Filter | Where-Object msExchHideFromAddressLists -ne $true | Select-Object name, ipPhone, Company, Title, Department | Sort-Object -Property Company, name
if ($Path) { $Results | Export-Csv -NoTypeInformation -Path $Path }
return $Results
