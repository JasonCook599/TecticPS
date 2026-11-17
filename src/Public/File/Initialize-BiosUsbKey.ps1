<#PSScriptInfo

.VERSION 1.0.6

.GUID 0c7d4d03-0299-400f-92a8-f857f9b8dc6e

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
This script will create a bootable BIOS key and apply an appropriate label.
#>

param(
  [string]$Path,
  [string]$Drive,
  [ValidateSet("Lenovo")][string]$Manufacturer = "Lenovo"
)

Push-Location $Path

Write-Verbose "Erasing $Drive"
Get-ChildItem -Path $Drive`:\ -Recurse | Remove-Item -Force -Recurse

Write-Verbose "Creating USB Drive"
if ($Manufacturer -eq "Lenovo") { & .\mkusbkey.bat $Drive`: | Write-Verbose }

Write-Verbose "Building drive label."
[string]$Model = (Get-Item (Split-Path -Parent -Path (Get-Location))).Name
$Label = ($Model -replace " ", "" -replace "Type", "" -replace "Gen", "G" -replace "\(", "" -replace "\)", "" -replace ",", "")
$Label = $Label.Substring(0, ($Label.Length, 11 | Measure-Object -Minimum).Minimum)

$AutoRun = "
[AutoRun]
label=$Model
"

Write-Verbose "Setting drive label: $Label"
Set-Volume -DriveLetter $Drive -NewFileSystemLabel $Label

Write-Verbose "Setting AutoRun label: $Model"
$AutoRun | Out-File -FilePath "$Drive`:\autorun.inf"

Pop-Location

Write-Verbose "Copying Logos"
if ($Manufacturer -eq "Lenovo") { Copy-Item -Path .\LOGO*.gif -Destination $Drive`:\Flash\ }
