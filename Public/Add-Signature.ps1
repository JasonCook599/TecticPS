<#PSScriptInfo

.VERSION 1.1.4

.GUID 9be6c147-e71b-44c4-b265-1b685692e411

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
This script will sign Powershell scripts with the availble code signing certificate.

.PARAMETER Path
This is the file or folder containing files to sign. If unspecified, it will run in the current folder.

.PARAMETER Filter
Use this to limit the search to spesific files. If unspesified, "*.ps1" will be used.

.PARAMETER Certificate
The certificate to use when signing. If unspesified, the first code signing certificate in the personal store will be used.

.PARAMETER Name
Used as the signing name when signing an executable file. If unspecified, will the current user's company.

.EXAMPLE
.\Sign-Script.ps1 -All
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript( { Test-Path -Path $_[0] })][array]$Path = (Get-Location),
  [string]$Filter = "*.ps*1",
  [ValidateScript( { Test-Certificate $_ })][System.Security.Cryptography.X509Certificates.X509Certificate]$Certificate = ((Get-ChildItem cert:currentuser\my\ -CodeSigningCert | Sort-Object NotBefore -Descending)[0]),
  [string]$Description = "Signed by " + (([ADSISearcher]"(&(objectCategory=User)(SAMAccountName=$env:username))").FindOne().Properties).company,
  [string]$SigntoolPath = "signtool.exe",
  [switch]$Append,
  [string]$Url,
  [string]$Algorithm = "SHA256"
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Get-ChildItem -File -Path $Path -Filter $Filter | ForEach-Object {
  If (([System.IO.Path]::GetExtension($_.FullName) -like ".ps*1")) { Set-AuthenticodeSignature -FilePath $_.FullName -Certificate $Certificate }
  elseif ([System.IO.Path]::GetExtension($_.FullName) -eq ".exe" -or [System.IO.Path]::GetExtension($_.FullName) -eq ".cat") {
    $Arguments = @("sign")
    if ($Append) { $Arguments += "/as" }
    if ($Url) { $Arguments += "/du `"$Url`"" }
    if ($Description) { $Arguments += "/d `"$Description`"" }
    if ($Algorithm) { $Arguments += "/fd `"$Algorithm`"" }
    $Arguments += "/i `"$(($Certificate.Issuer -split ", " | ConvertFrom-StringData).CN)`"" # Issuer
    $Arguments += "/n `"$(($Certificate.SubjectName.Name -split ", " | ConvertFrom-StringData).CN)`"" # Subject Name
    $Arguments += "/sha1 $($Certificate.Thumbprint)"
    $Arguments += "`"$($_.FullName)`""
    Write-Verbose "Running $SigntoolPath $($Arguments -join " ")"
    If ($PSCmdlet.ShouldProcess($_.FullName, "Add-Signature using $($Certificate.Thumbprint)")) {
      Start-Process -NoNewWindow -Wait -FilePath $SigntoolPath -ArgumentList $Arguments
    }
  }
  else { Write-Error "We don't know how to handle this file type: ($([System.IO.Path]::GetExtension($_.Name))" }

}
