<#PSScriptInfo

.VERSION 1.2.7

.GUID 8ab0507b-8af2-4916-8de2-9457194fb454

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


.PRIVATEDATA

#> 

<#
.SYNOPSIS
This script will install the neccesary applications and services on a given machine.

.DESCRIPTION
This script will install the neccesary applications and services on a given machine. It will also check for updates to third-party applications. This script will also configure certain items not able to be configured by Group Policy,

.PARAMETER BitLockerProtector
If a protector is specified, BitLocker will be enabled using that protector. Valid options are TPM, Pin, Password, and USB. You can also pass Disable to disable BitLocker

.PARAMETER BitLockerEncryptionMethod
Used to specify the encryption method for BitLocker. If unspecified, XtsAes256 will be used.

.PARAMETER BitLockerUSB
If the USB protector is spesified, use this to specify the USB drive to use.

.PARAMETER DriveLabel
This specifies what the drive will be labeled as. If unspecified, "Windows" will be used.

.PARAMETER DriveToLabel
This specifies which drive to label. If unspecified, the system drive will be used.

.PARAMETER Ninite
If specified, Ninite will be run and install the default third party applications.

.PARAMETER InstallTo
Specifies the defgault install device type for Ninite. Will use Ninite's default if unspecified.

.PARAMETER NetFX3
If specified, ".NET Framework 3.5 (includes .NET 2.0 and 3.0)" will be installed.

.PARAMETER ProvisioningPackage
Choose a Provisioning Package to be installed.

.PARAMETER RSAT
If specified, Remote Server Administrative Tools will be installed.

.PARAMETER Office
Specifes the version of Office to install. If unspecified, Office will not be installed.
  
.EXAMPLE
Install.ps1 -BitLocker -Office 2019

#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateSet("TPM", "Password", "Pin", "USB")][string]$BitLockerProtector,
  [string]$Office,
  [switch]$RSAT,
  [string]$ProvisioningPackage,
  [switch]$NetFX3,
  [switch]$Ninite,
  [string]$NiniteInstallTo = "Workstation",
  [ValidateScript({ Test-Path $_ })][string]$BitLockerUSB,
  [string]$BitLockerEncryptionMethod = "XtsAes256",
  [string]$DriveLabel = "Windows",
  [string]$DriveToLabel = ($env:SystemDrive.Substring(0, 1))
)

$meActual = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$me = "${meActual}:"
$parent = Split-Path $script:MyInvocation.MyCommand.Path

Import-Module $parent\***REMOVED***It\***REMOVED***IT.psm1 -Force
If (!(Test-Admin -Warn)) { Break }

If ($BitLockerProtector) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Enable-Bitlocker with `'$BitLockerProtector`' protector using $BitLockerEncryptionMethod")) {
    If ($BitLockerProtector -eq "Disable") { Disable-BitLocker -MountPoint $env:SystemDrive }
    Else {
      Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -RecoveryPasswordProtector
      $BLV = Get-BitLockerVolume -MountPoint $env:SystemDrive
      $RecoveryPassword = $BLV.KeyProtector | Where-Object KeyProtectorType -eq "RecoveryPassword"
      Backup-BitLockerKeyProtector -MountPoint $env:SystemDrive -KeyProtectorId $RecoveryPassword.KeyProtectorId | Out-Null
      If ($BitLockerProtector -eq "TPM") {
        Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod $BitLockerEncryptionMethod -TpmProtector
      }
      ElseIf ($BitLockerProtector -eq "Password") {
        $BitLockerSecurePassword = Read-Host -Prompt "Enter Password" -AsSecureString
        Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod $BitLockerEncryptionMethod -PasswordProtector -Password $BitLockerSecurePassword
      }
      ElseIf ($BitLockerProtector -eq "Pin") {
        $BitLockerSecurePin = Read-Host -Prompt "Enter PIN" -AsSecureString
        Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod $BitLockerEncryptionMethod -TPMandPinProtector -Pin $BitLockerSecurePin 
      }
      ElseIf ($BitLockerProtector -eq "USB") {
        Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod $BitLockerEncryptionMethod -StartupKeyProtector -StartupKeyPath $BitLockerUSB
      }
      Else {
        Write-Warning "No valid protector spesified. BitLocker will NOT be enabled."
      }
    }
  }
}

If ($NetFX3) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install .NET Framework 3.5 (includes .NET 2.0 and 3.0)")) {
    Write-Verbose "Installing .NET Framework 3.5 (includes .NET 2.0 and 3.0)"
    Get-WindowsCapability -Online -Name NetFx3* | Add-WindowsCapability -Online
  }
}

If ($RSAT) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install Remote Server Administrative Tools")) {
    Write-Verbose "Install Remote Server Administrative Tools"
    Get-WindowsCapability -Online -Name "RSAT*" | Add-WindowsCapability -Online
  }
}
If ($Ninite) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername) $NiniteInstallTo", "Install apps using Ninite")) {
    Write-Verbose "Running Ninite"
    & $parent\..\Ninite\Ninite.ps1 -Local -InstallTo $NiniteInstallTo
  }
}

If ($Office) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install Office $Office")) {
    Install-MicrosoftOffice -Version $Office
  }
}


If ($ProvisioningPackage) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install-ProvisioningPackage -QuietInstall -PackagePath $ProvisioningPackage")) {
    If (Test-Path -PathType Leaf -Path $ProvisioningPackage) { Install-ProvisioningPackage -QuietInstall -PackagePath $ProvisioningPackage }
    else { Write-Warning "$me The provisioning file specified is not valid." }
  }
}

If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Set-Volume -DriveLetter $DriveToLabel -NewFileSystemLabel $DriveLabel")) {
  Set-Volume -DriveLetter $DriveToLabel -NewFileSystemLabel $DriveLabel
  Write-Verbose "$me Checking for reboot."
  Import-Module $parent\Modules\pendingreboot.0.9.0.6\pendingreboot.psm1
  If ((Test-Path "HKLM:\SOFTWARE­\Microsoft­\Windows­\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") -or (Test-PendingReboot -SkipConfigurationManagerClientCheck).IsRebootPending) {
    Write-Verbose "A reboot is required. Reboot now?"
    Restart-Computer -Confirm
  }
}
# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSA38466RroXlOTA+s4r3OZyz
# fLqggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFKsbwG9Sh5IAqtI77c6M0BCIY6ux
# MA0GCSqGSIb3DQEBAQUABIICAD22KEGqamXbQauWWrnwbwPFh5OKx5L6Ja/kFYUj
# SnetrgOKRADw8+1MN4NrmcEaTlNnyYMQiRHcor7pRtH+IkmW8vz1kI/B8kZO24WY
# 5Ey1kqYCH8C9U9uLkXDaD+RpZzNNb/KnnlgQZp4m4waXcPBOcXDUq9syQRoQUJ5y
# HjjjOLS15Vb8lPb6Q3XP//+aSfdFIg8RwNMnjPjnkW9coS/bfYmsVUFOEoSdeUFu
# morDF/EkX9lht+Hby556PuqRDQxv2qsvsuE2Bkgex+o6anHNSOziQy7oN3M0CXSy
# CrXrg7isP9Gwusv+hWfvJg2dtnnFefONddjq3rx6WB3BiOWLPi91hHfrRBkW1zPB
# bLF7bDcYpUZpCNwUBuhx3oai0X4cn8/pZlJpMfFjmr/xC+HP41Fw+2N4ysR0uEgW
# 4YqWFVj5ifpLZzAq2FUegqwxX2UorHIn7ZE4OU7i0AKUb5uZZEl4GPh0eL1NayD7
# Kh/pHrhC764VahkpOZ1nT1tkf8+gizuokDvSyG41z3oTy/GoFlWzBTIVDdsVV3vL
# rBqfSM0Fc7sbPStyHRKkELEDDVlJ2iNAwOZ1VnaiuZIdKfdR6oiUClMNp440xhxg
# dcU6KrsVGjgSuyeZ8fk7XEDDmEQtdDWshQzuHCoJQF89Ani7L3w4aVDMHNIBui8x
# W68q
# SIG # End signature block
