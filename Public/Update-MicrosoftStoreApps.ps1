<#PSScriptInfo

.VERSION 1.0.1

.GUID 4cac6972-9cb0-4755-bfc1-ae2eb6dfc0d1

.AUTHOR Tony MCP

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) Tony MCP 2016

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
Updates Microsoft Store apps. Equivalent to clicking "Check for Updates" and "Update All" in the Microsoft Store app. Tt doesn't wait for the updates to complete before returning. Check the store app for the status of the updates.

.LINK

https://social.technet.microsoft.com/Forums/windows/en-US/5ac7daa9-54e6-43c0-9746-293dcb8ef2ec/how-to-force-update-of-windows-store-apps-without-launching-the-store-app

#>

$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_EnterpriseModernAppManagement_AppManagement01"
$wmiObj = Get-WmiObject -Namespace $namespaceName -Class $className
$wmiObj.UpdateScanMethod()
