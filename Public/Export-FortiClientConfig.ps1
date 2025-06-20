<#PSScriptInfo

.VERSION 1.2.12

.GUID 6604b9e8-5c58-4524-b094-07b549c2dad8

.AUTHOR Jason Cook

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
This will export the current Forti Client configuration.

.PARAMETER Path
The location the configuration will be exported to.

.EXAMPLE
Export-FortiClientConfig -Path backup.conf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  $Path = "backup.conf",
  [ValidateScript( { Test-Path -Path $_ })]$FCConfig = 'C:\Program Files\Fortinet\FortiClient\FCConfig.exe',
  [SecureString]$Password
)

$Arguments = ("-m all", ("-f " + $Path), "-o export", "-i 1")
if ($Password) { $Arguments += "-p $([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)))" }

if ($PSCmdlet.ShouldProcess($Path, "Export FortiClient Config")) {
  Start-Process -FilePath $FCConfig -ArgumentList $Arguments -NoNewWindow -Wait
}
