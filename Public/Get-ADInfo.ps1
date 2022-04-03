<#PSScriptInfo

.VERSION 1.0.1

.GUID 868aac51-6c72-482e-8b54-42a3c5f87596

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
The script will get information about users, groups, and computers from Active Directory.

.DESCRIPTION
The script will get information about users, groups, and computers from Active Directory.

.PARAMETER ListUpn
List the UPN for each user. Can be combined with -Filter.

.PARAMETER LikeUpn
Filters for a specific UPN. Must be used in conjunction with -ListUpn. This overrides -Filter.

.PARAMETER ListHomeDirectory
List the home directory for each user.  Can be combined with -Filter.

.PARAMETER Filter
Filters the search based on the spesified parameters.

.PARAMETER ListComputerPasswords
List the local admin password. Can be combined with -Filter.

.PARAMETER UpdateUpn
Updates the Upn. Must be used with -OldUpn and -NewUpn. Can be combined with -SearchBase

.PARAMETER OldUpn
Specifes the UPN to be changed from. If unspecified, will use "*@koinonia.local".

.PARAMETER NewUpn
Spesified the UPN to change to.  If unspecified, will use "*@***REMOVED***".

.PARAMETER SearchBase
Specifies the search base for the command.

.PARAMETER ListComputers
List the computers in the organization.  Can be combined with -Filter.

.PARAMETER Export
Export to a CSV file using the hard-coded search parameters. If no file specified, will use .\AD Users.csv

.PARAMETER Sid
Matches the specified SID to a user.

.EXAMPLE
Get-ADInfo.ps1 -listUpn
name       UserPrincipalName
----       -----------------
Jane Doe   Jane.Doe@domain1.com
John Doe   John.Doe@domain2.com

.EXAMPLE
Get-ADInfo.ps1 -listUpn -likeUpn domain2
name       UserPrincipalName
----       -----------------
John Doe   John.Doe@domain2.com

.EXAMPLE
Get-ADInfo.ps1 -listHomeDirectory
name      homeDirectory                           profilePath
----      -------------                           -----------
Jane Doe  \\server.domain1.com\Profile\Jane.Doe\
John Doe  \\server.domain2.com\Profile\John.Doe\

.EXAMPLE
Get-ADInfo.ps1 -ListComputerPasswords
name            ms-Mcs-AdmPwd
----            -------------
JANEDOE-LAPTOP  *TVCiN#8bMVOW
JOHNDOE-LAPTOP  r4o1eY747KXN6Ty
#>

param(
  [string]$Filter,
  [switch]$ListUpn,
  [string]$likeUpn,
  [switch]$updateUpnSuffix,
  [string]$oldUpnSuffix,
  [string]$newUpnSuffix,
  [string]$SearchBase,
  [switch]$ListHomeDirectory,
  [switch]$ListComputers,
  [switch]$ListComputerPasswords,
  [switch]$ListExtensions,
  [switch]$Export,
  [string]$Sid
)

$meActual = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$me = "${meActual}:"
$parent = Split-Path $script:MyInvocation.MyCommand.Path

Function checkAdmin {
  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
		}
}

If (!(Get-Module ActiveDirectory)) { Import-Module ActiveDirectory }

# List UPN
If ($ListUpn) {
  If ($likeUpn) {
    $UpnFilter = "*" + $likeUpn + "*"
  }
  Elseif ($Filter) {
    $UpnFilter = $Filter
  }
  Else {
    $UpnFilter = "*"
  }
  Write-Verbose "$me Listing all users with a UPN like $filter. Sorting by UPN"
  Get-ADUser -Filter { UserPrincipalName -like $UpnFilter } -Properties distinguishedName, UserPrincipalName | Select-Object name, UserPrincipalName | Sort-Object -Property UserPrincipalName | Format-Table
}

# Update UPN
If ($updateUpnSuffix) {
  Write-Verbose "$me Setting old UPN, new UPN, and Search Base if not specified."
  If (!$oldUpnSuffix) { $oldUpnSuffix = "@koinonia.local" }
  $OldUpnSearch = "*" + $oldUpnSuffix
  If (!$newUpnSuffix) { $newUpnSuffix = "@***REMOVED***" }
  If (!$searchBase) { $searchBase = "DC=koinonia,DC=local" }
  Write-Verbose "$me Starting update..."
  checkAdmin
  Write-Information -MessageData "$me Changing UPN to $newUpnSuffix for all uses with a $oldUpnSuffix UPN in $searchBase." -InformationAction Continue
  Get-ADUser -Filter { UserPrincipalName -like $OldUpnSearch } -SearchBase $searchBase |
  ForEach-Object {
    $OldUpn = $_.UserPrincipalName
    $Upn = $_.UserPrincipalName -ireplace [regex]::Escape($oldUpnSuffix), $newUpnSuffix
    Set-ADUser -identity $_ -UserPrincipalName $Upn
    $NewUpn = $_.UserPrincipalName
    Write-Verbose "$me Changed $OldUpn to $NewUpn"
  }
}

If ($ListHomeDirectory) {
  If (!$filter) { $filter = "*" }
  Write-Verbose "$me Listing all users with their Home Directory and Profile Path. Sorting by Home Directory"
  Get-ADUser -Filter $filter -Properties homeDirectory, profilePath  | Select-Object name, homeDirectory, profilePath | Sort-Object -Property homeDirectory -Descending | Format-Table
}

If ($ListComputers) {
  If (!$filter) { $filter = "*" }
  Write-Verbose "$me Getting OS Versions"
  Get-ADComputer -Filter * -Property Name, OperatingSystem, OperatingSystemVersion, operatingSystemServicePack | Sort-Object @{Expression = 'OperatingSystem'; Ascending = $true }, @{Expression = 'operatingSystemVersion'; Ascending = $false }, @{Expression = 'Name'; Ascending = $true } | Format-Table Name, OperatingSystem, OperatingSystemVersion, operatingSystemServicePack -Wrap -Auto
}

Function listComputerPasswords {
  param([string]$Filter, [string]$Message)
  If (!$filter) { $filter = "*" }
  checkAdmin
  Write-Information -MessageData "$Message" -InformationAction Continue
  Get-ADComputer -Filter $Filter -Properties ms-Mcs-AdmPwd | Select-Object name, ms-Mcs-AdmPwd | Sort-Object -Property ms-Mcs-AdmPwd -Descending | Format-Table
}
If ($ListComputerPasswords -AND $Filter) {
  listComputerPasswords -Message "$me Computers matching $filter." -Filter $Filter
}
Elseif ($ListComputerPasswords) {
  listComputerPasswords -Message "$me Non-mac passwords." -Filter 'Name -notlike "*-DM" -and Name -notlike "*-LM" -and Enabled -eq $True'
  listComputerPasswords -Message "$me Mac passwords." -Filter 'Name -like "*-DM" -or Name -like "*-LM" -and Enabled -eq $True'
  listComputerPasswords -Message "$me Disabled computer accounts." -Filter 'Enabled -eq $False'
}
  


If ($ListExtensions) {
  If (!$filter) { $filter = "*" }
  Write-Verbose "$me Getting ipPhone"
  Get-ADUser -LDAPFilter "(ipPhone=*)" -Properties ipPhone  | Select-Object name, ipPhone | Sort-Object -Property ipPhone
}

If ($Export) {
  #File Location
  If ($Export) { $ExportFile = $Export }
  If (!$ExportFile) { $ExportFile = $parent + "\AD Users.csv" }
  Write-Verbose "$me Writing to $ExportFile"

  #Set the domain to search at the Server parameter. Run powershell as a user with privilieges in that domain to pass different credentials to the command.
  #Searchbase is the OU you want to search. By default the command will also search all subOU's. To change this behaviour, change the searchscope parameter. Possible values: Base, onelevel, subtree
  #Ignore the filter and properties parameters

  $ADUserParams = @{
    'Server'      = 'KCFAD01.***REMOVED***.local'
    'Searchbase'  = 'OU=_***REMOVED***,DC=***REMOVED***,DC=local'
    'Searchscope' = 'Subtree'
    'Filter'      = '*'
    'Properties'  = '*'
  }

  #This is where to change if different properties are required.
  $SelectParams = @{
    'Property' = 'SAMAccountname', 'CN', 'title', 'DisplayName', 'Description', 'EmailAddress', 'mobilephone', @{name = 'businesscategory'; expression = { $_.businesscategory -join '; ' } }, 'office', 'officephone', 'state', 'streetaddress', 'city', 'employeeID', 'Employeenumber', 'enabled', 'lockedout', 'lastlogondate', 'badpwdcount', 'passwordlastset', 'created'
  }

  Get-ADUser @ADUserParams | Select-Object @SelectParams | Export-Csv $ExportFile
}

If ($Sid) {
  If (!$Sid) { Write-Error "Please specify a SID using the -SID paramater" }
  $Sid = [ADSI]"LDAP://<SID=$Sid>"
  Write-Output $Sid
}
# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpcVU5usHqV8/cHjCY+k8SjIC
# oLyggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFAgPKbjjWU1mkYk7wJVacHjS09ri
# MA0GCSqGSIb3DQEBAQUABIICAD8b77y561Y1f3cR7bo9DayrCDi22fpm5FUZnmfl
# mWiq+WUez4YbvrQR7ERgwgs3d7WUqw9kffWsnNzXysHsBGt7BuEnFVDQxHnLcNan
# cv75Rfwcv4FBxUg3A7rsM+g3cXeUUp3v10tUot/sQNPqvFEd3AgiQxFXbcZddV4R
# /gnHuBcx+CiPCyNvgGZ8gdU4f+OUKkNRsJNBfuEVc821hZfYGoJAhzp4ZsDLpWtd
# uaNe6y6oYN0MN87xqkq2Y/D83ZwpkWJvu0I/kVLJc5ufZfQOet/Sb7hADepOrMZ9
# TvHu61r06MXbgzKsi9gvLI7RIqyYdiVzCDkrLYjs+m1sIe6eIUedIedVoELUcUyP
# gGRpkwAKxhldftU+LY7kgxiLZW4YhQbhnoVPX46dwVuDRGaDcE/iiMd8ObVEm+Sn
# O5zAz7NNbseneAvty025HqUZWkRdBvhLqSrJp++2Bvvh3Dz3oKwLBP//jdC2aPUf
# uHvLFC4Yg0vUJOtalW5HLbkP+j6gKwqD1WIOdB45A3VA7tveMBYvwXb/F8e12Ir1
# HUzxJDSETZvEVGeO4faVkL/BuoFXFvG9Aqkv7Vo6IP7wAsAkAWPCUsmOcAagsbRp
# +9fVqnDyQArD0jNSaGw7CNkRw0LkrLUKRRxdm1L6vPh896RVc43eCvAMR/7n724N
# A34g
# SIG # End signature block
