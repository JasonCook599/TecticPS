<#
.SYNOPSIS
Get AAD Account SignIn Activity.

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