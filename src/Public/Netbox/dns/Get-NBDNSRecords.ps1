<#PSScriptInfo

.VERSION 1.0.2

.GUID 8f99a11e-688e-4aab-a593-9fcf2958c0f6

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
Get DNS records from the netbox-dns plugin

#>

param (
  [int]$ID,
  [string]$View,
  [string[]]$Fields,
  [hashtable]$Body
)

$Endpoint = "plugins/netbox-dns/records"
if ($ID) { $Endpoint += "/$ID" }

if (-not $Body) {
  [hashtable]$Body = @{}
  if ($View) { $Body.view = $View }
  if ($Fields) { [string]$Body.fields = $Fields -join "," }
}

return Get-NetboxResult -baseUrl $baseUrl -token $Token -Endpoint $Endpoint -Body $Body


