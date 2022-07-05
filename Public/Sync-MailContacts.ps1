<#PSScriptInfo

.VERSION 1.0.3

.GUID 6da14011-187b-4176-a61b-16836f8a0ad7

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
This script will sync users from one AD domain to another as Contacts.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [string]$SourceDomain,
    [string]$SourceSearchBase,

    [string]$DestinationDomain,
    [string]$DestinationOU,
    [string]$DestinationGroup,

    $WhereObject = { $null -ne $_.mail -and $_.Enabled -ne $false -and $_.msExchHideFromAddressLists -ne $true },

    [array]$SourceProperties = ("displayName", "givenName", "sn", "initials", "mail", "SamAccountName", "description", "wWWHomePage", "title", "department", "company", "manager", "telephoneNumber", "mobile", "facsimileTelephoneNumber", "homePhone", "pager", "physicalDeliveryOfficeName", "streetAddress", "l", "st", "postalCode", "co", "info"),
    [string]$SourceFilter = "*",
    [string]$DestinationFilter = "*"
)

$Source = @{}
if ($SourceSearchBase) { $Source.SearchBase = $SourceSearchBase }
if ($SourceDomain) { $Source.Server = $SourceDomain }
if ($SourceFilter) { $Source.Filter = $SourceFilter }
if ($SourceProperties) { $Source.Properties = $SourceProperties }

if ($DestinationGroup) {
    $GroupMembers = (Get-ADGroup -Identity $DestinationGroup -Properties Members).Members
    $GroupMembers | ForEach-Object {
        $i++ ; Progress -Index $i -Total $GroupMembers.count -Activity "Removing all members from $DestinationGroup." -Status "$_"
        Get-ADGroup $DestinationGroup -Server $DestinationDomain | Set-ADObject -Server $DestinationDomain -Remove @{'member' = $_ }
    }
    $i = 0
}

$SyncedUsers = Get-ADUser -Server $SourceDomain -Filter $SourceFilter -Properties $SourceProperties | Where-Object $WhereObject
$SyncedUsers | ForEach-Object {
    $i++ ; Progress -Index $i -Total $SyncedUsers.count -Activity "Syncing users from $SourceSearchBase to $DestinationOU" -Status "$_"
    $Properties = @{}
    if ($_.displayName) { $Properties.displayName = $_.DisplayName }
    if ($_.givenName) { $Properties.givenName = $_.GivenName }
    if ($_.sn) { $Properties.sn = $_.Surname }
    if ($_.initials) { $Properties.initials = $_.Initials }

    if ($_.mail) { $Properties.mail = $_.mail }
    # if ($_.SamAccountName) {$Properties.mailNickname = $_.SamAccountName}

    if ($_.description) { $Properties.description = $_.Description }
    if ($_.wWWHomePage) { $Properties.wWWHomePage = $_.wWWHomePage }

    if ($_.title) { $Properties.title = $_.Title }
    if ($_.department) { $Properties.department = $_.Department }
    if ($_.company) { $Properties.company = $_.Company }
    # if ($_.manager) { $Properties.manager = $_.Manager }

    if ($_.telephoneNumber) { $Properties.telephoneNumber = $_.TelephoneNumber }
    if ($_.mobile) { $Properties.mobile = $_.mobile }
    if ($_.facsimileTelephoneNumber) { $Properties.facsimileTelephoneNumber = $_.Fax }
    if ($_.homePhone) { $Properties.homePhone = $_.HomePhone }
    if ($_.pager) { $Properties.pager = $_.Pager }

    if ($_.physicalDeliveryOfficeName) { $Properties.physicalDeliveryOfficeName = $_.physicalDeliveryOfficeName }
    if ($_.streetAddress) { $Properties.streetAddress = $_.StreetAddress }
    if ($_.l) { $Properties.l = $_.City }
    if ($_.st) { $Properties.st = $_.State }
    if ($_.postalCode) { $Properties.postalCode = $_.PostalCode }
    if ($_.co) { $Properties.co = $_.Country }
    if ($_.info) { $Properties.info = $_.Notes }

    $ObjectPath = ( "CN=" + $_.DisplayName + ',' + $DestinationOU )
    $DisplayName = $_.DisplayName

    # Write-Verbose command occurs after the user is created to prevent logging when an error occurs.
    try {
        New-ADObject -Type "contact" -Name $_.DisplayName -Server $DestinationDomain -Path $DestinationOU -OtherAttributes $Properties
        Write-Verbose "Created contact for $DisplayName in $DestinationOU"
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] {
        try {
            Set-ADObject -Identity $ObjectPath -Server $DestinationDomain -Replace $Properties
            Write-Verbose "Updated contact for $DisplayName in $DestinationOU."
        }
        catch {
            Write-Warning "Failed to update $DisplayName in $DestinationOU"
            Write-Error $_
        }
    }

    if ($DestinationGroup) {
        Write-Verbose "Adding $($_.DisplayName) to $DestinationGroup"
        Set-ADGroup -Identity $DestinationGroup -Server $DestinationDomain -Add @{'member' = ("cn=" + $_.DisplayName + "," + $DestinationOU) }
    }
}
