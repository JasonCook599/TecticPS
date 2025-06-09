<#PSScriptInfo

.VERSION 1.0.4

.GUID f3ba5497-54b4-4b33-8c6f-33a678f5551c

.AUTHOR Jason Cook Laeeq Qazi - www.HostingController.com

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
This script will get all email addresses for the organization.

.DESCRIPTION
This script will get all email addresses for the organization. It is based on the answer located here: https://social.technet.microsoft.com/Forums/exchange/en-US/a234ba3b-37b4-4333-8954-5f46885c5e20/how-to-list-email-addresses-and-aliases-for-each-user?forum=exchangesvrgenerallegacy

.LINK
https://social.technet.microsoft.com/Forums/exchange/en-US/a234ba3b-37b4-4333-8954-5f46885c5e20/how-to-list-email-addresses-and-aliases-for-each-user?forum=exchangesvrgenerallegacy
#>

# Get mailgoxes and iterate through each email address and shows it either primary or an alias
Get-Mailbox | ForEach-Object {
  $host.UI.Write("Blue", $host.UI.RawUI.BackgroundColor, "'nUser Name: " + $$.DisplayName + "'n")
  For ($i = 0; $i -lt $_.EmailAddresses.Count; $i++) {
    $Address = $_.EmailAddresses[$i]
    $host.UI.Write("Blue", $host.UI.RawUI.BackGroundColor, $address.AddressString.ToString() + "`t")
    If ($Address.IsPrimaryAddress) {
      $host.UI.Write("Green", $host.UI.RawUI.BackGroundColor, "Primary Email Address`n")
    }
    Else {
      $host.UI.Write("Green", $host.UI.RawUI.BackGroundColor, "Alias`n")
    }
  }
}
