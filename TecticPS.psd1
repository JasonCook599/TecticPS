#
# Module manifest for module 'TecticPS'
#
# Generated by: Tectic
#
# Generated on: 2024-11-11
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'TecticPS.psm1'

# Version number of this module.
ModuleVersion = '1.1.168'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'ef2acbe7-8621-4897-b40b-f6c1f84abc6e'

# Author of this module
Author = 'Tectic'

# Company or vendor of this module
CompanyName = 'Tectic'

# Copyright statement for this module
Copyright = '(c) 2022 Tectic. All rights reserved.'

# Description of the functionality provided by this module
Description = 'This is a collection of scripts used for day to day management of IT resources.'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '5.1'

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Add-AllowedDmaDevices', 'Add-BluredPillarBars', 
               'Add-ComputerToDomain', 'Add-GroupEmail', 'Add-Path', 'Add-Signature', 
               'Backup-MySql', 'Clear-AdminCount', 'Clear-PrintQueue', 
               'Connect-Office365', 'Convert-Image', 'ConvertTo-3CXRates', 
               'ConvertTo-EndpointCertificate', 'ConvertTo-OutputImages', 
               'Copy-ToPublicDesktop', 'Disable-NetbiosTcpIp', 
               'Disable-SelfServicePurchase', 'Enable-AdUserPermissionInheritance', 
               'Enable-LicenseOptions', 'Enable-NestedVm', 
               'Export-AdUsersToAssetPanda', 'Export-FortiClientConfig', 
               'Export-FortiClientEmsZtnaRules', 'Export-MatchingCertificates', 
               'Find-EmptyOu', 'Get-AdComputerInfo', 'Get-ADInfo', 'Get-AdminCount', 
               'Get-AdUserInfo', 'Get-AdUserSid', 
               'Get-AzureAdDirectLicenseAssignments', 'Get-AzureAdMfaStatus', 
               'Get-AzureAdUserInfo', 'Get-BiosProductKey', 'Get-BitlockerStatus', 
               'Get-DuplicateFileNames', 'Get-ExchangeOnlineConnection', 
               'Get-ExchangePhoto', 'Get-FirmwareType', 'Get-GroupMembershipReport', 
               'Get-ipPhone', 'Get-LapsInfo', 'Get-MailboxAddresses', 'Get-MemoryType', 
               'Get-MfpEmails', 'Get-MsGraphAuthenticationMethod', 
               'Get-NewComputerName', 'Get-NewIP', 'Get-OrphanedGPO', 
               'Get-RecentEvents', 'Get-SecureBoot', 'Get-Spns', 
               'Get-StaleAADGuestAccounts', 'Get-TermsOfUse', 'Get-TpmInfo', 
               'Get-UserInfo', 'Get-Wallpaper', 'Grant-Matching', 
               'Import-FortiClientConfig', 'Initialize-BiosUsbKey', 
               'Initialize-OneDrive', 'Initialize-Workstation', 'Install-GCPW', 
               'Install-MicrosoftOffice', 'Install-RSAT', 'Install-WingetFromCsv', 
               'Invoke-CommandSimple', 'Invoke-TickleMailRecipients', 
               'Invoke-TouchFile', 'Measure-AverageDuration', 
               'Move-ArchivedEventLogs', 'Move-ArchiveEventLogs', 
               'New-FortiClientConfig', 'New-Password', 'New-RandomCharacters', 
               'Ping-Hosts', 'Remove-AuthenticodeSignature', 
               'Remove-AzureAdDirectLicenseAssignments', 'Remove-BlankLines', 
               'Remove-CachedWallpaper', 'Remove-GroupEmail', 
               'Remove-MailboxOrphanedSids', 'Remove-OldFolders', 
               'Remove-OldModuleVersions', 'Remove-UserPASSWD_NOTREQD', 
               'Remove-VsResistInstallFiles', 'Repair-AdAttributes', 
               'Repair-VmPermissions', 'Reset-CSC', 'Reset-GitBranch', 
               'Reset-InviteRedepmtion', 'Reset-WindowsUpdate', 'Resize-Image', 
               'Save-Password', 'Search-Registry', 'Set-AdPhoto', 
               'Set-ADUserPrimaryGroup', 'Set-AzureAdPhoto', 'Set-ComputerName', 
               'Set-DefaultWallpapers', 'Set-ExchangePhoto', 'Set-Owner', 
               'Set-RoomCalendarPermissions', 'Set-Wallpaper', 
               'Set-WindowsAccountAvatar', 'Show-BitlockerEncryptionStatus', 
               'Start-KioskApp', 'Start-PaperCutClient', 'Start-WindowsActivation', 
               'Stop-ForKey', 'Sync-MailContacts', 'Sync-Nps', 'Test-Admin', 
               'Test-CVE202134470', 'Test-DmaDevices', 'Test-PendingFileRename', 
               'Test-PendingReboot', 'Test-Photo', 'Test-RegistryValue', 
               'Test-ScriptMetadata', 'Test-Scripts', 'Test-VoipMs', 
               'Uninstall-MicrosoftTeams', 'Update-AadSsoKey', 
               'Update-MerakiSwitchPortNames', 'Update-MicrosoftStoreApps', 
               'Update-OfficeCache', 'Update-PKI', 'Update-UsersAcademyStudents', 
               'Update-UsersStaff', 'Wait-ForKey', 'AuthN', 'GetAADPendingGuests', 
               'GetAADSignIns', 'GetAADUserSignInActivity', 'InstallModule', 
               'LoadDefaults', 'ParseGuid', 'Progress', 'Requires', 'SelectPackage'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Windows','IT','IT Management'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/JasonCook599/TecticPS'

        # A URL to an icon representing this module.
        IconUri = 'https://tectic.ca/img/favicon-64.png'

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

