<#PSScriptInfo

.VERSION 1.0.6

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
.DESCRIPTION
Repair attributes for user in Active Directory.

.PARAMETER Actions
A array of actions to perform. By default, all actions except SetTelephoneNumber are performed.
 - Remove legacy Exchange attributes
 - Remove legacy proxy addresses
 - Remove proxy addresses if only one proxy address exists.
 - Clear mailNickname if mail attribute is empty.
 - Set mailNickname to SamAccountName
 - Set title to mail attirubte for shared mailboxes. This is used for better display in SharePoint.
 - Clear telephoneNumber attribute if mail atrribute is empty
 - Set telephoneNumber attribute to main line and extension, if present.

.PARAMETER SearchBase
The AD search base when gettings users and groups.

.PARAMETER Server
The AD server to search and run updates on.

.PARAMETER DefaltPhoneNumber
The default phone number to use when no phone number is already set.

.PARAMETER OnMicrosoft
The OnMicrosoft.com domain to remove from the proxy addresses.

.PARAMETER Filter
The AD filter when getting users and groups.

.PARAMETER LegacyExchangeAttributes
An array of the legacy exchange attributes to remove.

.PARAMETER Properties
An array of properties to search against.

#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [array]$Actions = @("LegacyExchange", "LegacyProxyAddresses", "ExtraProxyAddresses", "ClearMailNickname", "SetMailNickname", "ClearTelephoneNumber", "SetTelephoneNumber"),
    [string]$SearchBase,
    [string]$Server,
    [string]$DefaultPhoneNumber,
    [string]$OnMicrosoft,
    [string]$Filter = "*",
    $LegacyExchangeAttributes = @("msExchMailboxGuid", "msexchhomeservername", "legacyexchangedn", "mailNickname", "msexchmailboxsecuritydescriptor", "msexchpoliciesincluded", "msexchrecipientdisplaytype", "msexchrecipienttypedetails", "msexchumdtmfmap", "msexchuseraccountcontrol", "msexchversion", "targetAddress"),
    $Properties = @("ProxyAddresses", "mail", "mailNickname", "ipPhone", "telephoneNumber")
)

$SetAdOptions = @{}
if ($Server) { $SetAdOptions.Server = $Server }

$GetAdOptions = @{}
if ($SearchBase) { $GetAdOptions.SearchBase = $SearchBase }
if ($Server) { $GetAdOptions.Server = $Server }
if ($Properties) { $GetAdOptions.SearchBase = $Properties }
if ($Filter) { $GetAdOptions.Filter = $Filter } else { $GetAdOptions.Filter = "*" }

$Users = Get-ADUser -Properties $Properties -Filter $Filter @GetAdOptions
$Groups = Get-ADGroup -Properties $Properties -Filter $Filter @GetAdOptions

If ($PSCmdlet.ShouldProcess("Remove legacy exchange attributes") -and $Actions -contains "LegacyExchange") {
    $Users | Set-ADUser -Clear $LegacyExchangeAttributes @SetAdOptions
    $Groups | Where-Object Name -notlike "Group_*" | Set-ADGroup -Clear $LegacyExchangeAttributes @SetAdOptions
}

If ($PSCmdlet.ShouldProcess("Remove legacy proxy addresses attributes") -and $Actions -contains "LegacyProxyAddresses") {
    $Users | ForEach-Object {
        $Remove = $_.proxyaddresses | Where-Object { $_ -like "X500*" -or $_ -like "X400*" -or $_ -like $OnMicrosoft }
        ForEach ($proxyAddress in $Remove) {
            Write-Verbose "Removing $ProxyAddress from $($_.Name)"
            Set-ADUser -Identity $_.Name -Remove @{'ProxyAddresses' = $ProxyAddress } @SetAdOptions
        }
    }
    $Groups | Where-Object Name -notlike "Group_*" | ForEach-Object {
        $Remove = $_.proxyaddresses | Where-Object { $_ -like "X500*" -or $_ -like "X400*" -or $_ -like $OnMicrosoft }
        ForEach ($proxyAddress in $Remove) {
            Write-Verbose "Removing $ProxyAddress from $($_.Name)"
            Set-ADGroup -Identity $_.Name -Remove @{'ProxyAddresses' = $ProxyAddress } @SetAdOptions
        }
    }

}

If ($PSCmdlet.ShouldProcess("Clear ProxyAddresses if only one exists") -and $Actions -contains "ExtraProxyAddresses") {
    $Users | Where-Object { $_.ProxyAddresses.Count -eq 1 } | Set-ADUser -Clear ProxyAddresses @SetAdOptions
    $Groups | Where-Object Name -notlike "Group_*" | Where-Object { $_.ProxyAddresses.Count -eq 1 } | Set-ADGroup -Clear ProxyAddresses @SetAdOptions
}

If ($PSCmdlet.ShouldProcess("Clear mailNickname if mail attribute empty") -and $Actions -contains "ClearMailNickname") {
    $Users | Where-Object $null -eq mail | Where-Object mailNickname -ne $null | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Clear mailNickname } @SetAdOptions
    $Groups | Where-Object $null -eq mail | Where-Object mailNickname -ne $null | Where-Object Name -notlike "Group_*" | ForEach-Object { Set-ADGroup -Identity $_.SamAccountName -Clear mailNickname } @SetAdOptions
}

If ($PSCmdlet.ShouldProcess("Set mailNickname to SamAccountName") -and $Actions -contains "SetMailNickname") {
    $Users | Where-Object $null -ne mail | Where-Object { $_.mailNickname -ne $_.SamAccountName } | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Replace @{mailNickname = $_.SamAccountName } } @SetAdOptions
    $Groups | Where-Object $null -ne mail | Where-Object { $_.mailNickname -ne $_.SamAccountName } | Where-Object Name -notlike "Group_*" | ForEach-Object { Set-ADGroup -Identity $_.SamAccountName -Replace @{mailNickname = $_.SamAccountName } } @SetAdOptions
}

If ($PSCmdlet.ShouldProcess("Clear telephoneNumber if mail empty") -and $Actions -contains "ClearTelephoneNumber") {
    $Users | Where-Object $null -eq mail | Where-Object telephoneNumber -ne $null | Set-ADUser -Clear telephoneNumber @SetAdOptions
}

If ($PSCmdlet.ShouldProcess("Set telephoneNumber to default line and extension") -and $Actions -contains "SetTelephoneNumber") {
    while (!$DefaultPhoneNumber) { $DefaultPhoneNumber = Read-Host -Prompt "Enter the default phone number." }
    $Users | Where-Object $null -ne mail | ForEach-Object {
        if ($null -ne $_.ipphone) { $telephoneNumber = $DefaultPhoneNumber + " x" + $_.ipPhone.Substring(0, [System.Math]::Min(3, $_.ipPhone.Length)) }
        else { $telephoneNumber = $DefaultPhoneNumber }
        Set-ADUser -Identity $_.SamAccountName -Replace @{telephoneNumber = $telephoneNumber } @SetAdOptions
    }
}
