<#PSScriptInfo

.VERSION 1.0.3

.GUID 1591ca01-1cf9-4683-9d24-fbd1f746f44c

.AUTHOR Jason Cook

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) ***REMOVED*** 2022

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
This will return a random password which meets Active Directory's complexity requirements.
.PARAMETER Lenght
The lenght of the password to return. The default is 8 characters.

.PARAMETER Symbols
The number of symbols to include in the password. The default is 2 symbols.

.LINK
http://woshub.com/generating-random-password-with-powershell/

.LINK
https://docs.microsoft.com/en-us/dotnet/api/system.web.security.membership.generatepassword?view=netframework-4.8

#>
param (
  [int]$Lenght = 8,
  [int]$Symbols = 2
)

Add-Type -AssemblyName System.Web

do {
  $Password = [System.Web.Security.Membership]::GeneratePassword($Lenght, $Symbols)
  If (     ($Password -cmatch "[A-Z\p{Lu}\s]") `
      -and ($Password -cmatch "[a-z\p{Ll}\s]") `
      -and ($Password -match "[\d]") `
      -and ($Password -match "[^\w]")
  ) { $Complex = $True }
} While (-not $Complex)

return $Password
