<#PSScriptInfo

.VERSION 0.0.9

.GUID 25462e72-3b66-48be-a008-c3426067f398

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
Get all inbound routes.

#>
param ([int]$ID)

if ([int]$ID) { 
  return Get-YSResult "inbound_route/get" -Query @{id = $ID }
}
else {
  return Get-YSResult "inbound_route/list"
}



