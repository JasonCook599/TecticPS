<#PSScriptInfo
.VERSION 1.0.0
.GUID d410b890-4003-4030-8a47-ee4b5d91a254

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
Show progress in an easier to use format
#>
param(
    [int]$Index,
    [int]$Total,
    [string]$Name,
    [string]$Activity,
    [string]$Status = ("Processing {0} of {1}: {2}" -f $Index, $Total, $Name),
    [int]$PercentComplete = ($Index / $Total * 100)
) 
if ($Total -gt 1) { Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete }
