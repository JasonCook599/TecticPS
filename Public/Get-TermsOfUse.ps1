<#PSScriptInfo

.VERSION 1.0.2

.GUID 7c954769-1a02-4bbb-b1e0-8e9ea3dbb0c8

.AUTHOR Jason Cook

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) ***REMOVED*** 2022

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
Get AAD Terms of Use details.
#>

Requires -Module AzureADPreview
[System.Collections.ArrayList]$Results = @()

Get-AzureADAuditDirectoryLogs -Filter "loggedByService eq 'Terms Of Use'" | ForEach-Object {
  $Result = [PSCustomObject]@{
    PolicyName  = $_.TargetResources[0].DisplayName
    DisplayName = $_.TargetResources[1].DisplayName
    Upn         = $_.TargetResources[1].UserPrincipalName
    Activity    = $_.ActivityDisplayName
    Date        = $_.ActivityDateTime
    NotesKey    = $_.AdditionalDetails.Key
    NotesValue  = $_.AdditionalDetails.Value
  }
  $Results += $Result
}
return $Results
