<#PSScriptInfo
.VERSION 1.0.0
.GUID a0017a8d-5a3d-49a1-9c7f-5e0dbb5ee7d8

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
This is used to validate the existence of metadata on the individual scripts
#>
[System.Collections.ArrayList]$Results = @()
$SourceScripts = Get-ChildItem -Path *.ps1 -ErrorAction SilentlyContinue -Recurse | Where-Object { ($_.Name -ne "psakefile.ps1") -and ($_.Name -ne "***REMOVED***ITDefaults.ps1") -and ($_.Name -ne "Profile.ps1") }
$SourceScripts | ForEach-Object {
    try { $Info = Test-ScriptFileInfo  $_.FullName } catch { $Info = $false ; Write-Verbose "$_.Name does not have a valid PSScriptInfo block" }
    try { $Description = (Get-Help $_.FullName).Description } catch { $Description = $false ; Write-Verbose "$_.Name does not have a valid help block" }
    if ($Info) { $Info = $true } else { $Info = $False }
    if ($Description) { $Description = $true } else { $Description = $False }

    $Result = [PSCustomObject]@{
        File        = $_.Name
        Info        = $Info
        Description = $Description
    }
    $Results += $Result
}
return $Results
