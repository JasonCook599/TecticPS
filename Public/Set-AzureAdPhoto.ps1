<#PSScriptInfo

.VERSION 1.1.23

.GUID 688addc9-7585-4953-b9ab-c99d55df2729

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) TectTectic

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

.PARAMETER Photos
An array of photos to process. Photo names should match the user principal name, excluding the file extension.

.PARAMETER TenantId
The Azure AD tenant id. If not specified, it will try and use the current user's tennant.

.PARAMETER ClientId
When authenticating as an application, the ClientId of that application.

.PARAMETER Certificate
When authenticating as an application, the certificate used for authentication.

.PARAMETER Substitute
An array of substitutions to make in the between the file name and the user principal name. Can be used to upload for guest accounts.

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
  [guid]$ClientId,
  [System.Security.Cryptography.X509Certificates.X509Certificate]$Certificate,
  [hashtable]$Substitute,
  [string]$Suffix
)

Requires Microsoft.Graph.Users

$MgContext = Get-MgContext
$ConnectMgGraph = @{}
if ($TenantId) { $ConnectMgGraph.TenantId = $TenantId }
if ($ClientId -and $Certificate) {
  $ConnectMgGraph.ClientId = $ClientId
  $ConnectMgGraph.Certificate = $Certificate
}
elseif ($ClientId -or $Certificate) { throw "You must specify both or neither -ClientId and -Certificate" }
else { $ConnectMgGraph.Scopes = "User.ReadWrite.All" }

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
      Write-Debug "Replacing $($_.Name) with $($_.Value)"
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
