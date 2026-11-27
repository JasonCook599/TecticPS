<#PSScriptInfo

.VERSION 1.0.1

.GUID a55c2dfe-dfdf-4222-bfe2-cbf122a8540d

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
Rotates the keys for a Cloudflare Stream live input.

.PARAMETER AccountId
Your Cloudflare account identifier.
.PARAMETER InputId
Your live input identifier.
.PARAMETER Token
Your Cloudflare API token, usually starting with cfut_, cfat_, or cgk_.
.LINK
https://developers.cloudflare.com/changelog/post/2026-07-30-rotate-stream-broadcast-keys/
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [string]$AccountId,
  [string]$InputId,
  [securestring]$Token
)

if ($PSCmdlet.ShouldProcess($InputId)) {
  $Uri = "https://api.cloudflare.com/client/v4/accounts/$AccountId/stream/live_inputs/$InputId/rotate_keys"
  $response = Invoke-RestMethod -Uri $Uri -Method Post -Headers $headers -Authentication Bearer -Token $Token -ContentType "application/json"
  return $Response.result
}

