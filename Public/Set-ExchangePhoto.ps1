<#PSScriptInfo

.VERSION 1.0.4

.GUID 0887fff3-2d78-4028-8440-92c1196c6891

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
.SYNOPSIS
This will upload all profile photos to Office 365.

.DESCRIPTION
This will upload all profile photos to Office 365. It will match the filename to the mailbox identity. This can be used along with Set-AdPhotos to sync photos with Active Directory.

.PARAMETER Suffix
The suffix to add to the end of the mailbox identity. Can be used to upload for guest accounts.

.EXAMPLE
Set-ExchangePhoto -Path C:\Photos\

.EXAMPLE
Set-ExchangePhoto -Path C:\Photos\ -Suffix "_fabrikam.com#EXT#@contoso.com"
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [string]$Path = (Get-Location),
    [string]$Suffix
)

Requires ExchangeOnlineManagement

if (!(Get-ExchangeOnlineConnection)) { Connect-ExchangeOnline }

Get-ChildItem $Path | ForEach-Object {
    $User = [System.IO.Path]::GetFileNameWithoutExtension($_) + $Suffix
    If ($PSCmdlet.ShouldProcess($User, "Set-UserPhoto")) {
        return Set-UserPhoto -Identity $User -PictureData ([System.IO.File]::ReadAllBytes($_.FullName)) -Confirm:$false
    }
}
