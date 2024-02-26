param([Parameter(Mandatory = $true)] $Invocation)
try {
  $Function = ([System.IO.Path]::GetFileNameWithoutExtension($Invocation.MyCommand.Name) -replace "-", "")
  Write-Verbose "Loading defaults for $Function"

(Get-Command -Name ($Invocation.InvocationName)).Parameters.Keys | Foreach-Object {
    $Default = $TecticPS.$Function.$_
    if (-not $Invocation.BoundParameters.Keys.contains($_) -and $Default) {
      Write-Verbose "Setting `"$_`" to `"$Default`""
      Set-Variable -Name $_ -Value $Default -WhatIf:$false
    }
  }
}
catch { Write-Warning "Failed to load defaults." }