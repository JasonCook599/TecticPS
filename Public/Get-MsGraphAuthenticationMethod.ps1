<#PSScriptInfo

.VERSION 1.2.2

.GUID c42317a3-3385-41d1-821d-8622b798259a

.AUTHOR paul@thesysadminchannel.com & Jason Cook

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

#> 

<#
.DESCRIPTION
List MFA Authentication Methods for users using Graph API. A session using Connect-Graph must be open as a requirement.

.PARAMETER UserId
The UserId or UserPrincipalName to check.

.NOTES
    DateCreated: 2021-Jan-20

.EXAMPLE
    Get-MsGraphAuthenticationMethod -UserId user1@domain.com, user2@domain.com

.EXAMPLE
    Get-MsGraphAuthenticationMethod -UserId user1@domain.com, user2@domain.com -MethodType MicrosoftAuthenticatorApp, EmailAuthencation

.LINK
    https://thesysadminchannel.com/get-mfa-methods-using-msgraph-api-and-powershell-sdk/ -

#>
[CmdletBinding()]
param(
    [Parameter(
        Mandatory = $true,
        Position = 0
    )]
    [Alias('UserPrincipalName')]
    [string[]]  $UserId,

    [Parameter(
        Mandatory = $false
    )]
    [ValidateSet('AuthenticatorApp', 'PhoneAuthentication', 'Fido2', 'WindowsHelloForBusiness', 'EmailAuthentication', 'TemporaryAccessPass', 'Passwordless', 'SoftwareOath')]
    [string[]]   $MethodType
)

BEGIN {
    $ConnectionGraph = Get-MgContext
    if (-not $ConnectionGraph) {
        Write-Error "Please connect to Microsoft Graph" -ErrorAction Stop
    }

}

PROCESS {
    foreach ($User in $UserId) {
        try {
            $DeviceList = Get-MgUserAuthenticationMethod -UserId $User -ErrorAction Stop
            $DeviceOutput = foreach ($Device in $DeviceList) {

                #Converting long method to short-hand human readable method type.
                switch ($Device.AdditionalProperties["@odata.type"]) {
                    '#microsoft.graph.microsoftAuthenticatorAuthenticationMethod' {
                        $MethodAuthType = 'AuthenticatorApp'
                        $AdditionalProperties = $Device.AdditionalProperties["displayName"]
                    }

                    '#microsoft.graph.phoneAuthenticationMethod' {
                        $MethodAuthType = 'PhoneAuthentication'
                        $AdditionalProperties = $Device.AdditionalProperties["phoneType", "phoneNumber"] -join ' '
                    }

                    '#microsoft.graph.passwordAuthenticationMethod' {
                        $MethodAuthType = 'PasswordAuthentication'
                        $AdditionalProperties = $Device.AdditionalProperties["displayName"]
                    }

                    '#microsoft.graph.fido2AuthenticationMethod' {
                        $MethodAuthType = 'Fido2'
                        $AdditionalProperties = $Device.AdditionalProperties["model"]
                    }

                    '#microsoft.graph.windowsHelloForBusinessAuthenticationMethod' {
                        $MethodAuthType = 'WindowsHelloForBusiness'
                        $AdditionalProperties = $Device.AdditionalProperties["displayName"]
                    }

                    '#microsoft.graph.emailAuthenticationMethod' {
                        $MethodAuthType = 'EmailAuthentication'
                        $AdditionalProperties = $Device.AdditionalProperties["emailAddress"]
                    }

                    '#microsoft.graph.temporaryAccessPassAuthenticationMethod' {
                        $MethodAuthType = 'TemporaryAccessPass'
                        $AdditionalProperties = 'TapLifetime:' + $Device.AdditionalProperties["lifetimeInMinutes"] + 'm - Status:' + $Device.AdditionalProperties["methodUsabilityReason"]
                    }

                    '#microsoft.graph.passwordlessMicrosoftAuthenticatorAuthenticationMethod' {
                        $MethodAuthType = 'Passwordless'
                        $AdditionalProperties = $Device.AdditionalProperties["displayName"]
                    }

                    '#microsoft.graph.softwareOathAuthenticationMethod' {
                        $MethodAuthType = 'SoftwareOath'
                        $AdditionalProperties = $Device.AdditionalProperties["displayName"]
                    }
                }

                [PSCustomObject]@{
                    UserPrincipalName      = $User
                    AuthenticationMethodId = $Device.Id
                    MethodType             = $MethodAuthType
                    AdditionalProperties   = $AdditionalProperties
                }
            }

            if ($PSBoundParameters.ContainsKey('MethodType')) {
                $DeviceOutput | Where-Object { $_.MethodType -in $MethodType }
            }
            else {
                $DeviceOutput
            }

        }
        catch {
            Write-Error $_.Exception.Message

        }
        finally {
            $DeviceList = $null
            $MethodAuthType = $null
            $AdditionalProperties = $null

        }
    }
}

END {}
