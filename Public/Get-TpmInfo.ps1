<#
.SYNOPSIS
This script with gather information about TPM and Secure Boot from the spesified marchines.

.DESCRIPTION
This script with gather information about TPM and Secure Boot from the spesified marchines. It can request information from just the local computer or from a list of remote computers. It can also export the results as a CSV file.

.PARAMETER ComputerList
This can be used to select a text file with a list of computers to run this command against. Each device must appear on a new line. If unspesified, it will run againt the local machine.

.PARAMETER ReportFile
This can be used to export the results to a CSV file.

.EXAMPLE
Get-TPMInfo
System Information for: XXXX
Manufacturer: LENOVO
Model: 20ETXXXX
Serial Number: XXXX
Bios Version: LENOVO - 500
Bios Type: UEFI
Secure Boot Status: TRUE
TPM Version: 1.2
TPM: \\XXXX\root\CIMV2\Security\MicrosoftTpm:Win32_Tpm=@
GPT: @{Name=Disk #0, Partition #1; Index=1; Bootable=True; BootPartition=True; PrimaryPartition=True; SizeInMB=100}
Operating System: Microsoft Windows 10 Pro, Service Pack: 0
Total Memory in Gigabytes: 15.8858337402344
User logged In: XXXX\XXXX
Last Reboot: 08/31/2018 17:23:03

.NOTES
File Name  : Get-TpmInfo
Version    : 1.0.1
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2018-2022
#>
param(
  [string]$ComputerList,
  [string]$ReportFile
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

Function Get-SystemInfo($ComputerSystem) {
  If (-NOT (Test-Connection -ComputerName $ComputerSystem -Count 1 -ErrorAction SilentlyContinue)) {
    Write-Warning "$ComputerSystem is not accessible."
    $script:Report += New-Object psobject -Property @{
      RunAgainst          = $ComputerSystem;
      Satus               = "Offline"
      ComputerName        = "";
      Manufacturer        = "";
      Model               = "";
      Serial              = "";
      BiosVersion         = "";
      BiosType            = "";
      GptName             = "";
      GptIndex            = "";
      GptBootable         = "";
      GptBootPartition    = "";
      GptPrimaryPartition = "";
      GptSizeInMB         = "";
      ComputerSecureBoot  = "";
      TpmVersion          = "";
      OperatingSystem     = "";
      ServicePack         = "";
      MemoryGB            = "";
      LastSignIn          = "";
    }
    Return
		}
    
  $ComputerInfo = Get-CimInstance -ComputerName $ComputerSystem Win32_ComputerSystem
  $ComputerGptSystem = Get-CimInstance -ComputerName $ComputerSystem -query 'Select * from Win32_DiskPartition Where Type = "GPT: System"' | Select-Object Name, Index, Bootable, BootPartition, PrimaryPartition, @{n = "SizeInMB"; e = { $_.Size / 1MB } }
  $ComputerBios = Get-CimInstance -ComputerName $ComputerSystem Win32_BIOS
  $ComputerBiosType = Invoke-Command -ComputerName $ComputerSystem -ScriptBlock { if (Test-Path $env:windir\Panther\setupact.log) { (Select-String 'Detected boot environment' -Path "$env:windir\Panther\setupact.log"  -AllMatches).line -replace '.*:\s+' } else { if (Test-Path HKLM:\System\CurrentControlSet\control\SecureBoot\State) { "UEFI" } else { "BIOS" } } }
  $ComputerBiosType2 = Invoke-Command -ComputerName $ComputerSystem -ScriptBlock {
    Try {
      Confirm-SecureBootUEFI -ErrorVariable ProcessError
      $ComputerBiosType2 = "UEFI"
    }
    Catch { $ComputerBiosType2 = "BIOS" }
    Return $ComputerBiosType2
  }
  If ($ComputerBiosType2[1] -eq "I") {
    $ComputerBiosType2Output = $ComputerBiosType2
    $ComputerSecureBoot = $False
  }
  Else {
    $ComputerBiosType2Output = $ComputerBiosType2[1]
    $ComputerSecureBoot = $ComputerBiosType2[0]
  }
  $ComputerOs = Get-CimInstance -ComputerName $ComputerSystem Win32_OperatingSystem
  # $Tpm = Get-WmiObject -class Win32_Tpm -namespace root\CIMV2\Security\MicrosoftTpm -ComputerName $ComputerSystem -Authentication PacketPrivacy
  $Tpm = Get-CimInstance -class Win32_Tpm -namespace root\CIMV2\Security\MicrosoftTpm -ComputerName $ComputerSystem
  "System Information for: " + $ComputerInfo.Name
  "Manufacturer: " + $ComputerInfo.Manufacturer
  "Model: " + $ComputerInfo.Model
  "Serial Number: " + $ComputerBios.SerialNumber
  "Bios Version: " + $ComputerBios.Version
  "Bios Type: " + $ComputerBiosType
  "Bios Type (New Method): " + $ComputerBiosType2Output
  "Secure Boot Status: " + $ComputerSecureBoot
  "TPM Version: " + $Tpm.PhysicalPresenceVersionInfo
  "TPM: " + $Tpm
  "GPT: " + $ComputerGptSystem
  "Operating System: " + $ComputerOs.caption + ", Service Pack: " + $ComputerOs.ServicePackMajorVersion
  "Total Memory in Gigabytes: " + $ComputerInfo.TotalPhysicalMemory / 1gb
  "User logged In: " + $ComputerInfo.UserName
  "Last Reboot: " + $ComputerOs.LastBootUpTime
  ""
  ""
  $script:Report += New-Object psobject -Property @{
    RunAgainst          = $ComputerSystem;
    Satus               = "Online"
    ComputerName        = $ComputerInfo.Name;
    Manufacturer        = $ComputerInfo.Manufacturer;
    Model               = $ComputerInfo.Model;
    Serial              = $ComputerBios.SerialNumber;
    BiosVersion         = $ComputerBios.Version;
    BiosType            = $ComputerBiosType2Output;
    GptName             = $ComputerGptSystem.Name;
    GptIndex            = $ComputerGptSystem.Index;
    GptBootable         = $ComputerGptSystem.Bootable;
    GptBootPartition    = $ComputerGptSystem.BootPartition;
    GptPrimaryPartition = $ComputerGptSystem.PrimaryPartition;
    GptSizeInMB         = $ComputerGptSystem.SizeInMB;
    ComputerSecureBoot  = $ComputerSecureBoot;
    TpmVersion          = $Tpm.PhysicalPresenceVersionInfo;
    OperatingSystem     = $ComputerOs.caption;
    ServicePack         = $ComputerOs.ServicePackMajorVersion;
    MemoryGB            = $ComputerInfo.TotalPhysicalMemory / 1gb;
    LastSignIn          = $ComputerInfo.UserName;
    LastReboot          = $ComputerOs.LastBootUpTime
  }
  If ($script:ReportFile) { $script:Report | Export-Csv $script:ReportFile }
}

$script:Report = @()
If ($ComputerList) { foreach ($ComputerSystem in Get-Content $ComputerList) { Get-SystemInfo -ComputerSystem $ComputerSystem } }
Else { Get-SystemInfo -ComputerSystem $env:COMPUTERNAME }
If ($ReportFile) { $Report | Export-Csv $ReportFile }
# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBs8wiahegWdcyKSNVHzmBw3n
# 2tSggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFNZ/ZAXP1BpUS6+ofs1P1DvxFwgH
# MA0GCSqGSIb3DQEBAQUABIICAKHEWey6fkWUqBfTQv1x0YqJRfnT0h6Nb+Ld5RsE
# JrVJn/2fb7L4hMl+QDCsy1uZVRYVrA3r80MgkVgtS6CU5aqkBPEm/CD1oyzDdStt
# li3fn+nC8WpIYCeTHFP2Lzq3F6TjGXhJy7C2UZjlQ35t9S/rerC+GANrdcI8inCs
# tYiYVUIbC9rctjxMwwdkmdLDwaHEobKOqjKAeqNtpSdRLhqCQamr+gSpJFu3m5YT
# rz5T4ZMO/PlDPL0Juoa8L59qyLVejsjYjzjCh1LLjhCNUyaKpo/GtqgXlPWxbBO3
# 58IOwFyiTvh1EFr0vL2VC93suAih+x4g+81BFT+wwTw2GI1HzJAl6ZeXkfTqrOsh
# HiCyXOoKL17fenoYeTEssWqEbji8l3+Av6PNCaeWktnczGwh4mNlGhoa2mK6JwWL
# 3H6eX1rK+/PSsDdFa3blyGgDpVpC65+39rmf31gAJncdm2vekAoCdFbLGV0J2j3u
# MOfVA7SHN4W9ykfgqSYTtzN1d58p0PGu3zH8f+YSV52JUb0dJLgBcvuG1N1+KsI6
# NGSGQIV5wy5jkXHglshmMFDkXLl0k0ews8t5zpHMWIOp/w6RirWDGqonnJaN0ENq
# 4K6SgzbitoHVJ87WdxTFNkQ0ImQ3QGKJGpYSgYcfk50IqtSZUS4cSC6Ym51K5QEg
# wu1F
# SIG # End signature block
