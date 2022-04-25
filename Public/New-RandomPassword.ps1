<#PSScriptInfo
.VERSION 1.0.0
.GUID 1591ca01-1cf9-4683-9d24-fbd1f746f44c

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.SYNOPSIS
This will return a random password.

.DESCRIPTION
This will return a random password. The format of the password will be half lowercase, half uppercase, two numbers, and two symbols.

.PARAMETER Lenght
The lenght of the password to return.

.PARAMETER Characters
A string of characters to use.
#>
param (
  $length = 14
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$LengthAlpha = $Length - 4
$LengthLower = [math]::Max(0, $LengthAlpha / 2)
$LengthUpper = [math]::Max(0, $LengthAlpha - $LengthLower)
$Password = Get-RandomCharacters -length $LengthLower -characters "abcdefghiklmnoprstuvwxyz"
$Password += Get-RandomCharacters -length $LengthUpper -characters "ABCDEFGHKLMNOPRSTUVWXYZ"
$Password += Get-RandomCharacters -length 2 -characters "1234567890"
$Password += Get-RandomCharacters -length 2 -characters "!@#$%^&*()_+-=[]\{}|;:,./<>?"
Return $Password
