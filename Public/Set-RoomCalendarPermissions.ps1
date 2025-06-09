<#PSScriptInfo

.VERSION 1.0.6

.GUID 9d477618-5530-413c-bdf8-3ddf1580dbfa

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2024

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
Makes Availability information available to all users.

.PARAMETER User
What user should the permissions be set for. If not specified, the DEFAULT user is used.

.PARAMETER AccessRight
The access right to set. By default, the access right is set to LimitedDetails.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  $User = "Default",
  $AccessRights = "LimitedDetails"
)

Get-Mailbox -RecipientTypeDetails RoomMailbox | ForEach-Object {
  If ($PSCmdlet.ShouldProcess("$_", "Set-RoomCalendarPermissions")) {
    Set-MailboxFolderPermission -Identity $($_.Identity + ":\Calendar") -User $User -AccessRights $AccessRights
  }
}
