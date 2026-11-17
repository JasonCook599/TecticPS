<#PSScriptInfo

.VERSION 1.0.2

.GUID 5fd89654-0113-413f-9983-e8e0c46bb63b

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
Update an existing switch template.

.PARAMETER Name
The name of the switch template to update.

.PARAMETER Ports
An array of ports with attributes to update. Existing values will be kept.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [Parameter(Mandatory = $true)]
  [string]$Name,

  [array]$Ports
)

if ($Ports) {
  Write-Verbose "[$Name] Port configuration specified. Getting existing config."
  $SwitchTemplate = Get-FmgSwitchTemplate -Name $Name
  foreach ($Port in $SwitchTemplate.Ports) {
    Write-Debug "[$($Name)] Checking each port for changes."
    $NewPortConfig = $Ports | Where-Object port-name -eq $Port.'port-name'
    $Port.psobject.Properties.Remove('oid')
    if ($NewPortConfig) {
      Write-Verbose "[$($Name):$($Port.'port-name')] Updated port configuration found."
      foreach ($Item in $Port.psobject.properties.name) {
        Write-Debug "[$($Name):$($Port.'port-name')] Checking each property for changes."
        $CurrentValue = ($SwitchTemplate.ports | Where-Object port-name -eq $Port.'port-name').$Item
        $NewValue = $NewPortConfig.$Item
        
        if ($NewPortConfig.$Item -and $CurrentValue -ne $NewValue) {
          Write-Verbose "[$($Name):$($Port.'port-name')] Updating $Item to $($NewPortConfig.$Item)"
          ($SwitchTemplate.ports | Where-Object port-name -eq $Port.'port-name').$Item = $NewValue
        }
      }
    }
  }
}

$Data = [PSCustomObject]@{ports = [PSCustomObject]$SwitchTemplate.ports }

if ($PSCmdlet.ShouldProcess($Name)) {
  return Invoke-FmgJsonApi -url "pm/config/adom/$($FmgConfig.ADOM)/obj/switch-controller/managed-switch/$Name" -method update -Data $Data
}
