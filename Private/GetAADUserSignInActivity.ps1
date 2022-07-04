<#PSScriptInfo

.VERSION 1.0.1

.GUID b444ff47-447f-4196-90eb-08723fa0fbaf

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

.PARAMETER ID
(required) ObjectID of the user to get SignIn Activity for

.EXAMPLE
GetAADUserSignInActivity -ID "feeb81f9-af70-2d5a-aa8c-f035ddaabcde"

.LINK
http://darrenjrobinson.com/
#>
[cmdletbinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$ID
)

$global:myToken = AuthN -credential $Credential -tenantID $TenantId # Refresh Access Token

try {
    # Get AAD SignIn Activity.
    return Invoke-RestMethod -Headers @{Authorization = "Bearer $($myToken.AccessToken)" } `
        -Uri  "https://graph.microsoft.com/beta/users/$($ID)?`$select=id,displayName,signInActivity" `
        -Method Get
}
catch { Write-Error $_ }
