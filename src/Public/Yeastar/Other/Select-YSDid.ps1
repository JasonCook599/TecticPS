<#PSScriptInfo

.VERSION 1.0.5

.GUID 0f64ca03-8cc9-4411-8244-ea14fbec10bf

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2026

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
Select an available Yeastar DID.

#>

[CmdletBinding(
  SupportsShouldProcess = $true
)]
param(
  $OwnedDIDs,
  [string]$NormalizeMatch = "^([2-9]\d{2}[2-9]\d{6})$",
  [int]$NormalizeGroup = 1,
  [string]$NormalizePrefix = "+1",
  [string]$NormalizeSuffix,

  [string]$NumberKey = "number",
  [string]$RateCentreKey = "Description"
)

[array]$YeastarDIDs = Get-YSDid
  
Write-Verbose "Getting VoIP.ms DIDs."


if ($NormalizeMatch) {
  Write-Verbose "Normalizing VoIP.ms DIDs."
  foreach ($DID in $OwnedDIDs) {
    if ($DID.($NumberKey) -match $NormalizeMatch) {
      $DID.($NumberKey) = "$NormalizePrefix$($Matches[$NormalizeGroup])$NormalizeSuffix"
    }
  }
}

Write-Verbose "Selecting a rate centre."
[string]$RateCentre = $OwnedDIDs.($RateCentreKey) | Select-Object -Unique | Out-ConsoleGridView -Title 'Rate Centre' -OutputMode Single

Write-Verbose "[$RateCentre] Selecting a DID."
$RateCentreDIDs = $OwnedDIDs | Where-Object ($RateCentreKey) -eq $RateCentre

Write-Verbose "[$RateCentre] Finding available DIDs."
[array]$RateCentreDIDsFiltered = @()
foreach ($DID in $RateCentreDIDs) {
  if ($DID.($NumberKey) -notin $YeastarDIDs) { $RateCentreDIDsFiltered += $DID }
}


if ([int]$RateCentreDIDsFiltered.Count -le 0) {
  Write-Warning "[$RateCentre] No DIDs available in chosen rate centre."
  return 
}
[string]$SelectedDID = $RateCentreDIDsFiltered.($NumberKey) | Select-Object -Unique | Out-ConsoleGridView -Title 'DID' -OutputMode Single

return $SelectedDID



