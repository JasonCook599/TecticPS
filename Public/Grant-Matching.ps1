<#PSScriptInfo

.VERSION 1.0.8

.GUID 8e42dd4d-c91c-420c-99f5-7b233590ae2c

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
This powershell script will grant NTFS permissions on folders where the username and folder name match.

.DESCRIPTION
This powershell script will grant NTFS permissions on folders where the username and folder name match. It accepts three parameters, AccessRights, Domain, and Folder.
This script requires the NTFSSecurity module: https://github.com/raandree/NTFSSecurity

.LINK
https://github.com/raandree/NTFSSecurity

.PARAMETER AccessRights
This can be used to set the access right on the child folders. If unspecified, it will give FullControl. See documentation of the NTFSSecurity module for options.

.PARAMETER Domain
This can be used to set the domain of the users. If unspecified, it will use the 'KOINONIA' domain.

.PARAMETER Folder
This can be used to select a folder in which to run these commands on. If unspecified, it will run in the PowerShell has active.

.EXAMPLE
.\Grant-Matching.ps1 -AccessRights FullControl -Folder C:\Users
Grant-Matching: Granting DOMAIN\user FullControl on C:\Users\user
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
	$Path = (Get-ChildItem | Where-Object { $_.PSISContainer }),
	[string]$AccessRights = 'FullControl',
	[string]$Domain = $Env:USERDOMAIN
)

Requires -Modules NTFSSecurity

foreach ($UserFolder in $Path) {
	$Account = $Domain + '\' + $UserFolder
	$count++ ; Progress -Index $count -Total $Path.count -Activity "Granting $Account $AccessRights." -Name $UserFolder.FullName
	If ($PSCmdlet.ShouldProcess("$($UserFolder.FullName)", "Add-NTFSAccess")) {
		Add-NTFSAccess -Path $UserFolder.FullName -Account $Account -AccessRights $AccessRights
	}
}
