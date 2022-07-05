<#PSScriptInfo

.VERSION 1.0.5

.GUID 6309e154-81f6-4bd1-aff7-deaea3274934

.AUTHOR Jason Cook Robin Granberg (robin.granberg@microsoft.com)

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
Search for user accounts with "ADS_UF_PASSWD_NOTREQD" enabled and remove the flag

.NOTES
TODO Build better help
#>
################################################################################################
# RemoveUserPASSWD_NOTREQD.ps1
#
# AUTHOR: Robin Granberg (robin.granberg@microsoft.com)
#
# NAME: RemoveUserPASSWD_NOTREQD.ps1
# Version: 1.0
# Date: 1/10/12
#
# THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR
# FITNESS FOR A PARTICULAR PURPOSE.
#
# This sample is not supported under any Microsoft standard support program or service.
# The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
# implied warranties including, without limitation, any implied warranties of merchantability
# or of fitness for a particular purpose. The entire risk arising out of the use or performance
# of the sample and documentation remains with you. In no event shall Microsoft, its authors,
# or anyone else involved in the creation, production, or delivery of the script be liable for
# any damages whatsoever (including, without limitation, damages for loss of business profits,
# business interruption, loss of business information, or other pecuniary loss) arising out of
# the use of or inability to use the sample or documentation, even if Microsoft has been advised
# of the possibility of such damages.
################################################################################################
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", Scope = "Function", Target = "*")]
param([string]$Path,
    [string]$Server,
    [switch]$Subtree,
    [string]$LogFile,
    [switch]$help)

function funHelp() {
    Clear-Host
    $helpText = @"
THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR
FITNESS FOR A PARTICULAR PURPOSE.

This sample is not supported under any Microsoft standard support program or service.
The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
implied warranties including, without limitation, any implied warranties of merchantability
or of fitness for a particular purpose. The entire risk arising out of the use or performance
of the sample and documentation remains with you. In no event shall Microsoft, its authors,
or anyone else involved in the creation, production, or delivery of the script be liable for
any damages whatsoever (including, without limitation, damages for loss of business profits,
business interruption, loss of business information, or other pecuniary loss) arising out of
the use of or inability to use the sample or documentation, even if Microsoft has been advised

DESCRIPTION:
NAME: RemoveUserPASSWD_NOTREQD.ps1
Search for user accounts with "ADS_UF_PASSWD_NOTREQD" enabled and remove the flag
This script requires Active Directory Module for Windows PowerShell.
Run "import-module activedirectory" before running the script.

SYSTEM REQUIREMENTS:

- Windows Powershell

- Active Directory Module for Windows PowerShell

- Connection to a Active Directory Domain

- Modify User Object Permissions in Active Directory

PARAMETERS:

-Path          Where to start search, DistinguishedName within quotation mark (")
-Server        Name of Domain Controller
-Subtree       Do a subtree search (Optional)
-help          Prints the HelpFile (Optional)

SYNTAX:
 -------------------------- EXAMPLE 1 --------------------------

.\RemoveUserPASSWD_NOTREQD.ps1 -Server DC1 -Path "OU=Sales,DC=contoso,DC=com"

 Description
 -----------
 This command will remove "ADS_UF_PASSWD_NOTREQD" on all user accounts under OU=Sales,DC=contoso,DC=com.

 -------------------------- EXAMPLE 2 --------------------------

.\RemoveUserPASSWD_NOTREQD.ps1 -Server DC1 -Path "OU=Sales,DC=contoso,DC=com" -subtree

 Description
 -----------
 This command will remove "ADS_UF_PASSWD_NOTREQD" on all user accounts under OU=Sales,DC=contoso,DC=com and in all sub OU's.

 -------------------------- EXAMPLE 3 --------------------------

.\RemoveUserPASSWD_NOTREQD.ps1 -Server DC1 -Path "OU=Sales,DC=contoso,DC=com" -subtree -logfile c:\log.txt

 Description
 -----------
 This command will remove "ADS_UF_PASSWD_NOTREQD" on all user accounts under OU=Sales,DC=contoso,DC=com and in all sub OU's.
 The output will also be put in a logfile.

 -------------------------- EXAMPLE 4 --------------------------

.\RemoveUserPASSWD_NOTREQD.ps1  -help

 Description
 -----------
 Displays the help topic for the script

"@
    write-host $helpText
    exit
}
function reqHelp() {
    Clear-Host
    $helpText = @"
THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR
FITNESS FOR A PARTICULAR PURPOSE.

This sample is not supported under any Microsoft standard support program or service.
The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
implied warranties including, without limitation, any implied warranties of merchantability
or of fitness for a particular purpose. The entire risk arising out of the use or performance
of the sample and documentation remains with you. In no event shall Microsoft, its authors,
or anyone else involved in the creation, production, or delivery of the script be liable for
any damages whatsoever (including, without limitation, damages for loss of business profits,
business interruption, loss of business information, or other pecuniary loss) arising out of
the use of or inability to use the sample or documentation, even if Microsoft has been advised

DESCRIPTION:
NAME: RemoveUserPASSWD_NOTREQD.ps1
Search for user accounts with "ADS_UF_PASSWD_NOTREQD" enabled and remove the flag
This script requires Active Directory Module for Windows PowerShell.
Run "import-module activedirectory" before running the script.

SYSTEM REQUIREMENTS:

- Windows Powershell

- Active Directory Module for Windows PowerShell

- Connection to a Active Directory Domain

- Modify User Object Permissions in Active Directory

"@
    write-host $helpText
    exit
}
# Check for AD powershell module
if ($null -eq $(Get-Module | Where-Object { $_.name -eq "activedirectory" })) {
    reqHelp
    exit
}
$script:ErrCtrlrActionPreference = "SilentlyContinue"
#==========================================================================
# Function		: GetUserAccCtrlStatus
# Arguments     : string distinguishedName or User object
# Returns   	: String
# Description   : Returns userAccountControl status
#==========================================================================
Function GetUserAccCtrlStatus ($userDN) {

    $objUser = get-aduser -server $Server $userDN -properties useraccountcontrol

    [string] $strStatus = ""

    if ($objUser.useraccountcontrol -band 2)
    { $strStatus = $strStatus + ",ADS_UF_ACCOUNT_DISABLE" }
    if ($objUser.useraccountcontrol -band 8)
    { $strStatus = $strStatus + ",ADS_UF_HOMEDIR_REQUIRED" }
    if ($objUser.useraccountcontrol -band 16)
    { $strStatus = $strStatus + ",ADS_UF_LOCKOUT" }
    if ($objUser.useraccountcontrol -band 32)
    { $strStatus = $strStatus + ",ADS_UF_PASSWD_NOTREQD" }
    if ($objUser.useraccountcontrol -band 64)
    { $strStatus = $strStatus + ",ADS_UF_PASSWD_CANT_CHANGE" }
    if ($objUser.useraccountcontrol -band 128)
    { $strStatus = $strStatus + ",ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED" }
    if ($objUser.useraccountcontrol -band 512)
    { $strStatus = $strStatus + ",ADS_UF_NORMAL_ACCOUNT" }
    if ($objUser.useraccountcontrol -band 2048)
    { $strStatus = $strStatus + ",ADS_UF_INTERDOMAIN_TRUST_ACCOUNT" }
    if ($objUser.useraccountcontrol -band 4096)
    { $strStatus = $strStatus + ",ADS_UF_WORKSTATION_TRUST_ACCOUNT" }
    if ($objUser.useraccountcontrol -band 8192)
    { $strStatus = $strStatus + ",ADS_UF_SERVER_TRUST_ACCOUNT" }
    if ($objUser.useraccountcontrol -band 65536)
    { $strStatus = $strStatus + ",ADS_UF_DONT_EXPIRE_PASSWD" }
    if ($objUser.useraccountcontrol -band 131072)
    { $strStatus = $strStatus + ",ADS_UF_MNS_LOGON_ACCOUNT" }
    if ($objUser.useraccountcontrol -band 262144)
    { $strStatus = $strStatus + ",ADS_UF_SMARTCARD_REQUIRED" }
    if ($objUser.useraccountcontrol -band 524288)
    { $strStatus = $strStatus + ",ADS_UF_TRUSTED_FOR_DELEGATION" }
    if ($objUser.useraccountcontrol -band 1048576)
    { $strStatus = $strStatus + ",ADS_UF_NOT_DELEGATED" }
    if ($objUser.useraccountcontrol -band 2097152)
    { $strStatus = $strStatus + ",ADS_UF_USE_DES_KEY_ONLY" }
    if ($objUser.useraccountcontrol -band 4194304)
    { $strStatus = $strStatus + ",ADS_UF_DONT_REQUIRE_PREAUTH" }
    if ($objUser.useraccountcontrol -band 8388608)
    { $strStatus = $strStatus + ",ADS_UF_PASSWORD_EXPIRED" }
    if ($objUser.useraccountcontrol -band 16777216)
    { $strStatus = $strStatus + ",ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION" }
    if ($objUser.useraccountcontrol -band 33554432)
    { $strStatus = $strStatus + ",ADS_UF_NO_AUTH_DATA_REQUIRED" }
    if ($objUser.useraccountcontrol -band 67108864)
    { $strStatus = $strStatus + ",ADS_UF_PARTIAL_SECRETS_ACCOUNT" }

    [int] $index = $strStatus.IndexOf(",")
    If ($index -eq 0) {
        $strStatus = $strStatus.substring($strStatus.IndexOf(",") + 1, $strStatus.Length - 1 )
    }

    return $strStatus

}#End function

#==========================================================================
# Function		: CheckDNExist
# Arguments     : string distinguishedName
# Returns   	: Boolean
# Description   : Check If distinguishedName exist
#==========================================================================
function CheckDNExist {
    Param (
        $sADobjectName
    )
    $sADobjectName = "LDAP://" + $sADobjectName
    $ADobject = [ADSI] $sADobjectName
    If ($null -eq $ADobject.distinguishedName)
    { return $false }
    else
    { return $true }

}#End function

if ($help -or !($Path) -or !($Server)) { funHelp }
if (!($LogFile -eq "")) {
    if (Test-Path $LogFile) {
        Remove-Item $LogFile
    }
}
If (CheckDNExist $Path) {
    $index = 0
    if ($Subtree) {
        $users = get-aduser -server $Server -LDAPfilter "(&(objectCategory=person)(objectClass=user)(!userAccountControl:1.2.840.113556.1.4.803:=2048)(userAccountControl:1.2.840.113556.1.4.803:=32))" -searchbase $Path -properties useraccountcontrol -SearchScope Subtree

    }
    else {
        $users = get-aduser -server $Server -LDAPfilter "(&(objectCategory=person)(objectClass=user)(!userAccountControl:1.2.840.113556.1.4.803:=2048)(userAccountControl:1.2.840.113556.1.4.803:=32))" -searchbase $Path -properties useraccountcontrol -SearchScope OneLevel
    }
    if ($users -is [array]) {
        while ($index -le $users.psbase.length - 1) {
            $global:ErrCtrl = $false
            $global:strUserDN = $users[$index]
            $objUser = [ADSI]"LDAP://$global:strUserDN"
            $global:strUserName = $objUser.cn

            & { #Try
                set-aduser -server $Server $users[$index] -PasswordNotRequired $false
            }

            Trap [SystemException] {
                $global:ErrCtrl = $true
                Write-host $users[$index].name";Failed;"$_ -Foreground red
                if (!($LogFile -eq "")) {
                    [string] $strMsg = ($global:strUserName + ";Failed;" + $_.tostring().replace("`n", ""))
                    Out-File -Append -FilePath $LogFile -inputobject $strMsg -force
                }
                ; Continue
            }

            if ($ErrCtrl -eq $false) {
                Write-host $users[$index].name";Success;Status:"(GetUserAccCtrlStatus($users[$index])) -Foreground green
                if (!($LogFile -eq "")) {
                    [string] $strUserNames = $global:strUserName
                    [string] $strUrsStatus = GetUserAccCtrlStatus($global:strUserDN)
                    [string] $strMsg = ("$strUserNames" + ";Success;Status:" + "$strUrsStatus")
                    Out-File -Append -FilePath $LogFile -inputobject $strMsg -force
                }
            }
            $index++
        }
    }
    elseif ($null -ne $users) {
        $global:ErrCtrl = $false
        $global:strUserDN = $users
        $objUser = [ADSI]"LDAP://$global:strUserDN"
        $global:strUserName = $objUser.cn

        & { #Try
            $global:ErrCtrl = $false
            set-aduser -server $Server $users -PasswordNotRequired $false

        }

        Trap [SystemException] {
            $global:ErrCtrl = $true
            Write-host $users.name";Failed;"$_ -Foreground red
            if (!($LogFile -eq "")) {
                [string] $strMsg = ($global:strUserName + ";Failed;" + $_.tostring().replace("`n", ""))
                Out-File -Append -FilePath $LogFile -inputobject $strMsg -force
            }
            ; Continue
        }

        if ($ErrCtrl -eq $false) {

            Write-host $users.name";Success;Status:"(GetUserAccCtrlStatus($users)) -Foreground green
            if (!($LogFile -eq "")) {
                [string] $strUserNames = $global:strUserName
                [string] $strUrsStatus = GetUserAccCtrlStatus($global:strUserDN)
                [string] $strMsg = ("$strUserNames" + ";Success;Status:" + "$strUrsStatus")
                Out-File -Append -FilePath $LogFile -inputobject $strMsg -force
            }
        }
    }
}
else {
    Write-host "Failed! OU does not exist or can not be connected" -Foreground red
}
