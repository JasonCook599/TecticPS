<#PSScriptInfo

.VERSION 0.0.11

.GUID 975b5e06-eee0-461b-9b98-49351c762dcd

.AUTHOR Jason Cook Luke Murray (Luke.Geek.NZ)

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
Removes old version of installed PowerShell modules. Usefull for cleaning up after module updates.

.LINK
https://luke.geek.nz/powershell/remove-old-powershell-modules-versions-using-powershell/
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [array]$Modules = (Get-InstalledModule)
)
Requires -Version 2.0 -Modules PowerShellGet
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
foreach ($Module in $Modules) {
    $count++ ; Progress -Index $count -Total $Modules.count -Activity "Uninstalling old versions of $($Module.Name). [latest is $($Module.Version)]" -Name $Image.Name -ErrorAction SilentlyContinue
    $Installed = Get-InstalledModule -Name $Module.Name -AllVersions
    If ($Installed.count -gt 1) {
        Write-Verbose -Message "Uninstalling $($Installed.Count-1) old versions of $($Module.Name) [latest is $($Module.Version)]" -Verbose
        If ($PSCmdlet.ShouldProcess("$($Module.Name)", "Remove-OldModules")) {
            $Installed | Where-Object { $_.Version -ne $module.Version } | Uninstall-Module -Verbose
        }
    }
}
