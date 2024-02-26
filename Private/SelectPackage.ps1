<#PSScriptInfo

.VERSION 1.0.4

.GUID 0caaa663-ed3d-498c-a77e-d00e85146cd1

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
Select the winget pacakge to install. Used by the Initilize-Workstation command.

.PARAMETER Packages
A hashtable of packages to select from.

.PARAMETER Title
The title of the message box.

.PARAMETER Mode
Should a single or multiple package be selected?
#>

param(
    [Parameter(Mandatory = $True, ValuefromPipeline = $True)][hashtable]$Packages,
    [Parameter(ValuefromPipeline = $True)][string]$Title = "Select the packages to install",
    [Parameter(ValuefromPipeline = $True)][ValidateSet("Single" , "Multiple")][string]$Mode = "Single"
)

if ($Packages.count -gt 1) {
    $SelectedPackage = $Packages | Out-GridView -OutputMode $Mode -Title $Title
    return @{ $SelectedPackage.Name = $SelectedPackage.Value }
}

elseif ($Packages.count -eq 1) {
    while ("y", "n" -notcontains $Install ) { $Install = Read-Host "Do you want to install $($Packages.Keys)? [y/n] " }

    if ($Install -eq "Y" ) { return @{ $($Packages.Keys) = $($Packages.Values) } }
    else { return @{} }
}

else {
    Write-Warning "No packages to install. Press enter to continue."
    return @{}
}
