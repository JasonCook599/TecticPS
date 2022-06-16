<#PSScriptInfo

.VERSION 1.0.4

.GUID 0e319076-a254-46aa-948c-203373b9e47d

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
This script will rename the computer based on the prefix and serial number.

.PARAMETER Prefix
The prefix to use for the computer name.

.PARAMETER Serial
The serial nubmer to use for the computer name.

.PARAMETER PrefixLenght
The lenght of the prefix. This is used to truncate the prefix so the total length is less than 15 characters.

.PARAMETER NewName
The new name to use for the computer.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "Password")]
param (
    [string]$Prefix,
    [string]$User,
    [string]$Password,
    [string]$Serial = (Get-WmiObject win32_bios).Serialnumber,
    $PrefixLenght = ($(15 - $Serial.length), $Prefix.Length | Measure-Object -Minimum ).Minimum,
    $NewName = $Prefix.Substring(0, $PrefixLenght) + $Serial
)

if ($User -and $Password) {
    [SecureString]$SecurePassword = ($Password | ConvertTo-SecureString -AsPlainText -Force)
    [pscredential]$Credentials = (New-Object System.Management.Automation.PSCredential -ArgumentList $User, $SecurePassword)
    Write-Verbose "Renaming computer to `'$NewName`' as `'$User`'"
    return Rename-Computer -NewName $NewName -DomainCredential $Credentials
}
Write-Verbose "Renaming computer to `'$NewName`'"
return Rename-Computer -NewName $NewName