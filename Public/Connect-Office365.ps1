<#PSScriptInfo

.VERSION 2.1.3

.GUID ab066274-cee5-401d-99ff-1eeced8ca9af

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

#> 

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
		Requires Microsoft.Online.SharePoint.PowerShell
		If ($BasicAuth) { Connect-SPOService -Url https://$Tenant-admin.sharepoint.com -Credential $Credential | Write-Verbose }
		Else { Connect-SPOService -Url https://$Tenant-admin.sharepoint.com | Write-Verbose }
	}
	If ($SkypeForBusinessOnline) {
		Write-Verbose "$me Connecting to Skype For Business Online"
		Requires SkypeOnlineConnector
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
