<#PSScriptInfo

.VERSION 1.0.4

.GUID f54d5874-3851-47a7-87f5-7841980e0c7a

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
This script will copy the specified file to the public desktop.

.PARAMETER Path
The path of the item to copy.
#>
param(
    $Path,
    [ValidateSet("AD", "NPS", "Hyper-V", "Print", "IIS", "CA")][array]$Group,
    [string]$PublicDesktop = "$env:PUBLIC\Desktop"
)
if ($Path) {
    $Path | ForEach-Object { Copy-Item -Destination $PublicDesktop -Path $_ }
}
if ($Group -contains "AD") {
    Copy-Item -Destination $PublicDesktop -Path "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Active Directory Administrative Center.lnk"
    Copy-Item -Destination $PublicDesktop -Path "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Active Directory Users and Computers.lnk"
}
if ($Group -contains "NPS") {
    Copy-Item -Destination $PublicDesktop -Path "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Network Policy Server.lnk"
}
if ($Group -contains "Hyper-V") {
    Copy-Item -Destination $PublicDesktop -Path "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Hyper-V Manager.lnk"
}
if ($Group -contains "Print") {
    Copy-Item -Destination $PublicDesktop -Path "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Print Management.lnk"
}
if ($Group -contains "IIS") {
    Copy-Item -Destination $PublicDesktop -Path "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Administrative Tools\IIS Manager.lnk"
}

if ($Group -contains "CA") {
    Copy-Item -Destination $PublicDesktop -Path "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Administrative Tools\Certification Authority.lnk"
}
