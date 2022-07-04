<#PSScriptInfo

.VERSION 1.0.2

.GUID fb250771-93be-4da0-a4ec-edad2ccf7476

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
.SYNOPSIS
This will run a kiosk app.

.DESCRIPTION
This will run a kiosk app. Primarily, this is used to launch a web brower however can be used to launch any application. It will periodically check if the app is running and restart if it has been closed.

.PARAMETER Path
The location of the program to run.

.PARAMETER Url
The url to open. By default, this it designed to launch a web browser.

.PARAMETER Arguments
The argumnets to be passed to the program.

.PARAMETER Sleep
How long to sleep before checking that the app is running.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript({ Test-Path $_ -PathType Leaf })][string]$Path = ${env:ProgramFiles(x86)} + "\Microsoft\Edge\Application\msedge.exe", #"\Google\Chrome\Application\chrome.exe",
  [string]$Url,
  [array]$Arguments = "--kiosk $($Url)",
  [ValidateRange(1, [int]::MaxValue)][int]$Sleep = 5

)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

if ($PSCmdlet.ShouldContinue($Path, 'Starting kiosk app.')) {
  while ($true) {
    If (-Not (Get-Process | Select-Object Path | Where-Object Path -eq $Path)) { Start-Process -FilePath $Path -ArgumentList $Arguments }
    Start-Sleep -Seconds $Sleep
  }
}
