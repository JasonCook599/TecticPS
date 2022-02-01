param(
    [Parameter(Mandatory = $true)] $Invocation, 
    $DefaultsScripts = "***REMOVED***ITDefaults.ps1"
)

try {    
    $ModuleName = (Get-Command -Name $Invocation.MyCommand -ErrorAction SilentlyContinue).ModuleName
    $ModulePath = (Get-Module -Name $ModuleName).Path
    $ModuleRoot = Split-Path -Parent -Path $ModulePath
    Write-Verbose "Running command from a module."
}
catch { Write-Verbose "Not running command from a module." }

try {
    $ScriptPath = ((Get-Item $Invocation.InvocationName).DirectoryName)
    $ModuleRoot = Split-Path -Path $ScriptPath -Parent
    Test-Path -ErrorAction Stop -Path $ModuleRoot | Out-Null
    Write-Verbose "Running command from a script."
}
catch { Write-Verbose "Could not find script parent." }

try {
    $DefaultsPath = Join-Path -Path $ModuleRoot -ChildPath $DefaultsScripts
    Write-Verbose "Defaults Path: $DefaultsPath"
    Test-Path -ErrorAction Stop -Path $DefaultsPath | Out-Null
    return $DefaultsPath
}
catch { Write-Error "Error loading defaults script." }




Write-Error "Not running as a module and can't find script path. Defaults not loaded."

