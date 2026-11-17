<#PSScriptInfo

.VERSION 1.0.5

.GUID 97314a7e-aba8-41e8-8b1d-ca81372ae070

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2024

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

$Path | ForEach-Object {
  If ($PSCmdlet.ShouldProcess("$($_.Name)", "Update-OfficeCache")) {
    Push-Location -Path (Split-Path -Parent -Path $_.FullName)
    Start-Process -FilePath $Setup -ArgumentList @("/download", $_.Name) -NoNewWindow -Wait
    Pop-Location
  }
}
