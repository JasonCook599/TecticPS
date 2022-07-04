<#PSScriptInfo

.VERSION 1.2.3

.GUID 12bacb17-e597-4588-8a86-0e05142301b6

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
.SYNOPSIS
This script will install the specified version of Microsoft Office on the local machine.

.DESCRIPTION
This script will install the specified version of Microsoft Office on the local machine.

.PARAMETER Version
Specifes the version of Office to install. If unspecified, Office 2019 64 bit will be installed.

.EXAMPLE
Install-MicrosoftOffice

.EXAMPLE
Install-MicrosoftOffice -Version 2019Visio

.EXAMPLE
Install-MicrosoftOffice -Version 201932
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [ValidateSet(2019, 2016, 2013, 2010, 2007)][string]$Version,
    [ValidateSet("Visio", "x86", "Standard", $null)]$Options,
    [string]$InstallerPath,
    [ValidateSet("configure", "download", $null)][string]$Mode = "configure"
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
while (!$InstallerPath) { $InstallerPath = Read-Host -Prompt "Enter the installer path." }
if (!(Test-Path $InstallerPath)) { throw "Installer path is not valid" }

If ( $Version -eq "2007" ) { $Exe = Join-Path -Path $InstallerPath -ChildPath "2007 Pro Plus SP2\setup.exe" }
ElseIf ( $Version -eq "2010" ) { $Exe = Join-Path -Path $InstallerPath -ChildPath '2010 Pro Plus SP2\setup.exe' }
ElseIf ( $Version -eq "2013" ) { $Exe = Join-Path -Path $InstallerPath -ChildPath '2013 Pro Plus SP1 x86 x64\setup.exe' }
ElseIf ( $Version -eq "2016" ) { $Exe = Join-Path -Path $InstallerPath -ChildPath '2016 Pro Plus x86 41353\setup.exe' }
ElseIf ( $Version -eq "2019" ) {
    if ($Options -eq "Visio") { $ConfigFile = "***REMOVED***-2019-ProPlus-Visio.xml" }
    elseif ($Options -eq "x86") { $ConfigFile = "***REMOVED***-2019-ProPlus-32-Default.xml" }
    elseif ($Options -eq "Standard") { $ConfigFile = "***REMOVED***-2019-Standard-Default.xml" }
    else { $ConfigFile = "***REMOVED***-2019-ProPlus-Default.xml" }
    Write-Debug "Config file: $ConfigFile"
    $Exe = Join-Path -Path $InstallerPath -ChildPath 'Office Deployment Tool\setup.exe'
    $ConfigPath = Join-Path (Split-Path -Path $Exe -Parent) -ChildPath $ConfigFile
    if (Test-Path -Path $ConfigPath -PathType Leaf) {
        $Arguments = "/$Mode `"$ConfigPath`""
    }
    else { throw "Cannot find config file at $ConfigPath" }
}
else { Write-Error "Version not found. Please spesify a valid version." }
if (Test-Path -Path $Exe -PathType Leaf) {
    if ($Mode -eq "download") { $Message = "Downloading" } else { $Message = "Installing" }
    $Message += " Office $Version"
    if ($ConfigFile) { $Message += " with $ConfigFile" }
    If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", $Message)) {
        Write-Output $Message
        Write-Verbose "$Exe $Arguments"
        Start-Process -FilePath $Exe -NoNewWindow -Wait -ArgumentList $Arguments
    }
}
else { throw "Cannot find installer at $Exe" }
