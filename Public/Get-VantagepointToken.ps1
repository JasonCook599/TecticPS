<#PSScriptInfo

.VERSION 1.0.4

.GUID 6c901b8f-8592-44ec-9e59-a84b7e7633e1

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
Get an auth token for Vantagepoint.
#>

param (
  [Parameter(Mandatory = $true)][PSCredential]$APICredential,
  [Parameter(Mandatory = $true)][PSCredential]$UserCredential,
  [Parameter(Mandatory = $true)][string]$Database,
  [Parameter(Mandatory = $true)][string]$BaseUri,
  $Headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
  }
)

$Body = @{
  Username      = $UserCredential.UserName
  Password      = ([System.Net.NetworkCredential]::new("", $UserCredential.Password).Password)
  grant_type    = "password"
  Integrated    = "N"
  database      = $Database
  Client_Id     = $APICredential.UserName
  client_secret = ([System.Net.NetworkCredential]::new("", $APICredential.Password).Password)
  culture       = "en-US"
}

$Request = (Invoke-RestMethod "$BaseUri/token" -Method 'POST' -Headers $Headers -Body $Body)
$global:Vantagepoint = @{
  BaseUri = $BaseUri
  Headers = @{
    "Content-Type"  = "application/json"
    "Authorization" = "$($Request.token_type) $($Request.access_token)"
  }
  Token   = $Request.access_token
}
return $global:Vantagepoint
