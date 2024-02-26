<#PSScriptInfo

.VERSION 1.0.5

.GUID 14062539-2775-4450-bb0b-a3406d1db091

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
.SYNOPSIS
This script with gather information about TPM and Secure Boot from the spesified marchines.

.DESCRIPTION
This script with gather information about TPM and Secure Boot from the spesified marchines. It can request information from just the local computer or from a list of remote computers. It can also export the results as a CSV file.

.PARAMETER ComputerList
This can be used to select a text file with a list of computers to run this command against. Each device must appear on a new line. If unspesified, it will run againt the local machine.

.PARAMETER ReportFile
This can be used to export the results to a CSV file.

.EXAMPLE
Get-TPMInfo
System Information for: XXXX
Manufacturer: LENOVO
Model: 20ETXXXX
Serial Number: XXXX
Bios Version: LENOVO - 500
Bios Type: UEFI
Secure Boot Status: TRUE
TPM Version: 1.2
TPM: \\XXXX\root\CIMV2\Security\MicrosoftTpm:Win32_Tpm=@
GPT: @{Name=Disk #0, Partition #1; Index=1; Bootable=True; BootPartition=True; PrimaryPartition=True; SizeInMB=100}
Operating System: Microsoft Windows 10 Pro, Service Pack: 0
Total Memory in Gigabytes: 15.8858337402344
User logged In: XXXX\XXXX
Last Reboot: 08/31/2018 17:23:03
#>
param(
  [string]$ComputerList,
  [string]$ReportFile
)

Function Get-SystemInfo($ComputerSystem) {
  If (-NOT (Test-Connection -ComputerName $ComputerSystem -Count 1 -ErrorAction SilentlyContinue)) {
    Write-Warning "$ComputerSystem is not accessible."
    $script:Report += New-Object psobject -Property @{
      RunAgainst          = $ComputerSystem;
      Satus               = "Offline"
      ComputerName        = "";
      Manufacturer        = "";
      Model               = "";
      Serial              = "";
      BiosVersion         = "";
      BiosType            = "";
      GptName             = "";
      GptIndex            = "";
      GptBootable         = "";
      GptBootPartition    = "";
      GptPrimaryPartition = "";
      GptSizeInMB         = "";
      ComputerSecureBoot  = "";
      TpmVersion          = "";
      OperatingSystem     = "";
      ServicePack         = "";
      MemoryGB            = "";
      LastSignIn          = "";
    }
    Return
		}

  $ComputerInfo = Get-CimInstance -ComputerName $ComputerSystem Win32_ComputerSystem
  $ComputerGptSystem = Get-CimInstance -ComputerName $ComputerSystem -query 'Select * from Win32_DiskPartition Where Type = "GPT: System"' | Select-Object Name, Index, Bootable, BootPartition, PrimaryPartition, @{n = "SizeInMB"; e = { $_.Size / 1MB } }
  $ComputerBios = Get-CimInstance -ComputerName $ComputerSystem Win32_BIOS
  $ComputerBiosType = Invoke-Command -ComputerName $ComputerSystem -ScriptBlock { if (Test-Path $env:windir\Panther\setupact.log) { (Select-String 'Detected boot environment' -Path "$env:windir\Panther\setupact.log"  -AllMatches).line -replace '.*:\s+' } else { if (Test-Path HKLM:\System\CurrentControlSet\control\SecureBoot\State) { "UEFI" } else { "BIOS" } } }
  $ComputerBiosType2 = Invoke-Command -ComputerName $ComputerSystem -ScriptBlock {
    Try {
      Confirm-SecureBootUEFI -ErrorVariable ProcessError
      $ComputerBiosType2 = "UEFI"
    }
    Catch { $ComputerBiosType2 = "BIOS" }
    Return $ComputerBiosType2
  }
  If ($ComputerBiosType2[1] -eq "I") {
    $ComputerBiosType2Output = $ComputerBiosType2
    $ComputerSecureBoot = $False
  }
  Else {
    $ComputerBiosType2Output = $ComputerBiosType2[1]
    $ComputerSecureBoot = $ComputerBiosType2[0]
  }
  $ComputerOs = Get-CimInstance -ComputerName $ComputerSystem Win32_OperatingSystem
  # $Tpm = Get-WmiObject -class Win32_Tpm -namespace root\CIMV2\Security\MicrosoftTpm -ComputerName $ComputerSystem -Authentication PacketPrivacy
  $Tpm = Get-CimInstance -class Win32_Tpm -namespace root\CIMV2\Security\MicrosoftTpm -ComputerName $ComputerSystem
  "System Information for: " + $ComputerInfo.Name
  "Manufacturer: " + $ComputerInfo.Manufacturer
  "Model: " + $ComputerInfo.Model
  "Serial Number: " + $ComputerBios.SerialNumber
  "Bios Version: " + $ComputerBios.Version
  "Bios Type: " + $ComputerBiosType
  "Bios Type (New Method): " + $ComputerBiosType2Output
  "Secure Boot Status: " + $ComputerSecureBoot
  "TPM Version: " + $Tpm.PhysicalPresenceVersionInfo
  "TPM: " + $Tpm
  "GPT: " + $ComputerGptSystem
  "Operating System: " + $ComputerOs.caption + ", Service Pack: " + $ComputerOs.ServicePackMajorVersion
  "Total Memory in Gigabytes: " + $ComputerInfo.TotalPhysicalMemory / 1gb
  "User logged In: " + $ComputerInfo.UserName
  "Last Reboot: " + $ComputerOs.LastBootUpTime
  ""
  ""
  $script:Report += New-Object psobject -Property @{
    RunAgainst          = $ComputerSystem;
    Satus               = "Online"
    ComputerName        = $ComputerInfo.Name;
    Manufacturer        = $ComputerInfo.Manufacturer;
    Model               = $ComputerInfo.Model;
    Serial              = $ComputerBios.SerialNumber;
    BiosVersion         = $ComputerBios.Version;
    BiosType            = $ComputerBiosType2Output;
    GptName             = $ComputerGptSystem.Name;
    GptIndex            = $ComputerGptSystem.Index;
    GptBootable         = $ComputerGptSystem.Bootable;
    GptBootPartition    = $ComputerGptSystem.BootPartition;
    GptPrimaryPartition = $ComputerGptSystem.PrimaryPartition;
    GptSizeInMB         = $ComputerGptSystem.SizeInMB;
    ComputerSecureBoot  = $ComputerSecureBoot;
    TpmVersion          = $Tpm.PhysicalPresenceVersionInfo;
    OperatingSystem     = $ComputerOs.caption;
    ServicePack         = $ComputerOs.ServicePackMajorVersion;
    MemoryGB            = $ComputerInfo.TotalPhysicalMemory / 1gb;
    LastSignIn          = $ComputerInfo.UserName;
    LastReboot          = $ComputerOs.LastBootUpTime
  }
  If ($script:ReportFile) { $script:Report | Export-Csv $script:ReportFile }
}

$script:Report = @()
If ($ComputerList) { foreach ($ComputerSystem in Get-Content $ComputerList) { Get-SystemInfo -ComputerSystem $ComputerSystem } }
Else { Get-SystemInfo -ComputerSystem $env:COMPUTERNAME }
If ($ReportFile) { $Report | Export-Csv $ReportFile }
