<#PSScriptInfo

.VERSION 1.0.2

.GUID 240b7f82-8102-45be-9080-2cf28a7c5b3d

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
Sets windows account avatar from data in Active Directory.

.LINK
http://woshub.com/how-to-set-windows-user-account-picture-from-active-directory/#h2_2

.LINK
https://www.codetwo.com/admins-blog/use-active-directory-user-photos-windows-10/
#>

[CmdletBinding(SupportsShouldProcess = $true)]Param()
function Test-Null($InputObject) { return !([bool]$InputObject) }

$ADuser = ([ADSISearcher]"(&(objectCategory=User)(SAMAccountName=$env:username))").FindOne().Properties
$ADuser_photo = $ADuser.thumbnailphoto
$ADuser_sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value

If ((Test-Null $ADuser_photo) -eq $false) {
  $img_sizes = @(32, 40, 48, 96, 192, 200, 240, 448)
  $img_mask = "Image{0}.jpg"
  $img_base = "C:\Users\Public\AccountPictures"
  $reg_base = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\{0}"
  $reg_key = [string]::format($reg_base, $ADuser_sid)
  $reg_value_mask = "Image{0}"
  If ((Test-Path -Path $reg_key) -eq $false) { New-Item -Path $reg_key }
  Try {
    ForEach ($size in $img_sizes) {
      $dir = $img_base + "\" + $ADuser_sid
      If ((Test-Path -Path $dir) -eq $false) { $(mkdir $dir).Attributes = "Hidden" }
      $file_name = ([string]::format($img_mask, $size))
      $path = $dir + "\" + $file_name
      Write-Verbose " saving: $file_name"
      $ADuser_photo | Set-Content -Path $path -Encoding Byte -Force
      $name = [string]::format($reg_value_mask, $size)
      New-ItemProperty -Path $reg_key -Name $name -Value $path -Force
    }
  }
  Catch { Write-Error "Check permissions to files or registry." }
}
