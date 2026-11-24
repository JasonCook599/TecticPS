<#PSScriptInfo

.VERSION 1.0.5

.GUID b38a21f3-9578-45aa-88ca-7e8e4cb442ec

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
Converts to a PSCredential.

.PARAMETER JSON
A JSON string with the credentials.
.PARAMETER JsonSecureString
A SecureString which contains a JSON string with the credentials.
.PARAMETER UsernameKey
The key that contains the username value.
.PARAMETER PasswordKey
The key that contains the password value.
#>
[CmdletBinding()]
param (
  [switch]$SkipRemoval, [switch]$SkipUpdate,
  [switch]$ForceUpdate, [switch]$DoNotForceRemoval
)



if (-not $SkipUpdate) {
  # Write-Output "Updating all modules."
  $Modules = Get-InstalledModule
  foreach ($Module in $Modules) {
    $count++ ; Progress -Index $count -Total $Modules.count -Activity "Updating modules." -Name $Module.Name
    $Module | Update-Module -Force:$ForceUpdate -Verbose:$VerbosePreference
  }
  Remove-Variable count
}

if (-not $SkipRemoval) {
  [bool]$ForceRemoval = !$DoNotForceRemoval
  $Modules = Get-InstalledModule
  foreach ($Module in $Modules) {
    $count++ ; Progress -Index $count -Total $Modules.count -Activity "Checking for old versions." -Name $Module.Name
    Get-InstalledModule -Name $Module.Name -AllVersions | 
    Where-Object { $_.Version -ne $Module.Version } | 
    Uninstall-Module -Force:$ForceRemoval
  }
  Remove-Variable count
}





