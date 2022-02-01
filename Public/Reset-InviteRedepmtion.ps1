<#
 https://docs.microsoft.com/en-us/azure/active-directory/external-identities/reset-redemption-status
 #>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [array]$Email,
    [array]$UPN = ($Email.replace("@", "_") + "#EXT#@" + ((Get-AzureADTenantDetail).VerifiedDomains | Where-Object Initial -eq $true).Name),
    [Uri]$RecirectURL = "http://myapps.microsoft.com",
    [boolean]$SkipSendingInvitation,
    [boolean]$SkipResettingRedemtion,
    [switch]$All
    
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
$SkipSendingInvitation = -not $SkipSendingInvitation
$SkipResettingRedemtion = -not $SkipResettingRedemtion


if ($All) {
    $UPN = (Get-AzureADUser -Filter "UserType eq 'Guest'").UserPrincipalName
    Write-Warning "This will reset invites for all guest users. Are you sure?"
    Wait-ForKey "y"
    
}
[System.Collections.ArrayList]$Results = @()
$UPN | ForEach-Object {
    If ($PSCmdlet.ShouldProcess("$_", "Reset-InviteRedemption")) {
        $AzureAdUser = Get-AzureADUser -objectID $_
        $MsGraphUser = (New-Object Microsoft.Open.MSGraph.Model.User -ArgumentList $AzureAdUser.ObjectId)
        $Result = New-AzureADMSInvitation -InvitedUserEmailAddress $AzureAdUser.mail -SendInvitationMessage $SkipSendingInvitation -InviteRedirectUrl $RecirectURL -InvitedUser $MsGraphUser -ResetRedemption $SkipResettingRedemtion
        $Results += $Result
    }
}

Return $Results