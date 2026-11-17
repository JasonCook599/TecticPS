<#PSScriptInfo

.VERSION 1.0.4

.GUID 3d565984-6763-4bc0-833c-b04092fda1ad

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
Get or refresh the access token.

#>
[

CmdletBinding(SupportsShouldProcess = $true)]
param (
  [Parameter(ParameterSetName = 'Manual', 
    Mandatory = $false)]
  [Alias('ApiHost')]
  [ValidateNotNullOrEmpty()]
  [string]$Hostname = "yeastar.dennisgroup.com" ,

  [Parameter(Mandatory = $false)]
  [PSCredential]$Credential,

  [Parameter(Mandatory = $false)]
  [String]$ADOM = "root",

  [Parameter(ParameterSetName = 'Manual')]
  [ValidateSet('https', 'http', IgnoreCase = $true)]
  [string]$Scheme = 'https',

  [Parameter(ParameterSetName = 'Manual',
    Mandatory = $false)]
  [Alias('ApiPort')]
  [uint16]$Port = 443,

  [Parameter(ParameterSetName = 'URI',
    Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]$URI,


  [switch]$Refresh,
  [switch]$Revoke
)

Initialize-YSApiConnection -Overwrite

switch ($PSCmdlet.ParameterSetName) {
  'Manual' {
    $uriBuilder = [System.UriBuilder]::new($Scheme, $Hostname, $Port)
  }
  'URI' {
    $uriBuilder = [System.UriBuilder]::new($URI)
    if ([string]::IsNullOrWhiteSpace($uriBuilder.Host)) {
      throw "URI appears to be invalid. Must be in format [host.name], [scheme://host.name], or [scheme://host.name:port]"
    }
  }
}

[string]$YSApiConnection.HostScheme = $uriBuilder.Scheme
[string]$YSApiConnection.Hostname = $uriBuilder.Host
[uint16]$YSApiConnection.HostPort = $uriBuilder.Port
[pscredential]$YSApiConnection.Credential = $Credential

if ($uriBuilder.Scheme -eq 'http') {
  Write-Warning "Connecting via HTTP. This is not secure. All data will be transmitted in plaintext."
}

[Uri]$baseUrl = ([System.UriBuilder]::new($YSApiConnection.HostScheme, $YSApiConnection.Hostname, $YSApiConnection.HostPort, "/openapi/v1.0/")).Uri.AbsoluteUri

if ($null -eq $Credential -and $null -ne $YSApiConnection.Credential) { 
  Write-Verbose "Credential not specified. Using existing session credential."
  $Credential = $YSApiConnection.Credential 
}



if ($Revoke) {
  Write-Verbose "Revoking the token."
  $params = @{
    Uri             = [System.Uri]::new($baseUrl, "del_token?access_token=$($YSApiConnection.access_token)")
    Method          = "GET"
    ContentType     = 'application/json'
    UseBasicParsing = $true
  }
  $Result = Invoke-WebRequest @params
  Initialize-YSApiConnection -Overwrite
}
elseif (
  $null -ne $YSApiConnection.refresh_token -and #Refresh token exists
  $Refresh -or ( #Refresh requested
    $YSApiConnection.access_token_expire_time -le (Get-Date).AddMinutes(5) -and #Access token expiring soon
    $YSApiConnection.refresh_token_expire_time -gt (Get-Date).AddMinutes(-5) #Refresh token not expired
  )
) {
  Write-Verbose "Refreshing the existing token."
  $params = @{
    Uri             = [System.Uri]::new($baseUrl, "refresh_token")
    Method          = "POST"
    Body            = @{
      refresh_token = $YSApiConnection.refresh_token
    } | ConvertTo-Json
    ContentType     = 'application/json'
    UseBasicParsing = $true
  }
  $Result = Invoke-WebRequest @params
}
elseif ($Refresh -and $null -ne $YSApiConnection.Credential) {
  Write-Verbose "Token expired, getting a new one."
  return Connect-YSAPI -Credential $YSApiConnection.Credential -Hostname $YSApiConnection.ApiHost -Scheme $YSApiConnection.HostScheme -Port $YSApiConnection.HostPort
}
elseif ($YSApiConnection.access_token_expire_time -gt (Get-Date).AddMinutes(-5)) {
  $TokenLifetime = (New-TimeSpan -Start (Get-Date) -End $YSApiConnection.access_token_expire_time).Minutes
  Write-Debug "Token still valid for $TokenLifetime minutes. Doing nothing. Use -Refresh to override."
  return
}
else {
  Write-Verbose "Getting a new token."
  $params = @{
    Uri             = [System.Uri]::new($baseUrl, "get_token")
    Method          = "POST"
    Body            = @{
      Username = $YSApiConnection.Credential.UserName
      Password = $YSApiConnection.Credential.GetNetworkCredential().Password
    } | ConvertTo-Json
    ContentType     = 'application/json'
    UseBasicParsing = $true
  }
  $Result = Invoke-WebRequest @params
}

if ($Result.StatusCode -ne 200) {
  Write-Warning "An error occurred."
  throw "Failed. Status code: $($result.StatusCode)"
}

$Content = $Result.Content | ConvertFrom-Json
if ($Content.errcode -ne 0 -or $Content.errmsg -ne "SUCCESS") { throw "Failed. Error Message: $($Content.errmsg)" }
if ($Revoke) { return $Content.errmsg }

[datetime]$YSApiConnection.access_token_expire_time = (Get-Date).AddSeconds($Content.access_token_expire_time)
[string]$YSApiConnection.access_token = $Content.access_token
[datetime]$YSApiConnection.refresh_token_expire_time = (Get-Date).AddSeconds($Content.refresh_token_expire_time)
[string]$YSApiConnection.refresh_token = $Content.refresh_token
[bool]$YSApiConnection.Connected = $true

return $YSApiConnection

