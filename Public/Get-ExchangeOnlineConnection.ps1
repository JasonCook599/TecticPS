<#PSScriptInfo

.VERSION 1.0.3

.GUID 09be455e-f050-4430-a18e-fa5b4c346ba5

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) TectTectic

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
Test for a connection to Exchange Online.

.PARAMETER Session
Which session to test.

.LINK
https://www.reddit.com/r/PowerShell/comments/gupsze/comment/fsk09vo/?utm_source=share&utm_medium=web2x&context=3
#>
param($Session = (Get-PSSession | Where-Object { $_.Name -like "ExchangeOnlineInternalSession*" -and $_.State -eq "Opened" }))
if ($Session) { return $Session } else { return $null }
