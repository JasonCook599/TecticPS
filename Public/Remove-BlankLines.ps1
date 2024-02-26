<#PSScriptInfo

.VERSION 1.0.3

.GUID c0df5582-8e43-491d-92ce-410392bb9912

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2024

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
This will remove superfluous blank lines from a string.
#>

param([string]$String)
while ($String.Contains("`r`n`r`n`r`n")) { $String = ($String -replace "`r`n`r`n`r`n", "`r`n`r`n").Trim() }
return $String
