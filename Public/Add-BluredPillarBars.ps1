<#PSScriptInfo

.VERSION 1.0.4

.GUID 6ee394c8-c592-49d5-b16c-601955ef4d2f

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
This script will using ImageMagick to add blurred pillar bars to a set of images.

.DESCRIPTION
This script will scale to fill, then blur the spesified image. Then, on a new layer, it will scale to fit the image.

.PARAMETER Path
This is the image file or a folder of images to be modified.

.PARAMETER Format
The file format to convert images to. If unspesified, the existing format will be used.

.PARAMETER Aspect
The aspect ration to convert to, in x:y format. If unspesified, 16:9 will be used.

.PARAMETER Prefix
The text that appears before the filename for each converted image. If unspesified, the aspect ration in x_y format will be used.

.PARAMETER Suffix
The text that appears after the filename for each converted image. If unspesifed, no text will be used.

.PARAMETER MaxHeight
This is the max height of the converted image. If unspesified, the current height will be used.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript( { Test-Path -Path $_ })][Parameter(Mandatory = $true)][string]$Path,
  [string]$Background,
  [string]$Format,
  [string]$Aspect = "16:9",
  [string]$Prefix = ($Aspect -Replace ":", "x") + "_",
  [string]$Suffix,
  [ValidateRange(1, [int]::MaxValue)][int]$MaxHeight,
  [switch]$Preview
)

Get-ChildItem -File -Path $Path | ForEach-Object {
  If (!$Format) { $Format = [System.IO.Path]::GetExtension($_.Name) }
  If (!$Background) { $Background = $_.Name }
  $OutFile = $Prefix + [io.path]::GetFileNameWithoutExtension($_.Name) + $Suffix + $Format
  Write-Verbose "$me Resizing with aspect ratio of $Aspect and height of $MaxHeight to $OutFile"
  If ($PSCmdlet.ShouldProcess("$OutFile", "Add-BluredPillarBars")) {
    $run = 'magick.exe identify -format %h ' + $_.Name
    $Height = (Invoke-Expression $run)
    If (!$MaxHeight) { $MaxHeight = $Height }
    magick.exe convert $Background -blur 0x8 -gravity center -crop $Aspect -resize x$Height +repage $_.Name -gravity center -composite -scale x$MaxHeight -resize $Aspect $OutFile
  }
  $Format = $null
}
