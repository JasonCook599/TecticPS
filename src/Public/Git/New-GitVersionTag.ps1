<#PSScriptInfo

.VERSION 1.0.9

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
.PARAMETER Module
The name of the module to generate the manifest path.
.PARAMETER Branch
The name of the branch to switch to.
.PARAMETER SkipPull
Don't pull before creating the version tag.
.PARAMETER SkipPush
Don't push the tag after creation.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [string]$Module = (Get-Command -Name $MyInvocation.MyCommand.Name).Source,
  
  [Parameter(Mandatory = $true)]
  [version]$Version = [version](Test-ModuleManifest ./dist/$Module/$Module.psd1).Version,
  
  [string]$Branch = "main",

  [switch]$SkipPull, [switch]$SkipPush
)

if ($Path) { Push-Location -Path $Path }

If ($PSCmdlet.ShouldProcess("$Version")) {
  if ( $Branch) { git switch $([string]$Branch) }
  if (-not $SkipPull) { git pull }
  git tag -a "v$Version" -m "Release version $Version"
  if (-not $SkipPush) { git push origin "v$Version" }
}

if ($Path) { Pop-Location }

















