<#PSScriptInfo

.VERSION 1.1.1

.GUID 66f102b7-1405-45dc-8df3-0d1b8459f4de

.AUTHOR Jason Cook Darren J Robinson

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
FIND State/Dormant B2B Accounts and Stale/Dormant B2B Guest Invitations

.DESCRIPTION
Get all AAD Accounts which haven't signed in, in the last XX Days, or haven't accepted a B2B Guest Invitation in last XX Days. This is based on the blog post from Darren Robinson.

.LINK
https://blog.darrenjrobinson.com/finding-stale-azure-ad-b2b-guest-accounts-based-on-lastsignindatetime/

.PARAMETER TenantId
Microsoft 365 Tenant ID

.PARAMETER Credential
Registered AAD App ID and Secret

.PARAMETER StaleDays
Number of days over which an Azure AD Account that hasn't signed in is considered stale'

.PARAMETER StaleDate
Spesify a date to use as stale before which all sign ins are considered stale. This overrides the StaleDays oparameter

.PARAMETER GetLastSignIn
Should we find the last sign in date for stale users? This will take longer to process

.EXAMPLE
Get-StaleAADGuestAccounts
#>

param (
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]$TenantId , # Tenant ID 
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCredential]$Credential, # Registered AAD App ID and Secret
	$StaleDays = '90', # Number of days over which an Azure AD Account that hasn't signed in is considered stale'
	$StaleDate = (get-date).AddDays( - "$($StaleDays)").ToString('yyyy-MM-dd'), #Or spesify a spesific date to use as stale
	[switch]$GetLastSignIn
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Requires -Modules MSAL.PS

# Get InActivity Accounts and Filter Accounts down to Azure AD Guest Accounts
$StaleGuests = GetAADSignIns -date $StaleDate | Select-Object | Where-Object { $_.userType -eq 'Guest' }
Write-Host -ForegroundColor Green "$($StaleGuests.count) Guest accounts haven't signed in since $($StaleDate)"
# Disabled Guest Accounts
Write-Host -ForegroundColor Yellow "    $(($StaleGuests | Select-Object | Where-Object { $_.accountEnabled -eq $false }).Count) Guest accounts haven't signed in since $($StaleDate) and are flagged as 'Account Disabled'."

# Guest Accounts inivited but pending acceptance
$PendingGuests = GetAADPendingGuests
Write-Host -ForegroundColor Green "$($PendingGuests.count) Guest accounts are still 'pending' B2B Guest invitation acceptance."
$StalePendingGuests = $PendingGuests | Select-Object | Where-Object { [datetime]$_.externalUserStateChangeDateTime -le [datetime]"$($StaleDate)T00:00:00Z" }
Write-Host -ForegroundColor Yellow "    $($StalePendingGuests.count) Guest accounts were invited before '$($StaleDate)'"

# All Stale Accounts
$StaleAndPendingGuests = $null 
$StaleAndPendingGuests += $StaleGuests 
$StaleAndPendingGuests += $StalePendingGuests
Write-Host -ForegroundColor Green "$($StaleAndPendingGuests.count) Guest accounts are still 'pending' B2B Guest invitation acceptance or haven't signed in since '$($StaleDate)'."

If ($GetLastSignIn) {
	# Add lastSignInDateTime to the User PowerShell Object
	foreach ($Guest in $StaleGuests) {
		#Progress message
		$count++ ; Progress -Index $count -Total $StaleGuests.count -Activity "Getting last sign in for stale guests." -Name $Guest.UserPrincipalName.ToString()
		$signIns = $null 
		$signIns = GetAADUserSignInActivity -ID $Guest.id
		$Guest | Add-Member -Type NoteProperty -Name "lastSignInDateTime" -Value $signIns.signInActivity.lastSignInDateTime
	}
}

# Set default properties to return
$defaultProperties = @("mail", "accountEnabled", "creationType", "externalUserState", "userType")
If ($GetLastSignIn) { $defaultProperties += "lastSignInDateTime" }
$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$defaultProperties)
$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
$StaleAndPendingGuests | Add-Member MemberSet PSStandardMembers $PSStandardMembers
return $StaleAndPendingGuests

