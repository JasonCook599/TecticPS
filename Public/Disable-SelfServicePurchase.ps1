<#PSScriptInfo

.VERSION 1.0.2

.GUID 1af7209d-520d-4d2c-90f4-de3bc5cf2f48

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
This script will disallows self service purchases in Microsoft 365.

.LINK
https://github.com/MicrosoftDocs/microsoft-365-docs/blob/public/microsoft-365/commerce/subscriptions/allowselfservicepurchase-powershell.md
#>
Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase | ForEach-Object { Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductId $_.ProductID -Enabled $false }
