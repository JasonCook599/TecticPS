Get-ADUser -Filter { AdminCount -ne "0" } -Properties AdminCount | Select-Object name, AdminCount
