<#PSScriptInfo

.VERSION 1.0.4

.GUID c2b45e52-9f16-4a88-be7c-cc9d73214369

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
Disables each provided Vantagepoint employee.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [parameter(Mandatory = $true)][Alias("User")]$Username,
  $BaseUri = $global:Vantagepoint.BaseUri,
  $Headers = $global:Vantagepoint.Headers
)
if ($Username.count -gt 0) {
  $Username | ForEach-Object {
    If ($PSCmdlet.ShouldProcess($_, "Disabling Vantagepoint User")) {
      $Body = @{status = "I" }
      return Invoke-RestMethod "$BaseUri/security/user/$User" -Method PUT -Headers $Headers -Body ($Body | ConvertTo-Json)
    }
  }
}
