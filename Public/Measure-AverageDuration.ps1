<#PSScriptInfo

.VERSION 1.0.3

.GUID f4c6b8ab-e5d2-4967-b803-a410619bd191

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
This will run the specified command several times and report the average duration for execution.

.PARAMETER Command
The command that will be run.

.PARAMETER Times
How many times the command will be repeated

.PARAMETER Name
The name or description to use in the progress bar.
#>
param(
  [string]$Command,
  [ValidateRange(1, [int]::MaxValue)][int]$Times = 100,
  [string]$Name = $Command

)

1..$Times | ForEach-Object {
  Write-Progress -Id 1 -Activity $Name -PercentComplete $_
  $Duration += (Measure-Command {
      pwsh -noprofile -command $Command
    }).TotalMilliseconds
}
Write-Progress -id 1 -Activity $Name -Completed
return @{
  Average = $Duration / 100
  Total   = $Duration
}
