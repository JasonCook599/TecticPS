<#PSScriptInfo

.VERSION 1.2.1

.GUID 44daac91-76d4-41f5-a2ab-688d548ad0d1

.AUTHOR Jason Cook Martin Bengtsson

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


.PRIVATEDATA

#> 




<#
.SYNOPSIS
Install RSAT features for Windows 10 1809 or 1903
    
.DESCRIPTION
Install RSAT features for Windows 10 1809 or 1903. All features are installed online from Microsoft Update thus the script requires Internet access

.PARAMETER All
Installs all the features within RSAT. This takes several minutes, depending on your Internet connection

.PARAMETER Basic
Installs ADDS, DHCP, DNS, GPO, ServerManager

.PARAMETER ServerManager
Installs ServerManager

.PARAMETER Uninstall
Uninstalls all the RSAT features

.LINK
https://gist.github.com/PeterUpfold/0c83c5ad0bfa821c8a6948eeef5cd932

.LINK
https://www.imab.dk

.LINK
https://twitter.com/mwbengtsson
#> 

[CmdletBinding()]
param(
    [parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [switch]$All,
    [parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [switch]$Basic,
    [parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [switch]$ServerManager,
    [parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [switch]$Uninstall
)

# Check for administrative rights
if (-NOT([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning -Message "The script requires elevation"
    break
}

# Windows 10 1809 build
$1809Build = "17763"
# Windows 10 1903 build
$1903Build = "18362"
# Get running Windows build
$WindowsBuild = (Get-WmiObject -Class Win32_OperatingSystem).BuildNumber
# Getting executing directory - considering including the source files for RSAT to be installed from local source
#$runningDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

if (($WindowsBuild -eq $1809Build) -OR ($WindowsBuild -eq $1903Build)) {
    Write-Verbose -Verbose "Running correct Windows 10 build number for installing RSAT with Features on Demand. Build number is: $WindowsBuild"
    if ($PSBoundParameters["All"]) {
        Write-Verbose -Verbose "Script is running with -All parameter. Installing all available RSAT features"
        $Install = Get-WindowsCapability -Online | Where-Object { $_.Name -like "Rsat*" -AND $_.State -eq "NotPresent" }
        if ($null -ne $Install) {
            foreach ($Item in $Install) {
                $RsatItem = $Item.Name
                Write-Verbose -Verbose "Adding $RsatItem to Windows"
                try {
                    Add-WindowsCapability -Online -Name $RsatItem
                }
                catch [System.Exception] {
                    Write-Verbose -Verbose "Failed to add $RsatItem to Windows"
                    Write-Warning -Message $_.Exception.Message
                }
            }
        }
        else {
            Write-Verbose -Verbose "All RSAT features seems to be installed already"
        }
    }

    if ($PSBoundParameters["Basic"]) {
        Write-Verbose -Verbose "Script is running with -Basic parameter. Installing basic RSAT features"
        # Querying for what I see as the basic features of RSAT. Modify this if you think something is missing. :-)
        $Install = Get-WindowsCapability -Online | Where-Object { $_.Name -like "Rsat.ActiveDirectory*" -OR $_.Name -like "Rsat.DHCP.Tools*" -OR $_.Name -like "Rsat.Dns.Tools*" -OR $_.Name -like "Rsat.GroupPolicy*" -AND $_.State -eq "NotPresent" }
        if ($null -ne $Install) {
            foreach ($Item in $Install) {
                $RsatItem = $Item.Name
                Write-Verbose -Verbose "Adding $RsatItem to Windows"
                try {
                    Add-WindowsCapability -Online -Name $RsatItem
                }
                catch [System.Exception] {
                    Write-Verbose -Verbose "Failed to add $RsatItem to Windows"
                    Write-Warning -Message $_.Exception.Message
                }
            }
        }
        else {
            Write-Verbose -Verbose "The basic features of RSAT seems to be installed already"
        }
    }

    if ($PSBoundParameters["ServerManager"]) {
        Write-Verbose -Verbose "Script is running with -ServerManager parameter. Installing Server Manager RSAT feature"
        $Install = Get-WindowsCapability -Online | Where-Object { $_.Name -like "Rsat.ServerManager*" -AND $_.State -eq "NotPresent" } 
        if ($null -ne $Install) {
            $RsatItem = $Install.Name
            Write-Verbose -Verbose "Adding $RsatItem to Windows"
            try {
                Add-WindowsCapability -Online -Name $RsatItem
            }
            catch [System.Exception] {
                Write-Verbose -Verbose "Failed to add $RsatItem to Windows"
                Write-Warning -Message $_.Exception.Message ; break
            }
        }
        
        else {
            Write-Verbose -Verbose "$RsatItem seems to be installed already"
        }
    }

    if ($PSBoundParameters["Uninstall"]) {
        Write-Verbose -Verbose "Script is running with -Uninstall parameter. Uninstalling all RSAT features"
        # Querying for installed RSAT features first time
        $Installed = Get-WindowsCapability -Online | Where-Object { $_.Name -like "Rsat*" -AND $_.State -eq "Installed" -AND $_.Name -notlike "Rsat.ServerManager*" -AND $_.Name -notlike "Rsat.GroupPolicy*" -AND $_.Name -notlike "Rsat.ActiveDirectory*" } 
        if ($null -ne $Installed) {
            Write-Verbose -Verbose "Uninstalling the first round of RSAT features"
            # Uninstalling first round of RSAT features - some features seems to be locked until others are uninstalled first
            foreach ($Item in $Installed) {
                $RsatItem = $Item.Name
                Write-Verbose -Verbose "Uninstalling $RsatItem from Windows"
                try {
                    Remove-WindowsCapability -Name $RsatItem -Online
                }
                catch [System.Exception] {
                    Write-Verbose -Verbose "Failed to uninstall $RsatItem from Windows"
                    Write-Warning -Message $_.Exception.Message
                }
            }       
        }
        # Querying for installed RSAT features second time
        $Installed = Get-WindowsCapability -Online | Where-Object { $_.Name -like "Rsat*" -AND $_.State -eq "Installed" }
        if ($null -ne $Installed) { 
            Write-Verbose -Verbose "Uninstalling the second round of RSAT features"
            # Uninstalling second round of RSAT features
            foreach ($Item in $Installed) {
                $RsatItem = $Item.Name
                Write-Verbose -Verbose "Uninstalling $RsatItem from Windows"
                try {
                    Remove-WindowsCapability -Name $RsatItem -Online
                }
                catch [System.Exception] {
                    Write-Verbose -Verbose "Failed to remove $RsatItem from Windows"
                    Write-Warning -Message $_.Exception.Message
                }
            } 
        }
        else {
            Write-Verbose -Verbose "All RSAT features seems to be uninstalled already"
        }
    }
}
else {
    Write-Warning -Message "Not running correct Windows 10 build: $WindowsBuild"

}
# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUrp9e+gGgp1ieGikd5xf2eEBB
# dTWggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFO7ghdMiwZsp6ys6Z5TVUKdrHAEm
# MA0GCSqGSIb3DQEBAQUABIICAGmGczKYjimJeCPSm4qzuMatsMqQ8Kcn8kWKRCSq
# gaCLyiNG/ayQWjkU6V+WbSCxbPW4Wlq1MBmciAkzlCdCMnagbseVVHwAp5g2tskm
# QOSwafU4PKF9N9n3T8e8v0VBtCauPOa/iTv8J6b07X62LqsW7njXIrpzkTp8Il4Y
# t9rzR2OXHb9IMaJopDxmWoGh50HX9cQP91wHjoUxkfBnluwq4EiGfoc5J4/k0ydv
# w+R59f3WNlVU0fIdi2dd8ol0o3l7+r8VPlU9FWu8UO6UEOVaoAVUPvNnZ83HKe8c
# 3rhh0HcHU8P5kMXisuCCWAjLr7PMGAJ5g/E2vrHhGntw4A77dkxJ07TTTvwINnaT
# ioQ6Bmi+aC+QybLM8UwHhVr6XVsJlReGSbuOknaRdNkT8tTgAc89bdwzNbcWQ2NC
# N0qrVBserLu6dt5ZRGFgFq4V9/qfD6dQYGXyLvbxwh0A4M/4XOFEU0vMnqVeWV5a
# Ye1qwyjZmcPFSpwr+7aNI3Av59uMLF7a9+gLZ1nouEjT6Jv7THv6cRiWkmux3I7Z
# n44RKQ+9+mSP9WipFn+RTj1Yt5ic1TtBKG30vXhbJxqK/65+L/nVxjp1rWDZHF1k
# XoOO+KAht9coBclgFP73KJRlhzDNffMLapq4Ag2ZBQYmoU3HDiMBDQiqJaMLzEbE
# IFow
# SIG # End signature block
