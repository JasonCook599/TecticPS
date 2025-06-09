<#PSScriptInfo

.VERSION 1.1.8

.GUID 0775cf89-1a99-44ec-ac4e-7c80c95d87a2

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
This script removes the files leftover from a VCRedist from VC++ 2008 install.

.DESCRIPTION
This script will remove the extra files from a VCRedist from VC++ 2008 install, as per https://support.microsoft.com/en-ca/help/950683/vcredist-from-vc-2008-installs-temporary-files-in-root-directory

.LINK
https://support.microsoft.com/en-ca/help/950683/vcredist-from-vc-2008-installs-temporary-files-in-root-directory

.PARAMETER Drive
The drive from which to remove the files. If unspecified, the System Drive is used.

.EXAMPLE
Clean-VCRedist

.EXAMPLE
Clean-VCRedist.ps1 -Drive D
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [string]$Drive = $env:SystemDrive
)

$Files = "install.exe", "install.res.1028.dll", "install.res.1031.dll", "install.res.1033.dll", "install.res.1036.dll", "install.res.1040.dll", "install.res.1041.dll", "install.res.1042.dll", "install.res.2052.dll", "install.res.3082.dll", "vcredist.bmp", "globdata.ini", "install.ini", "eula.1028.txt", "eula.1031.txt", "eula.1033.txt", "eula.1036.txt", "eula.1040.txt", "eula.1041.txt", "eula.1042.txt", "eula.2052.txt", "eula.3082.txt", "VC_RED.MSI", "VC_RED.cab"
Foreach ($File in $Files) { Remove-Item $Drive\$File -ErrorAction SilentlyContinue }
