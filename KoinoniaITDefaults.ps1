param([Parameter(Mandatory = $true)] $Invocation)

$Function = ([System.IO.Path]::GetFileNameWithoutExtension($Invocation.MyCommand.Name) -replace "-", "")
Write-Verbose "Loading defaults for $Function"

(Get-Command -Name ($Invocation.InvocationName)).Parameters.Keys | Foreach-Object {
    $Default = $***REMOVED***It.$Function.$_
    if (-not $Invocation.BoundParameters.Keys.contains($_) -and $Default) {
        Write-Verbose "Setting `"$_`" to `"$Default`""
        Set-Variable -Name $_ -Value $Default
    }
}