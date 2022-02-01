<#
.SYNOPSIS
Get AAD B2B Accounts where the inviation hasn't been accepted.

.DESCRIPTION
Get AAD B2B Accounts where the inviation hasn't been accepted.

.EXAMPLE
GetAADPendingGuests 

.LINK
http://darrenjrobinson.com/

#>
[cmdletbinding()]
param()

$global:myToken = AuthN -credential $Credential -tenantID $TenantId # Refresh Access Token

try {
    # Get AAD B2B Pending Users.    
    return (Invoke-RestMethod -Headers @{Authorization = "Bearer $($myToken.AccessToken)" } `
            -Uri  "https://graph.microsoft.com/beta/users?filter=externalUserState eq 'PendingAcceptance'&`$top=999" `
            -Method Get).value 
}
catch { Write-Error $_ }