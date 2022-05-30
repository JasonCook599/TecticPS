<#PSScriptInfo

.VERSION 1.0.5

.GUID 9ee43161-d2de-4792-a59e-19ff0ef0717e

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
This script will output the email addresses needed for the scan to email function on MFPs.

.PARAMETER Path
The location where the results will be exported to.

.PARAMETER Properties
The properties to export.

.PARAMETER SearchBase
The base OU to search from.

.PARAMETER Filter
How should the AD results be filtered?
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateScript( { Test-Path ((Get-Item $_).parent) })][string]$Path,
    [array]$Properties = ("name", "mail"),
    [string]$SearchBase ,
    [string]$Filter = "*"
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

If ($SearchBase) { $Result = Get-ADUser -Properties $Properties -Filter $Filter -SearchBase $SearchBase | Where-Object Enabled -eq $true }
else { $Result = Get-ADUser -Properties $Properties -Filter $Filter | Where-Object Enabled -eq $true }
$Result += Get-ADUser -Properties $Properties -Identity "koinonia"
$Result += Get-ADUser -Properties $Properties -Identity "kcfit"
$Result = $Result | Where-Object msExchHideFromAddressLists -ne $true | Select-Object name, mail | Sort-Object -Property Company, name
$Result | ForEach-Object { $_.name = "$($_.name[0..23] -join '')" } #Trim lenght for import.
if ($Path) { $Result | Export-Csv -NoTypeInformation -Path $Path }
Return $Result

