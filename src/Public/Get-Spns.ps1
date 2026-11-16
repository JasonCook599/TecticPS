<#PSScriptInfo

.VERSION 1.0.5

.GUID 086f7358-170c-4f90-ab37-9b06888cd963

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2024

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
List all SPNs in Active Directory

.LINK
https://social.technet.microsoft.com/wiki/contents/articles/18996.active-directory-powershell-script-to-list-all-spns-used.aspx
#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
param()
#Set Search
Clear-Host
$search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
$search.filter = "(servicePrincipalName=*)"
$results = $search.Findall()

#list results
foreach ($result in $results) {
  $userEntry = $result.GetDirectoryEntry()
  Write-Host "Object Name  =  "$userEntry.name -backgroundcolor "yellow" -foregroundcolor "black"
  Write-Host "DN           =  "$userEntry.distinguishedName
  Write-Host "Object Cat.  =  "$userEntry.objectCategory
  Write-Host "servicePrincipalNames"
  $i = 1

  foreach ($SPN in $userEntry.servicePrincipalName) {
    $Output = "SPN (" + $i.ToString('000') + ")  =  " + $SPN
    Write-Host $Output
    $i += 1
  }
  Write-Host ""
}
