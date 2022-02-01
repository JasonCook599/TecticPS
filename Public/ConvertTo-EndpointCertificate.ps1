<#
    .SYNOPSIS
    This script will convert a PFX certificate for use with various services.

    .DESCRIPTION
    This script will convert a PFX certificate for use with various services. If will also provide instructions for any system that has spesific requirements for setup. This script requires & .\openssl.exe  to be available on the computer.

    .PARAMETER Path
    This is the certificate file which will be converted. This option is required. 

    .PARAMETER Prefix
    This string appears before the filename for each converted certificate. If unspesified, will use the name if the file being resized.

    .NOTES
    File Name  : ConvertTo-EndpointCertificate.ps1  
    Version    : 1.1.1
    Author     : ***REMOVED***

    Copyright (c) ***REMOVED*** 2019-2021
  #>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateScript( { Test-Path $_ })][string]$Path = (Get-Location),
  [string]$LocalPrefix,
  [string]$Suffix,
  [string]$Filter = "*.pfx"
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

$count = 1; $PercentComplete = 0;
$Certificates = Get-ChildItem -File -Path $Path -Filter $Filter
ForEach ($Certificate in $Certificates) {
  #Progress message
  $ActivityMessage = "Converting Certificates. Please wait..."
  $StatusMessage = ("Processing {0} of {1}: {2}" -f $count, @($Certificates).count, $Certificate.Name)
  $PercentComplete = ($count / @($Certificates).count * 100)
  Write-Progress -Activity $ActivityMessage -Status $StatusMessage -PercentComplete $PercentComplete
  $count++

  $Password = Read-Host "Enter Password"
  If ($PSCmdlet.ShouldProcess("$OutName", "Convert-Certificate")) {  
    $LocalPrefix = $Prefix + [System.IO.Path]::GetFileNameWithoutExtension($Certificate.FullName) + "_"
    $Path = $Certificate.FullName
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -out "$LocalPrefix`PEM.txt" -nodes 
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nocerts -out "$LocalPrefix`PEM_Key.txt" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nokeys -out "$LocalPrefix`PEM_Cert.txt" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nokeys -out "$LocalPrefix`PEM_Cert_NoNodes.txt"
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nokeys -out "$LocalPrefix`PEM_Cert.cer" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -export -in "$LocalPrefix`PEM_Cert.txt" -inkey "$LocalPrefix`PEM_Key.txt" -certfile "$LocalPrefix`PEM_Cert.txt" -out "$LocalPrefix`Unifi.p12" -name unifi -password pass:aircontrolenterprise
        
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nocerts -nodes | openssl.exe  rsa -out "$LocalPrefix`RSA_Key.txt"
    openssl.exe rsa  -passin "pass:$Password" -in "$LocalPrefix`PEM.txt" -pubout -out "$LocalPrefix`RSA_Pub.txt"
    Write-Output ""

    Write-Output "To import to Windows run the following commands.`n`$mypwd = Get-Credential -UserName 'Enter password below' -Message 'Enter password below'`nImport-PfxCertificate -FilePath C:\Local\Web.pfx -CertStoreLocation Cert:\LocalMachine\My -Password `$mypwd.Password`n"

    New-Item -Force -Type Directory -Name AlwaysUp | Out-Null
    Copy-Item "$LocalPrefix`PEM_Cert.txt" AlwaysUp\ctc-self-signed-certificate-exp-2024.pem
    Copy-Item "$LocalPrefix`PEM_Key.txt" AlwaysUp\ctc-self-signed-certificate-exp-2024-key.pem
    Write-Output "Always Up: Copy files to C:\Program Files (x86)\AlwaysUpWebService\certificates`n"

    New-Item -Force -Type Directory -Name CiscoSG300 | Out-Null
    Copy-Item "$LocalPrefix`PEM_Cert.txt" CiscoSG300\Cert.txt
    Copy-Item "$LocalPrefix`RSA_Pub.txt" CiscoSG300\RSA_Pub.txt
    Copy-Item "$LocalPrefix`RSA_Key.txt" CiscoSG300\RSA_Key.txt
    Write-Output "Cisco SG300: Use RSA Key, RSA Pub, and PEM Cert`nFor RSA Pub, remove the first 32 characters and change BEGIN/END PUBLIC KEY to BEGIN/END RSA PUBLIC KEY. Use only the primary certificate, not the entire chain. When importing, edit HTML to allow more than 2046 characters in certificate feild.`nInstructions from: https://severehalestorm.net/?p=54`n"

    New-Item -Force -Type Directory -Name PaperCutMobility | Out-Null
    Copy-Item "$LocalPrefix`PEM_Cert.txt" PaperCutMobility\tls.cer
    Copy-Item "$LocalPrefix`PEM_Key.txt" PaperCutMobility\tls.pem
    Write-Output "PaperCut Mobility: `n"

    New-Item -Force -Type Directory -Name Spiceworks | Out-Null
    Copy-Item "$LocalPrefix`PEM_Cert.txt" Spiceworks\ssl-cert.pem
    Copy-Item "$LocalPrefix`PEM_Key.txt" Spiceworks\ssl-private-key.pem
    Write-Output "Spiceworks: Copy files to C:\Program Files (x86)\Spiceworks\httpd\ssl`n"

    New-Item -Force -Type Directory -Name UnifiCloudKey | Out-Null
    Write-Verbose "Instructions from here: https://community.ubnt.com/t5/UniFi-Wireless/HOWTO-Install-Signed-SSL-Certificate-on-Cloudkey-and-use-for/td-p/1977049"
    Write-Output "Unifi Cloud Key: Copy files to '/etc/ssl/private' on the Cloud Key and run the following commands.`ncd /etc/ssl/private`nkeytool -importkeystore -srckeystore unifi.p12 -srcstoretype PKCS12 -srcstorepass aircontrolenterprise -destkeystore unifi.keystore.jks -storepass aircontrolenterprise`nkeytool -list -v -keystore unifi.keystore.jks`ntar cf cert.tar cloudkey.crt cloudkey.key unifi.keystore.jks`ntar tvf cert.tar`nchown root:ssl-cert cloudkey.crt cloudkey.key unifi.keystore.jks cert.tar`nchmod 640 cloudkey.crt cloudkey.key unifi.keystore.jks cert.tar`nnginx -t`n/etc/init.d/nginx restart; /etc/init.d/unifi restart`n"
    Copy-Item "$LocalPrefix`PEM_Cert.txt" UnifiCloudKey\cloudkey.crt
    Copy-Item "$LocalPrefix`PEM_Key.txt" UnifiCloudKey\cloudkey.key
    Copy-Item "$LocalPrefix``unifi.p12" UnifiCloudKey\unifi.p12

    New-Item -Force -Type Directory -Name UnifiCore | Out-Null
    Write-Output "Unifi Cloud Key: Copy files to '/data/unifi-core/config' on the Cloud Key and run the following commands.`n`nsystemctl restart unifi-core.service`n"
    Copy-Item "$LocalPrefix`PEM_Cert_NoNodes.txt" UnifiCore\unifi-core.crt
    Copy-Item "$LocalPrefix`RSA_Key.txt" UnifiCore\unifi-core.key

    New-Item -Force -Type Directory -Name USG | Out-Null
    Copy-Item "$LocalPrefix`PEM.txt" server.pem
    Write-Output "Edge Router or USG: Copy the PEM file to '/etc/lighttpd/server.pem' and run the following commands."
    Write-Output "kill -SIGINT `$(cat /var/run/lighttpd.pid)"
    Write-Output "/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf"
    Write-Output ""

    Write-Output "IIS Management: Add PFX certificate to server and run the following commanges in Powershell"
    Write-Output "`$mypwd = Get-Credential -UserName 'Enter password below' -Message 'Enter password below'>"
    Write-Output "Import-PfxCertificate -FilePath '.\***REMOVED*** Web.pfx' -CertStoreLocation Cert:\LocalMachine\My -Password `$mypwd.Password"
    Write-Output "`$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {`$_.subject -like `"****REMOVED****`"} | Where-Object {`$_.NotAfter -gt (Get-Date)} | Select-Object -ExpandProperty Thumbprint"
    Write-Output "Import-Module WebAdministration"
    Write-Output "Remove-Item -Path IIS:\SslBindings\0.0.0.0!8172"
    Write-Output "Get-Item -Path `"cert:\localmachine\my\`$cert`" | New-Item -Force -Path IIS:\SslBindings\0.0.0.0!8172"
    Write-Output "https://support.microsoft.com/en-us/help/3206898/enabling-iis-manager-and-web-deploy-after-disabling-ssl3-and-tls-1-0"
    Write-Output ""

    <#
          RSA
          RSA SG300
          RSA Pub
          pfx
          PEM
          p7b
          DER
          B64
          B64 Chain
          #>
  }
}

# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUV/cki/CLUk7qOJHrqH20Y/O6
# V3+ggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFNi4cGZvc9wrXMukGZ/uu72wZGoJ
# MA0GCSqGSIb3DQEBAQUABIICAEU5i4XVkmG1OBotHJPh84F5l1I8uLIj/JVouuc9
# tAEUPZu1jhW2sKdAwNpqBfl77p2Oq7Gx0fhFKp4gcaVqYr3N0wRdMLPus6XdyBPk
# qHffzInBJ5thEut+0aVeRKyaRHUgO4vCUvHDAmhVClMV5EdtWQQdX/nmVCzooemP
# Mv0RVb3LVeLl9IoET5ZmpCKbdGzuwWMhh3q7x+0iWdryoFHqRz8ZaymW6BeOd92r
# ayB+J0DoRIMMbZRIYjmd6vqmE+xPdSjcJvT2Bb7ETf2MQBHl1Iq3n35BOCWmjn3h
# kmMoyNOvUm2gGGxZMfpkOqZKk/eSPG5X1RkAcVy64EC7rxI05Do/uQaDOZeggdNW
# L9oenYIbDY1Gl4RWGTC2uvugGeRlS9qRbrwMmBn8/wExUAbRc1wZ6Nq0DsWnE9L7
# AaAf7auFFAsiMV6ZVxbn+ScMTQmn3QW2JTN/lz6HUX+OKGeXs1PfsLSjZ7JsoBj6
# 7piY7XZKn6Or1Nu6E84Rw2OhKIqlhUFxZXWJ1JR3ADm+91idDn3LolucB6JhvimW
# nbIgFBUUSgZOI8oxGjW2tpED3WG87i4w6VzZyZXR1KEfC6Bt3oJqK8FLr6RGaI9c
# k9FR+Ghw7LOPNIaDO3n88k7kfifZ7bcga8hbZBcmKaJ6hxdoE7SzZnNpIPNIksqU
# Tqbd
# SIG # End signature block
