[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateScript( { Test-Path ((Get-Item $_).parent) })][string]$Path = ".\AD.csv",
    [array]$Filter = "ipphone -like " * "}"
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

Get-ADUser -Properties name, ipPhone, Company, Title, Department, DistinguishedName -Filter $Filter | Where-Object msExchHideFromAddressLists -ne $true | Select-Object name, ipPhone, Company, Title, Department | Sort-Object -Property Company, name | Export-Csv -NoTypeInformation -Path $Path