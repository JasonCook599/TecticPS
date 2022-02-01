<#
.SYNOPSIS
This script will backup MySQL.

.DESCRIPTION
This script will backup MySQL.

.PARAMETER mySqlData
Specifies the MySql Data folder. If unspecified C:\mySQL\data will be used.

.PARAMETER BackupLocation
Specifies the backup location. If unspecified C:\Local\MySqlBackups will be used.

.PARAMETER ConfigFile
Specifies the config file used to connect to MySql Data folder. If unspecified .\my.cnf will be used. Below is an example config file.
[client]
user="User"
password="password"

[mysqldump]
single-transaction
add-drop-database
add-drop-table

.PARAMETER mySqlDump
Specifies the MySqlDump.exe location. If unspecified C:\mySQL\bin\mysqldump.exe will be used.

.PARAMETER NoTrim
This script will prevent trimming the number of backups to the specified number.

.PARAMETER Copies
This is the number of files to keep in the folder. If unspecified, it will keep 10 copies.

.EXAMPLE
Backup-MySql.ps1

.NOTES
File Name  : Backup-MySql.ps1
Version    : 1.0.1
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2018-2021
#>

param(
  [ValidateScript( { Test-Path -Path $_ -PathType Container })][string]$mySqlData = "C:\mySQL\data", #Patch to datatbases files directory
  [ValidateScript( { Test-Path -Path $_ -PathType Container })][string]$BackupLocation = "C:\Local\MySqlBackups", #Backup Directory
  [ValidateScript( { Test-Path -Path $_ -PathType Leaf })][string]$ConfigFile = ".\my.cnf", #Config file
  [ValidateScript( { Test-Path -Path $_ -PathType Leaf })][string]$mySqlDump = "C:\mySQL\bin\mysqldump.exe", #Patch to mysqldump.exe
  [switch]$NoTrim,
  [Int]$Copies = 10 #Number of copies to keep
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

Write-Verbose "Get only names of the databases folders"
$sqlDbDirList = Get-ChildItem -path $mySqlData | Where-Object { $_.PSIsContainer } | Select-Object Name

Write-Verbose "Starting Backup"
Foreach ($dbDir in $sqlDbDirList) {
  Write-Verbose "Starting on $dbDir"
  $dbBackupDir = $BackupLocation + "\" + $dbDir.Name
  Write-Verbose "Checking if $dbDir exits. Create if needed."
  If (!(Test-Path -path $dbBackupDir -PathType Container)) { New-Item -Path $dbBackupDir -ItemType Directory }
  $dbBackupFile = $dbBackupDir + "\" + $dbDir.Name + "_" + (Get-Date -format "yyyyMMdd_HHmmss")
  $sqlFile = $dbBackupFile + ".sql"
  Write-Verbose "Dumping to $sqlFile"
  & $mysqldump --defaults-extra-file=$ConfigFile -B $dbDir.Name -r $sqlFile
}

If (!$NoTrim) {
  Write-Verbose "Trimming backups. Keeping newest $Copies copies."
  Get-ChildItem $BackupLocation -Recurse | Where-Object { $_.PsIsContainer } | Sort-Object CreationTime -Descending | Select-Object -Skip $Copies | Remove-Item -Force
}
# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfb7eQ49xuHeuLOnaAPH4y7ed
# IN2ggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFGKKT7D9uBufartaMF5GfXwYtrWU
# MA0GCSqGSIb3DQEBAQUABIICANZV1t3+r7kuqHrhrrrJl+GIBsZzqyEUwx/5k9+Q
# JZTKUJxDjV05w35vA7v8lZHrgXnrOZ8bT+v52wTgPU73Xz41JiCvs1Wq4xlZiYpC
# e+2oYGGcCTQ58O7nyi9qHqR6m4biDyMfLdd09grZqztBJK4NvjQMB0SVxO9bMCSe
# YcPRyqG1OR6iMdntrfLHBcw+3QPh5twTXQ3UTkWw6A9O2HO+JJGqJXASPze7N2rc
# onaPKSq2cEPNjIB3+G+TWfOJbKYiVEwu+gJvdymB63J+zgDERhxn4IDIYp+8J8i8
# 688dT96slY1luDFNrZtbSH4DoWpBcCUoQQv8RWRhiHNBsAsNTWz84t3VKCgji5xI
# Ry77NxQhL7VnwAASlG1aCcKunRsNGKyciDNz+Q9gYfupqA2dYK8ReBoHYHbzzDAi
# hG2HUIwjQ0h9sOx4cOmjmoDcJHlpnp8G/P65UpXAmN9hToqYi+sFmFF3Xcj3gB3Z
# DnQUL6nwLejTXrbQ2/ZavwOdnBRdxtRLdIwPA7bbLLgM1Wvk4g2qZPmSXWl+IhJ1
# Yxcy9WaLsyT3PE+9fDt80nD2OWWXzBD5AoR7I23XtzE/ZUVSx2FSNbgmZXtfL2fu
# DRS0DigwmOYIDIE85qra8SPLZCz2LlESgNjIjDhNG6K0+/ELNOscbUw6Llv4Ips6
# khDP
# SIG # End signature block
