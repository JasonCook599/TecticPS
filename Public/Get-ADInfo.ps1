<#PSScriptInfo

.VERSION 1.0.1

.GUID 868aac51-6c72-482e-8b54-42a3c5f87596

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


.PRIVATEDATA

#> 



<#
.SYNOPSIS
The script will get information about users, groups, and computers from Active Directory.

.DESCRIPTION
The script will get information about users, groups, and computers from Active Directory.

.PARAMETER ListUpn
List the UPN for each user. Can be combined with -Filter.

.PARAMETER LikeUpn
Filters for a specific UPN. Must be used in conjunction with -ListUpn. This overrides -Filter.

.PARAMETER ListHomeDirectory
List the home directory for each user.  Can be combined with -Filter.

.PARAMETER Filter
Filters the search based on the spesified parameters.

.PARAMETER ListComputerPasswords
List the local admin password. Can be combined with -Filter.

.PARAMETER UpdateUpn
Updates the Upn. Must be used with -OldUpn and -NewUpn. Can be combined with -SearchBase

.PARAMETER OldUpn
Specifes the UPN to be changed from. If unspecified, will use "*@koinonia.local".

.PARAMETER NewUpn
Spesified the UPN to change to.  If unspecified, will use "*@***REMOVED***".

.PARAMETER SearchBase
Specifies the search base for the command.

.PARAMETER ListComputers
List the computers in the organization.  Can be combined with -Filter.

.PARAMETER Export
Export to a CSV file using the hard-coded search parameters. If no file specified, will use .\AD Users.csv

.PARAMETER Sid
Matches the specified SID to a user.

.EXAMPLE
Get-ADInfo.ps1 -listUpn
name       UserPrincipalName
----       -----------------
Jane Doe   Jane.Doe@domain1.com
John Doe   John.Doe@domain2.com

.EXAMPLE
Get-ADInfo.ps1 -listUpn -likeUpn domain2
name       UserPrincipalName
----       -----------------
John Doe   John.Doe@domain2.com

.EXAMPLE
Get-ADInfo.ps1 -listHomeDirectory
name      homeDirectory                           profilePath
----      -------------                           -----------
Jane Doe  \\server.domain1.com\Profile\Jane.Doe\
John Doe  \\server.domain2.com\Profile\John.Doe\

.EXAMPLE
Get-ADInfo.ps1 -ListComputerPasswords
name            ms-Mcs-AdmPwd
----            -------------
JANEDOE-LAPTOP  *TVCiN#8bMVOW
JOHNDOE-LAPTOP  r4o1eY747KXN6Ty
#>

param(
  [string]$Filter,
  [switch]$ListUpn,
  [string]$likeUpn,
  [switch]$updateUpnSuffix,
  [string]$oldUpnSuffix,
  [string]$newUpnSuffix,
  [string]$SearchBase,
  [switch]$ListHomeDirectory,
  [switch]$ListComputers,
  [switch]$ListComputerPasswords,
  [switch]$ListExtensions,
  [switch]$Export,
  [string]$Sid
)

$meActual = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$me = "${meActual}:"
$parent = Split-Path $script:MyInvocation.MyCommand.Path

Function checkAdmin {
  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
		}
}

If (!(Get-Module ActiveDirectory)) { Import-Module ActiveDirectory }

# List UPN
If ($ListUpn) {
  If ($likeUpn) {
    $UpnFilter = "*" + $likeUpn + "*"
  }
  Elseif ($Filter) {
    $UpnFilter = $Filter
  }
  Else {
    $UpnFilter = "*"
  }
  Write-Verbose "$me Listing all users with a UPN like $filter. Sorting by UPN"
  Get-ADUser -Filter { UserPrincipalName -like $UpnFilter } -Properties distinguishedName, UserPrincipalName | Select-Object name, UserPrincipalName | Sort-Object -Property UserPrincipalName | Format-Table
}

# Update UPN
If ($updateUpnSuffix) {
  Write-Verbose "$me Setting old UPN, new UPN, and Search Base if not specified."
  If (!$oldUpnSuffix) { $oldUpnSuffix = "@koinonia.local" }
  $OldUpnSearch = "*" + $oldUpnSuffix
  If (!$newUpnSuffix) { $newUpnSuffix = "@***REMOVED***" }
  If (!$searchBase) { $searchBase = "DC=koinonia,DC=local" }
  Write-Verbose "$me Starting update..."
  checkAdmin
  Write-Information -MessageData "$me Changing UPN to $newUpnSuffix for all uses with a $oldUpnSuffix UPN in $searchBase." -InformationAction Continue
  Get-ADUser -Filter { UserPrincipalName -like $OldUpnSearch } -SearchBase $searchBase |
  ForEach-Object {
    $OldUpn = $_.UserPrincipalName
    $Upn = $_.UserPrincipalName -ireplace [regex]::Escape($oldUpnSuffix), $newUpnSuffix
    Set-ADUser -identity $_ -UserPrincipalName $Upn
    $NewUpn = $_.UserPrincipalName
    Write-Verbose "$me Changed $OldUpn to $NewUpn"
  }
}

If ($ListHomeDirectory) {
  If (!$filter) { $filter = "*" }
  Write-Verbose "$me Listing all users with their Home Directory and Profile Path. Sorting by Home Directory"
  Get-ADUser -Filter $filter -Properties homeDirectory, profilePath  | Select-Object name, homeDirectory, profilePath | Sort-Object -Property homeDirectory -Descending | Format-Table
}

If ($ListComputers) {
  If (!$filter) { $filter = "*" }
  Write-Verbose "$me Getting OS Versions"
  Get-ADComputer -Filter * -Property Name, OperatingSystem, OperatingSystemVersion, operatingSystemServicePack | Sort-Object @{Expression = 'OperatingSystem'; Ascending = $true }, @{Expression = 'operatingSystemVersion'; Ascending = $false }, @{Expression = 'Name'; Ascending = $true } | Format-Table Name, OperatingSystem, OperatingSystemVersion, operatingSystemServicePack -Wrap -Auto
}

Function listComputerPasswords {
  param([string]$Filter, [string]$Message)
  If (!$filter) { $filter = "*" }
  checkAdmin
  Write-Information -MessageData "$Message" -InformationAction Continue
  Get-ADComputer -Filter $Filter -Properties ms-Mcs-AdmPwd | Select-Object name, ms-Mcs-AdmPwd | Sort-Object -Property ms-Mcs-AdmPwd -Descending | Format-Table
}
If ($ListComputerPasswords -AND $Filter) {
  listComputerPasswords -Message "$me Computers matching $filter." -Filter $Filter
}
Elseif ($ListComputerPasswords) {
  listComputerPasswords -Message "$me Non-mac passwords." -Filter 'Name -notlike "*-DM" -and Name -notlike "*-LM" -and Enabled -eq $True'
  listComputerPasswords -Message "$me Mac passwords." -Filter 'Name -like "*-DM" -or Name -like "*-LM" -and Enabled -eq $True'
  listComputerPasswords -Message "$me Disabled computer accounts." -Filter 'Enabled -eq $False'
}
  


If ($ListExtensions) {
  If (!$filter) { $filter = "*" }
  Write-Verbose "$me Getting ipPhone"
  Get-ADUser -LDAPFilter "(ipPhone=*)" -Properties ipPhone  | Select-Object name, ipPhone | Sort-Object -Property ipPhone
}

If ($Export) {
  #File Location
  If ($Export) { $ExportFile = $Export }
  If (!$ExportFile) { $ExportFile = $parent + "\AD Users.csv" }
  Write-Verbose "$me Writing to $ExportFile"

  #Set the domain to search at the Server parameter. Run powershell as a user with privilieges in that domain to pass different credentials to the command.
  #Searchbase is the OU you want to search. By default the command will also search all subOU's. To change this behaviour, change the searchscope parameter. Possible values: Base, onelevel, subtree
  #Ignore the filter and properties parameters

  $ADUserParams = @{
    'Server'      = 'KCFAD01.***REMOVED***.local'
    'Searchbase'  = 'OU=_***REMOVED***,DC=***REMOVED***,DC=local'
    'Searchscope' = 'Subtree'
    'Filter'      = '*'
    'Properties'  = '*'
  }

  #This is where to change if different properties are required.
  $SelectParams = @{
    'Property' = 'SAMAccountname', 'CN', 'title', 'DisplayName', 'Description', 'EmailAddress', 'mobilephone', @{name = 'businesscategory'; expression = { $_.businesscategory -join '; ' } }, 'office', 'officephone', 'state', 'streetaddress', 'city', 'employeeID', 'Employeenumber', 'enabled', 'lockedout', 'lastlogondate', 'badpwdcount', 'passwordlastset', 'created'
  }

  Get-ADUser @ADUserParams | Select-Object @SelectParams | Export-Csv $ExportFile
}

If ($Sid) {
  If (!$Sid) { Write-Error "Please specify a SID using the -SID paramater" }
  $Sid = [ADSI]"LDAP://<SID=$Sid>"
  Write-Output $Sid
}
