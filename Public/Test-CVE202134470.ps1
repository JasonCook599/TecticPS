<#PSScriptInfo

.VERSION 22.11.15

.GUID 83ac6137-696a-496a-a746-0372e8a20797

.AUTHOR Microsoft Corporation

.COMPANYNAME Microsoft Corporation

.COPYRIGHT Copyright (c) Microsoft Corporation

.TAGS

.LICENSEURI https://opensource.org/license/mit/

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#> 





<#
.SYNOPSIS
    Test for and addresses CVE-2021-34470.

.DESCRIPTION
    Environments running supported versions of Exchange Server should address
    CVE-2021-34470 by applying the CU and/or SU for the respective versions of
    Exchange, as described in
    https://techcommunity.microsoft.com/t5/exchange-team-blog/released-july-2021-exchange-server-security-updates/ba-p/2523421.

    Environments where the latest version of Exchange Server is any version before
    Exchange 2013, or environments where all Exchange servers have been removed, can
    use this script to address the vulnerability.

.EXAMPLE
    PS> .\Test-CVE-2021-34470.ps1
    Reports whether the vulnerability is present.
.EXAMPLE
    PS> .\Test-CVE-2021-34470.ps1 -ApplyFix
    Fixes the vulnerability if found. Note that this syntax requires Schema Admin.

<#
MIT License

Copyright (c) Microsoft Corporation.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE
#>
[CmdletBinding()]
param(
  [Parameter()]
  [switch]
  $ApplyFix
)

$ErrorActionPreference = "Stop"

$schemaMaster = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain().Forest.SchemaRoleOwner

$schemaDN = ([ADSI]"LDAP://$($schemaMaster)/RootDSE").schemaNamingContext

$storageGroupSchemaEntryDN = "LDAP://$($schemaMaster)/CN=ms-Exch-Storage-Group,$schemaDN"

if (-not ([System.DirectoryServices.DirectoryEntry]::Exists($storageGroupSchemaEntryDN))) {
  Write-Host "Exchange was not installed in this forest. Therefore, CVE-2021-34470 vulnerability is not present."
  return
}

$storageGroupSchemaEntry = [ADSI]($storageGroupSchemaEntryDN)
if ($storageGroupSchemaEntry.Properties["possSuperiors"].Count -eq 0) {
  Write-Host "CVE-2021-34470 vulnerability is not present."
  return
}

$hasUnexpectedValues = $false

foreach ($val in $storageGroupSchemaEntry.Properties["possSuperiors"]) {
  if ($val -eq "computer") {
    Write-Warning "CVE-2021-34470 vulnerability is present."
  }
  else {
    $hasUnexpectedValues = $true
    Write-Warning "CVE-2021-34470 vulnerability may be present due to an unexpected superior: $val"
  }
}

if ($ApplyFix) {
  if ($hasUnexpectedValues) {
    $OutputFile = "$PSScriptRoot\Test-CVE-2021-34470.log"
    "Attempting fix at $(Get-Date)." | Out-File $OutputFile -Append
    "Value prior to fix:" | Out-File $OutputFile -Append
    $storageGroupSchemaEntry.Properties["possSuperiors"] | Out-File $OutputFile -Append
  }

  try {
    Write-Host "Attempting to apply fix..."

    $rootDSE = [ADSI]("LDAP://$($schemaMaster)/RootDSE")
    [void]$rootDSE.Properties["schemaUpgradeInProgress"].Add(1)
    $rootDSE.CommitChanges()

    $storageGroupSchemaEntry.Properties["possSuperiors"].Clear()
    $storageGroupSchemaEntry.CommitChanges()

    Write-Host "Fix was applied successfully."
  }
  catch {
    Write-Warning "Failed to apply fix. Please ensure you have Schema Admin rights. Error was: `n$_"
  }
}
