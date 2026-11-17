<#PSScriptInfo

.VERSION 0.0.9

.GUID 366a409a-6ffe-4bd7-9d60-6d013d9619e1

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
Get PBX Information

.LINK
https://help.yeastar.com/en/p-series-software-edition/developer-guide/query-pbx-information.html
#>
return [bool]$YSApiConnection.Connected

