<#PSScriptInfo

.VERSION 1.2.12

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


#> 



<#
.SYNOPSIS
This script will install the neccesary applications and services on a given machine.

.DESCRIPTION
This script will install the neccesary applications and services on a given machine. It will also check for updates to third-party applications. This script will also configure certain items not able to be configured by Group Policy,

.PARAMETER Action
An array of actions to run.
    Rename: Rename the computer. Use -HostNamePrefix to set a prefix.
    LabelDrive: Label the drive, by default, the $env:SystemDrive will be labelled "Windows". Use -DriveToLabel to change the drive and -DriveLabel to change the label.
    ProvisioningPackage: Install a provisioning package. Use -ProvisioningPackage to select the appropriate pacakge.
    JoinDomain: Join the current computer to a domain. Specify the domain with -Domain
    BitLocker: Enable BitLocker. You can overridde the defaults using -BitLockerProtector and -BitlockerEncryptionMethod. 
    Office: Install Microsoft Office. You can override the version using -Office.
    RSAT: Install Remote Server Administration Tools.
    NetFX3: Install .Net 3.0
    Ninte: Run Ninite.
    Winget: Install the spesified packages and update existing applications using Winget. Use -Winget to select the appropriate package.
    Reboot: Reboot the machine.

.PARAMETER HostNamePrefix
The prefix to use for the hostname.

.PARAMETER BitLockerProtector
Enable BitLocker using the spesified protector. If unspecified, TPM will be used. Valid options are TPM, Pin, Password, and USB. You can also pass Disable to disable BitLocker

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
The path to the Provisioning Package to be installed.

.PARAMETER RSAT
If specified, Remote Server Administrative Tools will be installed.

.PARAMETER OfficeVersion
Specifes the version of Office to install. If unspecified, Office will not be installed.

.PARAMETER WingetPackages
A hashtable of winget packages to install. The key is the package name and the value are any custom options required.

#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [int]$Step,
  [ValidateSet("Rename", "LabelDrive", "ProvisioningPackage", "JoinDomain", "BitLocker", "Office", "Wallpaper", "RSAT", "NetFX3", "Ninite", "Winget", "Reboot")][array]$Action,
  [string]$HostNamePrefix,
  [string]$Domain,
  [ValidateSet("TPM", "Password", "Pin", "USB")][string]$BitLockerProtector = "TPM",
  [hashtable]$WingetPackages,
  [string]$OfficeVersion = "2019",
  [ValidateScript({ Test-Path $_ })][string]$Wallpapers,
  [ValidateScript({ Test-Path $_ })][string]$ProvisioningPackage,
  [switch]$Ninite,
  [string]$NiniteInstallTo = "Workstation",
  [ValidateScript({ Test-Path $_ })][string]$BitLockerUSB,
  [string]$BitLockerEncryptionMethod = "XtsAes256",
  [string]$DriveLabel = "Windows",
  [string]$DriveToLabel = ($env:SystemDrive.Substring(0, 1))
)

Test-Admin -Throw
Requires ***REMOVED***IT

if ($Step -eq 1) { $Action = @("Rename", "LabelDrive", "Wallpaper", "Winget") }
if ($Step -eq 2) { $Action = @("BitLocker", "Office", "", "Reboot") }

if ($Action -contains "Rename") { Set-ComputerName -Prefix $HostNamePrefix }

if ($Action -contains "LabelDrive") {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Set-Volume -DriveLetter $DriveToLabel -NewFileSystemLabel $DriveLabel")) {
    Set-Volume -DriveLetter $DriveToLabel -NewFileSystemLabel $DriveLabel
  }
}

if ($Action -contains "ProvisioningPackage" -or $ProvisioningPackage) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install-ProvisioningPackage -QuietInstall -PackagePath $ProvisioningPackage")) {
    If (Test-Path -PathType Leaf -Path $ProvisioningPackage) { Install-ProvisioningPackage -QuietInstall -PackagePath $ProvisioningPackage }
    else { Write-Warning "The provisioning file specified is not valid." }
  }
}

if ($Action -contains "JoinDomain") { Add-Computer -DomainName $DomainName -JoinDomain }

if ($Action -contains "BitLocker") {
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

if ($Action -contains "Office") {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install Office $OfficeVersion")) {
    Install-MicrosoftOffice -Version $OfficeVersion
  }
}

if ($Action -contains "Wallpaper") { Set-DefaultWallpapers -SourcePath $Wallpapers ; Set-WallPaper }

if ($Action -contains "RSAT") {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install Remote Server Administrative Tools")) {
    Write-Verbose "Install Remote Server Administrative Tools"
    Get-WindowsCapability -Online -Name "RSAT*" | Add-WindowsCapability -Online
  }
}

if ($Action -contains "NetFX3") {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install .NET Framework 3.5 (includes .NET 2.0 and 3.0)")) {
    Write-Verbose "Installing .NET Framework 3.5 (includes .NET 2.0 and 3.0)"
    Get-WindowsCapability -Online -Name NetFx3* | Add-WindowsCapability -Online
  }
}

if ($Action -contains "Ninite") {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername) $NiniteInstallTo", "Install apps using Ninite")) {
    Write-Verbose "Running Ninite"
    $parent = Split-Path $script:MyInvocation.MyCommand.Path
    & $parent\..\Ninite\Ninite.ps1 -Local -InstallTo $NiniteInstallTo
  }
}

if ($Action -contains "winget") {
  if ($null -ne $WingetPackages) {
    $WingetPackages.Keys | ForEach-Object {
      $Arguments = @( "install $_", "--accept-package-agreements", "--accept-source-agreements" )
      if ($WingetPackages[$_] -ne $null) { $Arguments += $WingetPackages[$_] }
      if ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install $_ with arguments: $Arguments")) { 
        Start-Process -Wait -NoNewWindow -FilePath winget -ArgumentList $Arguments 
      }
    }
  }
  
  if ($PsCmdlet.ShouldProcess("localhost ($env:computername)", "Upgrading packages with winget")) { 
    Start-Process -Wait -NoNewWindow -FilePath winget -ArgumentList "upgrade --all" 
  }
}

Write-Verbose "Checking for reboot."
If ( $Reboot -or $Action -contains "Reboot" -or (Test-Path "HKLM:\SOFTWARE­\Microsoft­\Windows­\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") ) {
  Write-Verbose "A reboot is required. Reboot now?"
  Restart-Computer -Confirm
}
