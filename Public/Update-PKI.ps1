<#PSScriptInfo

.VERSION 1.0.4

.GUID 8f760b1c-0ccc-43b7-bfed-9370fa84b7f8

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
Upload CRLs to GitHub if changed.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    $Path = "./",
    $AccessToken = "",
    $OwnerName = "",
    $RepositoryName = "",
    $BranchName = "",
    [switch]$Force
)

Get-ChildItem -Path $Path -Exclude *.sha256 | ForEach-Object {
    If ($PSCmdlet.ShouldProcess($_.Name, "Update-PKI")) {
        $NewHash = (Get-FileHash $_.FullName).Hash
        if ((Get-Content -Path ($_.FullName + ".sha256") -ErrorAction SilentlyContinue) -ne $NewHash -OR $Force) {
            Set-GitHubContent -OwnerName $OwnerName -RepositoryName $RepositoryName -BranchName $BranchName -AccessToken $AccessToken -CommitMessage ("Updating CRL from " + $env:computername) -Path  ("pki\" + $_.Name) -Content ([convert]::ToBase64String([IO.File]::ReadAllBytes($_.FullName)))
            $NewHash | Out-File -FilePath ($_.FullName + ".sha256")
        }
    }
}
