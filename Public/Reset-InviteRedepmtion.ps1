<#PSScriptInfo

.VERSION 1.0.1

.GUID 8697df26-a171-4f10-9929-fbff1e58ab4b

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
.DESCRIPTION
This will reset the invite status for guest AAD users.

.PARAMETER All
If specified, all guest users will be processed.

.PARAMETER Email
The email addresses to process. This can be omitted if spesifing UPNs.

.PARAMETER UPN
The UPNs to process. By default, it will generate for the email addresses specified.

.PARAMETER RedirectURL
The URL to redirect users to after sucessfull invite redeption.

.PARAMETER SkipSendingInvitation
Whether to skip sekping the invitation.

.PARAMETER SkipResettingRedeption
Whether to skip resetting the redeption status.

.LINK
https://docs.microsoft.com/en-us/azure/active-directory/external-identities/reset-redemption-status
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$All,
    [array]$Email,
    [array]$UPN = ($Email.replace("@", "_") + "#EXT#@" + ((Get-AzureADTenantDetail).VerifiedDomains | Where-Object Initial -eq $true).Name),
    [Uri]$RecirectURL = "http://myapps.microsoft.com",
    [boolean]$SkipSendingInvitation,
    [boolean]$SkipResettingRedemtion

)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
$SkipSendingInvitation = -not $SkipSendingInvitation
$SkipResettingRedemtion = -not $SkipResettingRedemtion

if ($All) {
    $UPN = (Get-AzureADUser -Filter "UserType eq 'Guest'").UserPrincipalName
    Write-Warning "This will reset invites for all guest users. Are you sure?"
    Wait-ForKey "y"

}
[System.Collections.ArrayList]$Results = @()
$UPN | ForEach-Object {
    $count++ ; Progress -Index $count -Total $UPN.count -Activity "Resetting Invite Redemption" -Name $_
    If ($PSCmdlet.ShouldProcess("$_", "Reset-InviteRedemption")) {
        $AzureAdUser = Get-AzureADUser -objectID $_
        $MsGraphUser = (New-Object Microsoft.Open.MSGraph.Model.User -ArgumentList $AzureAdUser.ObjectId)
        $Result = New-AzureADMSInvitation -InvitedUserEmailAddress $AzureAdUser.mail -SendInvitationMessage $SkipSendingInvitation -InviteRedirectUrl $RecirectURL -InvitedUser $MsGraphUser -ResetRedemption $SkipResettingRedemtion
        $Results += $Result
    }
}

Return $Results
