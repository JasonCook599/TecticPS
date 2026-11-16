<#PSScriptInfo

.VERSION 1.0.3

.GUID ba7e96d7-1170-4cc0-9e58-4062d6821790

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
This will reset the current directory to the specified Git branch.

.PARAMETER Branch
The name of the branch to set to.

.PARAMETER Path
The location of the Git repository. Default to the current directory.
#>

param(
  [string]$Branch = "master",
  [ValidateScript( { Test-Path $_ -PathType Container })][string]$Path
)

if ($Path) { Push-Location -Path $Path }
git clean -fd
git fetch origin
git checkout $Branch
git reset --hard origin/$Branch
Pop-Location
