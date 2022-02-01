[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateScript( { Test-Path ((Get-Item $_).parent) })][string]$Path = ".\AD.csv",
    [array]$Properties = ("name", "mail"),
    [string]$SearchBase ,
    [string]$Filter = "*"
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

If ($SearchBase) { $Result = Get-ADUser -Properties $Properties -Filter $Filter -SearchBase $SearchBase | Where-Object Enabled -eq $true }
else { $Result = Get-ADUser -Properties $Properties -Filter $Filter | Where-Object Enabled -eq $true }
$Result += Get-ADUser -Properties $Properties -Identity "koinonia"
$Result += Get-ADUser -Properties $Properties -Identity "kcfit"
$Result = $Result | Where-Object msExchHideFromAddressLists -ne $true | Select-Object name, mail | Sort-Object -Property Company, name
$Result | ForEach-Object { $_.name = "$($_.name[0..23] -join '')" } #Trim lenght for import.
$Result | Export-Csv -NoTypeInformation -Path $Path
Return $Result