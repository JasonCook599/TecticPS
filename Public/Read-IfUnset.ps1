<#PSScriptInfo

.VERSION 1.0.0

.GUID 0c0021de-c7ae-4fca-81f8-f61bc444decb

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
.SYNOPSIS
This script will get a selection from the user.

.DESCRIPTION
This script will get a selection from the user.

#>

param (
  [Parameter(ValueFromPipeline = $true)]$Parameter,
  [Parameter(ValueFromPipeline = $true)][string]$Prompt,
  [Parameter(ValueFromPipeline = $true)]$Default,
  $List,
  [switch]$Hide
)

if (Get-Variable $Parameter -ErrorAction SilentlyContinue ) {
  $Attributes.$Parameter = (Get-Variable $Parameter).Value
}
else {
  if ([string]::IsNullOrWhiteSpace($Default)) {
    Write-Debug "Default value not specified. Using existing value."
    $Default = $($User.$Parameter -join (","))
  }
  elseif ($Default) {
    Write-Debug "Default value specified. Listing as first option."
    $Prompt += " [" + $Default.ToString() + "]"
  }

  if ($List) {
    Write-Debug "Getting list input from user."
    $Attributes.$Parameter = Read-SelectionFromUser -Options $List -Prompt $Prompt -Default $Default
  }
  elseif (-not $Hide) {
    Write-Debug "Getting text input from user."
    $Response = (Read-Host -Prompt $Prompt)
  }

  if ([string]::IsNullOrWhiteSpace($Response) -and $Default) {
    Write-Debug "Empty response. Using default option."
    $Response = $Default
  }
  if (-not [string]::IsNullOrWhiteSpace($Response)) {
    Write-Debug "Setting '$Parameter' to '$Response'"
    $Attributes.$Parameter = $Response
  }
}
