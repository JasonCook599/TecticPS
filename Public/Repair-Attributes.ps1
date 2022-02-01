[CmdletBinding(SupportsShouldProcess = $true)]
param ()
Write-Verbose "Removing legacy attributes for users"
Get-ADUser -Filter *  | Sort-Object  SamAccountName, UserPrincipalName | Set-ADUser -Clear msExchMailboxGuid, msexchhomeservername, legacyexchangedn, mailNickname, msexchmailboxsecuritydescriptor, msexchpoliciesincluded, msexchrecipientdisplaytype, msexchrecipienttypedetails, msexchumdtmfmap, msexchuseraccountcontrol, msexchversion, targetAddress
Write-Verbose "Remove legacy attributes for non-Office 365 groups"
Get-ADGroup -Filter * | Where-Object Name -notlike "Group_*" | Sort-Object  SamAccountName, UserPrincipalName | Set-ADGroup -Clear msExchMailboxGuid, msexchhomeservername, legacyexchangedn, mailNickname, msexchmailboxsecuritydescriptor, msexchpoliciesincluded, msexchrecipientdisplaytype, msexchrecipienttypedetails, msexchumdtmfmap, msexchuseraccountcontrol, msexchversion, targetAddress

Write-Verbose "Remove legacy proxy addresses for users"
Get-ADUser -Filter * -Properties ProxyAddresses | ForEach-Object { $Remove = $_.proxyaddresses | Where-Object { $_ -like "X500*" -or $_ -like "X400*" -or $_ -like "*@***REMOVED***CF.mail.onmicrosoft.com" }; ForEach ($proxyAddress in $Remove) { Write-Output "Removing $ProxyAddress"; Set-ADUser -Identity $_.Name -Remove @{'ProxyAddresses' = $ProxyAddress } } }
Write-Verbose "Remove legacy proxy addresses for non-Office 365 groups"
Get-ADGroup -Filter * -Properties ProxyAddresses | Where-Object Name -notlike "Group_*" | ForEach-Object { $Remove = $_.proxyaddresses | Where-Object { $_ -like "X500*" -or $_ -like "X400*" -or $_ -like "*@***REMOVED***CF.mail.onmicrosoft.com" }; ForEach ($proxyAddress in $Remove) { Write-Output "Removing $ProxyAddress"; Set-ADGroup -Identity $_.Name -Remove @{'ProxyAddresses' = $ProxyAddress } } }

Write-Verbose "Remove proxy addresses if only one exists for users"
Get-ADUser -Filter * -Properties ProxyAddresses | Where-Object { $_.ProxyAddresses.Count -eq 1 } | Set-ADUser -Clear ProxyAddresses
Write-Verbose "Remove proxy addresses if only one exists for non-Office 365 groups"
Get-AdGroup -Filter * -Properties ProxyAddresses | Where-Object Name -notlike "Group_*" | Where-Object { $_.ProxyAddresses.Count -eq 1 } | Set-ADGroup -Clear ProxyAddresses

Write-Verbose "Clear mailNickname if mail attribute empty for users"
Get-ADUser -Filter * -Properties mail, mailNickname | Where-Object mail -eq $null | Where-Object mailNickname -ne $null | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Clear mailNickname }
Write-Verbose "Clear mailNickname if mail attribute empty for non-Office 365 groups"
Get-ADGroup -Filter * -Properties mail, mailNickname | Where-Object mail -eq $null | Where-Object mailNickname -ne $null | Where-Object Name -notlike "Group_*" | ForEach-Object { Set-ADGroup -Identity $_.SamAccountName -Clear mailNickname }

Write-Verbose "Set mailNickname to SamAccountName for users"
Get-ADUser -Filter * -Properties mail, mailNickname | Where-Object mail -ne $null | Where-Object { $_.mailNickname -ne $_.SamAccountName } | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Replace @{mailNickname = $_.SamAccountName } }
Write-Verbose "Set mailNickname to SamAccountName for non-Office 365 groups"
Get-ADGroup -Filter * -Properties mail, mailNickname | Where-Object mail -ne $null | Where-Object { $_.mailNickname -ne $_.SamAccountName } | Where-Object Name -notlike "Group_*" | ForEach-Object { Set-ADGroup -Identity $_.SamAccountName -Replace @{mailNickname = $_.SamAccountName } }

Write-Verbose "Set title to mail attribute for general delivery mailboxes. Used to easily show address in Sharepoint"
Get-ADUser -Filter * -SearchBase 'OU=Mailboxes,OU=Mail Objects,OU=_***REMOVED***,DC=***REMOVED***,DC=local' -Properties mail | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Title $_.mail }
  
Write-Verbose "Clear telephoneNumber attribute if mail atrribute is empty"
Get-ADUser -Filter * -Properties ipPhone, mail, telephoneNumber | Where-Object mail -eq $null | Where-Object telephoneNumber -ne $null | Set-ADUser -Clear telephoneNumber
Write-Verbose "Set telephoneNumber attribute to main line if ipPhone attribute is empty"
Get-ADUser -Filter * -Properties ipPhone, mail, telephoneNumber | Where-Object mail -ne $null | Where-Object ipPhone -eq $null | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Replace @{telephoneNumber = "+1 5197447447" } }
Write-Verbose "Set telephoneNumber attribute to main line with extension if ipPhone attribute is present"
Get-ADUser -Filter * -Properties ipPhone, mail, telephoneNumber | Where-Object mail -ne $null | Where-Object ipPhone -ne $null | ForEach-Object { $telephoneNumber = "+1 5197447447 x" + $_.ipPhone.Substring(0, [System.Math]::Min(3, $_.ipPhone.Length)) ; Set-ADUser -Identity $_.SamAccountName -Replace @{telephoneNumber = $telephoneNumber } }
# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU8hI+GLWhlYd6IKWNSkrKgubV
# /wyggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFBW1lN08cIb23jVZk//xxupolNVf
# MA0GCSqGSIb3DQEBAQUABIICALIV95m3nMdZpo5TrYa7Lh2LMIqSIUlplb2A3GwV
# EalmjplYEshHRfehrpfTrIIGpxBksqkoGEWlOAIXHN/gdioXVLxbyZRPSirCqjBe
# kxgJu/bWpLFNe2tBsIrNWrE0VEAIH903VeN4BViEz+2hBVb2OT1yGyzMSa5NE8Rf
# BJ6YS+KTOK29KLOsFBuO1zNKEl9PS1X9s12lG6jqX2s2Gvlel7nCNwDFLCzCIFVI
# 6bORofVyeVlkcfvI+ty5+E9SZCy1WWEVCpSHkvB+lVRr7/HkoR5TF1ZLM9IqO+HA
# C1LZ/yE0Rl2yefHZQYtyNg9Wb95TKEkfga5Zll2oXzfcXLwHWt9vgRJiYnyThXpw
# jc1Fma6fI4/eQ1QtKtpHXdDt8AanCEePfQdgmj1eyauaGmoXpYQQBjE22wmmZopv
# 4ffC8W8HWCgOZUopifurH79OS8rUTh6y4cMb5nUQ6Iq4oWOHEEKmrgtumhaVJcle
# u5MMnSb0gZf95Q2s1vpBU9qqVIxQ5rYFX/GTBynSzUyW5r+a2DvsfH0oK9LbanmX
# j+/bePvE902IXHGITVXyL8Y57tF5Gh2ixXQCY2OK1a8QM1Uuqef5ovmLPuZUSUOP
# nTTyI7705ejxV5iIACbtOMEjnw34nxYK94DDV2eCz2Dg6+pu05QhP+0VC5nTdFvY
# jCrd
# SIG # End signature block
