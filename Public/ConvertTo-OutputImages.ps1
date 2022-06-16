<#PSScriptInfo

.VERSION 1.1.3

.GUID 5c162a3a-dc4b-43d5-af07-7991ae41d03b

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

<#is script will resize the spesified images to the spesifications detailed in a json file.

.DESCRIPTION
This script will resize the spesified logos, wordmarks and banner images to the spesifications of various third party services. It will pull data from a json file.

.PARAMETER Path
This is the file or folder containing images to resize. If unspecified, it will run in the current folder.

.PARAMETER Prefix
The text to appear before the resized file.

.PARAMETER All
If specified, images will be created for all services, instead of just the common ones.

.EXAMPLE
ConvertTo-OutputImages
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
	[ValidateSet("Banner", "Logo", "Brandmark")][string]$Type = "Banner",
	[ValidateScript( { Test-Path $_ })][string]$Json,
	[string]$Filter,
	[ValidateScript( { ( (Test-Path $_) -and (-not $([bool]([System.Uri]$_).IsUnc)) ) } )][array]$Path = (Get-ChildItem -File -Filter $Filter),
	[ValidateScript( { Test-Path $_ })][string]$OutPath = (Get-Location),
	[switch]$Force,
	[string]$Destination,
	[string]$Prefix,
	[switch]$All
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

if (-not $Json) { throw "Json file not found." }
ForEach ($Image in $Path) {
	$Image = Get-ChildItem $Image
	$Formats = (Get-Content -Path $Json | ConvertFrom-Json).$Type
	$count1++; $count2 = 0
	If ($Destination) { $Formats = $Formats | Where-Object Destination -Contains $Destination }
	$Formats | ForEach-Object {
		$count2++; Progress -Index $count2 -Total ([math]::Max(1, $Formats.count)) -Activity "Resizing $count1 of $($Path.count): $($Image.Name)" -Name $_.Name
		If ($PSCmdlet.ShouldProcess("$($Image.FullName) > $($_.Name)", "Convert-Image")) {
			Convert-Image -Force:$Force -Path $Image.FullName -OutPath $OutPath -Dimensions $_.Dimensions  -Suffix ("_" + $_.Name) -Trim:$_.Trim -OutExtension $_.OutExtension -FileSize $_.FileSize -Mode $_.Mode
		} 
	}
}