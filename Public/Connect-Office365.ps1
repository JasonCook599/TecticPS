<#
.SYNOPSIS
This script will connect to various Office 365 services.

.DESCRIPTION
To connect to Azure Active Directory, you must first install "Microsoft Online Services Sign-in Assistant". This script will install the "MSOnline" module if required. Instructions are availible here (https://docs.microsoft.com/en-us/office365/enterprise/powershell/connect-to-office-365-powershell) and download here (https://www.microsoft.com/en-us/download/details.aspx?id=41950).

To connect to Sharepoint Online, you must first install "SharePoint Online Management Shell". Instructions are availible here (https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps) and download here (https://www.microsoft.com/en-ca/download/details.aspx?id=35588).

To connect to Skype for Business Online, you must first install "Skype for Business Online, Windows PowerShell Module". Instructions are availible here (https://docs.microsoft.com/en-us/office365/enterprise/powershell/manage-skype-for-business-online-with-office-365-powershell) and download here (https://www.microsoft.com/en-us/download/details.aspx?id=39366).

To connect to Exchange Online, you must first install "Microsoft.NET Framework 4.5" or later and then either the "Windows Management Framework 3.0" or the "Windows Management Framework 4.0". Instructions without MFA are availible here (https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/connect-to-exchange-online-powershell?view=exchange-ps). Instructions with MFA are availible here (https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/mfa-connect-to-exchange-online-powershell?view=exchange-ps)


.LINK
https://docs.microsoft.com/en-us/office365/enterprise/powershell/connect-to-office-365-powershell
.LINK
https://www.microsoft.com/en-us/download/details.aspx?id=41950
.LINK
https://docs.microsoft.com/en-us/office365/enterprise/powershell/manage-skype-for-business-online-with-office-365-powershell
.LINK
https://www.microsoft.com/en-us/download/details.aspx?id=39366

.LINK
https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps
.LINK
https://www.microsoft.com/en-ca/download/details.aspx?id=35588
.LINK
https://technet.microsoft.com/en-us/library/fp161372.aspx
.LINK
https://www.microsoft.com/en-us/download/details.aspx?id=35588
.LINK
https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/connect-to-exchange-online-powershell?view=exchange-ps
.LINK
https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/mfa-connect-to-exchange-online-powershell?view=exchange-ps

.PARAMETER Tenant
Specifies the Microsoft 365 tenant name.

.PARAMETER UPN
used to autofill the UPN for supported services.

.PARAMETER BasicAuth
Use basic auth.

.PARAMETER Credential
The credentials for basic auth.


.PARAMETER AzureAD
Connect to Azure Active Directory.

.PARAMETER MsolService
Connect to Microsoft Online (MSOL).

.PARAMETER SharepointOnline
Connects to Sharepoint Online.

.PARAMETER SkypeForBusinessOnline
Connects to Skype for Business.

.PARAMETER ExchangeOnline
Connect to Exchange Online.

.PARAMETER SecurityComplianceCenter
Connects to Security and Compliance Center

.PARAMETER Teams
Connects to Microsoft Teams.

.PARAMETER StaffHub
Connects to StaffHub.

.PARAMETER Disconnect
Disconnects from supported services

.NOTES
File Name  : Connect-ExchangeOnline.ps1  
Version    : 2.1.0
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2019-2021
#>
param(
	[ValidatePattern("^[^.]+$")][string]$Tenant,
	[ValidatePattern("^([^@]+)@(.+)")][string]$UPN = ([ADSI]"LDAP://<SID=$([System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value)>").UserPrincipalName,
	[PSCredential]$Credential,
	[switch]$BasicAuth,
	[switch]$AzureAD,
	[switch]$MsolService,
	[switch]$SharepointOnline,
	[switch]$SkypeForBusinessOnline,
	[switch]$ExchangeOnline,
	[switch]$SecurityComplianceCenter,
	[switch]$Teams,
	[switch]$StaffHub,
	[switch]$Disconnect
)

. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

While (-NOT $Tenant) { $Tenant = Read-Host -Prompt "Enter your Office 365 tennant. Do not include `".onmicrosoft.com`"" }
While (-NOT $UPN) { $UPN = Read-Host -Prompt "Enter your User Principal Name (UPN)" }

InstallModule -Name AzureAD #-AltName AzureADPreview
InstallModule -Name MSOnline
InstallModule -Name Microsoft.Online.SharePoint.PowerShell
InstallModule -Name ExchangeOnlineManagement
InstallModule -Name MicrosoftTeams
InstallModule -Name MicrosoftStaffHub

If ($BasicAuth -and (-not $Credential)) { $Credential = Get-Credential -UserName $UPN }

If ($Disconnect) {
	Write-Verbose "$me Disconnecting from all services."
	Remove-PSSession $sfboSession | Write-Verbose
	Remove-PSSession $exchangeSession | Write-Verbose
	Remove-PSSession $SccSession | Write-Verbose
	Disconnect-SPOService | Write-Verbose
}
Else {
	If ($AzureAD) {
		Write-Verbose "$me Connecting to AzureAD"
		If (Get-Module -Name AzureAdPreview -ListAvailable) { Import-Module AzureAdPreview | Write-Verbose }
		elseif (Get-Module -Name AzureAD -ListAvailable) { Import-Module AzureAD | Write-Verbose }
		else { Write-Error "$me Azure AD Module not available." }
		If ($BasicAuth) { Connect-AzureAD -Credential $Credential }
		Else { Connect-AzureAD -AccountId $UPN | Write-Verbose }
	}
	If ($MsolService) {
		Write-Verbose "$me Connecting to MsolService"
		If ($BasicAuth) { Connect-MsolService -Credential $Credential | Write-Verbose }
		Else { Connect-MsolService | Write-Verbose }
	}
	If ($SharepointOnline) {
		Write-Verbose "$me Connecting to Sharepoint Online"
		Import-Module Microsoft.Online.SharePoint.PowerShell | Write-Verbose
		If ($BasicAuth) { Connect-SPOService -Url https://$Tenant-admin.sharepoint.com -Credential $Credential | Write-Verbose }
		Else { Connect-SPOService -Url https://$Tenant-admin.sharepoint.com | Write-Verbose }
	}
	If ($SkypeForBusinessOnline) {
		Write-Verbose "$me Connecting to Skype For Business Online"
		Import-Module SkypeOnlineConnector | Write-Verbose
		If ($BasicAuth) { $sfboSession = New-CsOnlineSession -Credential $Credential | Write-Verbose }
		Else { $sfboSession = New-CsOnlineSession -UserName $UPN }
		Import-PSSession $sfboSession | Write-Verbose
	}
	If ($ExchangeOnline) {
		Write-Verbose "$me Connecting to Exchange Online"
		If (Get-Command Connect-ExchangeOnline -ErrorAction SilentlyContinue) {
			If ($BasicAuth) { Connect-ExchangeOnline -Credential $Credential | Write-Verbose }
			Else { Connect-ExchangeOnline -UserPrincipalName $UPN | Write-Verbose }
		}
		Else {
			If ($BasicAuth) {
				$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $Credential -Authentication "Basic" -AllowRedirection
				Import-PSSession $exchangeSession -DisableNameChecking | Write-Verbose
			}
			Else { Connect-ExchangeOnline -Credential $Credential | Write-Verbose }
		}
	}
	If ($SecurityComplianceCenter) {
		If ($BasicAuth) {
			$SccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $Credential -Authentication "Basic" -AllowRedirection
			Import-PSSession $SccSession -Prefix cc | Write-Verbose
		}
		Else {
			Write-Verbose "$me Connecting to Security and Compliance Center"
			Write-Warning "$me Cannot connect to Security  Compliance Center multi-factor authentication in this session. See for more information: https://docs.microsoft.com/powershell/exchange/office-365-scc/connect-to-scc-powershell/mfa-connect-to-scc-powershell?view=exchange-ps"
			Connect-IPPSSession -UserPrincipalName $UPN
		}
	}
	If ($Teams) {
		Write-Verbose "$me Connecting to Teams"
		Import-Module MicrosoftTeams | Write-Verbose
		If ($BasicAuth) { Connect-MicrosoftTeams $Credential | Write-Verbose }
		Else { Connect-MicrosoftTeams -AccountId $UPN | Write-Verbose }
	}
	If ($StaffHub -OR $Settings.Services.StaffHub) {
		Write-Verbose "$me Connecting to StaffHub"
		If ($BasicAuth) { Connect-MicrosoftTeams $Credential | Write-Verbose	}
		Else { Connect-StaffHub | Write-Verbose }
	}
}
# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUgPsuysmpfmPu3V2FVwpZ9fW9
# EF+ggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFPunEQLNVtXlIGmVXiBh5dmXrYEM
# MA0GCSqGSIb3DQEBAQUABIICAJ/UbVz0beEbDSCia863dSN85kSXPUGkGfLprxMA
# 4mKB0uglkrumv1VY39bjihOG7DeOzx8NwW8B6hWFLbKDrzkho61kuQK69VB96+rv
# RfoE0gm5cOfiWF+h5lJ5s4WL92ZVAsNNmjTCpFjX29YKDEtZAzhh9Yx+PJYAJZ1h
# 7sKsdhLpwAbQC7tgVEiM46Y4laG4FXvKjS0QBmZFGyR6+JyhKzrEpw+BBSGwSl+I
# gywPDdmf0X668SiqYMjjMKGVujZAl/Ipc5adxNj1vEb5w2/VZSXsi6VZSgiNuaDu
# fW1OhUClM8AmDRiYdU9iDFXva9Cr7XxFUqqp9rjn/Zrgg3x1iUOpRW5zLEPCgdFf
# 4nUIM7N5TpEiyNyneKDmjQXUQ2cz86ovntmeIokNNAL2o2q2uQLBUoPfJU++jwoZ
# XkV8KCyAg/CbC0ETvxcywbSzKmjdyD9xT0scdpxL3ybRBqC5B6f4VUJPOs099paX
# hxjJvGB7YmTOEDSbGTBb9iHXAV7B/TkXN+Fg1otehkP4tptZiDKZNT5UQEaYOi+j
# sB1PLWpblbbUGZsST2kM4H+omR7Fp/Ie7/tLfnaTO3kDz7CsELmAZhfRfcm7VQa+
# yZLL+f5i/ZXgEiXQ31LYUgNukA1CQ1j3DtxbazBE3VFPRVZYBLGGxWxZI29cnhoH
# KGPG
# SIG # End signature block
