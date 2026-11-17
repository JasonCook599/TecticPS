<#PSScriptInfo

.VERSION 1.0.2

.GUID 64fcef89-4be3-4471-86c8-9415312540d5

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
Invoke a FortiManager JSON RPC API call.

.PARAMETER url
The API url endpoint you ware calling

.PARAMETER method
The JSON RPC method for the API call.

.PARAMETER SkipConnectionCheck
Don't check that you are connected for FortiManager before sending the request.

.PARAMETER Data
The data to pass in the API call.

.PARAMETER Body
A custom body to send. This is typically generated automatically with the session token and other required information.

#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $false)]
    [String]$url,

    [Parameter(Mandatory = $false)]
    [String]$method = "get",

    [Parameter(Mandatory = $false)]
    [switch]$SkipConnectionCheck,

    [Parameter(Mandatory = $false)]
    [PSCustomObject]$Data,

    [Parameter(Mandatory = $false)]
    [array]$Body    
)

if (-not ( $FmgConfig.Connected -or $SkipConnectionCheck)) { throw "You must run Connect-Fmg first." }

[Uri]$rpcUrl = ([System.UriBuilder]::new($FmgConfig.HostScheme, $FmgConfig.Hostname, $FmgConfig.HostPort, "jsonrpc")).Uri.AbsoluteUri

if (-not $Body) {
    $Body = @{
        id      = 1
        session = ConvertFrom-SecureString -SecureString $FmgConfig.Session -AsPlainText
        method  = $method
        params  = @(
            @{ 
                url  = $url
                data = [PSCustomObject]$Data
            }
        )
    }
    $Body = $Body | ConvertTo-Json -Depth 100
}

if ($PSCmdlet.ShouldProcess($url)) {
    try {
        Write-Debug "[$url] Invoking API call."
        $Response = Invoke-RestMethod -Uri $rpcUrl -Method Post -Body $Body -ContentType "application/json"

        if ($Response.result.status.code -ne 0) {
            Write-Error "FMG returned an API status error: $($Response.result.status.message)"
            return $Response.result.status
        }
        else {
            Write-Verbose "[$url] Success."
            return $Response.result.data
        }
    }
    catch { Write-Error "Failed to execute JSON-RPC request: $_" }
    
}
else { return $Body }
