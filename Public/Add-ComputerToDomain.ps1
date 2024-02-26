<#PSScriptInfo

.VERSION 1.0.3

.GUID 847616c6-fd6a-4685-b96f-ff8446a849e0

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
This script will add the computer to the domain.

.PARAMETER Domain
The domain to join.

.PARAMETER User
The domain user with crednetials to join the domain.

.PARAMETER Password
The password for the domain user.

.PARAMETER OU
The OU to add the computer to.

.PARAMETER SecurePassword
The password for the domain user as a secure string.

.PARAMETER Credentials
The credentials object to use for the join.
#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "Password")]
param(
    [string]$Domain,
    [string]$User,
    [string]$Password,
    [string]$OU,
    [SecureString]$SecurePassword = ($Password | ConvertTo-SecureString -AsPlainText -Force),
    [pscredential]$Credentials = (New-Object System.Management.Automation.PSCredential -ArgumentList $User, $SecurePassword)
)

if ($OU) { Add-Computer -DomainName $Domain -Credential $Credentials -Force -OU $OU }
else { Add-Computer -DomainName $Domain -Credential $Credentials -Force }
