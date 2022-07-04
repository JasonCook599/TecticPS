<#PSScriptInfo

.VERSION 1.0.4

.GUID d2351cd7-428e-4c43-ab8e-d10239bb9d23

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

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [switch]$LegacyExchange,
    [switch]$LegacyProxyAddresses,
    [switch]$ExtraProxyAddresses,
    [switch]$ClearMailNickname,
    [switch]$SetMailNickname,
    [switch]$ClearTelephoneNumber,
    [switch]$SetTelephoneNumber,
    [string]$OnMicrosoft,
    [string]$DefaultPhoneNumber,
    [string]$Filter = "*",
    $LegacyExchangeAttributes = @("msExchMailboxGuid", "msexchhomeservername", "legacyexchangedn", "mailNickname", "msexchmailboxsecuritydescriptor", "msexchpoliciesincluded", "msexchrecipientdisplaytype", "msexchrecipienttypedetails", "msexchumdtmfmap", "msexchuseraccountcontrol", "msexchversion", "targetAddress"),
    $Properties = @("ProxyAddresses", "mail", "mailNickname", "ipPhone", "telephoneNumber"),
    [string]$SearchBase
)

while (!$DefaultPhoneNumber) { $DefaultPhoneNumber = Read-Host -Prompt "Enter the installer path." }

if ($SearchBase) {
    $Users = Get-ADUser -Properties $Properties -Filter $Filter -SearchBase $SearchBase
    $Groups = Get-ADGroup -Properties $Properties -Filter $Filter -SearchBase $SearchBase
}
else {
    $Users = Get-ADUser -Properties $Properties -Filter $Filter
    $Groups = Get-ADGroup -Properties $Properties -Filter $Filter
}

If ($PSCmdlet.ShouldProcess("Remove legacy exchange attributes") -and $LegacyExchange) {
    $Users | Set-ADUser -Clear $LegacyExchangeAttributes
    $Groups | Where-Object Name -notlike "Group_*" | Set-ADGroup -Clear $LegacyExchangeAttributes
}

If ($PSCmdlet.ShouldProcess("Remove legacy proxy addresses attributes") -and $LegacyProxyAddresses) {
    $Users | ForEach-Object {
        $Remove = $_.proxyaddresses | Where-Object { $_ -like "X500*" -or $_ -like "X400*" -or $_ -like $OnMicrosoft }
        ForEach ($proxyAddress in $Remove) {
            Write-Verbose "Removing $ProxyAddress from $($_.Name)"
            Set-ADUser -Identity $_.Name -Remove @{'ProxyAddresses' = $ProxyAddress }
        }
    }
    $Groups | Where-Object Name -notlike "Group_*" | ForEach-Object {
        $Remove = $_.proxyaddresses | Where-Object { $_ -like "X500*" -or $_ -like "X400*" -or $_ -like $OnMicrosoft }
        ForEach ($proxyAddress in $Remove) {
            Write-Verbose "Removing $ProxyAddress from $($_.Name)"
            Set-ADGroup -Identity $_.Name -Remove @{'ProxyAddresses' = $ProxyAddress }
        }
    }

}
If ($PSCmdlet.ShouldProcess("Clear ProxyAddresses if only one exists") -and $ExtraProxyAddresses) {
    $Users | Where-Object { $_.ProxyAddresses.Count -eq 1 } | Set-ADUser -Clear ProxyAddresses
    $Groups | Where-Object Name -notlike "Group_*" | Where-Object { $_.ProxyAddresses.Count -eq 1 } | Set-ADGroup -Clear ProxyAddresses
}

If ($PSCmdlet.ShouldProcess("Clear mailNickname if mail attribute empty") -and $ClearMailNickname) {
    $Users | Where-Object $null -eq mail | Where-Object mailNickname -ne $null | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Clear mailNickname }
    $Groups | Where-Object $null -eq mail | Where-Object mailNickname -ne $null | Where-Object Name -notlike "Group_*" | ForEach-Object { Set-ADGroup -Identity $_.SamAccountName -Clear mailNickname }
}

If ($PSCmdlet.ShouldProcess("Set mailNickname to SamAccountName") -and $SetMailNickname) {
    $Users | Where-Object $null -ne mail | Where-Object { $_.mailNickname -ne $_.SamAccountName } | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Replace @{mailNickname = $_.SamAccountName } }
    $Groups | Where-Object $null -ne mail | Where-Object { $_.mailNickname -ne $_.SamAccountName } | Where-Object Name -notlike "Group_*" | ForEach-Object { Set-ADGroup -Identity $_.SamAccountName -Replace @{mailNickname = $_.SamAccountName } }
}

If ($PSCmdlet.ShouldProcess("Clear telephoneNumber if mail empty") -and $ClearTelephoneNumber) {
    $Users | Where-Object $null -eq mail | Where-Object telephoneNumber -ne $null | Set-ADUser -Clear telephoneNumber
}

If ($PSCmdlet.ShouldProcess("Set telephoneNumber to default line and extension") -and $SetTelephoneNumber) {
    $Users | Where-Object $null -ne mail | ForEach-Object {
        if ($null -ne $_.ipphone) { $telephoneNumber = $DefaultPhoneNumber + " x" + $_.ipPhone.Substring(0, [System.Math]::Min(3, $_.ipPhone.Length)) }
        else { $telephoneNumber = $DefaultPhoneNumber }
        Set-ADUser -Identity $_.SamAccountName -Replace @{telephoneNumber = $telephoneNumber }
    }
}
