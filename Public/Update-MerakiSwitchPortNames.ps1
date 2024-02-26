<#PSScriptInfo

.VERSION 1.0.4

.GUID 1962b9ec-b51d-4ac4-9e92-12ddcf152a0a

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
Update the switch port names in Meraki based on the CSV file you specify.

.PARAMETER APIKey
Your Meraki API key.

.PARAMETER networkid
The network ID that contains the switches you wish to update.

.PARAMETER Path
The CSV file containing records you wish to update. Must contain the following columns 'Switch Name', 'Switch Port', and 'Switch Label'.

.PARAMETER Headers
An array of headers to send in each API request. Automatically generated using the APIKey paramater.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [string]$APIKey,
  [string]$networkid,
  [ValidateScript( { Test-Path $_ -PathType Leaf })][string]$Path,
  $Headers = @{
    "Content-Type"           = "application/json"
    "Accept"                 = "application/json"
    "X-Cisco-Meraki-API-Key" = $APIKey
  }
)

Write-Verbose "Getting devices for $networkid"
$Switches = Invoke-RestMethod -Method Get -Uri "https://api.meraki.com/api/v1/networks/$($networkid)/devices" -Headers $headers

function UpdateSwitchPortName {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param (
    [string]$SwitchName,
    [int]$Port,
    [string]$Name
  )

  $Serial = ($Switches | Where-Object name -eq $SwitchName).Serial
  $Body = @{ name = $Name } | ConvertTo-Json -Compress
  If ($PSCmdlet.ShouldProcess("$SwitchName $Port", "UpdateSwitchPortName to $Name")) {
    return Invoke-RestMethod -Method Put -Uri "https://api.meraki.com/api/v1/devices/$($Serial)/switch/ports/$($Port)" -Headers $headers -Body $Body
  }
}

$JackLocations = Import-Csv -Path $Path | Where-Object 'Switch Name' -NotLike ""
$JackLocations | ForEach-Object {
  $count++ ; Progress -Index $count -Total $JackLocations.count -Activity "Updating switch port names" -Name $($_.'Switch Port' + ": " + $_.'Switch Label')
  return UpdateSwitchPortName -SwitchName $_.'Switch Name' -Port $_.'Switch Port' -Name $_.'Switch Label'
}
