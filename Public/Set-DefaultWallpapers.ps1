<#PSScriptInfo

.VERSION 1.0.10

.GUID 910cea1b-4c78-4282-ac1d-7a64897475ea

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2025

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
.DESCRIPTION
Change the default Windows wallpaper for new users and copies wallpapers to system folder.

.PARAMETER SourcePath
The lcoation to search for images in.

.PARAMETER Images
An array of images to use. By default, this will select all *.jpg files in $SourcePath

.PARAMETER Name
The name of the folder to copy the images to. If not specified, this script will use "Defaults" and copy to $env:windir\Web\Wallpaper\$Name

.PARAMETER LockScreen
Sets the lock screen wallpaper and prevents the user from changing it.

.LINK
https://ccmexec.com/2015/08/replacing-default-wallpaper-in-windows-10-using-scriptmdtsccm/
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateScript( { Test-Path $_ })][string]$SourcePath,
  $Images = (Get-ChildItem $SourcePath -Filter *.jpg),
  [string]$Name = "Defaults",
  [switch]$LockScreen
)

Test-Admin -Throw -Message "You must be an administrator to modify the default wallpapers." | Out-Null

$DestinationPath = (Join-Path -Path $env:windir -ChildPath "Web\Wallpaper\$Name")
$SystemPath = (Join-Path -Path $env:windir -ChildPath "Web\Wallpaper\Windows")
$ResolutionPath = (Join-Path -Path $env:windir -ChildPath "Web\4K\Wallpaper\Windows")
$DefaultImagePath = (Join-Path -Path $SystemPath -ChildPath "img0.jpg")

Write-Verbose "Copying all wallpapers from $SourcePath to $DestinationPath"
try { Remove-Item -Path $DestinationPath -Recurse -Force | Out-null }
catch [System.Management.Automation.ItemNotFoundException] { Write-Verbose "$DestinationPath does not exists." }

New-Item -ItemType Directory -Path $DestinationPath -ErrorAction Stop | Out-null

$count = -1
$Images | ForEach-Object {
  $count++ ; Progress -Index $count -Total $Images.count -Activity "Copying wallpapers." -Name $_.Name
  Copy-Item -Path $_.FullName -Destination (Join-Path -Path $DestinationPath -ChildPath ("img" + $count + ".jpg")) -Force
}

Write-Verbose "Removing existing wallpapers."
Get-ChildItem -Path $SystemPath, $ResolutionPath -Recurse | ForEach-Object {
  Write-Verbose "Removing $($_.Name)"
  takeown /f $_.FullName
  icacls $($_.FullName) /Grant administrators:F
  Remove-Item $_.FullName
}
if ($Images.Count -lt 2) { $Image = $Images[0] }
else { $Image = $Images[(Get-Random -Minimum 0 -Maximum ($Images.Count - 1))] }

Write-Verbose "Setting default wallpaper to $($Image.Name)"
Copy-Item -Path $Image.FullName -Destination $DefaultImagePath

if ($LockScreen) {
  try {
    $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP\"
    $RegistryParent = (Split-Path -Path $RegistryPath -Parent)

    if (-not (Test-Path -Path $RegistryPath)) { New-Item -Path $RegistryParent -Name (Split-Path -Path $RegistryPath -Leaf) -ItemType RegistryKey }

    if (-not (Test-RegistryValue -Path $RegistryPath -Value LockScreenImagePath)) { New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP\ -Name LockScreenImagePath -Value "file:///C:\Windows\Web\Wallpaper\Windows\img0.jpg" -PropertyType "String" }
    else { Set-ItemProperty -Path $RegistryPath -Name LockScreenImagePath -Value "C:\Windows\Web\Wallpaper\Windows\img0.jpg" -Type String }

    if (-not (Test-RegistryValue -Path $RegistryPath -Value LockScreenImageUrl)) { New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP\ -Name LockScreenImageUrl -Value "file:///C:\Windows\Web\Wallpaper\Windows\img0.jpg" -PropertyType "String" }
    else { Set-ItemProperty -Path $RegistryPath -Name LockScreenImageUrl -Value "C:\Windows\Web\Wallpaper\Windows\img0.jpg" -Type String }

    if (-not (Test-RegistryValue -Path $RegistryPath -Value LockScreenImageStatus)) { New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP\ -Name LockScreenImageStatus -Value 1 -PropertyType "DWord" }
    else { Set-ItemProperty -Path $RegistryPath -Name LockScreenImageStatus -Value 1 -Type DWord }
  }
  catch {
    $_
    Write-Warning "Failed to set lockscreen wallpaper."
  }
}
