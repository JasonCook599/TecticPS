<#PSScriptInfo

.VERSION 1.0.2

.GUID 77381afe-eae9-46c7-a8cc-8cc27e6bed62

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
Connect to FortiManager.

.PARAMETER Hostname
The FQDN or IP address of your FortiManager instance.

.PARAMETER Token
You FortiManager API token. If not specified, it will request one from FortiCloud.

.PARAMETER ADOM
The active ADOM. Defaults to "root".

.PARAMETER Port
The port FortiManager is running on. Defaults to 443.

.PARAMETER Scheme
The scheme FortiManager is running on. Defaults to https.

.PARAMETER URI
The full URI of FortiManager. You can specify this instead of Hostname, Port, and Scheme.
#>
param (
    [Parameter(ParameterSetName = 'Manual', 
        Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$Hostname ,

    [Parameter(Mandatory = $false)]
    [SecureString]$Token = (Get-FortiCloudOauthToken),

    [Parameter(Mandatory = $false)]
    [String]$ADOM = "root",

    [Parameter(ParameterSetName = 'Manual')]
    [ValidateSet('https', 'http', IgnoreCase = $true)]
    [string]$Scheme = 'https',

    [Parameter(ParameterSetName = 'Manual',
        Mandatory = $false)]
    [uint16]$Port = 443,

    [Parameter(ParameterSetName = 'URI',
        Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$URI
)

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

Initialize-FmgConfig -Overwrite
$FmgConfig.HostScheme = $uriBuilder.Scheme
$FmgConfig.Hostname = $uriBuilder.Host
$FmgConfig.HostPort = $uriBuilder.Port
$FmgConfig.Token = $Token
$FmgConfig.ADOM = $ADOM

[Uri]$loginUrl = ([System.UriBuilder]::new($FmgConfig.HostScheme, $FmgConfig.Hostname, $FmgConfig.HostPort, "p/forticloud_jsonrpc_login/")).Uri.AbsoluteUri

if ($uriBuilder.Scheme -eq 'http') {
    Write-Warning "Connecting via HTTP. This is not secure. All data will be transmitted in plaintext."
}

$loginBody = @{
    access_token = ConvertFrom-SecureString -SecureString $Token -AsPlainText
} | ConvertTo-Json

try {
    $Response = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $loginBody -ContentType "application/json"
    [SecureString]$FmgConfig.Session = ConvertTo-SecureString  -AsPlainText -Force -String $Response.session
    Write-Verbose "Successfully established FMG Session Token."
}
catch {
    Write-Error "Failed FMG Cloud Login: $_"
    exit
}

[bool]$FmgConfig.Connected = (Test-FmgSession -SkipConnectionCheck)

return $FmgConfig
