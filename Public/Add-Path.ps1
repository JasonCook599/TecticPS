<#PSScriptInfo

.VERSION 1.0.7

.GUID bcbc3792-1f34-4100-867c-6fcf09230520

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
This will add a location to enviroment PATH.

.PARAMETER Path
The path to add.

.PARAMETER Machine
This will modify the machine path instead of the user's path.

.PARAMETER Force
This will override check of the maximum length.

.PARAMETER MaxLength
The maximum supported length for the PATH.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [Parameter(Mandatory = $true)][ValidateScript({ Test-Path -Path $_ -PathType Container })][string]$Path,
  [switch]$Machine,
  [switch]$Force,
  [ValidateRange(1, [int]::MaxValue)][int]$MaxLength = 1024
)

if ($Machine) {
  Write-Verbose "Adding `"$Path`" to system PATH"
  Test-Admin -Throw
  $Registry = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
}
else {
  Write-Verbose "Adding `"$Path`" to user PATH"
  $Registry = "Registry::HKCU\Environment\"
}

$NewPath = (Get-ItemProperty -Path $Registry -Name PATH).Path + ";" + $Path

Write-Verbose "PATH length is $($NewPath.length)"
if ($NewPath.length -gt $MaxLength -and (-not $Force)) {
  throw "Path is longer than $MaxLength characters. Paths this long may not behave as expected. Run with -Force to override."
}

Set-ItemProperty -Path $Registry -Name PATH -Value $NewPath -Verbose
