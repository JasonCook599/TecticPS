<#PSScriptInfo

.VERSION 1.2.7

.GUID 309e82fe-9a41-4ba2-afb4-8ef85e0fe38d

.AUTHOR Jason Cook

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) ***REMOVED*** 2022

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#> 

<#
.DESCRIPTION
This will import the current Forti Client configuration.

.PARAMETER Path
The location the configuration will be imported from.

.EXAMPLE
Import-FortiClientConfig -Path backup.conf

.LINK
https://getmodern.co.uk/automating-the-install-of-forticlient-vpn-via-mem-intune
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    $Path = "backup.conf",
    [ValidateScript( { Test-Path -Path $_ })]$FCConfig = 'C:\Program Files\Fortinet\FortiClient\FCConfig.exe',
    [SecureString]$Password
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Arguments = ("-m all", ("-f " + $Path), "-o import", "-i 1")
if ($Password) { $Arguments += "-p $([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)))" }

if ($PSCmdlet.ShouldProcess($Path, "Import FortiClient Config")) {
    Start-Process -FilePath $FCConfig -ArgumentList $Arguments -NoNewWindow -Wait
}
