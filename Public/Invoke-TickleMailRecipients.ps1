<#PSScriptInfo

.VERSION 1.2.3

.GUID ece98adc-3c44-4a02-a254-d4e7f2888f4f

.AUTHOR Jason Cook Joseph Palarchio

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
.SYNOPSIS
Address Lists in Exchange Online do not automatically populate during provisioning and there is no "Update-AddressList" cmdlet.  This script "tickles" mailboxes, mail users and distribution groups so the Address List populates.

.DESCRIPTION
Address Lists in Exchange Online do not automatically populate during provisioning and there is no "Update-AddressList" cmdlet.  This script "tickles" mailboxes, mail users and distribution groups so the Address List populates.

Usage: Additional information on the usage of this script can found at the following blog post:  http://blogs.perficient.com/microsoft/?p=25536

Disclaimer:  This script is provided AS IS without any support. Please test in a lab environment prior to production use.

.LINK
http://blogs.perficient.com/microsoft/?p=25536
#>
param(
  $Mailboxes = (Get-Mailbox -Resultsize Unlimited),
  $MailUsers = (Get-MailUser -Resultsize Unlimited),
  $DistributionGroups = (Get-DistributionGroup -Resultsize Unlimited)
)

foreach ($Mailbox in $Mailboxes) {
  $count1++ ; Progress -Index $count1 -Total $Mailboxes.count -Activity "Tickling mailboxes. Step 1 of 3" -Name $Mailbox.alias
  Set-Mailbox $Mailbox.alias -SimpleDisplayName $Mailbox.SimpleDisplayName -WarningAction silentlyContinue
}

foreach ($MailUser in $MailUsers) {
  $count2++ ; Progress -Index $count2 -Total $MailUsers.count -Activity "Tickling mail users. Step 2 of 3" -Name $Mailuser.alias
  Set-MailUser $Mailuser.alias -SimpleDisplayName $Mailuser.SimpleDisplayName -WarningAction silentlyContinue
}

foreach ($DistributionGroup in $DistributionGroups) {
  $count3++ ; Progress -Index $count3 -Total $DistributionGroups.count -Activity "Tickling distribution groups. Step 3 of 3" -Name $DistributionGroup.alias
  Set-DistributionGroup $DistributionGroup.alias -SimpleDisplayName $DistributionGroup.SimpleDisplayName -WarningAction silentlyContinue
}
