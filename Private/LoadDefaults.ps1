<#PSScriptInfo

.VERSION 1.0.5

.GUID 73e8a944-8951-4a89-9a54-d51db3f9afac

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
Load default parameters for various functions.
#>

# SkipLoadDefaults: true

param(
    [Parameter(Mandatory = $true)] $Invocation,
    $DefaultsScripts = "TecticPSDefaults.ps1"
)

try {
    $ModuleName = (Get-Command -Name $Invocation.MyCommand -ErrorAction SilentlyContinue).ModuleName
    $ModulePath = (Get-Module -Name $ModuleName).Path
    $ModuleRoot = Split-Path -Parent -Path $ModulePath
    Write-Debug "Running command from the `'$ModuleName`' module located at `'$ModulePath`'."
}
catch { Write-Debug "Not running command from a module." }

try {
    $ScriptPath = ((Get-Item $Invocation.InvocationName -ErrorAction SilentlyContinue).DirectoryName)
    $ModuleRoot = Split-Path -Path $ScriptPath -Parent
    Test-Path -ErrorAction Stop -Path $ModuleRoot | Out-Null
    Write-Debug "Running command from a script located at `'$ScriptPath`'."
}
catch { Write-Debug "Could not find script parent." }

try {
    $DefaultsPath = Join-Path -Path $ModuleRoot -ChildPath $DefaultsScripts
    Write-Debug "Defaults Path is  `'$DefaultsPath`'"
    Test-Path -ErrorAction Stop -Path $DefaultsPath | Out-Null
    return $DefaultsPath
}
catch {
    Write-Debug "Error loading defaults script."
    return Write-Error "Not running as a module and can't find script path. Defaults not loaded."
}
