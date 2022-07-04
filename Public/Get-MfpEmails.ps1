<#PSScriptInfo

.VERSION 2.0.3

.GUID 9ee43161-d2de-4792-a59e-19ff0ef0717e

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
This script will output the email addresses needed for the scan to email function on MFPs.

.PARAMETER Path
The location where the results will be exported to.

.PARAMETER Properties
The properties to export.

.PARAMETER SearchBase
The base OU to search from.

.PARAMETER Filter
How should the AD results be filtered?
#>

param(
    [ValidateSet("Canon", "KonicaMinolta")][string]$Vendor,
    [ValidateSet("csv", "abk")][string]$Format = "csv",
    [ValidateScript( { Test-Path (Split-Path $_ -Parent) })][string]$Path,
    [array]$Properties = ("name", "DisplayName", "mail", "enabled", "msExchHideFromAddressLists"),
    [array]$AdditionalUsers,
    [string]$SearchBase,
    $WhereObject = { $null -ne $_.mail -and $_.Enabled -ne $false -and $_.msExchHideFromAddressLists -ne $true },
    [string]$Server,
    [string]$Filter = "*"
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Arguments = @{}
if ($Properties) { $Arguments.Properties = $Properties }
if ($SearchBase) { $Arguments.SearchBase = $SearchBase }
if ($Server) { $Arguments.Server = $Server }
if ($Filter) { $Arguments.Filter = $Filter }

Write-Verbose "Searching AD"
$Users = Get-ADUser @Arguments

Write-Verbose "Searching for additional users"
if ($AdditionalUsers) {
    $Arguments.Remove("SearchBase")
    $AdditionalUsers | ForEach-Object {
        $Arguments.Identity = $_
        $Users += Get-ADUser @Arguments
    }
}

Write-Verbose "Sorting results"
$Users = $Users | Where-Object $WhereObject | Select-Object $Properties | Sort-Object $Properties[0]

if ($Vendor -eq "Canon") {
    $Results = @()
    $Index = 200
    if ($Format -eq "csv") {
        Write-Verbose "Starting export for Canon CSV"
        $Users | ForEach-Object {
            $Index++
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
    }
    elseif ($Format -eq "abk") {
        Write-Verbose "Starting export for Canon ABK"
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
    }

}
elseif ($Vendor -eq "KonicaMinolta") {
    Write-Verbose "Starting export for KonicaMinolta"
    $Users = $Users | Select-Object name, mail
    $Users | ForEach-Object { $_.name = "$($_.name[0..23] -join '')" }
    $Results = $Users
    if ($Path) { $Results | Export-Csv -NoTypeInformation -Path $Path }
}
elseif ($Null -eq $Vendor) { throw "Vendor must be specified" }
else { throw "Vendor `'$Vendor`' not supported" }

Write-Verbose "Finished"
return $Results
