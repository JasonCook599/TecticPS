<#PSScriptInfo

.VERSION 1.0.6

.GUID 01fdecd7-47c1-4691-bc07-15f93ce2cf1a

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
This script will Results the email addresses needed for the scan to email function on Canon MFPs.

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

$Index = 200
$Results = "# Canon AddressBook version: 1
`# CharSet: WCP1252
`# SubAddressBookName: Cambridge Users
`# DB Version: 0x0108"


$Users | ForEach-Object {
    $Index++
    Write-Verbose "$($_.DisplayName + ": " + $_.Enabled)"
    $Results += "

subdbid: 1
dn: $Index
cn: $($_.DisplayName)
cnread: $($_.DisplayName)
mailaddress: $($_.mail)
enablepartial: false
accesscode: 0
protocol: smtp
objectclass: top
objectclass: extensibleobject
objectclass: email"
}

If ($Path) { [IO.File]::WriteAllLines($Path, $Results) }

Return $Results
