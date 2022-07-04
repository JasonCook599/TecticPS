<#PSScriptInfo

.VERSION 1.0.1

.GUID e5758f99-a57e-4bcf-af21-30e5fd176e51

.AUTHOR Jason Cook Darren J Robinson

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
Get AAD Account SignIn Activity.

.PARAMETER date
(required) date whereby users haven't signed in since to return objects for

.EXAMPLE
GetAADSignIns -Date "2021-01-01"

.LINK
http://darrenjrobinson.com/
#>
[cmdletbinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$Date
)
$global:myToken = AuthN -credential $Credential -tenantID $TenantId # Refresh Access Token

try {
    # Get AAD B2B Users
    return (Invoke-RestMethod -Headers @{Authorization = "Bearer $($myToken.AccessToken)" } `
            -Uri  "https://graph.microsoft.com/beta/users?filter=signInActivity/lastSignInDateTime le $($Date)" `
            -Method Get).value
}
catch { Write-Error $_ }
