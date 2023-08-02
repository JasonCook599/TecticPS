<#PSScriptInfo

.VERSION 1.0.1

.GUID 44859c27-bbf8-4831-8b02-ee12be6c726d

.AUTHOR Jason Cook

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) ***REMOVED*** 2023

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
This will convert the rates from VoIP.ms to an XML file for use in 3CX. This script is not well optimized and will take a long time to run.

.PARAMETER Path
The path to export the rates to.

.PARAMETER RatesPath
The path to a CSV file containing the rates.

.PARAMETER Rates
An array of the current rates. Automatically generates from the file specified in RatesPath.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [string]$Path,
  [ValidateScript( { Test-Path $_ -PathType Leaf })][string]$RatePath,
  [array]$Rates = (Import-Csv $RatePath)
)

Write-Verbose "Generating file header"
$Output = '<?xml version="1.0" encoding="utf-8"?>
<TenantProperties>
  <TenantProperty>
    <name>BILL_0000</name>
    <type>String</type>
    <value n="default" p="default" r="15" />
  </TenantProperty>'

Write-Verbose "Generating file content"
$Rates | ForEach-Object {
  $count++ ; Progress -Index $count -Total $Rates.count -Activity "Generating XML" -Name $("[" + $_.'Prefix ' + "] " + $_.'Description ')
  $Output += "
  <TenantProperty>
    <name>BILL_$('{0:d4}' -f $count)</name>
    <type>String</type>
    <value n=`"$(($_.'Description ').replace("&","&amp;") )`" p=`"+$($_.'Prefix ')`" r=`"$([math]::Round([decimal]$_."Rate Value" * 100,2))`" />
  </TenantProperty>"

}

Write-Verbose "Generating file footer"
$Output += '
</TenantProperties>'

if ($Path) {
  Write-Verbose "Writing file to $Path"
  $Output | Out-File -FilePath $Path -Encoding utf8
}
else { Write-Verbose "No path specified. Not writing to file." }

Write-Verbose "Done"
return $Output
