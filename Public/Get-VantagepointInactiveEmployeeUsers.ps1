<#PSScriptInfo

.VERSION 1.0.4

.GUID ba61cd23-49f3-46f7-ae52-de4cf16b031f

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2025

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
Get Vantagepoint users if the User is active and Employee is inactive.
#>

param (
  $Users = (Get-VantagepointUsers)
)
return $Users | Where-Object Status -ne "I" | Where-Object EmployeeStatus -ne "A" | Where-Object EmployeeStatus -ne ""
