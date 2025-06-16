<#PSScriptInfo

.VERSION 1.0.4

.GUID 067a1554-d6dd-40d2-b3b7-b313f1a990b3

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
Get Vantagepoint users.
#>

param(
  $BaseUri = $global:Vantagepoint.BaseUri,
  $Headers = $global:Vantagepoint.Headers
)
return Invoke-RestMethod "$BaseUri/user" -Method GET -Headers $Headers
