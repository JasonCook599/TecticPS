<#PSScriptInfo

.VERSION 1.1.6

.GUID 4625bce9-661a-4a70-bb4e-46ea09333f33

.AUTHOR Jason Cook Microsoft

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
This script will output the amount of memory and the type using WMI information.

.DESCRIPTION
This script will output the amount of memory and the type using WMI information. Type information is taken from here: https://msdn.microsoft.com/en-us/library/aa394347(v=vs.85).aspx

.EXAMPLE
Get-MemoryType
moduleCapacityMB : {8192, 8192}
moduleCapacityGB : {8, 8}
totalCapacityMB  : 16384
totalCapacityGB  : 16
Dimm             : {24, 24}
DimmType         : DDR3

.NOTES
Credits    : Created by Microsoft. Available under Creative Commons Attribution 4.0 International License.

.LINK
https://msdn.microsoft.com/en-us/library/aa394347(v=vs.85).aspx

.LINK
https://github.com/MicrosoftDocs/win32/blob/docs/desktop-src/CIMWin32Prov/win32-physicalmemory.md

.LINK
https://github.com/MicrosoftDocs/win32/blob/docs/LICENSE
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = "False positive")]
param()
$PhysicalMemory = Get-CimInstance -Class Win32_PhysicalMemory | Select-Object MemoryType, Capacity
$PhysicalMemory | ForEach-Object {
	If ( $_.MemoryType -eq '0' ) { $DimmType = 'Unknown' }
	ElseIf ( $_.MemoryType -eq '1' ) { $DimmType = 'Other' }
	ElseIf ( $_.MemoryType -eq '2' ) { $DimmType = 'DRAM' }
	ElseIf ( $_.MemoryType -eq '3' ) { $DimmType = 'Synchronous DRAM' }
	ElseIf ( $_.MemoryType -eq '4' ) { $DimmType = 'Cache DRAM' }
	ElseIf ( $_.MemoryType -eq '5' ) { $DimmType = 'EDO' }
	ElseIf ( $_.MemoryType -eq '6' ) { $DimmType = 'EDRAM' }
	ElseIf ( $_.MemoryType -eq '6' ) { $DimmType = 'VRAM' }
	ElseIf ( $_.MemoryType -eq '8' ) { $DimmType = 'SRAM' }
	ElseIf ( $_.MemoryType -eq '9' ) { $DimmType = 'RAM' }
	ElseIf ( $_.MemoryType -eq '10' ) { $DimmType = 'ROM' }
	ElseIf ( $_.MemoryType -eq '11' ) { $DimmType = 'Flash' }
	ElseIf ( $_.MemoryType -eq '12' ) { $DimmType = 'EEPROM' }
	ElseIf ( $_.MemoryType -eq '13' ) { $DimmType = 'FEPROM' }
	ElseIf ( $_.MemoryType -eq '14' ) { $DimmType = 'EPROM' }
	ElseIf ( $_.MemoryType -eq '15' ) { $DimmType = 'CDRAM' }
	ElseIf ( $_.MemoryType -eq '16' ) { $DimmType = '3DRAM' }
	ElseIf ( $_.MemoryType -eq '17' ) { $DimmType = 'SDRAM' }
	ElseIf ( $_.MemoryType -eq '18' ) { $DimmType = 'SGRAM' }
	ElseIf ( $_.MemoryType -eq '19' ) { $DimmType = 'RDRAM' }
	ElseIf ( $_.MemoryType -eq '20' ) { $DimmType = 'DDR' }
	ElseIf ( $_.MemoryType -eq '21' ) { $DimmType = 'DDR2' }
	ElseIf ( $_.MemoryType -eq '22' ) { $DimmType = 'DDR2 FB-DIMM' }
	ElseIf ( $_.MemoryType -eq '24' ) { $DimmType = 'DDR3' }
	ElseIf ( $_.MemoryType -eq '25' ) { $DimmType = 'FBD2' }
	$TotalCapacity += $_.Capacity
}
$Result = [PSCustomObject]@{
	moduleCapacityMB = $PhysicalMemory | ForEach-Object { $_.Capacity / 1MB }
	moduleCapacityGB = $PhysicalMemory | ForEach-Object { $_.Capacity / 1GB }
	totalCapacityMB  = $TotalCapacity / 1MB
	totalCapacityGB  = $TotalCapacity / 1GB
	Dimm             = $PhysicalMemory.MemoryType
	DimmType         = $DimmType
}
Return $Result
