<#PSScriptInfo

.VERSION 1.0.5

.GUID 10b98a61-ebf3-499f-847f-4aa18b41a9dd

.AUTHOR Jason Cook Rajeev Buggaveeti

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
.SYNOPSIS
This will download all profile photos from Office 365.

.DESCRIPTION
This will download all profile photos from Office 365. This can be used along with Set-AdPhotos to syn photos with Active Directory

.PARAMETER Return
Whether to return what options have been set. If unspesified, this is False.

.PARAMETER Users
Array of users to run the command against. If unspesified, will run against all Exchange mailboxes.

.PARAMETER PhotoDirectory
The directory where downloaded photos will be saved to.

.PARAMETER CroppedPhotoDirectory
The directory where cropped photos will be saved to.

.PARAMETER ResultsFile
A csv file to save the results to.

.EXAMPLE
Get-ExchangePhotos

.LINK
https://blogs.technet.microsoft.com/rajbugga/2017/05/16/picture-sync-from-office-365-to-ad-powershell-way/
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [switch]$Return,
    [array]$Users = (Get-Mailbox -ResultSize Unlimited),
    [string]$Path = (Get-Location).ProviderPath,
    [string]$CroppedPath = $Path + "\Cropped\",
    [string]$ResultsFile
)

$Results = @()

#Download all user profile pictures from Office 365:
Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $Path -ItemType Directory -Force -Confirm:$false | Out-Null
#Output to store Resized images#
Get-ChildItem -Path $CroppedPath -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $CroppedPath -ItemType Directory -Force -Confirm:$false | Out-Null

foreach ($User in $Users) {
    $count++ ; Progress -Index $count -Total $Users.count -Activity "Downloading users photos." -Name $User.UserPrincipalName.ToString()

    $Result = @{}

    $PhotoPath = $Path + "\" + $User.Alias + ".jpg"
    $CroppedPhotoPath = $CroppedPath + $User.Alias + ".jpg"
    $Photo = Get-UserPhoto -Identity $User.UserPrincipalName -ErrorAction SilentlyContinue

    If ($null -ne $Photo.PictureData) {
        If ($PSCmdlet.ShouldProcess("$User", "Get-ExchangePhoto")) {
            [io.file]::WriteAllBytes($PhotoPath, $Photo.PictureData)
            Resize-Image -InputFile $PhotoPath -Width 96 -Height 96 -OutputFile $CroppedPhotoPath
            Write-Verbose "Profile photo downloaded for $($User.Alias)."
        }
        $Result.Add("PhotoStatus", $true)
    }
    else {
        Write-Warning "$User does not have a profile photo."
        $Result.Add("PhotoStatus", $false)
    }

    $Result.Add("DisplayName", $user.DisplayName)
    $Result.Add("UserPrincipalName", $user.UserPrincipalName)
    $Result.Add("RecipientType", $user.RecipientType)
    $Result.Add("Alias", $user.Alias)
    $Results += New-Object PSObject -Property $Result
}

If ($ResultsFile) { $Results | Export-CSV $ResultsFile -NoTypeInformation -Encoding UTF8 }
Return $Results
