<#PSScriptInfo

.VERSION 2.0.3

.GUID 0677b108-26b5-409b-a169-b0eb45399dcf

.AUTHOR Nicola Suter

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

#Requires -Module MSOnline

<#
.DESCRIPTION
Script to cleanup direct Azure AD license assignments. This script will only remove a direct assignment if there is an associated group assignment. Before running the script make sure that you have the MSOnline PowerShell module installed. Connect to MSOnline with: Connect-MsolService

.PARAMETER WhatIf
Predict changes

.PARAMETER SaveReport
Whether to save the report to the script location.

.LINK
https://github.com/nicolonsky/Techblog/tree/master/CleanupAzureADLicensing

.LINK
https://learn.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-groups-migrate-users

#>

[CmdletBinding(SupportsShouldProcess)]
param (
  $Users = (Get-MsolUser -All -ErrorAction Stop),
  $Skus = (Get-MgSubscribedSku)
)

$Results = @()

$Users | ForEach-Object {
  Write-Verbose "Processing $($_.UserPrincipalName)"
  $count++ ; Progress -Index $count -Total $Users.count -Activity "Processing all licenses." -Name $_.UserPrincipalName
  $User = $_
  $_.Licenses | ForEach-Object {
    <#
      the "GroupsAssigningLicense" array contains objectId's of groups which inherit licenses
      if the array contains an entry with the users own objectId the license was assigned directly to the user
      if the array contains no entries and the user has a license assigned he also got a direct license assignment
      #>
    if ($_.GroupsAssigningLicense -contains $User.ObjectId -and $_.GroupsAssigningLicense.Count -gt 1) {
      Write-Verbose "$($User.UserPrincipalName) ($($User.ObjectId)) has direct license assignment for '$($_.AccountSkuId)'"
      $_.GroupsAssigningLicense.Remove($User.ObjectId) | Out-Null

      # TODO Repalce static strings with regex matches.
      $SkuGUID = ($Skus | Where-Object SkuPartNumber -eq (($_.AccountSkuId) -replace ("\w\:", ""))).Id -replace ("[{]?[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}[}]?_", "")

      if ($PSCmdlet.ShouldProcess($user.UserPrincipalName, "Remove license assignment for sku '$($_.AccountSkuId)'")) {
        Write-Verbose "Removing license assignment for sku '$($_.AccountSkuId) on target '$($User.UserPrincipalName)'"
        Set-MgUserLicense -UserId $User.objectId -AddLicenses @() -RemoveLicenses $SkuGUID | Out-Null
      }
      $Result = [PSCustomObject]@{
        UserPrincipalName      = $user.UserPrincipalName
        ObjectId               = $user.ObjectId
        GroupsAssigningLicense = $_.GroupsAssigningLicense
        AccountSkuId           = $_.AccountSkuId
        SkuGUID                = $SkuGUID
      }
      $Results += $Result
      return $Result
    }
  }

}

if ($Results) { Write-Warning "Found $($Results.Count) direct assigned license(s)." }
else { Write-Output "No direct license assignments found" }
