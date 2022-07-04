<#PSScriptInfo

.VERSION 1.0.1

.GUID 4fc14578-f8eb-4ae2-8e39-77c0f197cff8

.AUTHOR Jason Cook

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) ***REMOVED*** 2022

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
Automatically update Academy student users.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [ValidateScript( { Test-Path $_ })][string] $UserPath = ".\Students.csv",
    [array]$Users = (Import-Csv $UserPath | Sort-Object -Property "Grade Level", "FirstName LastName"),
    $HomePage,
    $Company,
    $Office,
    $Title,
    $Path

)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Get-ADUser -Filter * -SearchBase $Path | Set-ADUser -Enabled $false
[System.Collections.ArrayList]$Results = @()

$Users | ForEach-Object {
    $Name = $_."FirstName LastName"
    $GivenName = $Name.split(" ")[0]
    $Surname = $Name.split(" ")[1]
    $Department = "Grade " + $_."Grade Level" -replace "0", ""
    $SamAccountName = $GivenName + "." + $Surname
    $UserPrincipalName = $SamAccountName + "@" + $HomePage
    $EmailAddress = $UserPrincipalName
    $PasswordSecure = Get-Password

    try {
        New-ADUser -DisplayName $Name -GivenName $GivenName -Surname $Surname -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName -EmailAddress $EmailAddress -Title $Title -Department $Department -Office $Office -Company $Company -HomePage $HomePage -Enabled $true -Name $Name -AccountPassword $PasswordSecure -Path $Path

        $Result = [PSCustomObject]@{
            Grade        = $Department
            Name         = $Name
            EmailAddress = $UserPrincipalName
            Password     = $Password
            Status       = "New"
        }
        $Results += $Result
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] {
        Set-ADUser -Identity $SamAccountName -DisplayName $Name -GivenName $GivenName -Surname $Surname -SamAccountName $SamAccountName -UserPrincipalName $UserPrincipalName -EmailAddress $EmailAddress -Title $Title -Department $Department -Office $Office -Company $Company -HomePage $HomePage -Enabled $true

        $Result = [PSCustomObject]@{
            Grade        = $Department
            Name         = $Name
            EmailAddress = $UserPrincipalName
            Password     = ""
            Status       = "Updated"
        }
        $Results += $Result
    }
}
Start-Sleep -Seconds 10
Search-ADAccount -AccountDisabled -SearchBase $Path | ForEach-Object {
    $Result = [PSCustomObject]@{
        Name         = $_.Name
        EmailAddress = $_.UserPrincipalName
        Password     = ""
        Status       = "Disabled"
    }
    $Results += $Result
}
Return $Results
