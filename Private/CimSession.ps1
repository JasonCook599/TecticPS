<#PSScriptInfo

.VERSION 1.0.1

.GUID 2e98e078-34ab-45f7-8e39-57926daaa825

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
Find an existing CIM session, or create a new one.

.PARAMETER ComputerName
The computer to create the session on.
#>
param (
  [string][Parameter(Position = 0, Mandatory = $true)]$ComputerName
)

try { $Session = (Get-CimSession -ComputerName $ComputerName -ErrorAction SilentlyContinue)[0] }
catch { $Session = (New-CimSession -ComputerName DGIIPAM1M) }
return $Session
