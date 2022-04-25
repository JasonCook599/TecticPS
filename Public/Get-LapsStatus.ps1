<#PSScriptInfo

.VERSION 1.0.1

.GUID c64f1f09-036c-471d-898c-c9b3da6f53a8

.AUTHOR Jason Cook

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) ***REMOVED*** 2022

#> 

<#
.DESCRIPTION
Shows the percentage of machines which have LAPS configured.

.PARAMETER Details
If set, will show which computers have a password set.

.PARAMETER Filter
Filters the search based on the spesified parameters.

.PARAMETER ShowPasswords
Will also output passwords.
#>
param(
    [string]$Filter = "*",
    [switch]$Details,
    [string]$Show
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Results = @()
Get-ADComputer -Filter $Filter -Properties ms-Mcs-AdmPwd | Sort-Object ms-Mcs-AdmPwd, Name | ForEach-Object {
    if ($Show) { $Password = $_.'ms-Mcs-AdmPwd' } else { $Password = '********' }
    if ($_.'ms-Mcs-AdmPwd') { $Status = $true } else { $Status = $false }       
    $Result = [PSCustomObject]@{
        Name     = $_.Name
        Status   = $Status
        Password = $Password    
    }
    $Results += $Result
}
if ($Details) { return $Results } else { 
    
    
    $EnabledCount = ($Results | Where-Object Status -eq $true).Count
    $DisabledCount = ($Results | Where-Object Status -eq $false).Count
    $TotalCount = $Results.count
    
    return [PSCustomObject]@{
        Enabled         = $EnabledCount
        Disabed         = $DisabledCount
        Total           = $TotalCount
        PercentComplete = $EnabledCount / $TotalCount * 100
    }
}