<#PSScriptInfo

.VERSION 1.0.7

.GUID 69467669-0324-4e1a-88bb-671624f015ff

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
Creates a new git version tag

.PARAMETER Version
The version name specified.
.PARAMETER Path
The location of the Git repository. Default to the current directory.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [string]$Module = (Get-Command -Name $MyInvocation.MyCommand.Name).Source,
  [version]$Version = [version](Test-ModuleManifest ./dist/$Module/$Module.psd1).Version,
  [switch]$SkipPush
)

if ($Path) { Push-Location -Path $Path }

If ($PSCmdlet.ShouldProcess("$Version")) {
  git tag -a "v$Version" -m "Release version $Version"
  if (-not $SkipPush) { git push origin "v$Version" }
}

if ($Path) { Pop-Location }















