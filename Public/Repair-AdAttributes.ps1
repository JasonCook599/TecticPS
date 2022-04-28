<#PSScriptInfo
.VERSION 1.0.0
.GUID d2351cd7-428e-4c43-ab8e-d10239bb9d23

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.SYNOPSIS
Repair attributes for user in Active Directory.

.DESCRIPTION
Repair attributes for user in Active Directory. The following actions will be performed.
 - Remove legacy Exchange attributes
 - Remove legacy proxy addresses
 - Remove proxy addresses if only one proxy address exists.
 - Clear mailNickname if mail attribute is empty.
 - Set mailNickname to SamAccountName
 - Set title to mail attirubte for shared mailboxes. This is used for better display in SharePoint.
 - Clear telephoneNumber attribute if mail atrribute is empty
 - Set telephoneNumber attribute to main line and extension, if present.
#>
<# TODO Add paramateres to limit which actions are performed.#>
[CmdletBinding(SupportsShouldProcess = $true)]
param ()
Write-Verbose "Removing legacy attributes for users"
Get-ADUser -Filter *  | Sort-Object  SamAccountName, UserPrincipalName | Set-ADUser -Clear msExchMailboxGuid, msexchhomeservername, legacyexchangedn, mailNickname, msexchmailboxsecuritydescriptor, msexchpoliciesincluded, msexchrecipientdisplaytype, msexchrecipienttypedetails, msexchumdtmfmap, msexchuseraccountcontrol, msexchversion, targetAddress
Write-Verbose "Remove legacy attributes for non-Office 365 groups"
Get-ADGroup -Filter * | Where-Object Name -notlike "Group_*" | Sort-Object  SamAccountName, UserPrincipalName | Set-ADGroup -Clear msExchMailboxGuid, msexchhomeservername, legacyexchangedn, mailNickname, msexchmailboxsecuritydescriptor, msexchpoliciesincluded, msexchrecipientdisplaytype, msexchrecipienttypedetails, msexchumdtmfmap, msexchuseraccountcontrol, msexchversion, targetAddress

Write-Verbose "Remove legacy proxy addresses for users"
Get-ADUser -Filter * -Properties ProxyAddresses | ForEach-Object { $Remove = $_.proxyaddresses | Where-Object { $_ -like "X500*" -or $_ -like "X400*" -or $_ -like "*@***REMOVED***CF.mail.onmicrosoft.com" }; ForEach ($proxyAddress in $Remove) { Write-Output "Removing $ProxyAddress"; Set-ADUser -Identity $_.Name -Remove @{'ProxyAddresses' = $ProxyAddress } } }
Write-Verbose "Remove legacy proxy addresses for non-Office 365 groups"
Get-ADGroup -Filter * -Properties ProxyAddresses | Where-Object Name -notlike "Group_*" | ForEach-Object { $Remove = $_.proxyaddresses | Where-Object { $_ -like "X500*" -or $_ -like "X400*" -or $_ -like "*@***REMOVED***CF.mail.onmicrosoft.com" }; ForEach ($proxyAddress in $Remove) { Write-Output "Removing $ProxyAddress"; Set-ADGroup -Identity $_.Name -Remove @{'ProxyAddresses' = $ProxyAddress } } }

Write-Verbose "Remove proxy addresses if only one exists for users"
Get-ADUser -Filter * -Properties ProxyAddresses | Where-Object { $_.ProxyAddresses.Count -eq 1 } | Set-ADUser -Clear ProxyAddresses
Write-Verbose "Remove proxy addresses if only one exists for non-Office 365 groups"
Get-AdGroup -Filter * -Properties ProxyAddresses | Where-Object Name -notlike "Group_*" | Where-Object { $_.ProxyAddresses.Count -eq 1 } | Set-ADGroup -Clear ProxyAddresses

Write-Verbose "Clear mailNickname if mail attribute empty for users"
Get-ADUser -Filter * -Properties mail, mailNickname | Where-Object mail -eq $null | Where-Object mailNickname -ne $null | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Clear mailNickname }
Write-Verbose "Clear mailNickname if mail attribute empty for non-Office 365 groups"
Get-ADGroup -Filter * -Properties mail, mailNickname | Where-Object mail -eq $null | Where-Object mailNickname -ne $null | Where-Object Name -notlike "Group_*" | ForEach-Object { Set-ADGroup -Identity $_.SamAccountName -Clear mailNickname }

Write-Verbose "Set mailNickname to SamAccountName for users"
Get-ADUser -Filter * -Properties mail, mailNickname | Where-Object mail -ne $null | Where-Object { $_.mailNickname -ne $_.SamAccountName } | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Replace @{mailNickname = $_.SamAccountName } }
Write-Verbose "Set mailNickname to SamAccountName for non-Office 365 groups"
Get-ADGroup -Filter * -Properties mail, mailNickname | Where-Object mail -ne $null | Where-Object { $_.mailNickname -ne $_.SamAccountName } | Where-Object Name -notlike "Group_*" | ForEach-Object { Set-ADGroup -Identity $_.SamAccountName -Replace @{mailNickname = $_.SamAccountName } }

Write-Verbose "Set title to mail attribute for general delivery mailboxes. Used to easily show address in Sharepoint"
Get-ADUser -Filter * -SearchBase 'OU=Mailboxes,OU=Mail Objects,OU=_***REMOVED***,DC=***REMOVED***,DC=local' -Properties mail | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Title $_.mail }
  
Write-Verbose "Clear telephoneNumber attribute if mail atrribute is empty"
Get-ADUser -Filter * -Properties ipPhone, mail, telephoneNumber | Where-Object mail -eq $null | Where-Object telephoneNumber -ne $null | Set-ADUser -Clear telephoneNumber
Write-Verbose "Set telephoneNumber attribute to main line if ipPhone attribute is empty"
Get-ADUser -Filter * -Properties ipPhone, mail, telephoneNumber | Where-Object mail -ne $null | Where-Object ipPhone -eq $null | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Replace @{telephoneNumber = "+1 5197447447" } }
Write-Verbose "Set telephoneNumber attribute to main line with extension if ipPhone attribute is present"
Get-ADUser -Filter * -Properties ipPhone, mail, telephoneNumber | Where-Object mail -ne $null | Where-Object ipPhone -ne $null | ForEach-Object { $telephoneNumber = "+1 5197447447 x" + $_.ipPhone.Substring(0, [System.Math]::Min(3, $_.ipPhone.Length)) ; Set-ADUser -Identity $_.SamAccountName -Replace @{telephoneNumber = $telephoneNumber } }