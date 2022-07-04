<#PSScriptInfo

.VERSION 1.0.2

.GUID 97314a7e-aba8-41e8-8b1d-ca81372ae070

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
Update the office cache for each XML file in the current folder.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    $Path = (Get-ChildItem -Filter "*.xml"),
    $Setup = ".\setup.exe"
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Path | ForEach-Object {
    If ($PSCmdlet.ShouldProcess("$($_.Name)", "Update-OfficeCache")) {
        Start-Process -FilePath $Setup -ArgumentList @("\download", $_.FullName) -NoNewWindow -Wait
    }
}
