<#PSScriptInfo

.VERSION 1.0.11

.GUID 0e319076-a254-46aa-948c-203373b9e47d

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
This script will rename the computer based on the prefix and serial number.

.PARAMETER Prefix
The prefix to use for the computer name.

.PARAMETER Serial
The serial nubmer to use for the computer name.

.PARAMETER PrefixLenght
The length of the prefix. This is used to truncate the prefix so the total length is less than 15 characters.

.PARAMETER NewName
The new name to use for the computer.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "Password")]
param (
  [string]$Prefix,
  [string]$User,
  [string]$Password,
  $NewName = (Get-NewComputerName -Prefix $Prefix)
)

$Arguments = @{}
if ($NewName) { $Arguments.NewName = $NewName }
if ($User -and $Password) {
  [SecureString]$SecurePassword = ($Password | ConvertTo-SecureString -AsPlainText -Force)
  [PSCredential]$DomainCredential = (New-Object System.Management.Automation.PSCredential -ArgumentList $User, $SecurePassword)
  $Arguments.DomainCredential = $DomainCredential
}

Write-Verbose "Renaming computer to `'$NewName`'"
try { return Rename-Computer @Arguments -ErrorAction Stop }
catch [System.InvalidOperationException] {
  if ($_.FullyQualifiedErrorId -eq "NewNameIsOldName,Microsoft.PowerShell.Commands.RenameComputerCommand") {
    Write-Verbose "Computer already has the name `'$NewName`'"
    return $null
  }
  else { throw $_ }
}
