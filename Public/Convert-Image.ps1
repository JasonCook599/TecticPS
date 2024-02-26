<#PSScriptInfo

.VERSION 1.0.12

.GUID 717cb6fa-eb4d-4440-95e3-f00940faa21e

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
This script will resize an image using ImageMagick.

.LINK
https://imagemagick.org/

.PARAMETER Path
This is the file or folder containing images to resize. If unspecified, it will run in the current folder.

.PARAMETER Dimensions
The dimension to which the image should be resized in WxH. You must spesify either width or height.

.PARAMETER Suffix
The text to appear after the resized file.

.PARAMETER Prefix
The text to appear before the resized file.

.PARAMETER OutName
The name of the resized file. If specified, it will override the Prefix and Suffix parameters. If unspecified, it will be $Prefix$CurentFileName$Suffix.$OutExtension.

.PARAMETER OutExtension
The file extension to use for the converted image. If unspecified, the existing extension will will be used.

.PARAMETER FileSize
The file size of the final file. This paramater only functions when outputting to the JPEG format.

.PARAMETER Filter
Use this to limit the search to spesific files.

.PARAMETER Force
Use this paramater to bypass the check when overwriting an existing file.

.PARAMETER Return
The parameter will return the Name, FullName, InputName, InputFullName for each file.

.EXAMPLE
Convert-Image -Dimensions 1920x1080 -Suffix _1080p

.EXAMPLE
Convert-Image -Path C:\Images -Dimensions 1920x1080 -Suffix _1080p -Prefix Resized_ -OutExtension jpeg -FileSize 750KB -Filter "*.jpg" -Force -Return
Name                          FullName
----                          --------
Resized_Image (1)_1080p.jpeg  C:\Images\Resized_Image (1)_1080p.jpeg
Resized_Image (2)_1080p.jpeg  C:\Images\Resized_Image (2)_1080p.jpeg
Resized_Image (3)_1080p.jpeg  C:\Images\Resized_Image (3)_1080p.jpeg
Resized_Image (4)_1080p.jpeg  C:\Images\Resized_Image (4)_1080p.jpeg
Resized_Image (5)_1080p.jpeg  C:\Images\Resized_Image (5)_1080p.jpeg
Resized_Image (6)_1080p.jpeg  C:\Images\Resized_Image (6)_1080p.jpeg
Resized_Image (7)_1080p.jpeg  C:\Images\Resized_Image (7)_1080p.jpeg
Resized_Image (8)_1080p.jpeg  C:\Images\Resized_Image (8)_1080p.jpeg
Resized_Image (9)_1080p.jpeg  C:\Images\Resized_Image (9)_1080p.jpeg

.LINK
https://imagemagick.org/script/command-line-processing.php#geometry
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
	[string]$Filter,
	[ValidateScript( { ( (Test-Path $_) -and (-not $([bool]([System.Uri]$_).IsUnc)) ) } )][array]$Path = (Get-ChildItem -File -Filter $Filter),
	[ValidateScript( { Test-Path $_ })][string]$OutPath = (Get-Location),
	[string]$OutName,
	[string][ValidatePattern("((((\d+%){1,2})|((\d+)?x\d+(\^|!|<|>|\^)*?)|(\d+x?(\d+)?(\^|!|<|>|\^)*?)|(\d+@)|(\d+:\d+))$|^$)")]$Dimensions,
	[string]$Suffix,
	[string]$Prefix,
	[switch]$Trim,
	[ValidateSet("NorthWest", "North", "NorthEast", "West", "Center", "East", "SouthWest", "South", "SouthEast")][string]$Gravity = "Center",
	[ValidateSet("Crop", "Pad", "None", $null)][string]$Mode = "Crop",
	[string]$ColorSpace,
	[string][ValidatePattern("(^\..+$|^$)")]$OutExtension,
	[string]$FileSize,
	[switch]$Force,
	[ValidateScript( { Test-Path -Path $_ -PathType Leaf })][string]$Magick = ((Get-Command magick).Source)
)

If (!(Get-Command magick -ErrorAction SilentlyContinue)) {
	Write-Error "magick.exe is not available in your PATH."
	Break
}

[System.Collections.ArrayList]$Results = @()

ForEach ($Image in $Path) {
	Clear-Variable -Name OutName
	$Image = Get-ChildItem $Image
	if ([bool]([System.Uri]$Image.FullName).IsUnc) { throw "Path is not local." }
	$count++ ; Progress -Index $count -Total $Path.count -Activity "Resizing images." -Name $Image.Name

	$Arguments = $null
	If (!$OutExtension) { $ImageOutExtension = [System.IO.Path]::GetExtension($Image.Name) } #If OutExtension not set, use current
	Else { $ImageOutExtension = $OutExtension } #Otherwise use spesified extension
	If (-not $OutName) { $OutName = $Prefix + [io.path]::GetFileNameWithoutExtension($Image.Name) + $Suffix + $ImageOutExtension }
	$Out = Join-Path $OutPath $OutName #Out full path
	If ($PSCmdlet.ShouldProcess("$OutName", "Convert-Image")) {
		If (Test-Path $Out) {
			If ($Force) {}
			ElseIf (!($PSCmdlet.ShouldContinue("$Out already exists. Overwrite?", ""))) { Break }
		}
		$Arguments += '"' + $Image.FullName + '" '
		If ($Dimensions) {
			If ($Trim) { $Arguments += '-trim ' }
			$Arguments += '-resize "' + $Dimensions + '" '
			$Arguments += '-gravity "' + $Gravity + '" '
			If ($Mode -eq "Crop") { $Arguments += '-crop "' + $Dimensions + '+0+0" ' }
			ElseIf ($Mode -eq "Pad") { $Arguments += '-background none -extent "' + $Dimensions + '+0+0" ' }
		}

		If ($FileSize -And ($ImageOutExtension -ne ".jpg") -And ($ImageOutExtension -ne ".jpeg")) {
			Write-Warning "FileSize paramater is only valid for JPEG images. $OutName will ignore this parameter."
		}
		ElseIf ($FileSize) { $Arguments += '-define jpeg:extent=' + $FileSize + ' ' }
		$Arguments += '+repage '
		If ($ColorSpace) { $Arguments += '-colorspace ' + $ColorSpace + ' ' }
		$Arguments += '"' + $Out + '"'

		Write-Verbose $Arguments
		Start-Process -FilePath $Magick -ArgumentList $Arguments -NoNewWindow -Wait
		$Result = [PSCustomObject]@{
			Arguments     = $Arguments
			Name          = $OutName
			FullName      = $Out
			InputName     = Split-Path -Path $Image.FullName -Leaf
			InputFullName	= $Image.FullName
		}
		$Results += $Result
	}
}
Return $Results
