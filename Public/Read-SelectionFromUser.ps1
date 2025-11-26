<#PSScriptInfo

.VERSION 1.0.0

.GUID ca65435a-13a7-41be-8091-4316686da31c

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
  [Parameter(Mandatory = $true)][string[]]$Options,
  [Parameter(Mandatory = $true)][string]$Prompt,
  $Default
)

[int]$Response = 0;
[bool]$ValidResponse = $false

while (!($ValidResponse)) {
  [int]$OptionNo = 0

  Write-Host $Prompt -ForegroundColor DarkYellow
  If ($Default) { $DefaultPrompt = $Default } else { $DefaultPrompt = "None" }
  Write-Host "[0]: $DefaultPrompt"
  foreach ($Option in $Options) {
    $OptionNo += 1
    Write-Host ("[$OptionNo]: {0}" -f $Option)
  }

  if ([Int]::TryParse((Read-Host), [ref]$Response)) {
    if ($Response -eq 0) { return '' }
    elseif ($Response -le $OptionNo) { $ValidResponse = $true }
  }
}
return $Options.Get($Response - 1)