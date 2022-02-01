<#
.SYNOPSIS
This script enable the spesified license options in Microsoft 365.

.DESCRIPTION
This script enable the spesified license options in Microsoft 365.

.PARAMETER Return
Whether to return what options have been set. If unspesified, this is False.

.PARAMETER AccountSkuId
Account SKU ID to run against.

.PARAMETER KeepEnabled
Whether to keep enabled services if nothing is spesified.

.PARAMETER Users
Array of users to run the command against. If unspesified, will run against all licensed users.

.PARAMETER NoForms
An array of users which will have Forms disabled.

.PARAMETER NoFlow
An array of users which will have Flow disabled.

.PARAMETER NoPowerApps
An array of users which will have PowerApps disabled.

.PARAMETER NoPlanner
An array of users which will have Planner disabled.

.PARAMETER NoOfficeOnline
An array of users which will have Office Online disabled.

.PARAMETER NoSharepoint
An array of users which will have Sharepoint disabled.

.PARAMETER NoExchange
An array of users which will have Exchange disabled.

.EXAMPLE
Enable-LicenseOptions

.NOTES
File Name  : Enable-LicenseOptions.ps1  
Version    : 1.3.0
Author     : Roman Zarka | Microsoft Services and ***REMOVED***
Licence    : Creative Commons Attribution-ShareAlike 4.0 International License | https://creativecommons.org/licenses/by-sa/4.0/

by Roman Zarka | Microsoft Services
Copyright (c) ***REMOVED*** 2019-2021

.LINK
https://blogs.technet.microsoft.com/zarkatech/2012/12/05/bulk-enable-office-365-license-options/

.LINK
https://docs.microsoft.com/en-us/microsoft-365/enterprise/assign-licenses-to-user-accounts-with-microsoft-365-powershell?view=o365-worldwide
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [switch]$Return,
  [string]$AccountSkuId = "STANDARDWOFFPACK",
  [switch]$KeepEnabled = $False,
  [switch]$Assign = $False,
  [array]$Users = (Get-MsolUser -All | Where-Object { $_.IsLicensed -eq $true } | Select-Object UserPrincipalName | Sort-Object UserPrincipalName),
  [array]$NoForms = (Get-ADGroupMember -Recursive -Identity "Office 365-No Forms" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoStream = (Get-ADGroupMember -Recursive -Identity "Office 365-No Stream" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoFlow = (Get-ADGroupMember -Recursive -Identity "Office 365-No Flow" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoPowerApps = (Get-ADGroupMember -Recursive -Identity "Office 365-No PowerApps" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoPlanner = (Get-ADGroupMember -Recursive -Identity "Office 365-No Planner" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoTeams = (Get-ADGroupMember -Recursive -Identity "Office 365-No Teams" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoOfficeOnline = (Get-ADGroupMember -Recursive -Identity "Office 365-No Office Online" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoSharepoint = (Get-ADGroupMember -Recursive -Identity "Office 365-No Sharepoint" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoExchange = (Get-ADGroupMember -Recursive -Identity "Office 365-No Exchange" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName)
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

[System.Collections.ArrayList]$Results = @()
$count = 1; $PercentComplete = 0;
ForEach ($User in $Users) {
  #Progress message
  $ActivityMessage = "Setting available licence data for users. Please wait..."
  $StatusMessage = ("Processing {0} of {1}: {2}" -f $count, @($Users).count, $User.UserPrincipalName.ToString())
  $PercentComplete = ($count / @($Users).count * 100)
  Write-Progress -Activity $ActivityMessage -Status $StatusMessage -PercentComplete $PercentComplete
  $count++
  
  # Mark all services as disabled.
  # Services.
  <#
Name            SKU                     Notes
Search          MICROSOFT_SEARCH        This app is assigned at the organization level. It can't be assigned per user.
RMS             RMS_S_BASIC             This app is assigned at the organization level. It can't be assigned per user.
Whiteboard      WHITEBOARD_PLAN1
Todo            BPOS_S_TODO_1
Forms           FORMS_PLAN_E1
Stream          STREAM_O365_E1
Staffhub        Deskless
Power Automate  FLOW_O365_P1
Power Apps      POWERAPPS_O365_P1
Planner         PROJECTWORKMANAGEMENT
Teams           TEAMS1
Sway            SWAY
MDM             INTUNE_O365            This app is assigned at the organization level. It can't be assigned per user.
Yammer          YAMMER_ENTERPRISE
Office Online   SHAREPOINTWAC
Skyper          MCOSTANDARD
Sharepoint      SHAREPOINTSTANDARD
Exchange        EXCHANGE_S_STANDARD
#>

  $Services = @{}
  If ($KeepEnabled) {
    (Get-MsolUser -UserPrincipalName $User.UserPrincipalName).Licenses | Where-Object AccountSkuId -like "*:$AccountSkuId" | ForEach-Object {

      ForEach-Object {
        # Mark currently enabled licenses services as enabled.
        # Comment out the lines for services you wish to force disable.
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "WHITEBOARD_PLAN1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Whiteboard = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "BPOS_S_TODO_1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Todo = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "FORMS_PLAN_E1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Forms = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "STREAM_O365_E1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Stream = $True }
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "Deskless" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.StaffHub = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "FLOW_O365_P1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Flow = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "POWERAPPS_O365_P1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.PowerApps = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "PROJECTWORKMANAGEMENT" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Planner = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "TEAMS1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Teams = $True }
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "SWAY" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Sway = $True }
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "YAMMER_ENTERPRISE" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Yammer = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "SHAREPOINTWAC" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.OfficeOnline = $True }
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "MCOSTANDARD" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Skype = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "SHAREPOINTSTANDARD" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Sharepoint = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "EXCHANGE_S_STANDARD" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Exchange = $True }
      }
    }
  }

  # Services you wish to enable by default.
  $Services.Todo = $True
  $Services.Forms = $True
  $Services.Stream = $True
  $Services.Flow = $True
  $Services.PowerApps = $True
  $Services.Planner = $True
  $Services.Teams = $True
  $Services.OfficeOnline = $True
  $Services.Sharepoint = $True
  $Services.Exchange = $True

  # Disabling services for members of corrosponding group.
  $SearchUpn = "*" + $User.UserPrincipalName + "*"
  If ($NoForms -like $SearchUpn) { $Services.Forms = $False }
  If ($NoStream -like $SearchUpn) { $Services.Stream = $False }
  If ($NoFlow -like $SearchUpn) { $Services.Flow = $False }
  If ($NoPowerApps -like $SearchUpn) { $Services.PowerApps = $False }
  If ($NoPlanner -like $SearchUpn) { $Services.Planner = $False }
  If ($NoTeams -like $SearchUpn) { $Services.Teams = $False }
  If ($NoOfficeOnline -like $SearchUpn) { $Services.OfficeOnline = $False }
  If ($NoSharepoint -like $SearchUpn) { $Services.Sharepoint = $False }
  If ($NoExchange -like $SearchUpn) { $Services.Exchange = $False }
  
  # Disable services still marked as disabled
  $DisabledOptions = @()
  If (!$Services.Whiteboard) { $DisabledOptions += "WHITEBOARD_PLAN1" }
  If (!$Services.Todo) { $DisabledOptions += "BPOS_S_TODO_1" }
  If (!$Services.Forms) { $DisabledOptions += "FORMS_PLAN_E1" }
  If (!$Services.Stream) { $DisabledOptions += "STREAM_O365_E1" }
  If (!$Services.StaffHub) { $DisabledOptions += "Deskless" }
  If (!$Services.Flow) { $DisabledOptions += "FLOW_O365_P1" }
  If (!$Services.PowerApps) { $DisabledOptions += "POWERAPPS_O365_P1" }
  If (!$Services.Planner) { $DisabledOptions += "PROJECTWORKMANAGEMENT" }
  If (!$Services.Teams) { $DisabledOptions += "TEAMS1" }
  If (!$Services.Sway) { $DisabledOptions += "SWAY" }
  If (!$Services.Intune) { $DisabledOptions += "INTUNE_O365" }
  If (!$Services.Yammer) { $DisabledOptions += "YAMMER_ENTERPRISE" }
  If (!$Services.OfficeOnline) { $DisabledOptions += "SHAREPOINTWAC" }
  If (!$Services.Skype) { $DisabledOptions += "MCOSTANDARD" }
  If (!$Services.Sharepoint) { $DisabledOptions += "SHAREPOINTSTANDARD" }
  If (!$Services.Exchange) { $DisabledOptions += "EXCHANGE_S_STANDARD" }
  
  if ($PSCmdlet.ShouldProcess($User.UserPrincipalName, "Enable-LicenseOptions")) {
    If ($Assign) {
      Set-MsolUser -UserPrincipalName $User.UserPrincipalName -UsageLocation CA
      Start-Sleep -Seconds 5
      $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
      $License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value ((Get-AzureADSubscribedSku | Where-Object SkuPartNumber -eq STANDARDWOFFPACK).SkuPartNumber) -EQ).SkuID
      $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
      $LicensesToAssign.AddLicenses = $License
      Set-AzureADUserLicense -ObjectId $User.UserPrincipalName -AssignedLicenses $LicensesToAssign
      Start-Sleep -Seconds 2
    }
    $LicenseOptions = New-MsolLicenseOptions -AccountSkuId ((Get-MsolAccountSku | Where-Object AccountSkuId -like *$AccountSkuId).AccountSkuId) -DisabledPlans $DisabledOptions
    Set-MsolUserLicense -User $User.UserPrincipalName -LicenseOptions $LicenseOptions
  }
  $Result = [PSCustomObject]@{
    Upn          = $User.UserPrincipalName
    Whiteboard   = $Services.Whiteboard
    Todo         = $Services.Todo
    Forms        = $Services.Forms
    Stream       = $Services.Stream
    StaffHub     = $Services.StaffHub
    Flow         = $Services.Flow
    PowerApps    = $Services.PowerApps
    Planner      = $Services.Planner
    Teams        = $Services.Teams
    Sway         = $Services.Sway
    Intune       = $Services.Intune
    Yammer       = $Services.Yammer
    OfficeOnline = $Services.OfficeOnline
    Skype        = $Services.Skype
    Sharepoint   = $Services.Sharepoint
    Exchange     = $Services.Exchange
  }
  $Results += $Result
}
If ($Return) { Return $Results }
# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUzHvyqhrrqJdgXh6iyH689QLb
# ySKggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFKYG9C8c0Nm8Fe+5Kk3E/8UUxres
# MA0GCSqGSIb3DQEBAQUABIICAKZVB9oxVHqVl8TjgrbfrPkVnYg5dzwlZOypz/n0
# iyNzKho3MPLjA4WtzcT7owrXA0Uig60JpXfnaVcoYrZU4RpUlaDpiYdz+XxNJZ/a
# 7MUYOfFGWoEDi5GXKS7HcENamtJXvooYsnYaCR1f1NnM07Wu3hZ/vrl+EGNZgq3M
# LE61nRiXgf397GWLPvH+JAf4rhU2NzAzUmtNXEgsVFL80xYD4SaAi8VuMbKNAguE
# eRkWHGAGNx2gDJUYJWFmx0E9SCnpT6KgBJleI9falCJo0CQmxY4JogjB7VGPTw01
# RZeTRoojZA15ygDHlddtgYOZKqfgWTInf2f3rcwjIQj/Rrh+L1U/DIkAx8KxTjEN
# Z9ZYMbRaB7XZ96VqwZp3XHUc3BmyB1kB+FfYct5L16iHTeWgXa4J2RVv+JpxiM12
# IIcpLdXuyvl6+kBmtkATwlMdmGC25xbikvWHglzMziqyLDrREGqnd/8yqhFq0eT3
# Ynv9wY+ZcmoOmdB7Vg9QbRExBuzp0+F+hN1OhRW0kPcoMpmce+OMVyAW/Ai2cR0k
# WcRQHtaVjQ7LQ+IbWAOANaxtmMAp+QDA2jY5H4zEcVJSJW1HK6k38xUObfGWbx6a
# L6+Qj5fea/HU+K5He1zRW5UXVcSFe3GAWbtwMo9IaT1mpDyk1+PbXpSfUbaLrIYK
# gIYp
# SIG # End signature block
