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
param([string]$Path,
    [string]$Server,
    [switch]$Subtree,
    [string]$LogFile,
    [switch]$help)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwYP22trz14+GKLtOhlJwMgqo
# dYyggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
# 9w0BAQsFADAiMSAwHgYDVQQDExdLb2lub25pYSBSb290IEF1dGhvcml0eTAeFw0x
# ODA0MDkxNzE4MjRaFw0yODA0MDkxNzI4MjRaMFgxFTATBgoJkiaJk/IsZAEZFgVs
# b2NhbDEYMBYGCgmSJomT8ixkARkWCEtvaW5vbmlhMSUwIwYDVQQDExxLb2lub25p
# YSBJc3N1aW5nIEF1dGhvcml0eSAxMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAwQZJAkaKEsFXEV/6i/XPyrmFiZ4uFyigwSzUBvBJ+FiXk0dX3zr5hX68
# FoxSTSJGwfWZNL1rzfMkw+ehtd1kqgCYRwJ2TZiQevSVOx2Gj5OrsaEHw1mKcbGP
# j2dboAG95ZsidwqyXqBwHDbxJW3xRSSh5jGpZpEXl5gO6IvX2nT7ATcJ8Vq+s0af
# ww/QHVPAELDXDM/mYZftoGLZz717hfDL2YwVq6sADEUSf8+qiFDgGody3JsYz2wz
# O1YxqGhFfJT7uV4wPlAyXRFBPdHFMKLkDg3l++qb1fw8zZQnvLQQ2dRK9+Nuh7Q7
# iOCVX2/ESkn1VWySq4qmRCq2IxCTSC9R/JTfHHLzZ+wTt79i4ylDyPQDIfBMTwOh
# vVzxCvpvBirqfn0JaUcDxzcAaEVr41WNFQv09O1XUYu9qw1j59ogEUc7i0IPMFbq
# reZ43bIYbEQiHWyzObjxQ6HUBxyGbtqmg5gm5X8p42egtUJLPl1EW0L05VDMKgBz
# WxVUeitCsjmuSPi78b8G2LDwGEM3EEJWI29BQov0TPBIlnddhPUxNkrps7S8ZmdS
# /FCpWUnYWPXpGVtuyKFouynpTEd25iO9vOuOH+EuXRfGDR+JGQLWFuBsaNdKpOBX
# QlRzwCwpxhATToUZ2RLH2L+t8owK/l/Mmq0qCE4hJv8utRCTsHUCAwEAAaOCAdcw
# ggHTMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTAVWX0ludkYgskUG6CXca7
# YIL5iDCBqAYDVR0gBIGgMIGdMIGaBg4rBgEEAYOGSQEBAQUBATCBhzBgBggrBgEF
# BQcCAjBUHlIAUABvAGwAaQBjAHkAIABTAHQAYQB0AGUAbQBlAG4AdAA6ACAAaAB0
# AHQAcAA6AC8ALwBwAGsAaQAuAGsAYwBmAC4AbwByAGcALwBwAGsAaQAvMCMGCCsG
# AQUFBwIBFhdodHRwOi8vcGtpLmtjZi5vcmcvcGtpLzAZBgkrBgEEAYI3FAIEDB4K
# AFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSME
# GDAWgBQ3VizjAphUZ/xTllcA4YGtLMZwvjBHBgNVHR8EQDA+MDygOqA4hjZodHRw
# Oi8vcGtpLmtjZi5vcmcvcGtpL0tvaW5vbmlhJTIwUm9vdCUyMEF1dGhvcml0eS5j
# cmwwUgYIKwYBBQUHAQEERjBEMEIGCCsGAQUFBzAChjZodHRwOi8vcGtpLmtjZi5v
# cmcvcGtpL0tvaW5vbmlhJTIwUm9vdCUyMEF1dGhvcml0eS5jcnQwDQYJKoZIhvcN
# AQELBQADggIBACwQT8YLvbK8yk1w548coVbviyabJuLR3HFflJbzNObXmeHPYC+m
# 2uF/LEvqA9azZ9ggKn61QO45BXOtu6Heif7Yn9agX0PFmQhxRlghRw9g57RHPhfN
# BdUamvcPmSGt1m+/lVxPfa9BeemqTOno7EjzhN0fN5o9oMtlnaPYurz+sg4qPgNq
# v0R1Ns5othE0rFqwfEQKwjvZZMj9gk8QiKz30897s+GU/cumShCNLRR/G3e7kCjw
# gyCmneS/T8DhMjYN4qQfVKUb5+X1pHQxCwSIhRma05GWrF4ZH4W0kbEkmlTwhbYO
# CltTSVFXlx+X/LPwaGC05TkkIjuoLubKSKzZXL/AGsCdFJDLMO3u+3UdfNtOV7/6
# UQle936nyS0eOvD0XgCtkGdU3/miVOpTPH4tE1TIMu9QYDySThWXEz9rkeP6vk4+
# evaYRa8Kfl8b5YleUyrDPeOAwRTBVcBLGL2RtUSjpz+D+PK/wbV8VrzEWmydeO0w
# eMZOOMpoEUJBCPO0skRFB6nwx7xfDAwWVQsFJ4d5DHZQNsAsXYbbOHZtdf+n+seX
# 0xzGHYs0cMQAHf1V+s2Ja/2AnO03tJ/uMnRqqFJG1HqG0R/T5YV7h7X1/LVbebwO
# LZZi0w82sFtyETySRo8AGQEKF7WLY3WJyG6RdVgLxvcIUhi2Dc5x6IjtMIIIATCC
# BemgAwIBAgITIgAADHxZeZBscIM3YQAAAAAMfDANBgkqhkiG9w0BAQsFADBYMRUw
# EwYKCZImiZPyLGQBGRYFbG9jYWwxGDAWBgoJkiaJk/IsZAEZFghLb2lub25pYTEl
# MCMGA1UEAxMcS29pbm9uaWEgSXNzdWluZyBBdXRob3JpdHkgMTAeFw0yMTExMTUx
# NjM4NDdaFw0yMjExMTUxNjM4NDdaMIHFMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwx
# GDAWBgoJkiaJk/IsZAEZFghLb2lub25pYTESMBAGA1UECwwJX0tvaW5vbmlhMQ4w
# DAYDVQQLEwVVc2VyczEVMBMGA1UECxMMQmxvb21pbmdkYWxlMQ8wDQYDVQQLEwZD
# aHVyY2gxDjAMBgNVBAsTBVN0YWZmMRMwEQYDVQQDEwpKYXNvbiBDb29rMSEwHwYJ
# KoZIhvcNAQkBFhJKYXNvbi5Db29rQGtjZi5vcmcwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQDwN91V292vy9GcOuBoPPYpHSeEhqOyWlmxWUdGFRDPv3ST
# FextzADS19BiV/werFJyS32viu1le9hFwORP/+K8ABGAoso3caaq69vAo5Erqd7x
# +gcNM9B7ItgQLIfCGHiN54bBNwWT1BJr/I56rTG92jXCYTHdN8RI+GAxdb3+xkuu
# drCyuLUExIkmzY5q9MiHX6rlNsdkDP6f6aMxVW+U0sOhXR+fxCMkgXFqCTvlhjAP
# z2mxYqEBmJb9nwdSov5n3lu6YEuCo1ddsATeHPDhYdgPoKIKFq9NauZGB/m7vCSd
# E7qEGNdbENHEnflDKwVSeYBL45acenlAU5Rau/dsDQ6s1PsG5q4U0jYXwW0hV45B
# h123Kg6MAb3/CiudVxD9sNBvDJJL1k15RN3sOB0xdQYO+zuPy972eBPFobvtANTD
# dxxCOnKPuwXRiRU6xaoU5AVgpgp1snBhyyBRhMjY+jLdqtnIlezgoJ7oBH5lmm4W
# N/jHZCJIjyD0FQnIT2nswk5m5Mt8sV07ZvNAhQ83Cv3UpuJ2CoWI7DA+9NA15P4V
# QvzFluEWbfEP7B7UTKmBy9iZKBjZkQ/K5Q5npgHLbEfyYjZUhTZF+u9wu1ZE2N3P
# OBiIFNLQJzCs1wQdNW9j3Lh927q4/UYzmHSW/TXLTLpO0sAlYgYgMZ7V9XaU0QID
# AQABo4ICVDCCAlAwOwYJKwYBBAGCNxUHBC4wLAYkKwYBBAGCNxUIgZbgd/3wcIWZ
# lTeEqo0lg7DnY3jI7VKCoqVGAgFkAgEhMD8GA1UdJQQ4MDYGCCsGAQUFBwMEBgor
# BgEEAYI3CgMEBggrBgEFBQcDAwYIKwYBBQUHAwIGCisGAQQBgjdDAQEwCwYDVR0P
# BAQDAgSwME8GCSsGAQQBgjcVCgRCMEAwCgYIKwYBBQUHAwQwDAYKKwYBBAGCNwoD
# BDAKBggrBgEFBQcDAzAKBggrBgEFBQcDAjAMBgorBgEEAYI3QwEBMEQGCSqGSIb3
# DQEJDwQ3MDUwDgYIKoZIhvcNAwICAgCAMA4GCCqGSIb3DQMEAgIAgDAHBgUrDgMC
# BzAKBggqhkiG9w0DBzAdBgNVHQ4EFgQU+GvN2GPT7Nzos4/UvTXojcu3GpswHwYD
# VR0jBBgwFoAUwFVl9JbnZGILJFBugl3Gu2CC+YgwTgYDVR0fBEcwRTBDoEGgP4Y9
# aHR0cDovL3BraS5rY2Yub3JnL3BraS9Lb2lub25pYSUyMElzc3VpbmclMjBBdXRo
# b3JpdHklMjAxLmNybDBZBggrBgEFBQcBAQRNMEswSQYIKwYBBQUHMAKGPWh0dHA6
# Ly9wa2kua2NmLm9yZy9wa2kvS29pbm9uaWElMjBJc3N1aW5nJTIwQXV0aG9yaXR5
# JTIwMS5jcnQwQQYDVR0RBDowOKAiBgorBgEEAYI3FAIDoBQMEmphc29uLmNvb2tA
# a2NmLm9yZ4ESSmFzb24uQ29va0BrY2Yub3JnMA0GCSqGSIb3DQEBCwUAA4ICAQCO
# x749r4EodqxVpIwBz+LxP//goz0n42hUQsD+BGQ5ohsMA4GczB+/zmrhq6xnF5bE
# qOZETG69WIsMj85PENJKpcA0xIM57F6zuBRaicZHL1WC003XodecT+/QnmUaJjzl
# 5A35fogYvl5RaluYZ89OGVUMx3bkBOkt3u0zfsW+bnXikJW9tUOmepeongzU7/OC
# L9msflFZDFxSLkumx8W/sfWNKUNeByoaWwUCp9noGW0gBAEiM/I1xWRkPMSNcbnI
# 8bk/6kAWzPe012uc/rXMDq/xJKQeD+OiV9nRMnKBGNRZELP8QSR4bAqFkhaY3M1y
# 9xgerRDCkOpXTAy1Ht0Oz0xI/Tyh1jNwH93Xynneu84FFjKgtUvAXXo3MWf7nd7H
# ZIcTkf0biYCJI3Qij4kKbJa8I4NJoICa9nzF9ef1AAsen3iuXSlau+YskqDKJJmM
# mQINbNllX9GS2N6kH0pnyUgSNXfZmb9d+5pZApavZtKoRdZr2Z/xhKsWNoLnDW8Q
# JDXTKkQODY4gBxrH2T9qNfHZ5SuF6zxekluWD0dhfqyljaWOIjIqXRHbqGMcrr3S
# MqLmcnh72nO5kAIdDumQ0tQGq1sWiBn9fFRBKQosIavTWkZVyVDRDDq9rIb9GKMT
# 1w3EwXuPdqq+APlFZ06PLOFLVAwWoaqiMruKB9owizGCAxAwggMMAgEBMG8wWDEV
# MBMGCgmSJomT8ixkARkWBWxvY2FsMRgwFgYKCZImiZPyLGQBGRYIS29pbm9uaWEx
# JTAjBgNVBAMTHEtvaW5vbmlhIElzc3VpbmcgQXV0aG9yaXR5IDECEyIAAAx8WXmQ
# bHCDN2EAAAAADHwwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKEC
# gAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwG
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFH32fQBo/b9XT6GB4OwnYKg3bmiF
# MA0GCSqGSIb3DQEBAQUABIICAC/R44TrTjmjszGQbSUEmCU+CWD+hfJ+dDL7JINi
# UqsdC42cw7VjLqWSuE9ahkVXgUf7F5Oz6CWtJ6Q5dgNsFUSmllznqgwlVp/AXfEA
# KTGLe6NH3TERjkfWWIKvhfddKhdfFqIR99S1MAbYXx2zVhFW4XhnV87dh4muBfES
# 8GkHNaT1LTICjfw5jNF6aOvr0BOPmfhTZzuCEyIb5xSx+LiFHHl5EDpVC+rnnt48
# txa62So7T/uZkmVrMkTYIxNwv/2a6NJR7h9gz3rt2iO3xg/KFZJC2/fNUP1YrQSB
# Qc8+M1gLZFnfkb3fwDDxQXpmGA6f0fJE2SOh1HWBaKn/h2Kf9ChqjfzOXVn53def
# 7L7HzdVNJocUGWwu5OQbAq7SxEYuvDFx/SFuCSI7ydG88NOqKIOb8nyZhkC4napP
# U/T9SKF33SCTXzaswFBuYPBXNeda3zJs/cGhhggo7xNVUWczfESuXSDNi5ETEbVy
# WQ/J4yUsiBz1w8xKIIJki/vRJ4Ld3CCN9mslx/wOGbvsj1t3s0GpW/gZTdJ4KxPJ
# xcWHaVQSYkXCptmj6nuhIysvu79XU+mpOMClySCchIl5AMsqCKlPtEC6+Jl9PXVW
# Zo2nay5KJKsbyKqsa2S6WKplGWYnChXqpiZ0GfzzZh3pC8U3oBPhkAbPLBneJ9Km
# ldjw
# SIG # End signature block
