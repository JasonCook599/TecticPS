<#PSScriptInfo

.VERSION 1.0.13

.GUID 5e6104a0-232a-4fb1-8858-62e1d8220721

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) TectTectic

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
Find files with the same name.
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$Path,
  [hashtable]$Params = @{
    Recurse = $true
    File    = $true
  }
)

$Files = @()
$Results = @()

$Path | ForEach-Object { $Files += Get-ChildItem -Path $_  @Params }
$Files | ForEach-Object { if (($Files.Name -eq $_.Name).count -gt 1 ) { $Results += $_ } }

return $Results
