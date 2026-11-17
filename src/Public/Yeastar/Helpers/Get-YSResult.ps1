<#PSScriptInfo

.VERSION 0.0.24

.GUID 0b24bf46-65e0-4d89-a3c7-94c4019f06c3

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
Gets the result of the API call.

#>


param (
  [Parameter(ValueFromPipeline = $true)][string]$Endpoint,
  $Query,
  [ValidateSet('GET', 'POST', 'PATCH', 'DELETE')][string]$Method = 'GET',
  $Body,

  [Parameter(Mandatory = $false)]
  [switch]$SkipConnectionCheck
)

if (-not ($YSApiConnection.Connected -or $SkipConnectionCheck) ) { throw "Yeastar session not available. Please run Connect-YSAPI." }
elseif ($YSApiConnection.access_token_expire_time -le (Get-Date).AddMinutes(5)) { Connect-YSAPI -Refresh }

[Uri]$baseUrl = ([System.UriBuilder]::new($YSApiConnection.HostScheme, $YSApiConnection.Hostname, $YSApiConnection.HostPort, "/openapi/v1.0/")).Uri.AbsoluteUri

$Query = ConvertTo-QueryString -InputObject ($Query + @{access_token = $YSApiConnection.access_token })

$params = @{
  Uri    = [System.Uri]::new($baseUrl, "$Endpoint`?$Query")
  Method = $Method
}

if ($Body) { $Params["Body"] = $Body | ConvertTo-Json -Compress }

Write-Verbose "Requesting $($params.Uri) $($params.Body)"
$Result = Invoke-RestMethod @Params
if ($Result.errcode -ne 0) { throw $Result }
return $Result.Data



