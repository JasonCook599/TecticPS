<#PSScriptInfo

.VERSION 1.0.6

.GUID b757fe20-fd8f-489d-bb21-9d01146274cd

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
This will run the specified file.

.PARAMETER Path
The file you wish to run.
#>

param([ValidateScript( { Test-Path $_ -PathType Leaf })][string]$Path)
& $Path
