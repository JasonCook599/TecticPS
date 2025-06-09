<#PSScriptInfo

.VERSION 1.0.3

.GUID e456e40a-3a80-483a-8e0d-320bacc12d82

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
Get a list of exports from IT Glue.

.DESCRIPTION
Get a list of exports from IT Glue.

.PARAMETER Sort
Field to sort the exports by. Default is "updated-at".

.PARAMETER Count
Number of exports to return. Default is one.

.PARAMETER Count
ID of a specific export to return.

.PARAMETER BaseUri
Base URI of the IT Glue API

.PARAMETER APIKey
Your IT Glue API Key.

.EXAMPLE
Get-ITGlueExports -Id 123456 -APIKey "ITG.*******************"

.LINK
https://github.com/IT-Glue-Public/automation/tree/main/Exports
#>
[CmdletBinding(DefaultParameterSetName = 'Multiple')]
param(
  [Parameter(ParameterSetName = "Multiple")]$Sort = "-updated-at",
  [Parameter(ParameterSetName = "Multiple")]$Count = 1,
  [Parameter(ParameterSetName = "Id")][uint64]$Id,
  [ValidateScript( { $_[$_.Length - 1] -ne "/" })]$BaseUri = "https://api.itglue.com", # Don't allow superfluous forward slash in address
  [string]$APIKey,
  $Headers = @{
    "x-api-key" = $APIKey
  }
)

switch ($PSCmdlet.ParameterSetName) {
  Multiple { $ResourceUri = "/exports?page[number]=1&sort=$Sort&page[size]=$Count" }
  Id { $ResourceUri = ('/exports/{0}' -f $id) }
}
Write-Debug "ResourceUri: $ResourceUri "

return (Invoke-RestMethod -Method get -Uri ($BaseUri + $ResourceUri) -Headers $Headers -ContentType application/vnd.api+json).data
