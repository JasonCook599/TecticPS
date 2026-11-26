<#PSScriptInfo

.VERSION 1.0.2

.GUID d0ca1948-69a0-44b5-839a-b2f3b8962f40

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2026

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
Get DNS views from the netbox-dns plugin

#>

param ([int]$ID)
$Endpoint = "plugins/netbox-dns/views"
if ($ID) { $Endpoint += "/$ID" }
Get-NetboxResult -baseUrl $baseUrl -token $Token -Endpoint $Endpoint


