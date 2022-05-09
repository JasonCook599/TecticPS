<#PSScriptInfo

.VERSION 1.0.5

.GUID ce6000db-e45d-4622-804c-c45eaa20a737

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
This script will output the email addresses needed for the scan to email function on Canon MFPs.

.LINK
https://oip.manual.canon/USRMA-4706-zz-CS-3700-enUV/contents/devu-mcn_mng-rui-setdata_impt_expt-indivi-adrs.html

.PARAMETER Properties
The properties to export.

.PARAMETER Path
The location to export the address book to.

.PARAMETER WhereObject
Filters the returned results based on the spesified parameters.

.PARAMETER SearchBase
The base OU to search from.

.PARAMETER Filter
How should the AD results be filtered?
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [array]$Properties = ("name", "DisplayName", "mail", "enabled"),
    [string]$Path,
    $WhereObject = { $_.mail -ne $null -and $_.Enabled -ne $false },
    [string]$SearchBase ,
    [string]$Filter = "*"
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

if ($SearchBase) {
    $Users = Get-ADUser -Filter $Filter -SearchBase $SearchBase -Properties $Properties | Where-Object $WhereObject | Sort-Object $Properties[0]
}
else {
    $Users = Get-ADUser -Filter $Filter -Properties $Properties | Where-Object $WhereObject | Sort-Object $Properties[0]
}



$Results = @()
$Index = 200
$Users | ForEach-Object {
    $Index++
    Write-Verbose "$($_.DisplayName + ": " + $_.Enabled)"
    $Result = [PSCustomObject]@{
        objectclass       = "email"
        cn                = $_.DisplayName
        cnread            = $_.DisplayName
        cnshort           = $null
        subdbid           = 1
        mailaddress       = $_.mail
        dialdata          = $null
        uri               = $null
        url               = $null
        path              = $null
        protocol          = "smtp"
        username          = $null
        pwd               = $null
        member            = $null
        indxid            = $Index
        enablepartial     = "off"
        sub               = $null
        faxprotocol       = $null
        ecm               = $null
        txstartspeed      = $null
        commode           = $null
        lineselect        = $null
        uricommode        = $null
        uriflag           = $null
        pwdinputflag      = $null
        ifaxmode          = $null
        transsvcstr1      = $null
        transsvcstr2      = $null
        ifaxdirectmode    = $null
        documenttype      = $null
        bwpapersize       = $null
        bwcompressiontype = $null
        bwpixeltype       = $null
        bwbitsperpixel    = $null
        bwresolution      = $null
        clpapersize       = $null
        clcompressiontype = $null
        clpixeltype       = $null
        clbitsperpixel    = $null
        clresolution      = $null
        accesscode        = 0
        uuid              = $null
        cnreadlang        = "en"
        enablesfp         = $null
        memberobjectuuid  = $null
        loginusername     = $null
        logindomainname   = $null
        usergroupname     = $null
        personalid        = $null
    }
    $Results += $Result
}

If ($Path) {
    
    $Results | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8 
    $(
        "# Canon AddressBook CSV version: 0x0002
# CharSet: UTF-8
# SubAddressBookName: Cambridge Users
# DB Version: 0x010a
"
    (Get-Content $Path -Raw) -replace "`"", ""
    ) | Out-File $Path -Encoding UTF8
}

Return $Results
