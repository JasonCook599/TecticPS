<#PSScriptInfo

.VERSION 1.0.1

.GUID fc0d9531-8d08-4b67-8247-7ade678c2d31

.AUTHOR Jason Cook CarlosDZRZ

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
Remove Mailbox Orphaned_SIDs Access Control Lists (ACLs) and Access Control Entries (ACEs)

.DESCRIPTION
Remove Mailbox Orphaned_SIDs Access Control Lists (ACLs) and Access Control Entries (ACEs)

.PARAMETER  Alias
The Alias parameter specifies the alias (mail nickname) of the user.

.PARAMETER  PathFolder
Specifies a path to log folder location.The default location is $env:USERPROFILE+'\EXCH_RemoveSIDs\'

.EXAMPLE
Remove-MailboxOrphaned_SIDs -Alias test_mailbox

.EXAMPLE
Get-Mailbox test_mailbox | Remove-MailboxOrphaned_SIDs

.EXAMPLE
$mailboxes = Get-Mailbox -ResultSize 0
$mailboxes | Remove-MailboxOrphaned_SIDs

.OUTPUTS
Log file.

.NOTES
Date Created: 04/08/2016

.LINK
https://technet.microsoft.com/es-es/library/aa998218(v=exchg.160).aspx

.LINK
https://technet.microsoft.com/en-us/library/hh360993.aspx

#>
[CmdletBinding()]
Param
(
	[parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string[]]$Alias,
	[string]$PathFolder = $env:USERPROFILE + '\EXCH_RemoveSIDs\'
)
Begin {
	$date = (Get-Date).Day.ToString() + "-" + (Get-Date).Month.ToString() + "-" + (Get-Date).Year.ToString()
	$filename = "RemoveSIDs_" + $date
	Write-Verbose $PathFolder
	if (!(Test-Path -Path $PathFolder -PathType Container)) {
		New-Item -Path $PathFolder  -ItemType directory
		Write-Host -ForegroundColor Green "create a new folder"
	}
	$filepath = $PathFolder + $filename + '.log'
	$stream = [System.IO.StreamWriter] $filepath
	$usrs_access = ""
	$usr_access = ""
}
Process {
	foreach ($Aliasmbx in $Alias) {
		$writelog = $false
		$SID_AccessRights = $null
		$SID_SendAs = $null
		$usrs_access = Get-MailboxPermission $Aliasmbx | Where-Object { ($_.isinherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF") } | Select-Object User, AccessRights
		foreach ($usr_access in $usrs_access) {
			if ($usr_access.User -like 'S-1-5-21*') {
				$writelog = $true
				Remove-MailboxPermission $Aliasmbx -User $usr_access.User -AccessRights $usr_access.AccessRights -Confirm:$false
				Write-Verbose "SID to delete:  $($usr_access.User) with the following permissions: $($usr_access.AccessRights) on $Aliasmbx mailbox"
				$SID_AccessRights += "SID to delete:  $($usr_access.User) with the following permissions: $($usr_access.AccessRights) `r`n"
			}
		}
		# $usrs_SendAs = Get-Mailbox $Aliasmbx | Get-ADPermission | Where-Object {($_.ExtendedRights -like "*-As*") -and -not ($_.User -like "NT AUTHORITY\SELF")}
		foreach ($usr_SendAs in $usrs_SendAs) {
			if ($usr_SendAs.User -like 'S-1-5-21*') {
				$writelog = $true
				Remove-AdPermission $Aliasmbx -User $usr_SendAs.User -ExtendedRights $usr_SendAs.ExtendedRights -Confirm:$false
				Write-Verbose "SID to delete:  $($usr_SendAs.User) with the permission $($usr_SendAs.ExtendedRights) on $Aliasmbx mailbox"
				$SID_SendAs += "SID to delete:  $($usr_SendAs.User) with the permission $($usr_SendAs.ExtendedRights) `r`n"
			}
		}
		if ($writelog) {
			$stream.WriteLine("============================================================================")
			$stream.WriteLine("Buzon: $Aliasmbx")
			if ($null -ne $SID_AccessRights) { $stream.WriteLine($SID_AccessRights) }
			if ($null -ne $SID_SendAs) { $stream.WriteLine($SID_SendAs) }
			$stream.WriteLine("============================================================================")
		}
	}
}#End Process
End {
	$stream.close()
}
