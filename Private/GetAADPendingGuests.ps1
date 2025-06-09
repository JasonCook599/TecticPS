<#PSScriptInfo

.VERSION 1.0.4

.GUID d2231470-2326-4498-80d2-0456b0018d0a

.AUTHOR Jason Cook Darren J Robinson

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
Get AAD B2B Accounts where the invitation hasn't been accepted.

.EXAMPLE
GetAADPendingGuests

.LINK
http://darrenjrobinson.com/
#>
[CmdletBinding()]
param()

$global:myToken = AuthN -credential $Credential -tenantID $TenantId # Refresh Access Token

try {
  # Get AAD B2B Pending Users.
  return (Invoke-RestMethod -Headers @{Authorization = "Bearer $($myToken.AccessToken)" } `
      -Uri  "https://graph.microsoft.com/beta/users?filter=externalUserState eq 'PendingAcceptance'&`$top=999" `
      -Method Get).value
}
catch { Write-Error $_ }
