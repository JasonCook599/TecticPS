param(
    [int]$Index,
    [int]$Total,
    [string]$Name,
    [string]$Activity,
    [string]$Status = ("Processing {0} of {1}: {2}" -f $Index, $Total, $Name),
    [int]$PercentComplete = ($Index / $Total * 100)
) 
if ($Total -gt 1) { Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete }