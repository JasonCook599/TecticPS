<#PSScriptInfo

.VERSION 1.0.11

.GUID a3cdb0bc-2c01-4aa3-b702-707a5060c071

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) TectTectic

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
Test that a photo meets the requrements.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  $Path,
  $Photos = (Get-ChildItem -Recurse -File -Path $Path),
  [int]$Width,
  [int]$Height,
  [switch]$Square,
  $FileSize
)
Add-Type -AssemblyName System.Drawing
$Results = @()
$Photos | ForEach-Object {
  $Image = New-Object System.Drawing.Bitmap $_.FullName
  [PSObject]$Result = New-Object PSObject -Property @{ Path = $_.FullName }
  if (($Width -and $Image.Width -gt $Width) -or ($Height -and $Image.Height -gt $Height)) { $Result | Add-Member -MemberType NoteProperty -Value $true -Name BadDimensions }
  if ($Square -and $Image.Width -ne $Image.Height) { $Result | Add-Member -MemberType NoteProperty -Value $true -Name NotSquare }
  if ($FileSize -and $_.Length -gt $FileSize) { $Result | Add-Member -MemberType NoteProperty -Value $true -Name TooBig }
  if ( $Result.BadDimensions -or $Result.NotSquare -or $Result.TooBig ) {
    Write-Warning "$($_.Name) does not meet the requirements."
    $Results += $Result
  }
}
return $Results
