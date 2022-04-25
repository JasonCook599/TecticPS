<#PSScriptInfo

.VERSION 1.2.7

.GUID 8ab0507b-8af2-4916-8de2-9457194fb454

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
This script will install the neccesary applications and services on a given machine.

.DESCRIPTION
This script will install the neccesary applications and services on a given machine. It will also check for updates to third-party applications. This script will also configure certain items not able to be configured by Group Policy,

.PARAMETER BitLockerProtector
If a protector is specified, BitLocker will be enabled using that protector. Valid options are TPM, Pin, Password, and USB. You can also pass Disable to disable BitLocker

.PARAMETER BitLockerEncryptionMethod
Used to specify the encryption method for BitLocker. If unspecified, XtsAes256 will be used.

.PARAMETER BitLockerUSB
If the USB protector is spesified, use this to specify the USB drive to use.

.PARAMETER DriveLabel
This specifies what the drive will be labeled as. If unspecified, "Windows" will be used.

.PARAMETER DriveToLabel
This specifies which drive to label. If unspecified, the system drive will be used.

.PARAMETER Ninite
If specified, Ninite will be run and install the default third party applications.

.PARAMETER InstallTo
Specifies the defgault install device type for Ninite. Will use Ninite's default if unspecified.

.PARAMETER NetFX3
If specified, ".NET Framework 3.5 (includes .NET 2.0 and 3.0)" will be installed.

.PARAMETER ProvisioningPackage
Choose a Provisioning Package to be installed.

.PARAMETER RSAT
If specified, Remote Server Administrative Tools will be installed.

.PARAMETER Office
Specifes the version of Office to install. If unspecified, Office will not be installed.
  
.EXAMPLE
Install.ps1 -BitLocker -Office 2019

#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateSet("TPM", "Password", "Pin", "USB")][string]$BitLockerProtector,
  [string]$Office,
  [switch]$RSAT,
  [string]$ProvisioningPackage,
  [switch]$NetFX3,
  [switch]$Ninite,
  [string]$NiniteInstallTo = "Workstation",
  [ValidateScript({ Test-Path $_ })][string]$BitLockerUSB,
  [string]$BitLockerEncryptionMethod = "XtsAes256",
  [string]$DriveLabel = "Windows",
  [string]$DriveToLabel = ($env:SystemDrive.Substring(0, 1))
)

$meActual = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$me = "${meActual}:"
$parent = Split-Path $script:MyInvocation.MyCommand.Path

Import-Module $parent\***REMOVED***It\***REMOVED***IT.psm1 -Force
If (!(Test-Admin -Warn)) { Break }

If ($BitLockerProtector) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Enable-Bitlocker with `'$BitLockerProtector`' protector using $BitLockerEncryptionMethod")) {
    If ($BitLockerProtector -eq "Disable") { Disable-BitLocker -MountPoint $env:SystemDrive }
    Else {
      Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -RecoveryPasswordProtector
      $BLV = Get-BitLockerVolume -MountPoint $env:SystemDrive
      $RecoveryPassword = $BLV.KeyProtector | Where-Object KeyProtectorType -eq "RecoveryPassword"
      Backup-BitLockerKeyProtector -MountPoint $env:SystemDrive -KeyProtectorId $RecoveryPassword.KeyProtectorId | Out-Null
      If ($BitLockerProtector -eq "TPM") {
        Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod $BitLockerEncryptionMethod -TpmProtector
      }
      ElseIf ($BitLockerProtector -eq "Password") {
        $BitLockerSecurePassword = Read-Host -Prompt "Enter Password" -AsSecureString
        Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod $BitLockerEncryptionMethod -PasswordProtector -Password $BitLockerSecurePassword
      }
      ElseIf ($BitLockerProtector -eq "Pin") {
        $BitLockerSecurePin = Read-Host -Prompt "Enter PIN" -AsSecureString
        Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod $BitLockerEncryptionMethod -TPMandPinProtector -Pin $BitLockerSecurePin 
      }
      ElseIf ($BitLockerProtector -eq "USB") {
        Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod $BitLockerEncryptionMethod -StartupKeyProtector -StartupKeyPath $BitLockerUSB
      }
      Else {
        Write-Warning "No valid protector spesified. BitLocker will NOT be enabled."
      }
    }
  }
}

If ($NetFX3) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install .NET Framework 3.5 (includes .NET 2.0 and 3.0)")) {
    Write-Verbose "Installing .NET Framework 3.5 (includes .NET 2.0 and 3.0)"
    Get-WindowsCapability -Online -Name NetFx3* | Add-WindowsCapability -Online
  }
}

If ($RSAT) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install Remote Server Administrative Tools")) {
    Write-Verbose "Install Remote Server Administrative Tools"
    Get-WindowsCapability -Online -Name "RSAT*" | Add-WindowsCapability -Online
  }
}
If ($Ninite) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername) $NiniteInstallTo", "Install apps using Ninite")) {
    Write-Verbose "Running Ninite"
    & $parent\..\Ninite\Ninite.ps1 -Local -InstallTo $NiniteInstallTo
  }
}

If ($Office) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install Office $Office")) {
    Install-MicrosoftOffice -Version $Office
  }
}


If ($ProvisioningPackage) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install-ProvisioningPackage -QuietInstall -PackagePath $ProvisioningPackage")) {
    If (Test-Path -PathType Leaf -Path $ProvisioningPackage) { Install-ProvisioningPackage -QuietInstall -PackagePath $ProvisioningPackage }
    else { Write-Warning "$me The provisioning file specified is not valid." }
  }
}

If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Set-Volume -DriveLetter $DriveToLabel -NewFileSystemLabel $DriveLabel")) {
  Set-Volume -DriveLetter $DriveToLabel -NewFileSystemLabel $DriveLabel
  Write-Verbose "$me Checking for reboot."
  Import-Module $parent\Modules\pendingreboot.0.9.0.6\pendingreboot.psm1
  If ((Test-Path "HKLM:\SOFTWARE­\Microsoft­\Windows­\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") -or (Test-PendingReboot -SkipConfigurationManagerClientCheck).IsRebootPending) {
    Write-Verbose "A reboot is required. Reboot now?"
    Restart-Computer -Confirm
  }
}
