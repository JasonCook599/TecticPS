<#PSScriptInfo
.VERSION 1.0.1
.GUID 70496d42-6d10-460f-9e42-132a6b70e09d

.AUTHOR
Jason Cook
Vincent Christiansen - vincent@sameie.com

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
This will store a password to the specified file.

.PARAMETER Path
The location the password will be stored.

.EXAMPLE
Store-Password

.EXAMPLE
Store-Password -Path .\Password.txt

.LINK
http://www.sameie.com/2017/10/05/create-hashed-password-file-for-powershell-use/
#>
param(
  [string]$Path = ".\Password.txt",
  [pscredential]$credential = (Get-Credential)
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
$Credential.Password | ConvertFrom-SecureString | Set-Content $Path
