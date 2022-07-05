<#PSScriptInfo

.VERSION 1.3.2

.GUID 61ab8232-0c28-495f-9e44-3c511c2634ea

.AUTHOR Jason Cook & Roman Zarka | Microsoft Services

.COMPANYNAME ***REMOVED*** & Microsoft Services

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
This script enable the spesified license options in Microsoft 365.

.PARAMETER Return
Whether to return what options have been set. If unspesified, this is False.

.PARAMETER AccountSkuId
Account SKU ID to run against.

.PARAMETER KeepEnabled
Whether to keep enabled services if nothing is spesified.

.PARAMETER Users
Array of users to run the command against. If unspesified, will run against all licensed users.

.PARAMETER NoForms
An array of users which will have Forms disabled.

.PARAMETER NoFlow
An array of users which will have Flow disabled.

.PARAMETER NoPowerApps
An array of users which will have PowerApps disabled.

.PARAMETER NoPlanner
An array of users which will have Planner disabled.

.PARAMETER NoOfficeOnline
An array of users which will have Office Online disabled.

.PARAMETER NoSharepoint
An array of users which will have Sharepoint disabled.

.PARAMETER NoExchange
An array of users which will have Exchange disabled.

.EXAMPLE
Enable-LicenseOptions

.NOTES
Credits    : Created by Roman Zarka at Microsoft. Available under Creative Commons Attribution 4.0 International License.

.LINK
https://blogs.technet.microsoft.com/zarkatech/2012/12/05/bulk-enable-office-365-license-options/

.LINK
https://docs.microsoft.com/en-us/microsoft-365/enterprise/assign-licenses-to-user-accounts-with-microsoft-365-powershell?view=o365-worldwide

.LINK
https://github.com/MicrosoftDocs/microsoft-365-docs/blob/public/LICENSE
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [switch]$Return,
  [string]$AccountSkuId = "STANDARDWOFFPACK",
  [switch]$KeepEnabled = $False,
  [switch]$Assign = $False,
  [array]$Users = (Get-MsolUser -All | Where-Object { $_.IsLicensed -eq $true } | Select-Object UserPrincipalName | Sort-Object UserPrincipalName),
  [array]$NoForms = (Get-ADGroupMember -Recursive -Identity "Office 365-No Forms" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoStream = (Get-ADGroupMember -Recursive -Identity "Office 365-No Stream" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoFlow = (Get-ADGroupMember -Recursive -Identity "Office 365-No Flow" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoPowerApps = (Get-ADGroupMember -Recursive -Identity "Office 365-No PowerApps" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoPlanner = (Get-ADGroupMember -Recursive -Identity "Office 365-No Planner" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoTeams = (Get-ADGroupMember -Recursive -Identity "Office 365-No Teams" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoOfficeOnline = (Get-ADGroupMember -Recursive -Identity "Office 365-No Office Online" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoSharepoint = (Get-ADGroupMember -Recursive -Identity "Office 365-No Sharepoint" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoExchange = (Get-ADGroupMember -Recursive -Identity "Office 365-No Exchange" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName)
)

[System.Collections.ArrayList]$Results = @()
$count = 1; $PercentComplete = 0;
ForEach ($User in $Users) {
  #Progress message
  $ActivityMessage = "Setting available licence data for users. Please wait..."
  $StatusMessage = ("Processing {0} of {1}: {2}" -f $count, @($Users).count, $User.UserPrincipalName.ToString())
  $PercentComplete = ($count / @($Users).count * 100)
  Write-Progress -Activity $ActivityMessage -Status $StatusMessage -PercentComplete $PercentComplete
  $count++

  # Mark all services as disabled.
  # Services.
  <#
Name            SKU                     Notes
Search          MICROSOFT_SEARCH        This app is assigned at the organization level. It can't be assigned per user.
RMS             RMS_S_BASIC             This app is assigned at the organization level. It can't be assigned per user.
Whiteboard      WHITEBOARD_PLAN1
Todo            BPOS_S_TODO_1
Forms           FORMS_PLAN_E1
Stream          STREAM_O365_E1
Staffhub        Deskless
Power Automate  FLOW_O365_P1
Power Apps      POWERAPPS_O365_P1
Planner         PROJECTWORKMANAGEMENT
Teams           TEAMS1
Sway            SWAY
MDM             INTUNE_O365            This app is assigned at the organization level. It can't be assigned per user.
Yammer          YAMMER_ENTERPRISE
Office Online   SHAREPOINTWAC
Skyper          MCOSTANDARD
Sharepoint      SHAREPOINTSTANDARD
Exchange        EXCHANGE_S_STANDARD
#>

  $Services = @{}
  If ($KeepEnabled) {
    (Get-MsolUser -UserPrincipalName $User.UserPrincipalName).Licenses | Where-Object AccountSkuId -like "*:$AccountSkuId" | ForEach-Object {

      ForEach-Object {
        # Mark currently enabled licenses services as enabled.
        # Comment out the lines for services you wish to force disable.
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "WHITEBOARD_PLAN1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Whiteboard = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "BPOS_S_TODO_1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Todo = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "FORMS_PLAN_E1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Forms = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "STREAM_O365_E1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Stream = $True }
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "Deskless" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.StaffHub = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "FLOW_O365_P1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Flow = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "POWERAPPS_O365_P1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.PowerApps = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "PROJECTWORKMANAGEMENT" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Planner = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "TEAMS1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Teams = $True }
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "SWAY" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Sway = $True }
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "YAMMER_ENTERPRISE" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Yammer = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "SHAREPOINTWAC" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.OfficeOnline = $True }
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "MCOSTANDARD" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Skype = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "SHAREPOINTSTANDARD" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Sharepoint = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "EXCHANGE_S_STANDARD" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Exchange = $True }
      }
    }
  }

  # Services you wish to enable by default.
  $Services.Todo = $True
  $Services.Forms = $True
  $Services.Stream = $True
  $Services.Flow = $True
  $Services.PowerApps = $True
  $Services.Planner = $True
  $Services.Teams = $True
  $Services.OfficeOnline = $True
  $Services.Sharepoint = $True
  $Services.Exchange = $True

  # Disabling services for members of corrosponding group.
  $SearchUpn = "*" + $User.UserPrincipalName + "*"
  If ($NoForms -like $SearchUpn) { $Services.Forms = $False }
  If ($NoStream -like $SearchUpn) { $Services.Stream = $False }
  If ($NoFlow -like $SearchUpn) { $Services.Flow = $False }
  If ($NoPowerApps -like $SearchUpn) { $Services.PowerApps = $False }
  If ($NoPlanner -like $SearchUpn) { $Services.Planner = $False }
  If ($NoTeams -like $SearchUpn) { $Services.Teams = $False }
  If ($NoOfficeOnline -like $SearchUpn) { $Services.OfficeOnline = $False }
  If ($NoSharepoint -like $SearchUpn) { $Services.Sharepoint = $False }
  If ($NoExchange -like $SearchUpn) { $Services.Exchange = $False }

  # Disable services still marked as disabled
  $DisabledOptions = @()
  If (!$Services.Whiteboard) { $DisabledOptions += "WHITEBOARD_PLAN1" }
  If (!$Services.Todo) { $DisabledOptions += "BPOS_S_TODO_1" }
  If (!$Services.Forms) { $DisabledOptions += "FORMS_PLAN_E1" }
  If (!$Services.Stream) { $DisabledOptions += "STREAM_O365_E1" }
  If (!$Services.StaffHub) { $DisabledOptions += "Deskless" }
  If (!$Services.Flow) { $DisabledOptions += "FLOW_O365_P1" }
  If (!$Services.PowerApps) { $DisabledOptions += "POWERAPPS_O365_P1" }
  If (!$Services.Planner) { $DisabledOptions += "PROJECTWORKMANAGEMENT" }
  If (!$Services.Teams) { $DisabledOptions += "TEAMS1" }
  If (!$Services.Sway) { $DisabledOptions += "SWAY" }
  If (!$Services.Intune) { $DisabledOptions += "INTUNE_O365" }
  If (!$Services.Yammer) { $DisabledOptions += "YAMMER_ENTERPRISE" }
  If (!$Services.OfficeOnline) { $DisabledOptions += "SHAREPOINTWAC" }
  If (!$Services.Skype) { $DisabledOptions += "MCOSTANDARD" }
  If (!$Services.Sharepoint) { $DisabledOptions += "SHAREPOINTSTANDARD" }
  If (!$Services.Exchange) { $DisabledOptions += "EXCHANGE_S_STANDARD" }

  if ($PSCmdlet.ShouldProcess($User.UserPrincipalName, "Enable-LicenseOptions")) {
    If ($Assign) {
      Set-MsolUser -UserPrincipalName $User.UserPrincipalName -UsageLocation CA
      Start-Sleep -Seconds 5
      $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
      $License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value ((Get-AzureADSubscribedSku | Where-Object SkuPartNumber -eq STANDARDWOFFPACK).SkuPartNumber) -EQ).SkuID
      $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
      $LicensesToAssign.AddLicenses = $License
      Set-AzureADUserLicense -ObjectId $User.UserPrincipalName -AssignedLicenses $LicensesToAssign
      Start-Sleep -Seconds 2
    }
    $LicenseOptions = New-MsolLicenseOptions -AccountSkuId ((Get-MsolAccountSku | Where-Object AccountSkuId -like *$AccountSkuId).AccountSkuId) -DisabledPlans $DisabledOptions
    Set-MsolUserLicense -User $User.UserPrincipalName -LicenseOptions $LicenseOptions
  }
  $Result = [PSCustomObject]@{
    Upn          = $User.UserPrincipalName
    Whiteboard   = $Services.Whiteboard
    Todo         = $Services.Todo
    Forms        = $Services.Forms
    Stream       = $Services.Stream
    StaffHub     = $Services.StaffHub
    Flow         = $Services.Flow
    PowerApps    = $Services.PowerApps
    Planner      = $Services.Planner
    Teams        = $Services.Teams
    Sway         = $Services.Sway
    Intune       = $Services.Intune
    Yammer       = $Services.Yammer
    OfficeOnline = $Services.OfficeOnline
    Skype        = $Services.Skype
    Sharepoint   = $Services.Sharepoint
    Exchange     = $Services.Exchange
  }
  $Results += $Result
}
If ($Return) { Return $Results }
