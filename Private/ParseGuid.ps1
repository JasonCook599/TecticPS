param (
    [string]$String,
    [ValidateSet("N", "D", "B", "P")][string]$Format = "B"
)
$Guid = [System.Guid]::empty
If ([System.Guid]::TryParse($String, [System.Management.Automation.PSReference]$Guid)) {
    $Guid = [System.Guid]::Parse($String)
}
Else {
    $Guid = $null
}
return $Guid.ToString($Format)