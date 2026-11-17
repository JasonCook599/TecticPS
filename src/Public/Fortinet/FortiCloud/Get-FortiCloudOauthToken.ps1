<#PSScriptInfo

.VERSION 1.0.2

.GUID 841134f9-fc1b-42fb-a1bf-a88bca5731fd

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
Get OAuth token from FortiCloud

.PARAMETER clientId
FortiCloud OAuth client ID

.PARAMETER Credential
FortiCloud username and password.

.PARAMETER oauthUrl
The FortiCloud OAuth URL. 
#>
param (
    [string]$clientId,
    [PSCredential]$Credential,
    [uri]$oauthUrl = "https://customerapiauth.fortinet.com/api/v1/oauth/token/"
)
Write-Debug "Gererating request body."
$Body = @{
    username   = $Credential.UserName
    password   = ConvertFrom-SecureString -SecureString $Credential.Password -AsPlainText
    client_id  = $clientId
    grant_type = "password"
} | ConvertTo-Json

try {
    Write-Verbose "Getting FortiCloud OAuth Token"
    $Response = Invoke-RestMethod -Uri $oauthUrl -Method Post -Body $Body -ContentType "application/json"
    [SecureString]$Token = ConvertTo-SecureString  -AsPlainText -Force -String $Response.access_token
    Write-Verbose "Successfully acquired OAuth Token."
}
catch {
    Write-Error "Failed to retrieve OAuth token: $_"
    exit
}

return [SecureString]$Token
