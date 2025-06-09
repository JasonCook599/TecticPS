<#PSScriptInfo

.VERSION 1.0.6

.GUID 32f72580-a957-48f1-ba2e-da24f5550bb6

.AUTHOR saw-friendship

.COMPANYNAME

.COPYRIGHT Copyright (c) Tectic 2024

.TAGS ActiveDirectory AD User Primary Group Member

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

#>

<#

.EXAMPLE
Get-ADUser -Filter {Name -like 'u6*'} -Properties primaryGroupID,MemberOf | Set-ADUserPrimaryGroup -Group (Get-ADGroup 'Domain Users')

.EXAMPLE
Set-ADUserPrimaryGroup u676 'Domain Users'

.EXAMPLE
Set-ADUserPrimaryGroup u676,u677 'Domain Users'

.EXAMPLE
Get-ADUser u676 | Set-ADUserPrimaryGroup -Group (Get-ADGroup 'Domain Users')

.EXAMPLE
Get-ADUser -Filter {Name -like 'u6*'} | Set-ADUserPrimaryGroup -Group 'Domain Users'

.DESCRIPTION
Script for change the primary group of an AD user

.LINK
https://www.powershellgallery.com/packages/Set-ADUserPrimaryGroup/1.0.3/Content/Set-ADUserPrimaryGroup.ps1

#>

Param (
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$User,
  [Parameter(Mandatory = $true)]$Group
)
Begin {
  if ($Group.SID) {
    $ADGroup = $Group
  }
  else {
    $ADGroup = $Group | Get-ADGroup
  }

  $primaryGroupID = $ADGroup.SID -replace @('.+\-', '')

}

Process {
  $User | ForEach-Object {
    if ($_.PropertyNames -contains 'primaryGroupID' -and $_.PropertyNames -contains 'MemberOf') {
      $ADUser = $_
    }
    else {
      $ADUser = $_ | Get-ADUser -Properties primaryGroupID, MemberOf
    }

    if ($ADUser.MemberOf -notcontains $ADGroup.DistinguishedName) {
      try {
        Add-ADGroupMember -Identity $ADGroup.DistinguishedName -Members $ADUser.SID -ErrorAction SilentlyContinue
      }
      catch {
        # Write-Error $Error[0]
        exit
      }
    }

    $ADUser | Set-ADUser -Replace @{'primaryGroupID' = $primaryGroupID } -ErrorAction SilentlyContinue -PassThru | Get-ADUser -Properties primaryGroup, primaryGroupID, MemberOf
  }
}

End {}
