<#PSScriptInfo

.VERSION 1.0.1

.GUID a2fd3f34-5e6e-4bab-a860-ce9048a23348

.AUTHOR Jason Cook

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) ***REMOVED*** 2023

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
Installs multiple apps using Winget

.PARAMETER Path
Path the the CSV file containing the list of apps to install. Must contain an "ID" column.

.PARAMETER Apps
An array of apps to install. Usually generated from the file specified in Path.

.PARAMETER Scope
The install scope for the application. Machine by default. Can specify $null to use the default scope.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript( { Test-Path $_ -PathType Leaf })][string]$Path,
  [array]$Apps = ((Import-Csv $Path | Where-Object Source -eq "winget" | Where-Object Skip -ne $true | Sort-Object Id).Id),
  [string]$Scope = "--scope machine"
)
return $Apps | ForEach-Object {
  If ($PSCmdlet.ShouldProcess($_, "winget install")) {
    Start-Process -FilePath "winget" -ArgumentList "install $_ $Scope" -NoNewWindow -Wait
  }
}
