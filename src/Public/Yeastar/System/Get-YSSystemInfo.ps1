<#PSScriptInfo

.VERSION 0.0.9

.GUID e27c9d4a-7a3c-46e3-92e2-c6ca95c583ed

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

return Get-YSResult "system/information"



