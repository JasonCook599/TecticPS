<#PSScriptInfo

.VERSION 1.0.12

.GUID edfc8010-fc8d-4eba-8934-4c3a75725d33

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
This will update the LastWriteTime of the specifeid file to the current time.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param(
  [Parameter(ValueFromPipeline = $true, Mandatory = $true)][string]$Path,
  [Parameter(ValueFromPipeline = $true)][System.DateTime]$Date = (Get-Date)
)

If ($PSCmdlet.ShouldProcess($Path)) {
  try { return (Get-ChildItem $Path -ErrorAction Stop).LastWriteTime = $Date }
  catch { return (New-Item -Path $Path).CreationTime }
}
