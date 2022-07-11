<#PSScriptInfo

.VERSION 1.0.1

.GUID 7e41b659-a682-489a-830d-5a118f2e11be

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
Enable permission interitance for the specified users.

.PARAMETER USers
An array of users to enable inheritence for.

.LINK
https://itomation.ca/enable-ad-object-inheritance-using-powershell/
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param (
    $Users,
    $Preserve = $true,
    $Action = "Enable"
)

Test-Admin -Warn -Message "You likely need to must be an administrator to change permissions." | Out-Null

if ($Action -eq "Enable") {
    $EnableInheritance = $true
}
else {
    $EnableInheritance = $false
}

$Users | ForEach-Object {
    $DistinguishedName = [ADSI]("LDAP://" + $_)
    $Acl = $DistinguishedName.psbase.objectSecurity
    [PSCustomObject]$Results = @{
        SamAccountName    = $_.SamAccountName
        DistinguishedName = $_.DistinguishedName
        Inheritence       = $Acl.get_AreAccessRulesProtected()
        Changed           = $null
    }
    if ($Acl.get_AreAccessRulesProtected()) {
        If ($PSCmdlet.ShouldProcess($_.SamAccountName, "Enable-AdUserPermissionInheritance.ps1")) {
            $Acl.SetAccessRuleProtection($EnableInheritance, $Preserve)
            $DistinguishedName.psbase.commitchanges()
            $Results.Changed = $true
            return [PSCustomObject]$Results
        }
        elseif ( $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent ) { return [PSCustomObject]$Results }
    }
    elseif ( $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent ) { return [PSCustomObject]$Results }
}
