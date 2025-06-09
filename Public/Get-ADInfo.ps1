<#PSScriptInfo

.VERSION 1.0.6

.GUID 868aac51-6c72-482e-8b54-42a3c5f87596

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
.DESCRIPTION
The script can list and update UPN information for users.

.PARAMETER ListUpn
List the UPN for each user. Can be combined with -Filter.

.PARAMETER LikeUpn
Filters for a specific UPN. Must be used in conjunction with -ListUpn. This overrides -Filter.

.PARAMETER Filter
Filters the search based on the specified parameters.

.PARAMETER updateUpnSuffix
Updates the Upn. Must be used with -OldUpn and -NewUpn. Can be combined with -SearchBase

.PARAMETER oldUpnSuffix
Specifes the UPN to be changed from.

.PARAMETER newUpnSuffix
specified the UPN to change to.

.PARAMETER SearchBase
Specifies the search base for the command.

.EXAMPLE
Get-ADInfo.ps1 -listUpn
name       UserPrincipalName
----       -----------------
Jane Doe   Jane.Doe@domain1.com
John Doe   John.Doe@domain2.com

.EXAMPLE
Get-ADInfo.ps1 -listUpn -likeUpn domain2
name       UserPrincipalName
----       -----------------
John Doe   John.Doe@domain2.com

#>

param(
  [string]$Filter,
  [switch]$ListUpn,
  [string]$likeUpn,
  [switch]$updateUpnSuffix,
  [string]$oldUpnSuffix,
  [string]$newUpnSuffix,
  [string]$SearchBase
)

Test-Admin -Warn -Message "You are not running as an admin. Results may be incomplete."

Requires ActiveDirectory

If ($ListUpn) {
  If ($likeUpn) { $UpnFilter = "*" + $likeUpn + "*" }
  Elseif ($Filter) { $UpnFilter = $Filter }
  Else { $UpnFilter = "*" }

  Write-Verbose "Listing all users with a UPN like $UpnFilter. Sorting by UPN"
  return Get-ADUser -Filter { UserPrincipalName -like $UpnFilter } -Properties distinguishedName, UserPrincipalName | Select-Object name, UserPrincipalName | Sort-Object -Property UserPrincipalName
}

If ($updateUpnSuffix) {
  Write-Verbose "Setting old UPN, new UPN, and Search Base if not specified."
  $OldUpnSearch = "*" + $oldUpnSuffix
  Write-Verbose "Starting update..."
  checkAdmin
  Write-Information -MessageData "Changing UPN to $newUpnSuffix for all uses with a $oldUpnSuffix UPN in $searchBase." -InformationAction Continue
  Get-ADUser -Filter { UserPrincipalName -like $OldUpnSearch } -SearchBase $searchBase |
  ForEach-Object {
    $OldUpn = $_.UserPrincipalName
    $Upn = $_.UserPrincipalName -ireplace [regex]::Escape($oldUpnSuffix), $newUpnSuffix
    Set-ADUser -identity $_ -UserPrincipalName $Upn
    $NewUpn = $_.UserPrincipalName
    Write-Verbose "Changed $OldUpn to $NewUpn"
  }
}
