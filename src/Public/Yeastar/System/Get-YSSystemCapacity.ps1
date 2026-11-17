<#PSScriptInfo

.VERSION 0.0.9

.GUID 52b8c3d1-d92d-43fd-833f-fc1318c77bb9

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
Get PBX capacity

.LINK
https://help.yeastar.com/en/p-series-software-edition/developer-guide/query-pbx-capacity.html
#>

return Get-YSResult "system/capacity"



