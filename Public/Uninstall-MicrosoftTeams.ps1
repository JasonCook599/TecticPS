<#PSScriptInfo

.VERSION 1.0.3

.GUID 81af22bb-f7a1-42a0-8570-1ac57f49e6bf

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
.SYNOPSIS
This script allows you to uninstall the Microsoft Teams app and remove Teams directory for a user.
.DESCRIPTION
Use this script to clear the installed Microsoft Teams application. Run this PowerShell script for each user profile for which the Teams App was installed on a machine. After the PowerShell has executed on all user profiles, Teams can be redeployed.
#>
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice("Uninstall-MicrosoftTeams", "Are you sure you want to proceed?", $choices, 1)
if ($decision -eq 0) {
    $TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
    $TeamsUpdateExePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams', 'Update.exe')
    try {
        if (Test-Path -Path $TeamsUpdateExePath) { Start-Process -FilePath $TeamsUpdateExePath -ArgumentList "-uninstall -s" -PassThru -NoNewWindow -Wait }
        if (Test-Path -Path $TeamsPath) { Remove-Item -Path $TeamsPath -Recurse }
    }
    catch {
        Write-Error -ErrorRecord $_
        exit /b 1
    }
}
else { Break }
