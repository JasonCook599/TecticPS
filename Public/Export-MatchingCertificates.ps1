<#PSScriptInfo

.VERSION 1.0.5

.GUID 31c7075a-49f8-4f99-ad29-aa9d83ab8dc3

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
.SYNOPSIS
This script will fetch all certificates matching the chosen template.

.DESCRIPTION
This script will fetch all certificates matching the chosen template. Usefull for adding certificate to Trusted Publishers.

.PARAMETER Path
The location the certificates will be exported to.

.PARAMETER CertificationAuthority
The servername of the certification authority which issued the certificates.

.PARAMETER Date
Filter based on expiry date. By default, the current date will be used.

.PARAMETER Templates
A list of the templates to search for.

.LINK
https://github.com/PKISolutions/PSPKI
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateScript( { Test-Path $_ })][string]$Path = (Get-Location),
  [string]$CertificationAuthority = ((Get-CA | Select-Object Computername).Computername),
  $Date = (Get-Date),
  $Templates
)
Requires -Modules PSPKI

if (-not $Templates) { throw "You must specify the templates to search for." }
$Templates | Foreach-Object {
  Write-Verbose "Searching for $_"
  Get-IssuedRequest -CertificationAuthority $CertificationAuthority -Property RequestID, RawCertificate, Request.RequesterName, CertificateTemplate -Filter "NotAfter -ge $Date", "CertificateTemplate -eq $_" | ForEach-Object {
    $OutPath = Join-Path -Path $Path -ChildPath ("$($_.RequestID)-$($_.CommonName).crt")
    Write-Verbose "Found $($_.RequestID)-$($_.CommonName). Writing to $OutPath"
    Set-Content -Path $OutPath -Value ("-----BEGIN CERTIFICATE-----`n" + $_.RawCertificate + "-----END CERTIFICATE-----")

    $OutPath = (Get-Item $OutPath).FullName # Needed for use with PS drives
    $Thumbprint = (New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $OutPath).Thumbprint
    $Destination = Join-Path -Path (Split-Path -Path $OutPath -Parent) -ChildPath ("\$($_.RequestID)-$($_.CommonName)-$Thumbprint.crt")
    Write-Verbose "Moving file from $OutPath to $Destination"
    Move-Item -Path $OutPath -Destination $Destination
  }
}
