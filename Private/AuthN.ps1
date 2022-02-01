<#
.SYNOPSIS
Authenticate to Azure AD and receieve Access and Refresh Tokens.

.DESCRIPTION
Authenticate to Azure AD and receieve Access and Refresh Tokens.

.PARAMETER tenantID
(required) Azure AD TenantID.

.PARAMETER credential
(required) ClientID and ClientSecret of the Azure AD registered application with the necessary permissions.

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