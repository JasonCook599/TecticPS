<#
.SYNOPSIS
This script shows three methods to determine the underlying system firmware (BIOS) type - either UEFI or Legacy BIOS.

.DESCRIPTION
This script shows three methods to determine the underlying system firmware (BIOS) type - either UEFI or Legacy BIOS.

The first method relies on the fact that Windows setup detects the firmware type as a part of the Windows installation
routine and records its findings in the setupact.log file in the \Windows\Panther folder.  It's a trivial task to use
Select-String to extract the relevent line from this file and to pick off the (U)EFI or BIOS keyword it contains.

To do a proper job there are two choices; both involve using Win32 APIs which we call from PowerShell through a compiled
(Add-Type) class using P/Invoke.

For Windows 7/Server 2008R2 and above, the GetFirmwareEnvironmentVariable Win32 API (designed to extract firmware environment
variables) can be used.  This API is not supported on non-UEFI firmware and will fail in a predictable way when called - this 
will identify a legacy BIOS.  On UEFI firmware, the API can be called with dummy parameters, and while it will still fail 
(probably!) the resulting error code will be different from the legacy BIOS case.

For Windows 8/Server 2012 and above there's a more elegant solution in the form of the GetFirmwareType() API.  This
returns an enum (integer) indicating the underlying firmware type.

Chris Warwick, @cjwarwickps,  September 2013


.EXAMPLE
Get-FirmwareType

.NOTES
File Name  : Get-FirmwareType.ps1  
Version    : 1.1.0
Author     : Chris Warwick and ***REMOVED***
Credits    : Copyright (c) 2015 Chris Warwick. Released under the MIT License.

Copyright (c) ***REMOVED*** 2019-2022

.LINK
https://github.com/ChrisWarwick/GetUEFI/blob/master/GetFirmwareBIOSorUEFI.psm1

.LINK
https://github.com/ChrisWarwick/GetUEFI/blob/master/LICENSE
 #>

# First method, one-liner, extract answer from setupact.log using Select-String and tidy-up with -replace
# Look in the setup logfile to see what bios type was detected (EFI or BIOS)
(Select-String 'Detected boot environment' C:\Windows\Panther\setupact.log -AllMatches ).line -replace '.*:\s+'

<#
Second method, use the GetFirmwareEnvironmentVariable Win32 API.

From MSDN (http://msdn.microsoft.com/en-ca/library/windows/desktop/ms724325%28v=vs.85%29.aspx):

"Firmware variables are not supported on a legacy BIOS-based system. The GetFirmwareEnvironmentVariable function will 
always fail on a legacy BIOS-based system, or if Windows was installed using legacy BIOS on a system that supports both 
legacy BIOS and UEFI. 

"To identify these conditions, call the function with a dummy firmware environment name such as an empty string ("") for 
the lpName parameter and a dummy GUID such as "{00000000-0000-0000-0000-000000000000}" for the lpGuid parameter. 
On a legacy BIOS-based system, or on a system that supports both legacy BIOS and UEFI where Windows was installed using 
legacy BIOS, the function will fail with ERROR_INVALID_FUNCTION. On a UEFI-based system, the function will fail with 
an error specific to the firmware, such as ERROR_NOACCESS, to indicate that the dummy GUID namespace does not exist."


From PowerShell, we can call the API via P/Invoke from a compiled C# class using Add-Type.  In Win32 any resulting
API error is retrieved using GetLastError(), however, this is not reliable in .Net (see 
blogs.msdn.com/b/adam_nathan/archive/2003/04/25/56643.aspx), instead we mark the pInvoke signature for 
GetFirmwareEnvironmentVariableA with SetLastError=true and use Marshal.GetLastWin32Error()

Note: The GetFirmwareEnvironmentVariable API requires the SE_SYSTEM_ENVIRONMENT_NAME privilege.  In the Security 
Policy editor this equates to "User Rights Assignment": "Modify firmware environment values" and is granted to 
Administrators by default.  Because we don't actually read any variables this permission appears to be optional.

#>

Function IsUEFI {

    <#
.Synopsis
   Determines underlying firmware (BIOS) type and returns True for UEFI or False for legacy BIOS.
.DESCRIPTION
   This function uses a complied Win32 API call to determine the underlying system firmware type.
.EXAMPLE
   If (IsUEFI) { # System is running UEFI firmware... }
.OUTPUTS
   [Bool] True = UEFI Firmware; False = Legacy BIOS
.FUNCTIONALITY
   Determines underlying system firmware type
#>

    [OutputType([Bool])]
    Param ()

    Add-Type -Language CSharp -TypeDefinition @'

    using System;
    using System.Runtime.InteropServices;

    public class CheckUEFI
    {
        [DllImport("kernel32.dll", SetLastError=true)]
        static extern UInt32 
        GetFirmwareEnvironmentVariableA(string lpName, string lpGuid, IntPtr pBuffer, UInt32 nSize);

        const int ERROR_INVALID_FUNCTION = 1; 

        public static bool IsUEFI()
        {
            // Try to call the GetFirmwareEnvironmentVariable API.  This is invalid on legacy BIOS.

            GetFirmwareEnvironmentVariableA("","{00000000-0000-0000-0000-000000000000}",IntPtr.Zero,0);

            if (Marshal.GetLastWin32Error() == ERROR_INVALID_FUNCTION)

                return false;     // API not supported; this is a legacy BIOS

            else

                return true;      // API error (expected) but call is supported.  This is UEFI.
        }
    }
'@


    [CheckUEFI]::IsUEFI()
}




<#

Third method, use GetFirmwareTtype() Win32 API.

In Windows 8/Server 2012 and above there's an API that directly returns the firmware type and doesn't rely on a hack.
GetFirmwareType() in kernel32.dll (http://msdn.microsoft.com/en-us/windows/desktop/hh848321%28v=vs.85%29.aspx) returns 
a pointer to a FirmwareType enum that defines the following:

typedef enum _FIRMWARE_TYPE { 
  FirmwareTypeUnknown  = 0,
  FirmwareTypeBios     = 1,
  FirmwareTypeUefi     = 2,
  FirmwareTypeMax      = 3
} FIRMWARE_TYPE, *PFIRMWARE_TYPE;

Once again, this API call can be called in .Net via P/Invoke.  Rather than defining an enum the function below 
just returns an unsigned int.

#>




# Windows 8/Server 2012 or above:


Function Get-BiosType {

    <#
.Synopsis
   Determines underlying firmware (BIOS) type and returns an integer indicating UEFI, Legacy BIOS or Unknown.
   Supported on Windows 8/Server 2012 or later
.DESCRIPTION
   This function uses a complied Win32 API call to determine the underlying system firmware type.
.EXAMPLE
   If (Get-BiosType -eq 1) { # System is running UEFI firmware... }
.EXAMPLE
    Switch (Get-BiosType) {
        1       {"Legacy BIOS"}
        2       {"UEFI"}
        Default {"Unknown"}
    }
.OUTPUTS
   Integer indicating firmware type (1 = Legacy BIOS, 2 = UEFI, Other = Unknown)
.FUNCTIONALITY
   Determines underlying system firmware type
#>

    [OutputType([UInt32])]
    Param()

    Add-Type -Language CSharp -TypeDefinition @'

    using System;
    using System.Runtime.InteropServices;

    public class FirmwareType
    {
        [DllImport("kernel32.dll")]
        static extern bool GetFirmwareType(ref uint FirmwareType);

        public static uint GetFirmwareType()
        {
            uint firmwaretype = 0;
            if (GetFirmwareType(ref firmwaretype))
                return firmwaretype;
            else
                return 0;   // API call failed, just return 'unknown'
        }
    }
'@


    [FirmwareType]::GetFirmwareType()
}



# An electron is pulled-up for speeding. The policeman says, “Sir, do you realise you were travelling at 130mph?” The electron says, “Oh great, now I’m lost.”


# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUcKx9PBrn4aI3KcilKnzDTYre
# A6aggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
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
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFJA2ty8SLQuoZtosFDk1zw9wuY/R
# MA0GCSqGSIb3DQEBAQUABIICAABIDxizS2RVCaYQrCD0zzfpivVLsLCWSk/qb1Hi
# S0NDumlB9e1JAkb6AiPnhZ8AaUEn4SIlx60pIeMISBNmerPpytkR78JiAUjjuFqP
# GPeh/Itok/WjCanhn5oUW2a/OnDWgGeImF9rg5iyBk55EjbkouwoTCYatVSbk/6I
# 9R8wy7PQXHpBDJPwo69/29e/jIbohWQ4ZwguclJud+s4xrRDX46FIT/AFr+ZCkBo
# FCnd9hsq2sYawOsPwDj3GQtcmeNbm+ML1Jb7SvZKj+rI29eccsh+enmxG4tSgucY
# Q3L/QaWVurA9F4E2mxq+yayukwjHmqfNxqdGh3Jqu84uYT0QFkH4doDKnWqzi4h6
# rRC+s6STRiK+V7se+LrrB8iVBBpdxNDWhAmBHLQE/hQfYTKbHYjBgmltVM+FmSAA
# CNaX+wVsc6AAU5+p8KOtOPS9M8BjWNXO5dPhSaz9NfP9OoMAgazIS1sbV5LWKTIs
# MCtsgPJJ3e23U9SUzxnp0WjtYVa0wN5Ns3u+2b4cG2nNQes+TNEBCT0Nd8hvEwMr
# IT/S1QqiheXo6PCfP/gDB6TgYj7Zy8h9/oxqyJ16Prqnu+bsILXgcb87O7neUcb1
# IWo7AhjXdVSlGR1Asl1S/Da78EgfXW/ICPcbnMY0UUJSBOZrnfRtfiAxBOB2dwrC
# S2a/
# SIG # End signature block
