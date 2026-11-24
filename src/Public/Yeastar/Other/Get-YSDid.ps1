<#PSScriptInfo

.VERSION 1.0.5

.GUID a72f4122-dc81-4116-8a77-aef370fbbb3d

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
Get all DIDs in use.

#>

Write-Verbose "Getting Yeastar DIDs."
[array]$InboundRoutes = Get-YSInboundRoute
[array]$InboundRouteInfo = @()
foreach ($Route in $InboundRoutes) { $InboundRouteInfo += Get-YSInboundRoute -ID $Route.ID }

[array]$YeastarDIDs = ($InboundRouteInfo.did_pattern_to_ext_list.did_pattern + $InboundRouteInfo.did_pattern_list.did_pattern) | Select-Object -Unique

return [array]$YeastarDIDs





