<#PSScriptInfo

.VERSION 1.0.8

.GUID 7e5f0eae-b0a0-4a32-b318-fe51695f9de3

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
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification = 'The PasswordKey variable is used to store the password key, not the password itself.')]
param (
  [Parameter(Mandatory, ParameterSetName = 'Json', Position = 0)]
  [ValidateScript(
    { Test-Json -Json $_ },
    ErrorMessage = "The provided string is not valid JSON."
  )]
  [string]$Json,

  [Parameter(Mandatory, ParameterSetName = 'JsonSecureString', Position = 0)]
  [securestring]$JsonSecureString,

  [string]$UsernameKey = "Username",
  [string]$PasswordKey = "Password"
)

if ($JsonSecureString) { 
  Write-Debug "Converting JsonSecureString to Json"
  [string]$Json = ConvertFrom-SecureString -AsPlainText $JsonSecureString 
}
if ($Json) {
  Write-Debug "Converting JsonSecureString to Json"
  [hashtable]$Data = $Json | ConvertFrom-Json -AsHashtable
  
  Write-Debug "Getting username"
  [string]$Username = $Data.$UsernameKey
  
  Write-Debug "Getting password"
  [securestring]$Password = $Data.$PasswordKey | ConvertTo-SecureString -AsPlainText
  
  Write-Debug "Returning credential"
  return [pscredential]::new($Username, $Password)
}
else {
  throw "Invalid input data"
}






