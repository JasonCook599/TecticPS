<#PSScriptInfo

.VERSION 1.0.5

.GUID 120db2ff-3cb8-43ea-aa2c-f044ff52c144

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2025

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#> 





<#
.DESCRIPTION
Automatically update staff users.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateScript( { Test-Path $_ })][string] $UserPath = ".\Staff.csv",
  [array]$Users = (Import-Csv $UserPath | Sort-Object -Property Surname, GivenName),
  $HomePage,
  $Company,
  $Office,
  $Path
)

[System.Collections.ArrayList]$Results = @()

$Users | ForEach-Object {
  If ($_.PreferredGivenName) { $GivenName = $_.PreferredGivenName } Else { $GivenName = $_.GivenName }
  If ($_.PreferredSurname) { $Surname = $_.PreferredSurname } Else { $Surname = $_.Surname }
  $DisplayName = $GivenName + " " + $Surname
  $SamAccountName = $GivenName + "." + $Surname
  $UserPrincipalName = $SamAccountName + "@" + $HomePage
  $EmailAddress = $UserPrincipalName
  $Department = $_.Title.split("\s-\s")[0]
  $Title = $_.Title.split(" - ")[1]
  $Office = $_.Office.split(" - ")[0]

  $StreetAddress = $_.StreetAddress
  If ($_.StreetAddress2) { $StreetAddress += `n + $_.StreetAddress2 }

  try {
    $Password = ConvertTo-SecureString (Get-RandomPassword) -AsPlainText -Force

    New-ADUser -DisplayName $DisplayName -GivenName $GivenName -Surname $Surname -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName -EmailAddress $EmailAddress -Title $Title -Department $Department -Office $Office -Company $Company -HomePage $HomePage -Enabled $true -Name $SamAccountName -StreetAddress $StreetAddress -City $_.City -State $_.State -PostalCode $_.PostalCode -OfficePhone $_.OfficePhone -AccountPassword $PasswordSecure -Path $Path -WhatIf

    $Result = [PSCustomObject]@{
      DisplayName  = $DisplayName
      Department   = $Department
      Title        = $Title
      EmailAddress = $UserPrincipalName
      Password     = $Password
      Status       = "New"
    }
    $Results += $Result
  }
  catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] {
    Set-ADUser -Identity $SamAccountName -DisplayName $DisplayName -GivenName $GivenName -Surname $Surname -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName -EmailAddress $EmailAddress -Title $Title -Department $Department -Office $Office -Company $Company -HomePage $HomePage -Enabled $true -Name $SamAccountName -StreetAddress $StreetAddress -City $_.City -State $_.State -PostalCode $_.PostalCode -OfficePhone $_.OfficePhone -WhatIf

    $Result = [PSCustomObject]@{
      Name         = $Name
      Department   = $Department
      Title        = $Title
      EmailAddress = $UserPrincipalName
      Password     = $Password
      Status       = "New"
    }
    $Results += $Result
  }
}
<#     Start-Sleep -Seconds 10
    Get-ADUser -Filter * -SearchBase $Path | Sort-Object Name | ForEach-Object {
        If (-NOT ($_.SamAccountName -in $Users)) { Write-Host $_.SamAccountName }
    }

    Search-ADAccount -AccountDisabled -SearchBase $Path | ForEach-Object {
        $Result = [PSCustomObject]@{
            Name         = $_.Name
            EmailAddress = $_.UserPrincipalName
            Password     = ""
            Status       = "Disabled"
        }
        $Results += $Result
    } #>
Return $Results
