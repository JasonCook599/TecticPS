<#PSScriptInfo

.VERSION 1.0.10

.GUID 0fef518a-4c3a-40e1-ad0c-95c442574793

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
Get all DHCP reservations in Netbox.

.PARAMETER baseUrl
The base URL for the netbox API

.PARAMETER token
The API token used for authentication.

.PARAMETER Endpoint
The REST API endpoint you want to hit.

.PARAMETER Body
Body request parameters.

.PARAMETER Method
HTTP method. Defaults to GET.

.PARAMETER Headers
HTTP headers for the request.

.PARAMETER Uri
The full URI to hit. By default generated from baseUrl and Endpoint
#>
param (
  $baseUrl,
  $token,
  $Endpoint, 
  $Body,
  $Method = "Get",
  $Headers = @{
    "Accept"        = "application/json"
    "Authorization" = "Token $Token"
  },
  $Uri = "$baseUrl/api/$Endpoint/",
  [int]$limit = 1000
)

  
if ($null -eq $Body.limit) {
  if ($null -eq $Body) { 
    Write-Verbose "[$Endpoint] Empty body. Setting result limit."
    $Body = @{limit = $limit } 
  } 
  else { 
    Write-Verbose "[$Endpoint] Empty limit in body. Setting result limit."
    $Body.limit = $limit 
  }
}

Write-Verbose "[$Endpoint] Getting all results."
do {
  $Response = Invoke-RestMethod -Uri $Uri -Headers $Headers -Method $Method -Body $Body
  
  $Results += $Response.results
  try { [System.Uri]$Uri = $Response.next }
  catch { return $Response }

} while ($null -ne $Uri)
return $Results
