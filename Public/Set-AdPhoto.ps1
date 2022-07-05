<#PSScriptInfo

.VERSION 1.1.2

.GUID 5dcbac67-cebe-4cb8-bf95-8ad720c25e72

.AUTHOR Jason Cook Rajeev Buggaveeti

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
This will set Active Directory thumbnailPhoto from matching files in the specified directory.

.DESCRIPTION
This will set Active Directory thumbnailPhoto from matching files in the specified directory.

.PARAMETER Path
The directory where photos will be pulled from.

.PARAMETER Users
Array of users to run the command against. If unspesified, it will run against all files in the specified directory.

.EXAMPLE
Set-AdPhoto

.LINK
https://blogs.technet.microsoft.com/rajbugga/2017/05/16/picture-sync-from-office-365-to-ad-powershell-way/
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [ValidateScript( { Test-Path $_ })][string]$Path = (Get-Location),
    [array]$Users = (Get-ChildItem $Path -File)
)

Test-Admin -Warn -Message "You are not running this script as an administrator. It may not work as expected." | Out-null
foreach ($User in $Users) {
    $count++ ; Progress -Index $count -Total $Users.count -Activity "Setting users photos." -Name [System.IO.Path]::GetFileNameWithoutExtension($User.Name)

    $Account = [System.IO.Path]::GetFileNameWithoutExtension($User.Name)
    $Search = [System.DirectoryServices.DirectorySearcher]([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).GetDirectoryEntry()
    $Search.Filter = "(&(objectclass=user)(objectcategory=person)(samAccountName=$account))"
    $Result = $Search.FindOne()

    if ($null -ne $Result) {
        If ($PSCmdlet.ShouldProcess("$Account", "Set-AdPhotos")) {
            try {
                Write-Verbose "Setting photo for user `"$($UserResult.displayname)`""
                [byte[]]$Photo = Get-Content ($Path + "\" + $User) -Encoding Byte
                $UserResult = $Result.GetDirectoryEntry()
                $UserResult.put("thumbnailPhoto", $Photo)
                $UserResult.setinfo()
            }
            catch [System.Management.Automation.MethodInvocationException] {
                if (Test-Admin) { Throw "You do not have permission to make these changes." }
                else { Throw "You do not have permission to make these changes. Try running as admin." }
            }
        }
    }
    else { Write-Warning "User `"$account`" does not exist. Skipping." }
}
