<#PSScriptInfo

.VERSION 1.0.2

.GUID 8ccdb627-b33f-4be2-b6e0-f9cb992ee398

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
Return the product key stored in the UEFI bios.
#>
return (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
