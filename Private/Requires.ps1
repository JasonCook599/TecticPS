<#PSScriptInfo

.VERSION 2.0.3

.GUID f8ca5dd1-fef2-4024-adc9-124a3007870a

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
Used to specify required modules and prompt to install if missing.

.DESCRIPTION
Used to specify required modules and prompt to install if missing. The primary purpose for the creation of this is to allow the loading of a module even if the requirements of spesific scripts or functions are not met.

This mimicks the #Requires format however has a limited feature set. Notable differences or limitations are listed below. Contributions are welcome to address these limitations.
    - It is only possible to check if a module has been installed. You cannot check for spesific versions.
    - The PSEdition paramater has been renamed to PSEditonName as the former is reserved.
    - This does not support the following parameters: Assembly, PSSnapin, ShellId

.PARAMETER Modules
An array of PowerShell modules that the script requires. Unlike a #Requires statement, you cannot specify version numbers.

If the required modules aren't in the current session, PowerShell imports them. If the modules can't be imported, PowerShell prompt to install. If the installation fails or is declined, the check fails.

.PARAMETER Version
Specifies the minimum version of PowerShell that the script requires. Enter a major version number and optional minor version number.

.PARAMETER PSEditionName
Specifies a PowerShell edition that the script requires. Valid values are Core for PowerShell and Desktop for Windows PowerShell.

.PARAMETER RunAsAdministrator
the PowerShell session in which you're running the script must be started with elevated user rights. The RunAsAdministrator parameter is ignored on a non-Windows operating system. The RunAsAdministrator parameter was introduced in PowerShell 4.0.

.PARAMETER Warn
If specified, a warning will be thrown when a check fails. By default, a terminating error will be thrown.

.PARAMETER Force
If specified, missing modules will be installed without prompting.

.PARAMETER FailedInstallMessage
The message to show for a failed module installation.

.PARAMETER SkippedInstallMessage
The message to show for a skipped module installation.

.PARAMETER PsVersionMessage
The message to show for an invalid PowerShell version.

.PARAMETER PSEditionMessage
The message to show for an invalid PowerShell edition.

.NOTES
Credits    : Some text from Microsoft's official documentation. Available under Creative Commons Attribution 4.0 International License.

.LINK
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_requires?view=powershell-7.2

.LINK
https://github.com/MicrosoftDocs/PowerShell-Docs/blob/staging/reference/7.2/Microsoft.PowerShell.Core/About/about_Requires.md
#>
param(
    [Parameter(ValueFromPipeline = $true)][array]$Modules,
    [string]$Version,
    [ValidateSet("Core", "Desktop")][string]$PSEditionName,
    [switch]$RunAsAdministrator,
    [switch]$Warn,
    [switch]$Force,
    [string]$FailedInstallMessage = "Failed to install required module.",
    [string]$SkippedInstallMessage = "Installation of the required mdoule was skiped",
    [string]$PsVersionMessage = "Powershell $Version is required. You have $($PSVersionTable.PSVersion)",
    [string]$PSEditionMessage = "You are running the $($PSVersionTable.PSEdition) edition. $PsEditionName is required."
)
<# 
#Requires -PSSnapin <PSSnapin-Name> [-Version <N>[.<n>]]
#Requires -ShellId <ShellId> -PSSnapin <PSSnapin-Name> [-Version <N>[.<n>]]
#>

# Covert to a valid version number. Not using [version] type to allow passing a single digit as the version.
try { [version]$Version = $Version } 
catch {
    try { $Version = [version]::New($Version, 0) } 
    catch { throw "$Version is not a valid version" } 
}

# Allow warning instead of thowing for optional requirements.
function Fail {
    param(
        [Parameter(ValueFromPipeline = $true)][string]$Message
    )
    if ($Warn) { Write-Warning $Message } else { throw $Message } 
}

if ($Modules) {
    foreach ($Module in $Modules) {
        if (Get-Module -Name $Module) { Write-Verbose "Module $Module is already loaded." }
        elseIf (Get-Module -ListAvailable -Name $Module) { Import-Module $Module }
        else {
            if (-Not $Force) { $choice = Read-Host -Prompt "Module '$Module' is not available but is required. Install? (Y)" }
            else { Write-Output "'$Module' is not installed. Installing now." }
            
            if ($choice -eq "Y" -or $Force) { 
                try { Install-Module $Module }
                catch {
                    try { Install-Module $Module -Scope CurrentUser }
                    catch { Fail $FailedInstallMessage } 
                }
                Import-Module $Module
            }
            else { Fail $SkippedInstallMessage }
        }
    }

}

if ($Version -gt $PSVersionTable.PSVersion) { Fail $PsVersionMessage } 
if ($PSEditionName -and $PSEditionName -ne $PSVersionTable.PSEdition) { Fail $PSEditionMessage }
if ($RunAsAdministrator -and [System.Environment]::OSVersion.Platform -eq "Win32NT") {
    if ($Warn) { Test-Admin -Warn } else { Test-Admin -Throw }
}

if ($RunAsAdministrator -and [System.Environment]::OSVersion.Platform -eq "Win32NT") {
    if ($Warn) { Test-Admin -Warn } else { Test-Admin -Throw }
}

