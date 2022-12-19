<#PSScriptInfo

.VERSION 1.1.17

.GUID 688addc9-7585-4953-b9ab-c99d55df2729

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
This will upload all profile photos to Office 365.

.DESCRIPTION
This will upload all profile photos to Office 365. It will match the filename to the mailbox identity. This can be used along with Set-AdPhotos to sync photos with Active Directory.

.PARAMETER Suffix
The suffix to add to the end of the mailbox identity. Can be used to upload for guest accounts.

.EXAMPLE
Set-AzureAdPhoto -Path C:\Photos\

.EXAMPLE
Set-AzureAdPhoto -Path C:\Photos\ -Suffix "_fabrikam.com#EXT#@contoso.com"

.LINK
https://www.michev.info/Blog/Post/3908/updating-your-profile-photo-as-guest-via-the-microsoft-graph-sdk-for-powershell
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    $Photos = (Get-ChildItem -Recurse -File),
    [guid]$TenantId,
    [hashtable]$Substitute,
    [string]$Suffix
)

Requires Microsoft.Graph.Users

$MgContext = Get-MgContext
$ConnectMgGraph = @{Scopes = "User.ReadWrite.All" }
if ($TenantId) { $ConnectMgGraph.TenantId = $TenantId }

while (($TenantId -and $MgContext.TenantId -ne $TenantId) -or $MgContext.Scopes -notcontains "User.ReadWrite.All") {
    Connect-MgGraph @ConnectMgGraph | Write-Verbose
    $MgContext = Get-MgContext
}

$Photos | ForEach-Object {
    $count++ ; Progress -Index $count -Total $Photos.count -Activity "Uploading profile photos." -Name $_.Name

    Clear-Variable -ErrorAction SilentlyContinue -Name UploadError
    Clear-Variable -ErrorAction SilentlyContinue -Name User

    Write-Debug "Adding `'$Suffix`' to `$UserId"
    $UserId = ([System.IO.Path]::GetFileNameWithoutExtension($_) + $Suffix)

    If ($Substitute) {
        $Substitute.GetEnumerator() | ForEach-Object {
            Write-Verbose "Replacing $($_.Name) with $($_.Value)"
            $UserId = $UserId -replace $_.Name, $_.Value
        }
    }
    $User = Get-MgUser -UserId $UserId -ErrorAction SilentlyContinue

    If ($PSCmdlet.ShouldProcess($User.DisplayName, "Set-MgUserPhotoContent")) {
        if ($User.Id) {
            Set-MgUserPhotoContent -UserId $User.Id -InFile $_.FullName -ErrorVariable UploadError
            return [PSCustomObject]@{
                UserId       = $User.Id
                DisplayName  = $User.DisplayName
                EmailAddress = $User.Mail
                Photo        = $_.FullName
                PhotoDate    = $_.LastWriteTime
                Error        = $UploadError[0]
            }
        }
        else {
            return [PSCustomObject]@{
                UserId       = $UserId
                DisplayName  = $null
                EmailAddress = $null
                Photo        = $_.FullName
                PhotoDate    = $_.LastWriteTime
                Error        = "User does not exist."
            }
        }
    }
}
