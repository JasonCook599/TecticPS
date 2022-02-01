<#
	.SYNOPSIS
	This script will resize an image using ImageMagick.

	.DESCRIPTION
	This script will resize an image using ImageMagick.

	.LINK
	https://imagemagick.org/

	.PARAMETER Path
	This is the file or folder containing images to resize. If unspecified, it will run in the current folder.

	.PARAMETER Dimensions
	The dimension to which the image should be resized in WxH. You must spesify either width or height.

	.PARAMETER Suffix
	The text to appear after the resized file.

	.PARAMETER Prefix
	The text to appear before the resized file.

	.PARAMETER OutExtension
	The file extension to use for the converted image. If unspecified, the existing extension will will be used.
	
	.PARAMETER FileSize
	The file size of the final file. This paramater only functions when outputting to the JPEG format.

	.PARAMETER Filter
	Use this to limit the search to spesific files.

	.PARAMETER Force
	Use this paramater to bypass the check when overwriting an existing file.

	.PARAMETER Return
	The parameter will return the Name, FullName, InputName, InputFullName for each file.

	.EXAMPLE
	Convert-Image -Dimensions 1920x1080 -Suffix _1080p

	.EXAMPLE
	Convert-Image -Path C:\Images -Dimensions 1920x1080 -Suffix _1080p -Prefix Resized_ -OutExtension jpeg -FileSize 750KB -Filter "*.jpg" -Force -Return
	Name                          FullName
	----                          --------
	Resized_Image (1)_1080p.jpeg  C:\Images\Resized_Image (1)_1080p.jpeg
	Resized_Image (2)_1080p.jpeg  C:\Images\Resized_Image (2)_1080p.jpeg
	Resized_Image (3)_1080p.jpeg  C:\Images\Resized_Image (3)_1080p.jpeg
	Resized_Image (4)_1080p.jpeg  C:\Images\Resized_Image (4)_1080p.jpeg
	Resized_Image (5)_1080p.jpeg  C:\Images\Resized_Image (5)_1080p.jpeg
	Resized_Image (6)_1080p.jpeg  C:\Images\Resized_Image (6)_1080p.jpeg
	Resized_Image (7)_1080p.jpeg  C:\Images\Resized_Image (7)_1080p.jpeg
	Resized_Image (8)_1080p.jpeg  C:\Images\Resized_Image (8)_1080p.jpeg
	Resized_Image (9)_1080p.jpeg  C:\Images\Resized_Image (9)_1080p.jpeg

	.NOTES
	File Name  : Convert-Image.ps1
	Version    : 1.0.1
	Author     : ***REMOVED***

	Copyright (c) ***REMOVED*** 2019-2021

	.LINK
	https://imagemagick.org/script/command-line-processing.php#geometry
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
	[ValidateScript( { Test-Path $_ })][array]$Path = (Get-Location),
	[ValidateScript( { Test-Path $_ })][string]$OutPath = (Get-Location),
	[string][ValidatePattern("((((\d+%){1,2})|((\d+)?x\d+(\^|!|<|>|\^)*?)|(\d+x?(\d+)?(\^|!|<|>|\^)*?)|(\d+@)|(\d+:\d+))$|^$)")]$Dimensions,
	[string]$Suffix,
	[string]$Prefix,
	[switch]$Trim,
	[ValidateSet("NorthWest", "North", "NorthEast", "West", "Center", "East", "SouthWest", "South", "SouthEast")][string]$Gravity = "Center",
	[ValidateSet("Crop", "Pad", "None", $null)][string]$Mode = "Crop",
	[string]$ColorSpace,
	[string][ValidatePattern("(^\..+$|^$)")]$OutExtension,
	[string]$FileSize,
	[string]$Filter,
	[switch]$Force,
	[ValidateScript( { Test-Path -Path $_ -PathType Leaf })][string]$Magick = ((Get-Command magick).Source)
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

If (!(Get-Command magick -ErrorAction SilentlyContinue)) {
	Write-Error "magick.exe is not available in your PATH."
	Break
}
	
[System.Collections.ArrayList]$Results = @()

$Images = Get-ChildItem -File -Path $Path -Filter $Filter
ForEach ($Image in $Images) {
	$count++ ; Progress -Index $count -Total $Images.count -Activity "Resizing images." -Name $Image.Name

	$Arguments = $null		
	If (!$OutExtension) { $ImageOutExtension = [System.IO.Path]::GetExtension($Image.Name) } #If OutExtension not set, use current
	Else { $ImageOutExtension = $OutExtension } #Otherwise use spesified extension
	$OutName += $Prefix + [io.path]::GetFileNameWithoutExtension($Image.Name) + $Suffix + $ImageOutExtension #Out file name
	$Out = Join-Path $OutPath $OutName #Out full path
	If ($PSCmdlet.ShouldProcess("$OutName", "Convert-Image")) {
		If (Test-Path $Out) {
			If ($Force) {}
			ElseIf (!($PSCmdlet.ShouldContinue("$Out already exists. Overwrite?", ""))) { Break }
		}
		$Arguments += '"' + $Image.FullName + '" '
		If ($Dimensions) {
			If ($Trim) { $Arguments += '-trim ' }
			$Arguments += '-resize "' + $Dimensions + '" '
			$Arguments += '-gravity "' + $Gravity + '" '
			If ($Mode -eq "Crop") { $Arguments += '-crop "' + $Dimensions + '+0+0" ' }
			ElseIf ($Mode -eq "Pad") { $Arguments += '-background none -extent "' + $Dimensions + '+0+0" ' }
		}
		
		If ($FileSize -And ($ImageOutExtension -ne ".jpg") -And ($ImageOutExtension -ne ".jpeg")) {
			Write-Warning "FileSize paramater is only valid for JPEG images. $OutName will ignore this parameter."
		}
		ElseIf ($FileSize) { $Arguments += '-define jpeg:extent=' + $FileSize + ' ' }
		$Arguments += '+repage '
		If ($ColorSpace) { $Arguments += '-colorspace ' + $ColorSpace + ' ' }
		$Arguments += '"' + $Out + '"'

		Write-Verbose $Arguments
		Start-Process -FilePath $Magick -ArgumentList $Arguments -NoNewWindow -Wait
		$Result = [PSCustomObject]@{
			Arguments     = $Arguments
			Name          = $OutName
			FullName      = $Out
			InputName     = Split-Path -Path $Image.FullName -Leaf
			InputFullName	= $Image.FullName
		}
		$Results += $Result
	}
}
Return $Results

# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdDgEOCJbki1gwcAQriSZW7y8
# pvyggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFCpOsB6rDRqBhqPL0wqNuUFF3xXH
# MA0GCSqGSIb3DQEBAQUABIICAH4rtcUZsUmfKP1TkVOFJznwX2jNgH9y0Q0I2s1E
# OuaQiB34I197ejVpZGnQbglp5tpZ4suv/FqftFNymE4ZsDZe2myvmQZCp3+RJ6MF
# pM2xIkcDzoWb7Atgsvvd44gdiGnH+JUZpHTlFHU/owckrWjLK9O8ijSV5bU978qI
# N25xKRoGWzShcZcDCZrTtcjOYo2X34ewUSk70Ml1sZgJQ9rg1ALUAUkKoPlLZAHM
# qwoiB9K14yMefsAwBUVUiKwcdqbPBiyDbB0hoD0uP873el4q4x9eP0FAUmTmGo8M
# xs/c52AV0wXuKfUOuQQPiyfyp2Tdnu5ViRxN+z5Esumyzw6KQHvzcvtjDiMPi6TB
# SsvsBYl4vEACKggkbtubhaUTNq0WoIOGY9A0ilOLoBwipb1JgxKN7YWfReWSsnNO
# O8BlR1ukc6afQHoyneYFiw3Sik2LaMteo18ljq94fqhkfOuikW46fmBPEWvXcfWZ
# Wkz0XfKF1ylWM8A++juSNdVCZcQGaSPJVPvjMVEtuV00vdI/cMefGEQ5wGveXCDm
# l7u6p8oK1c6XO089whnPZrM/32GaZs1a6hnLT5qKi9bt+W3upKaGwsQVQILSeFQV
# NT4xYn7T7X2/J42WK1zMUGDfC+1/esJyRFBQKId21FTxlC+9nkQz9dwODyhfzKwb
# Le/n
# SIG # End signature block
