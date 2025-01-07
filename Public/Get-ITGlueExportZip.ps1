<#PSScriptInfo

.VERSION 1.0.1

.GUID fc1c5ecb-9dfd-48a3-956b-b9cd702e136c

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
.SYNOPSIS
Downloads an export from IT Glue.

.DESCRIPTION
Downloads an export from IT Glue.

.PARAMETER Export
The export to download, usually passed in from Get-ITGlueExports.

.PARAMETER Path
The location to save the export to. If you only pass in a directory, the file will be named automatically based on the export information.

.EXAMPLE
Get-ITGlueExports -Id 123456 -APIKey "ITG.*******************" Get-ITGlueExportZip -Path C:\Backups\

.LINK
https://github.com/IT-Glue-Public/automation/tree/main/Exports
#>
param (
  [ValidateScript( { [uint64]$_.Id -and [System.URI]$_.attributes."download-url" })][Parameter(ParameterSetName = "Export", ValueFromPipeline = $true)]$Export,
  [ValidateScript( { Test-Path -Path $_ -Isvalid })]$Path
)

Write-Verbose "Validating Uri: $Uri"
[System.URI]$Uri = $Export.attributes."download-url"
if ($Uri.Scheme -ne "https") { throw "Invalid download-url: $Uri" }

Write-Debug "Building output file path"
if (Test-Path -Path $Path -PathType Container) {
  if ($Export.attributes."export-all" -eq $true) { $FileName = "Account" }
  else { $FileName = $Export.attributes."organization-id".ToString() + "-" + $Export.attributes."organization-name" }
  $FileName += "-" + ($Export.attributes."created-at" -replace ":", "-")
  $OutFile = Join-Path -Path $Path -ChildPath "$FileName.zip"
}
else { $OutFile = $Path }

Write-Verbose "Starting export to $OutFile"
$Response = Invoke-RestMethod -Uri $Uri -OutFile $OutFile

$Return = $Export.attributes
$Return | Add-Member -NotePropertyName Path -NotePropertyValue $OutFile
$Return | Add-Member -NotePropertyName Response -NotePropertyValue $Response
return $Return
