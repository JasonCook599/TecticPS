<#PSScriptInfo

.VERSION 1.0.1

.GUID fe011093-6980-4847-aa9c-f7a7b47a3a5b

.AUTHOR Jason Cook & Darren J Robinson

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
.SYNOPSIS
Authenticate to Azure AD and receieve Access and Refresh Tokens.

.DESCRIPTION
Authenticate to Azure AD and receieve Access and Refresh Tokens.

.PARAMETER tenantID
(required) Azure AD TenantID.

.PARAMETER credential
(required) ClientID and Cli
.EXAMPLE
$Credential = Get-Credential
AuthN -credential $Credential -tenantID '74ea519d-9792-4aa9-86d9-abcdefgaaa'

.LINK
http://darrenjrobinson.com/

#>
[cmdletbinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$tenantID,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][System.Management.Automation.PSCredential]$credential
)

if (!(Get-Command Get-MsalToken)) { Install-Module -name MSAL.PS -Force -AcceptLicense }
try { return (Get-MsalToken -ClientId $credential.UserName -ClientSecret $credential.Password -TenantId $tenantID) } # Authenticate and Get Tokens
catch { Write-Error $_ }
