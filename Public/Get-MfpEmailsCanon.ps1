<#PSScriptInfo

.VERSION 1.0.2

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

.PARAMETER Properties
The properties to export.

.PARAMETER SearchBase
The base OU to search from.

.PARAMETER Filter
How should the AD results be filtered?
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [array]$Properties = ("name", "DisplayName", "mail"),
    [string]$SearchBase ,
    [string]$Filter = "*"
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

if ($SearchBase) {
    $Users = Get-ADUser -Filter $Filter -SearchBase $SearchBase -Properties $Properties
}
else {
    $Users = Get-ADUser -Filter $Filter -Properties $Properties
}


$Results = @()
$Index = 200
$Users | ForEach-Object {
    $Index++
    [PSCustomObject]@{
        objectclass   = "email"
        cn            = $_.DisplayName
        cnread        = $_.DisplayName
        subdbid       = 1
        # mailaddress   = $_.mail;
        protocol      = "smtp"
        indxid        = $Index
        enablepartial = "off"
        accesscode    = 0
        uuid          = New-Guid
    }
    $Results += $Result
}

Return $Results
