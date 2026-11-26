<#PSScriptInfo

.VERSION 1.0.2

.GUID 046374a2-9109-46ad-963f-3b63de149fc0

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
Get DNS zone from the netbox-dns plugin

#>

param ([int]$ID)
$Endpoint = "plugins/netbox-dns/zones"
if ($ID) { $Endpoint += "/$ID" }
Get-NetboxResult -baseUrl $baseUrl -token $Token -Endpoint $Endpoint


