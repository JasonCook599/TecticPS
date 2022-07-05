function AuthN {
<#PSScriptInfo

.VERSION 1.0.1

.GUID fe011093-6980-4847-aa9c-f7a7b47a3a5b

.AUTHOR Jason Cook & Darren J Robinson

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
Authenticate to Azure AD and receieve Access and Refresh Tokens.

.DESCRIPTION
Authenticate to Azure AD and receieve Access and Refresh Tokens.

.PARAMETER tenantID
(required) Azure AD TenantID.

.PARAMETER credential
(required) ClientID and Cli
.EXAMPLE
$Credential = Get-Credential
AuthN -credential $Credential -tenantID '74ea519d-9792-4aa9-86d9-abcdefgaaa'

.LINK
http://darrenjrobinson.com/

#>
[cmdletbinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$tenantID,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][System.Management.Automation.PSCredential]$credential
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

if (!(Get-Command Get-MsalToken)) { Install-Module -name MSAL.PS -Force -AcceptLicense }
try { return (Get-MsalToken -ClientId $credential.UserName -ClientSecret $credential.Password -TenantId $tenantID) } # Authenticate and Get Tokens
catch { Write-Error $_ }
}
function GetAADPendingGuests {
<#PSScriptInfo

.VERSION 1.0.1

.GUID d2231470-2326-4498-80d2-0456b0018d0a

.AUTHOR Jason Cook Darren J Robinson

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
Get AAD B2B Accounts where the inviation hasn't been accepted.

.EXAMPLE
GetAADPendingGuests

.LINK
http://darrenjrobinson.com/
#>
[cmdletbinding()]
param()

$global:myToken = AuthN -credential $Credential -tenantID $TenantId # Refresh Access Token

try {
    # Get AAD B2B Pending Users.
    return (Invoke-RestMethod -Headers @{Authorization = "Bearer $($myToken.AccessToken)" } `
            -Uri  "https://graph.microsoft.com/beta/users?filter=externalUserState eq 'PendingAcceptance'&`$top=999" `
            -Method Get).value
}
catch { Write-Error $_ }
}
function GetAADSignIns {
<#PSScriptInfo

.VERSION 1.0.1

.GUID e5758f99-a57e-4bcf-af21-30e5fd176e51

.AUTHOR Jason Cook Darren J Robinson

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
Get AAD Account SignIn Activity.

.PARAMETER date
(required) date whereby users haven't signed in since to return objects for

.EXAMPLE
GetAADSignIns -Date "2021-01-01"

.LINK
http://darrenjrobinson.com/
#>
[cmdletbinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$Date
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
$global:myToken = AuthN -credential $Credential -tenantID $TenantId # Refresh Access Token

try {
    # Get AAD B2B Users
    return (Invoke-RestMethod -Headers @{Authorization = "Bearer $($myToken.AccessToken)" } `
            -Uri  "https://graph.microsoft.com/beta/users?filter=signInActivity/lastSignInDateTime le $($Date)" `
            -Method Get).value
}
catch { Write-Error $_ }
}
function GetAADUserSignInActivity {
<#PSScriptInfo

.VERSION 1.0.1

.GUID b444ff47-447f-4196-90eb-08723fa0fbaf

.AUTHOR Jason Cook Darren J Robinson

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
Get AAD Account SignIn Activity.

.PARAMETER ID
(required) ObjectID of the user to get SignIn Activity for

.EXAMPLE
GetAADUserSignInActivity -ID "feeb81f9-af70-2d5a-aa8c-f035ddaabcde"

.LINK
http://darrenjrobinson.com/
#>
[cmdletbinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$ID
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$global:myToken = AuthN -credential $Credential -tenantID $TenantId # Refresh Access Token

try {
    # Get AAD SignIn Activity.
    return Invoke-RestMethod -Headers @{Authorization = "Bearer $($myToken.AccessToken)" } `
        -Uri  "https://graph.microsoft.com/beta/users/$($ID)?`$select=id,displayName,signInActivity" `
        -Method Get
}
catch { Write-Error $_ }
}
function InstallModule {
<#PSScriptInfo

.VERSION 1.0.1

.GUID 10ba8c03-4333-4f67-b11b-b25fef85943b

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
Install module if not pressent.
#>
param($Name, $AltName)
Write-Verbose "$me Installing $Name Module if missing"
If (!(Get-Module -ListAvailable -Name $Name)) {
	Install-Module $Name
}
}
function LoadDefaults {
<#PSScriptInfo

.VERSION 1.0.1

.GUID 73e8a944-8951-4a89-9a54-d51db3f9afac

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
Load default parameters for various functions.
#>
param(
    [Parameter(Mandatory = $true)] $Invocation,
    $DefaultsScripts = "***REMOVED***ITDefaults.ps1"
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

try {
    $ModuleName = (Get-Command -Name $Invocation.MyCommand -ErrorAction SilentlyContinue).ModuleName
    $ModulePath = (Get-Module -Name $ModuleName).Path
    $ModuleRoot = Split-Path -Parent -Path $ModulePath
    Write-Verbose "Running command from a module."
}
catch { Write-Verbose "Not running command from a module." }

try {
    $ScriptPath = ((Get-Item $Invocation.InvocationName -ErrorAction SilentlyContinue).DirectoryName)
    $ModuleRoot = Split-Path -Path $ScriptPath -Parent
    Test-Path -ErrorAction Stop -Path $ModuleRoot | Out-Null
    Write-Verbose "Running command from a script."
}
catch { Write-Verbose "Could not find script parent." }

try {
    $DefaultsPath = Join-Path -Path $ModuleRoot -ChildPath $DefaultsScripts
    Write-Verbose "Defaults Path: $DefaultsPath"
    Test-Path -ErrorAction Stop -Path $DefaultsPath | Out-Null
    return $DefaultsPath
}
catch { Write-Error "Error loading defaults script." }

Write-Error "Not running as a module and can't find script path. Defaults not loaded."
}
function ParseGuid {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 93f9436d-928a-4cf8-a5a0-e3f3f6bdcf14

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
Parse a GUID
#>
param (
    [string]$String,
    [ValidateSet("N", "D", "B", "P")][string]$Format = "B"
)
$Guid = [System.Guid]::empty
If ([System.Guid]::TryParse($String, [System.Management.Automation.PSReference]$Guid)) {
    $Guid = [System.Guid]::Parse($String)
}
Else {
    $Guid = $null
}
return $Guid.ToString($Format)
}
function Progress {
<#PSScriptInfo

.VERSION 1.0.3

.GUID d410b890-4003-4030-8a47-ee4b5d91a254

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
Show progress in an easier to use format
#>
param(
    [int]$Index,
    [int]$Total,
    [string]$Name,
    [string]$Activity,
    [string]$Status = ("Processing {0} of {1}: {2}" -f $Index, $Total, $Name),
    [int]$PercentComplete = ($Index / $Total * 100)
)

if ($PercentComplete -eq 100) { $Completed = $true } else { $Completed = $false }
if ($Total -gt 1) { Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete -Completed:$Completed }
}
function Requires {
<#PSScriptInfo

.VERSION 2.0.4

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

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
<#
#>

try { [version]$Version = $Version }
catch {
    try { $Version = [version]::New($Version, 0) }
    catch { throw "$Version is not a valid version" }
}

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

if ($RunAsAdministrator -and [System.Environment]::OSVersion.Platform -eq "Win32NT") {
    if ($Warn) { Test-Admin -Warn } else { Test-Admin -Throw }
}
}
function SelectPackage {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 0caaa663-ed3d-498c-a77e-d00e85146cd1

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
Select the winget pacakge to install. Used by the Initilize-Workstation command.

.PARAMETER Packages
A hashtable of packages to select from.

.PARAMETER Title
The title of the message box.

.PARAMETER Mode
Should a single or multiple package be selected?
#>

param(
    [Parameter(Mandatory = $True, ValuefromPipeline = $True)][hashtable]$Packages,
    [Parameter(ValuefromPipeline = $True)][string]$Title = "Select the packages to install",
    [Parameter(ValuefromPipeline = $True)][ValidateSet("Single" , "Multiple")][string]$Mode = "Single"
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

if ($Packages.count -gt 1) {
    $SelectedPackage = $Packages | Out-GridView -OutputMode $Mode -Title $Title
    return @{ $SelectedPackage.Name = $SelectedPackage.Value }
}

elseif ($Packages.count -eq 1) {
    while ("y", "n" -notcontains $Install ) { $Install = Read-Host "Do you want to install $($Packages.Keys)? [y/n] " }

    if ($Install -eq "Y" ) { return @{ $($Packages.Keys) = $($Packages.Values) } }
    else { return @{} }
}

else {
    Write-Warning "No packages to install. Press enter to continue."
    return @{}
}
}
function Add-AllowedDmaDevices {
<#PSScriptInfo

.VERSION 1.0.2

.GUID a684ddd1-559b-48e2-bbdf-a85a3d50d3f6

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
This script will Allow spesific devices to the list of Allowed Buses.

.DESCRIPTION
This script will Allow spesific devices to the list of Allowed Buses. The primary use if for automatic BitLocker encryption.

.PARAMETER ComputerInfo
The Manufacturer and Model of the current device.

.PARAMETER Path
The registry path for AllowedBuses

.PARAMETER DeviceList
A hashtable of all the address of allowed devices in the format of Manufactuer.Model.Name.

.PARAMETER AllowedDevices
An list of all the devices allowed on this spesific device.
#>
param(
    $ComputerInfo = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Manufacturer, Model),
    $Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DmaSecurity\AllowedBuses",
    $DeviceList = @{
        Lenovo = @{
            "20YG003FUS" = @{
                "PCI Express Root Port A" = "PCI\VEN_1022&DEV_1634"
                "PCI Express Root Port B" = "PCI\VEN_1022&DEV_1635"
                "PCI standard ISA bridge" = "PCI\VEN_1022&DEV_790E"
            }
        }
    },
    $AllowedDevices = $DeviceList.$($ComputerInfo.Manufacturer).$($ComputerInfo.Model)
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
foreach ($Device in $AllowedDevices.GetEnumerator()) {
    New-ItemProperty -Path $Path -Name $Device.Name -Value $Device.Value -PropertyType "String" -Force -WhatIf
}
}
function Add-BluredPillarBars {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 6ee394c8-c592-49d5-b16c-601955ef4d2f

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
This script will using ImageMagick to add blurred pillar bars to a set of images.

.DESCRIPTION
This script will scale to fill, then blur the spesified image. Then, on a new layer, it will scale to fit the image.

.PARAMETER Path
This is the image file or a folder of images to be modified.

.PARAMETER Format
The file format to convert images to. If unspesified, the existing format will be used.

.PARAMETER Aspect
The aspect ration to convert to, in x:y format. If unspesified, 16:9 will be used.

.PARAMETER Prefix
The text that appears before the filename for each converted image. If unspesified, the aspect ration in x_y format will be used.

.PARAMETER Suffix
The text that appears after the filename for each converted image. If unspesifed, no text will be used.

.PARAMETER MaxHeight
This is the max height of the converted image. If unspesified, the current height will be used.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript( { Test-Path -Path $_ })][Parameter(Mandatory = $true)][string]$Path,
  [string]$Background,
  [string]$Format,
  [string]$Aspect = "16:9",
  [string]$Prefix = ($Aspect -Replace ":", "x") + "_",
  [string]$Suffix,
  [ValidateRange(1, [int]::MaxValue)][int]$MaxHeight,
  [switch]$Preview
)

Get-ChildItem -File -Path $Path | ForEach-Object {
  If (!$Format) { $Format = [System.IO.Path]::GetExtension($_.Name) }
  If (!$Background) { $Background = $_.Name }
  $OutFile = $Prefix + [io.path]::GetFileNameWithoutExtension($_.Name) + $Suffix + $Format
  Write-Verbose "$me Resizing with aspect ratio of $Aspect and height of $MaxHeight to $OutFile"
  If ($PSCmdlet.ShouldProcess("$OutFile", "Add-BluredPillarBars")) {
    $run = 'magick.exe identify -format %h ' + $_.Name
    $Height = (Invoke-Expression $run)
    If (!$MaxHeight) { $MaxHeight = $Height }
    magick.exe convert $Background -blur 0x8 -gravity center -crop $Aspect -resize x$Height +repage $_.Name -gravity center -composite -scale x$MaxHeight -resize $Aspect $OutFile
  }
  $Format = $null
}
}
function Add-ComputerToDomain {
<#PSScriptInfo

.VERSION 1.0.1

.GUID 847616c6-fd6a-4685-b96f-ff8446a849e0

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
This script will add the computer to the domain.

.PARAMETER Domain
The domain to join.

.PARAMETER User
The domain user with crednetials to join the domain.

.PARAMETER Password
The password for the domain user.

.PARAMETER OU
The OU to add the computer to.

.PARAMETER SecurePassword
The password for the domain user as a secure string.

.PARAMETER Credentials
The credentials object to use for the join.
#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "Password")]
param(
    [string]$Domain,
    [string]$User,
    [string]$Password,
    [string]$OU,
    [SecureString]$SecurePassword = ($Password | ConvertTo-SecureString -AsPlainText -Force),
    [pscredential]$Credentials = (New-Object System.Management.Automation.PSCredential -ArgumentList $User, $SecurePassword)
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

if ($OU) { Add-Computer -DomainName $Domain -Credential $Credentials -Force -OU $OU }
else { Add-Computer -DomainName $Domain -Credential $Credentials -Force }
}
function Add-GroupEmail {
<#PSScriptInfo

.VERSION 1.0.1

.GUID 772c6454-68cf-42aa-89b9-dd6dc5939e1b

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
Add an email address to an existing Microsoft 365 group.

.DESCRIPTION
Add an email address to an existing Microsoft 365 group. You can also use this to set the primary address for the group.

.PARAMETER Identity
The identity of the group you wish to change.

.PARAMETER EmailAddress
The email address you whish to add.

.PARAMETER SetPrimary
If set, this will set the email adress you specified as the primary address for the group.

.EXAMPLE
Add-GroupEmail -Identity staff -EmailAddress staff@example.com
#>
param (
    [string]$Identity,
    [mailaddress]$EmailAddress,
    [switch]$SetPrimary
)

Set-UnifiedGroup -Identity $-Identity -EmailAddresses: @{Add = $EmailAddress }
If ($SetPrimary) { Set-UnifiedGroup -Identity $-Identity -PrimarySmtpAddress  $EmailAddress }
}
function Add-Path {
<#PSScriptInfo

.VERSION 1.0.2

.GUID bcbc3792-1f34-4100-867c-6fcf09230520

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
This will add a location to enviroment PATH.

.PARAMETER Path
The path to add.

.PARAMETER Machine
This will modify the machine path instead of the user's path.

.PARAMETER Force
This will override check of the maximum lenght.

.PARAMETER MaxLenght
The maximum supported lenght for the PATH.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true)][ValidateScript({ Test-Path -Path $_ -PathType Container })][string]$Path,
    [switch]$Machine,
    [switch]$Force,
    [ValidateRange(1, [int]::MaxValue)][int]$MaxLength = 1024
)

if ($Machine) {
    Write-Verbose "Adding `"$Path`" to system PATH"
    Test-Admin -Throw
    $Registry = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
}
else {
    Write-Verbose "Adding `"$Path`" to user PATH"
    $Registry = "Registry::HKCU\Environment\"
}

$NewPath = (Get-ItemProperty -Path $Registry -Name PATH).Path + ";" + $Path

Write-Verbose "PATH length is $($NewPath.length)"
if ($NewPath.length -gt $MaxLength -and (-not $Force)) {
    throw "Path is longer than $MaxLength characters. Paths this long may not behave as expected. Run with -Force to override."
}

Set-ItemProperty -Path $Registry -Name PATH -Value $NewPath -Verbose
}
function Add-Signature {
<#PSScriptInfo

.VERSION 1.1.5

.GUID 9be6c147-e71b-44c4-b265-1b685692e411

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
This script will sign Powershell scripts with the availble code signing certificate.

.PARAMETER Path
This is the file or folder containing files to sign. If unspecified, it will run in the current folder.

.PARAMETER Filter
Use this to limit the search to spesific files. If unspesified, "*.ps1" will be used.

.PARAMETER Certificate
The certificate to use when signing. If unspesified, the first code signing certificate in the personal store will be used.

.PARAMETER Name
Used as the signing name when signing an executable file. If unspecified, will the current user's company.

.EXAMPLE
.\Sign-Script.ps1 -All
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript( { Test-Path -Path $_[0] })][array]$Path = (Get-Location),
  [string]$Filter = "*.ps*1",
  [ValidateScript( { Test-Certificate $_ })][System.Security.Cryptography.X509Certificates.X509Certificate]$Certificate = ((Get-ChildItem cert:currentuser\my\ -CodeSigningCert | Sort-Object NotBefore -Descending)[0]),
  [string]$Description = "Signed by " + (([ADSISearcher]"(&(objectCategory=User)(SAMAccountName=$env:username))").FindOne().Properties).company,
  [string]$SigntoolPath = "signtool.exe",
  [switch]$Append,
  [string]$Url,
  [string]$Algorithm = "SHA256"
)

Get-ChildItem -File -Path $Path -Filter $Filter | ForEach-Object {
  If (([System.IO.Path]::GetExtension($_.FullName) -like ".ps*1")) { Set-AuthenticodeSignature -FilePath $_.FullName -Certificate $Certificate }
  elseif ([System.IO.Path]::GetExtension($_.FullName) -eq ".exe" -or [System.IO.Path]::GetExtension($_.FullName) -eq ".cat") {
    $Arguments = @("sign")
    if ($Append) { $Arguments += "/as" }
    if ($Url) { $Arguments += "/du `"$Url`"" }
    if ($Description) { $Arguments += "/d `"$Description`"" }
    if ($Algorithm) { $Arguments += "/fd `"$Algorithm`"" }
    $Arguments += "/i `"$(($Certificate.Issuer -split ", " | ConvertFrom-StringData).CN)`"" # Issuer
    $Arguments += "/n `"$(($Certificate.SubjectName.Name -split ", " | ConvertFrom-StringData).CN)`"" # Subject Name
    $Arguments += "/sha1 $($Certificate.Thumbprint)"
    $Arguments += "`"$($_.FullName)`""
    Write-Verbose "Running $SigntoolPath $($Arguments -join " ")"
    If ($PSCmdlet.ShouldProcess($_.FullName, "Add-Signature using $($Certificate.Thumbprint)")) {
      Start-Process -NoNewWindow -Wait -FilePath $SigntoolPath -ArgumentList $Arguments
    }
  }
  else { Write-Error "We don't know how to handle this file type: ($([System.IO.Path]::GetExtension($_.Name))" }

}
}
function Backup-MySql {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 401b32f3-314a-47cf-b910-04c7f2492db2

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
This script will backup MySQL.

.PARAMETER mySqlData
Specifies the MySql Data folder. If unspecified C:\mySQL\data will be used.

.PARAMETER BackupLocation
Specifies the backup location. If unspecified C:\Local\MySqlBackups will be used.

.PARAMETER ConfigFile
Specifies the config file used to connect to MySql Data folder. If unspecified .\my.cnf will be used. Below is an example config file.
[client]
user="User"
password="password"

[mysqldump]
single-transaction
add-drop-database
add-drop-table

.PARAMETER mySqlDump
Specifies the MySqlDump.exe location. If unspecified C:\mySQL\bin\mysqldump.exe will be used.

.PARAMETER NoTrim
This script will prevent trimming the number of backups to the specified number.

.PARAMETER Copies
This is the number of files to keep in the folder. If unspecified, it will keep 10 copies.

.EXAMPLE
Backup-MySql
#>

param(
  [ValidateScript( { Test-Path -Path $_ -PathType Container })][string]$mySqlData = "C:\mySQL\data", #Patch to datatbases files directory
  [ValidateScript( { Test-Path -Path $_ -PathType Container })][string]$BackupLocation = "C:\Local\MySqlBackups", #Backup Directory
  [ValidateScript( { Test-Path -Path $_ -PathType Leaf })][string]$ConfigFile = ".\my.cnf", #Config file
  [ValidateScript( { Test-Path -Path $_ -PathType Leaf })][string]$mySqlDump = "C:\mySQL\bin\mysqldump.exe", #Patch to mysqldump.exe
  [switch]$NoTrim,
  [ValidateRange(1, [int]::MaxValue)][int]$Copies = 10 #Number of copies to keep
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Write-Verbose "Get only names of the databases folders"
$sqlDbDirList = Get-ChildItem -path $mySqlData | Where-Object { $_.PSIsContainer } | Select-Object Name

Write-Verbose "Starting Backup"
Foreach ($dbDir in $sqlDbDirList) {
  Write-Verbose "Starting on $dbDir"
  $dbBackupDir = $BackupLocation + "\" + $dbDir.Name
  Write-Verbose "Checking if $dbDir exits. Create if needed."
  If (!(Test-Path -path $dbBackupDir -PathType Container)) { New-Item -Path $dbBackupDir -ItemType Directory }
  $dbBackupFile = $dbBackupDir + "\" + $dbDir.Name + "_" + (Get-Date -format "yyyyMMdd_HHmmss")
  $sqlFile = $dbBackupFile + ".sql"
  Write-Verbose "Dumping to $sqlFile"
  & $mysqldump --defaults-extra-file=$ConfigFile -B $dbDir.Name -r $sqlFile
}

If (!$NoTrim) {
  Write-Verbose "Trimming backups. Keeping newest $Copies copies."
  Get-ChildItem $BackupLocation -Recurse | Where-Object { $_.PsIsContainer } | Sort-Object CreationTime -Descending | Select-Object -Skip $Copies | Remove-Item -Force
}
}
function Clear-AdminCount {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 5e42fd43-6940-434e-bb1c-aebb8ac32e44

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
This script will clear the AdminAcount for all user who have it set.

.LINK
https://docs.microsoft.com/en-us/windows/win32/adschema/a-admincount
#>
Get-ADUser -Filter { AdminCount -ne "0" } -Properties AdminCount | Set-ADUser -Clear AdminCount
}
function Clear-PrintQueue {
<#PSScriptInfo

.VERSION 1.0.4

.GUID 4656316e-19c9-4d45-a8cb-6c26f6548e22

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
This will clear all print jobs in the queue.

.DESCRIPTION
This will delete all *.shd and .spl file in %systemroot%\system32\spool\printers\ and restart the spooler service.

.PARAMETER ComputerName
This can be used to select a computer to clear the print jobs on. This option is required.

.EXAMPLE
Clear-PrintQueue -ComputerName PrintServer
#>
param(
  [string]$ComputerName
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

while (!$ComputerName) { $ComputerName = Read-Host -Prompt "Enter the Computer Name." }

Invoke-Command -ComputerName $ComputerName -ScriptBlock {
  Write-Verbose "Stopping spooler service."
  Stop-Service -Name spooler -Force
  Start-Sleep -Seconds 3
  Write-Verbose "Deleting *.shd"
  Get-ChildItem $env:SystemRoot\system32\spool\printers *.shd | ForEach-Object ($_) { Remove-Item $_.FullName }
  Write-Verbose "Deleting *.spl"
  Get-ChildItem $env:SystemRoot\system32\spool\printers *.spl | ForEach-Object ($_) { Remove-Item $_.FullName }
  Write-Verbose "Starting spooler service."
  Start-Service -Name spooler
  Write-Verbose "Finished."
}
}
function Connect-Office365 {
<#PSScriptInfo

.VERSION 2.1.3

.GUID ab066274-cee5-401d-99ff-1eeced8ca9af

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
This script will connect to various Office 365 services.

.DESCRIPTION
To connect to Azure Active Directory, you must first install "Microsoft Online Services Sign-in Assistant". This script will install the "MSOnline" module if required. Instructions are availible here (https://docs.microsoft.com/en-us/office365/enterprise/powershell/connect-to-office-365-powershell) and download here (https://www.microsoft.com/en-us/download/details.aspx?id=41950).

To connect to Sharepoint Online, you must first install "SharePoint Online Management Shell". Instructions are availible here (https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps) and download here (https://www.microsoft.com/en-ca/download/details.aspx?id=35588).

To connect to Skype for Business Online, you must first install "Skype for Business Online, Windows PowerShell Module". Instructions are availible here (https://docs.microsoft.com/en-us/office365/enterprise/powershell/manage-skype-for-business-online-with-office-365-powershell) and download here (https://www.microsoft.com/en-us/download/details.aspx?id=39366).

To connect to Exchange Online, you must first install "Microsoft.NET Framework 4.5" or later and then either the "Windows Management Framework 3.0" or the "Windows Management Framework 4.0". Instructions without MFA are availible here (https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/connect-to-exchange-online-powershell?view=exchange-ps). Instructions with MFA are availible here (https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/mfa-connect-to-exchange-online-powershell?view=exchange-ps)

.LINK
https://docs.microsoft.com/en-us/office365/enterprise/powershell/connect-to-office-365-powershell
.LINK
https://www.microsoft.com/en-us/download/details.aspx?id=41950
.LINK
https://docs.microsoft.com/en-us/office365/enterprise/powershell/manage-skype-for-business-online-with-office-365-powershell
.LINK
https://www.microsoft.com/en-us/download/details.aspx?id=39366

.LINK
https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps
.LINK
https://www.microsoft.com/en-ca/download/details.aspx?id=35588
.LINK
https://technet.microsoft.com/en-us/library/fp161372.aspx
.LINK
https://www.microsoft.com/en-us/download/details.aspx?id=35588
.LINK
https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/connect-to-exchange-online-powershell?view=exchange-ps
.LINK
https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/mfa-connect-to-exchange-online-powershell?view=exchange-ps

.PARAMETER Tenant
Specifies the Microsoft 365 tenant name.

.PARAMETER UPN
used to autofill the UPN for supported services.

.PARAMETER BasicAuth
Use basic auth.

.PARAMETER Credential
The credentials for basic auth.

.PARAMETER AzureAD
Connect to Azure Active Directory.

.PARAMETER MsolService
Connect to Microsoft Online (MSOL).

.PARAMETER SharepointOnline
Connects to Sharepoint Online.

.PARAMETER SkypeForBusinessOnline
Connects to Skype for Business.

.PARAMETER ExchangeOnline
Connect to Exchange Online.

.PARAMETER SecurityComplianceCenter
Connects to Security and Compliance Center

.PARAMETER Teams
Connects to Microsoft Teams.

.PARAMETER StaffHub
Connects to StaffHub.

.PARAMETER Disconnect
Disconnects from supported services
#>
param(
	[ValidatePattern("^[^.]+$")][string]$Tenant,
	[ValidatePattern("^([^@]+)@(.+)")][string]$UPN = ([ADSI]"LDAP://<SID=$([System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value)>").UserPrincipalName,
	[PSCredential]$Credential,
	[switch]$BasicAuth,
	[switch]$AzureAD,
	[switch]$MsolService,
	[switch]$SharepointOnline,
	[switch]$SkypeForBusinessOnline,
	[switch]$ExchangeOnline,
	[switch]$SecurityComplianceCenter,
	[switch]$Teams,
	[switch]$StaffHub,
	[switch]$Disconnect
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

While (-NOT $Tenant) { $Tenant = Read-Host -Prompt "Enter your Office 365 tennant. Do not include `".onmicrosoft.com`"" }
While (-NOT $UPN) { $UPN = Read-Host -Prompt "Enter your User Principal Name (UPN)" }

InstallModule -Name AzureAD #-AltName AzureADPreview
InstallModule -Name MSOnline
InstallModule -Name Microsoft.Online.SharePoint.PowerShell
InstallModule -Name ExchangeOnlineManagement
InstallModule -Name MicrosoftTeams
InstallModule -Name MicrosoftStaffHub

If ($BasicAuth -and (-not $Credential)) { $Credential = Get-Credential -UserName $UPN }

If ($Disconnect) {
	Write-Verbose "$me Disconnecting from all services."
	Remove-PSSession $sfboSession | Write-Verbose
	Remove-PSSession $exchangeSession | Write-Verbose
	Remove-PSSession $SccSession | Write-Verbose
	Disconnect-SPOService | Write-Verbose
}
Else {
	If ($AzureAD) {
		Write-Verbose "$me Connecting to AzureAD"
		If (Get-Module -Name AzureAdPreview -ListAvailable) { Import-Module AzureAdPreview | Write-Verbose }
		elseif (Get-Module -Name AzureAD -ListAvailable) { Import-Module AzureAD | Write-Verbose }
		else { Write-Error "$me Azure AD Module not available." }
		If ($BasicAuth) { Connect-AzureAD -Credential $Credential }
		Else { Connect-AzureAD -AccountId $UPN | Write-Verbose }
	}
	If ($MsolService) {
		Write-Verbose "$me Connecting to MsolService"
		If ($BasicAuth) { Connect-MsolService -Credential $Credential | Write-Verbose }
		Else { Connect-MsolService | Write-Verbose }
	}
	If ($SharepointOnline) {
		Write-Verbose "$me Connecting to Sharepoint Online"
		Requires Microsoft.Online.SharePoint.PowerShell
		If ($BasicAuth) { Connect-SPOService -Url https://$Tenant-admin.sharepoint.com -Credential $Credential | Write-Verbose }
		Else { Connect-SPOService -Url https://$Tenant-admin.sharepoint.com | Write-Verbose }
	}
	If ($SkypeForBusinessOnline) {
		Write-Verbose "$me Connecting to Skype For Business Online"
		Requires SkypeOnlineConnector
		If ($BasicAuth) { $sfboSession = New-CsOnlineSession -Credential $Credential | Write-Verbose }
		Else { $sfboSession = New-CsOnlineSession -UserName $UPN }
		Import-PSSession $sfboSession | Write-Verbose
	}
	If ($ExchangeOnline) {
		Write-Verbose "$me Connecting to Exchange Online"
		If (Get-Command Connect-ExchangeOnline -ErrorAction SilentlyContinue) {
			If ($BasicAuth) { Connect-ExchangeOnline -Credential $Credential | Write-Verbose }
			Else { Connect-ExchangeOnline -UserPrincipalName $UPN | Write-Verbose }
		}
		Else {
			If ($BasicAuth) {
				$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $Credential -Authentication "Basic" -AllowRedirection
				Import-PSSession $exchangeSession -DisableNameChecking | Write-Verbose
			}
			Else { Connect-ExchangeOnline -Credential $Credential | Write-Verbose }
		}
	}
	If ($SecurityComplianceCenter) {
		If ($BasicAuth) {
			$SccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $Credential -Authentication "Basic" -AllowRedirection
			Import-PSSession $SccSession -Prefix cc | Write-Verbose
		}
		Else {
			Write-Verbose "$me Connecting to Security and Compliance Center"
			Write-Warning "$me Cannot connect to Security  Compliance Center multi-factor authentication in this session. See for more information: https://docs.microsoft.com/powershell/exchange/office-365-scc/connect-to-scc-powershell/mfa-connect-to-scc-powershell?view=exchange-ps"
			Connect-IPPSSession -UserPrincipalName $UPN
		}
	}
	If ($Teams) {
		Write-Verbose "$me Connecting to Teams"
		Import-Module MicrosoftTeams | Write-Verbose
		If ($BasicAuth) { Connect-MicrosoftTeams $Credential | Write-Verbose }
		Else { Connect-MicrosoftTeams -AccountId $UPN | Write-Verbose }
	}
	If ($StaffHub -OR $Settings.Services.StaffHub) {
		Write-Verbose "$me Connecting to StaffHub"
		If ($BasicAuth) { Connect-MicrosoftTeams $Credential | Write-Verbose	}
		Else { Connect-StaffHub | Write-Verbose }
	}
}
}
function Convert-Image {
<#PSScriptInfo

.VERSION 1.0.6

.GUID 717cb6fa-eb4d-4440-95e3-f00940faa21e

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
This script will resize an image using ImageMagick.

.LINK
https://imagemagick.org/

.PARAMETER Path
This is the file or folder containing images to resize. If unspecified, it will run in the current folder.

.PARAMETER Dimensions
The dimension to which the image should be resized in WxH. You must spesify either width or height.

.PARAMETER Suffix
The text to appear after the resized file.

.PARAMETER Prefix
The text to appear before the resized file.

.PARAMETER OutExtension
The file extension to use for the converted image. If unspecified, the existing extension will will be used.

.PARAMETER FileSize
The file size of the final file. This paramater only functions when outputting to the JPEG format.

.PARAMETER Filter
Use this to limit the search to spesific files.

.PARAMETER Force
Use this paramater to bypass the check when overwriting an existing file.

.PARAMETER Return
The parameter will return the Name, FullName, InputName, InputFullName for each file.

.EXAMPLE
Convert-Image -Dimensions 1920x1080 -Suffix _1080p

.EXAMPLE
Convert-Image -Path C:\Images -Dimensions 1920x1080 -Suffix _1080p -Prefix Resized_ -OutExtension jpeg -FileSize 750KB -Filter "*.jpg" -Force -Return
Name                          FullName
----                          --------
Resized_Image (1)_1080p.jpeg  C:\Images\Resized_Image (1)_1080p.jpeg
Resized_Image (2)_1080p.jpeg  C:\Images\Resized_Image (2)_1080p.jpeg
Resized_Image (3)_1080p.jpeg  C:\Images\Resized_Image (3)_1080p.jpeg
Resized_Image (4)_1080p.jpeg  C:\Images\Resized_Image (4)_1080p.jpeg
Resized_Image (5)_1080p.jpeg  C:\Images\Resized_Image (5)_1080p.jpeg
Resized_Image (6)_1080p.jpeg  C:\Images\Resized_Image (6)_1080p.jpeg
Resized_Image (7)_1080p.jpeg  C:\Images\Resized_Image (7)_1080p.jpeg
Resized_Image (8)_1080p.jpeg  C:\Images\Resized_Image (8)_1080p.jpeg
Resized_Image (9)_1080p.jpeg  C:\Images\Resized_Image (9)_1080p.jpeg

.LINK
https://imagemagick.org/script/command-line-processing.php#geometry
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
	[string]$Filter,
	[ValidateScript( { ( (Test-Path $_) -and (-not $([bool]([System.Uri]$_).IsUnc)) ) } )][array]$Path = (Get-ChildItem -File -Filter $Filter),
	[ValidateScript( { Test-Path $_ })][string]$OutPath = (Get-Location),
	[string][ValidatePattern("((((\d+%){1,2})|((\d+)?x\d+(\^|!|<|>|\^)*?)|(\d+x?(\d+)?(\^|!|<|>|\^)*?)|(\d+@)|(\d+:\d+))$|^$)")]$Dimensions,
	[string]$Suffix,
	[string]$Prefix,
	[switch]$Trim,
	[ValidateSet("NorthWest", "North", "NorthEast", "West", "Center", "East", "SouthWest", "South", "SouthEast")][string]$Gravity = "Center",
	[ValidateSet("Crop", "Pad", "None", $null)][string]$Mode = "Crop",
	[string]$ColorSpace,
	[string][ValidatePattern("(^\..+$|^$)")]$OutExtension,
	[string]$FileSize,
	[switch]$Force,
	[ValidateScript( { Test-Path -Path $_ -PathType Leaf })][string]$Magick = ((Get-Command magick).Source)
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

If (!(Get-Command magick -ErrorAction SilentlyContinue)) {
	Write-Error "magick.exe is not available in your PATH."
	Break
}

[System.Collections.ArrayList]$Results = @()

ForEach ($Image in $Path) {
	$Image = Get-ChildItem $Image
	if ([bool]([System.Uri]$Image.FullName).IsUnc) { throw "Path is not local." }
	$count++ ; Progress -Index $count -Total $Path.count -Activity "Resizing images." -Name $Image.Name

	$Arguments = $null
	If (!$OutExtension) { $ImageOutExtension = [System.IO.Path]::GetExtension($Image.Name) } #If OutExtension not set, use current
	Else { $ImageOutExtension = $OutExtension } #Otherwise use spesified extension
	$OutName = $Prefix + [io.path]::GetFileNameWithoutExtension($Image.Name) + $Suffix + $ImageOutExtension #Out file name
	$Out = Join-Path $OutPath $OutName #Out full path
	If ($PSCmdlet.ShouldProcess("$OutName", "Convert-Image")) {
		If (Test-Path $Out) {
			If ($Force) {}
			ElseIf (!($PSCmdlet.ShouldContinue("$Out already exists. Overwrite?", ""))) { Break }
		}
		$Arguments += '"' + $Image.FullName + '" '
		If ($Dimensions) {
			If ($Trim) { $Arguments += '-trim ' }
			$Arguments += '-resize "' + $Dimensions + '" '
			$Arguments += '-gravity "' + $Gravity + '" '
			If ($Mode -eq "Crop") { $Arguments += '-crop "' + $Dimensions + '+0+0" ' }
			ElseIf ($Mode -eq "Pad") { $Arguments += '-background none -extent "' + $Dimensions + '+0+0" ' }
		}

		If ($FileSize -And ($ImageOutExtension -ne ".jpg") -And ($ImageOutExtension -ne ".jpeg")) {
			Write-Warning "FileSize paramater is only valid for JPEG images. $OutName will ignore this parameter."
		}
		ElseIf ($FileSize) { $Arguments += '-define jpeg:extent=' + $FileSize + ' ' }
		$Arguments += '+repage '
		If ($ColorSpace) { $Arguments += '-colorspace ' + $ColorSpace + ' ' }
		$Arguments += '"' + $Out + '"'

		Write-Verbose $Arguments
		Start-Process -FilePath $Magick -ArgumentList $Arguments -NoNewWindow -Wait
		$Result = [PSCustomObject]@{
			Arguments     = $Arguments
			Name          = $OutName
			FullName      = $Out
			InputName     = Split-Path -Path $Image.FullName -Leaf
			InputFullName	= $Image.FullName
		}
		$Results += $Result
	}
}
Return $Results
}
function ConvertTo-EndpointCertificate {
<#PSScriptInfo

.VERSION 2.0.2

.GUID c3469cd9-dc7e-4a56-88f2-d896c9baeb21

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
    This script will convert a PFX certificate for use with various services.

    .DESCRIPTION
    This script will convert a PFX certificate for use with various services. If will also provide instructions for any system that has spesific requirements for setup. This script requires & .\openssl.exe  to be available on the computer.

    .PARAMETER Path
    This is the certificate file which will be converted. This option is required.

    .PARAMETER Prefix
    This string appears before the filename for each converted certificate. If unspesified, will use the name if the file being resized.
  #>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateScript( { Test-Path $_ })][string]$Path = (Get-Location),
  [ValidateSet("Windows", "AlwaysUp", "CiscoSG300", "PaperCutMobility", "Spiceworks", "UnifiCloudKey", "UnifiCore", "USG", "IISManagement", "3CX")][array]$Services,
  [string]$Prefix,
  [string]$Suffix,
  [string]$Filter = "*.pfx",
  $Certificates = (Get-ChildItem -File -Path $Path -Filter $Filter)
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

ForEach ($Certificate in $Certificates) {
  $count++ ; Progress -Index $count -Total @($Certificates).count -Activity "Resizing images." -Name $Certificate.Name
  $Password = Read-Host "Enter Password"

  If ($PSCmdlet.ShouldProcess("$OutName", "Convert-Certificate")) {
    $Prefix = $Prefix + [System.IO.Path]::GetFileNameWithoutExtension($Certificate.FullName) + "_"
    $Path = $Certificate.FullName

    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -out "$Prefix`PEM.txt" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nocerts -out "$Prefix`PEM_Key.txt" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nokeys -out "$Prefix`PEM_Cert.txt" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nokeys -out "$Prefix`PEM_Cert_NoNodes.txt"
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nokeys -out "$Prefix`PEM_Cert.cer" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -export -in "$Prefix`PEM_Cert.txt" -inkey "$Prefix`PEM_Key.txt" -certfile "$Prefix`PEM_Cert.txt" -out "$Prefix`Unifi.p12" -name unifi -password pass:aircontrolenterprise

    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nocerts -nodes | openssl.exe  rsa -out "$Prefix`RSA_Key.txt"
    openssl.exe rsa  -passin "pass:$Password" -in "$Prefix`PEM.txt" -pubout -out "$Prefix`RSA_Pub.txt"

    if ($Services -contains "Windows") {
      Write-Output "Windows: Run the following commands.
`$mypwd = Get-Credential -UserName 'Enter password below' -Message 'Enter password below'
`nImport-PfxCertificate -FilePath $($Certificate.FullName) -CertStoreLocation Cert:\LocalMachine\My -Password `$mypwd.Password
"
    }
    if ($Services -contains "IISManagement") {
      Write-Verbose "Instructions from https://support.microsoft.com/en-us/help/3206898/enabling-iis-manager-and-web-deploy-after-disabling-ssl3-and-tls-1-0"
      Write-Output "IIS Management: Add PFX certificate to Windows and run the following commanges in Powershell
`$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {`$_.subject -like `"*Common Name*`"} | Where-Object {`$_.NotAfter -gt (Get-Date)} | Select-Object -ExpandProperty Thumbprint
Import-Module WebAdministration
Remove-Item -Path IIS:\SslBindings\0.0.0.0!8172
Get-Item -Path `"cert:\localmachine\my\`$cert`" | New-Item -Force -Path IIS:\SslBindings\0.0.0.0!8172
"
    }
    if ($Services -contains "AlwaysUp") {
      Write-Output "Always Up: Copy files to C:\Program Files (x86)\AlwaysUpWebService\certificates`n"
      New-Item -Force -Type Directory -Name AlwaysUp | Out-Null
      Copy-Item "$Prefix`PEM_Cert.txt" AlwaysUp\ctc-self-signed-certificate-exp-2024.pem
      Copy-Item "$Prefix`PEM_Key.txt" AlwaysUp\ctc-self-signed-certificate-exp-2024-key.pem

    }
    if ($Services -contains "CiscoSG300") {
      Write-Output "Cisco SG300: Use RSA Key, RSA Pub, and PEM Cert
For RSA Pub, remove the first 32 characters and change BEGIN/END PUBLIC KEY to BEGIN/END RSA PUBLIC KEY. Use only the primary certificate, not the entire chain. When importing, edit HTML to allow more than 2046 characters in certificate feild.
Instructions from: https://severehalestorm.net/?p=54
"
      New-Item -Force -Type Directory -Name CiscoSG300 | Out-Null
      Copy-Item "$Prefix`PEM_Cert.txt" CiscoSG300\Cert.txt
      Copy-Item "$Prefix`RSA_Pub.txt" CiscoSG300\RSA_Pub.txt
      Copy-Item "$Prefix`RSA_Key.txt" CiscoSG300\RSA_Key.txt
    }
    if ($Services -contains "PaperCutMobility") {
      Write-Output "PaperCut Mobility: `n"
      New-Item -Force -Type Directory -Name PaperCutMobility | Out-Null
      Copy-Item "$Prefix`PEM_Cert.txt" PaperCutMobility\tls.cer
      Copy-Item "$Prefix`PEM_Key.txt" PaperCutMobility\tls.pem
    }
    if ($Services -contains "Spiceworks") {
      Write-Output "Spiceworks: Copy files to C:\Program Files (x86)\Spiceworks\httpd\ssl`n"
      New-Item -Force -Type Directory -Name Spiceworks | Out-Null
      Copy-Item "$Prefix`PEM_Cert.txt" Spiceworks\ssl-cert.pem
      Copy-Item "$Prefix`PEM_Key.txt" Spiceworks\ssl-private-key.pem
    }
    if ($Services -contains "UnifiCloudKey") {
      Write-Verbose "Instructions from here: https://community.ubnt.com/t5/UniFi-Wireless/HOWTO-Install-Signed-SSL-Certificate-on-Cloudkey-and-use-for/td-p/1977049"
      Write-Output "Unifi Cloud Key: Copy files to '/etc/ssl/private' on the Cloud Key and run the following commands:
cd /etc/ssl/private
keytool -importkeystore -srckeystore unifi.p12 -srcstoretype PKCS12 -srcstorepass aircontrolenterprise -destkeystore unifi.keystore.jks -storepass aircontrolenterprise
keytool -list -v -keystore unifi.keystore.jks
tar cf cert.tar cloudkey.crt cloudkey.key unifi.keystore.jks
tar tvf cert.tar
chown root:ssl-cert cloudkey.crt cloudkey.key unifi.keystore.jks cert.tar
chmod 640 cloudkey.crt cloudkey.key unifi.keystore.jks cert.tar
nginx -t
/etc/init.d/nginx restart; /etc/init.d/unifi restart
"
      New-Item -Force -Type Directory -Name UnifiCloudKey | Out-Null
      Copy-Item "$Prefix`PEM_Cert.txt" UnifiCloudKey\cloudkey.crt
      Copy-Item "$Prefix`PEM_Key.txt" UnifiCloudKey\cloudkey.key
      Copy-Item "$Prefix``unifi.p12" UnifiCloudKey\unifi.p12
    }
    if ($Services -contains "UnifiCore") {
      Write-Output "Unifi Cloud Key: Copy files to '/data/unifi-core/config' on the Cloud Key and run the following commands.
systemctl restart unifi-core.service
"
      New-Item -Force -Type Directory -Name UnifiCore | Out-Null
      Copy-Item "$Prefix`PEM_Cert_NoNodes.txt" UnifiCore\unifi-core.crt
      Copy-Item "$Prefix`RSA_Key.txt" UnifiCore\unifi-core.key
    }
    if ($Services -contains "USG") {
      Write-Output "Edge Router or USG: Copy the PEM file to '/etc/lighttpd/server.pem' and run the following commands.
kill -SIGINT `$(cat /var/run/lighttpd.pid)
/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
"
      New-Item -Force -Type Directory -Name USG | Out-Null
      Copy-Item "$Prefix`PEM.txt" USG\server.pem
    }
    if ($Services -contains "3CX") {
      Write-Verbose "Instructions from: https://help.3cx.com/kb/en-us/33-installation/148-how-can-i-replace-the-ssl-certificates-for-a-custom-domain"
      Write-Output "3CX Windows: Rename to match existing files, then copy to C:\Program Files\3CX Phone System\Bin\nginx\conf\Instance1 and restart the `'3CX Phone System Nginx Webserver`' service.
      Restart-Service -DisplayName `"3CX PhoneSystem Nginx Server`"
"
      New-Item -Force -Type Directory -Name 3CX | Out-Null
      Copy-Item "$Prefix`PEM_Cert.txt" 3CX\YOURFQDN-crt.pem
      Copy-Item "$Prefix`PEM_Key.txt" 3CX\YOURFQDN-key.pem
    }
    <#
          RSA
          RSA SG300
          RSA Pub
          pfx
          PEM
          p7b
          DER
          B64
          B64 Chain
          #>
  }
}
}
function ConvertTo-OutputImages {
<#PSScriptInfo

.VERSION 1.1.6

.GUID 5c162a3a-dc4b-43d5-af07-7991ae41d03b

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
This script will resize the spesified logos, wordmarks and banner images to the spesifications of various third party services. It will pull data from a json file.

.PARAMETER Path
This is the file or folder containing images to resize. If unspecified, it will run in the current folder.

.PARAMETER Prefix
The text to appear before the resized file.

.PARAMETER All
If specified, images will be created for all services, instead of just the common ones.

.EXAMPLE
ConvertTo-OutputImages
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
	[ValidateSet("Banner", "Logo", "Brandmark")][string]$Type = "Banner",
	[ValidateScript( { Test-Path $_ })][string]$Json,
	[string]$Filter,
	[ValidateScript( { ( (Test-Path $_) -and (-not $([bool]([System.Uri]$_).IsUnc)) ) } )][array]$Path = (Get-ChildItem -File -Filter $Filter),
	[ValidateScript( { Test-Path $_ })][string]$OutPath = (Get-Location),
	[switch]$Force,
	[string]$Destination,
	[string]$Prefix,
	[switch]$All
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

if (-not $Json) { throw "Json file not found." }
ForEach ($Image in $Path) {
	$Image = Get-ChildItem $Image
	$Formats = (Get-Content -Path $Json | ConvertFrom-Json).$Type
	$count1++; $count2 = 0
	If ($Destination) { $Formats = $Formats | Where-Object Destination -Contains $Destination }
	$Formats | ForEach-Object {
		$count2++; Progress -Index $count2 -Total ([math]::Max(1, $Formats.count)) -Activity "Resizing $count1 of $($Path.count): $($Image.Name)" -Name $_.Name
		If ($PSCmdlet.ShouldProcess("$($Image.FullName) > $($_.Name)", "Convert-Image")) {
			Convert-Image -Force:$Force -Path $Image.FullName -OutPath $OutPath -Dimensions $_.Dimensions  -Suffix ("_" + $_.Name) -Trim:$_.Trim -OutExtension $_.OutExtension -FileSize $_.FileSize -Mode $_.Mode
		}
	}
}
}
function Disable-NetbiosTcpIp {
<#PSScriptInfo

.VERSION 1.1.1

.GUID 460f5844-8755-46df-8fb5-a12fa88bf413

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
This script will disable Netbios TCP/IP on all interfaces.

.DESCRIPTION
This script will disable Netbios TCP/IP on all interfaces.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param ()

function ParseGuid {
    param (
        [string]$String,
        [ValidateSet("N", "D", "B", "P")][string]$Format = "B"
    )
    $Guid = [System.Guid]::empty
    If ([System.Guid]::TryParse($String, [System.Management.Automation.PSReference]$Guid)) {
        $Guid = [System.Guid]::Parse($String)
    }
    Else {
        $Guid = $null
    }
    return $Guid.ToString($Format)
}
If (!(Test-Admin -Warn)) { Break }
$Interfaces = Get-ChildItem "HKLM:SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces"
$Interfaces | ForEach-Object {
    $Path = $_.PSPath
    $Guid = ParseGuid $Path.Substring($Path.Length - 38)
    $count++ ; Progress -Index $count -Total $Interfaces.count -Activity "Disabling Netbios TCP/IP" -Name (Get-NetAdapter | Where-Object InterfaceGuid -eq ($Guid)).name
    Set-ItemProperty -Path $Path -Name NetbiosOptions -Value 2
}
}
function Disable-SelfServicePurchase {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 1af7209d-520d-4d2c-90f4-de3bc5cf2f48

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
This script will disallows self service purchases in Microsoft 365.

.LINK
https://github.com/MicrosoftDocs/microsoft-365-docs/blob/public/microsoft-365/commerce/subscriptions/allowselfservicepurchase-powershell.md
#>
Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase | ForEach-Object { Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductId $_.ProductID -Enabled $false }
}
function Enable-LicenseOptions {
<#PSScriptInfo

.VERSION 1.3.2

.GUID 61ab8232-0c28-495f-9e44-3c511c2634ea

.AUTHOR Jason Cook & Roman Zarka | Microsoft Services

.COMPANYNAME ***REMOVED*** & Microsoft Services

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
This script enable the spesified license options in Microsoft 365.

.PARAMETER Return
Whether to return what options have been set. If unspesified, this is False.

.PARAMETER AccountSkuId
Account SKU ID to run against.

.PARAMETER KeepEnabled
Whether to keep enabled services if nothing is spesified.

.PARAMETER Users
Array of users to run the command against. If unspesified, will run against all licensed users.

.PARAMETER NoForms
An array of users which will have Forms disabled.

.PARAMETER NoFlow
An array of users which will have Flow disabled.

.PARAMETER NoPowerApps
An array of users which will have PowerApps disabled.

.PARAMETER NoPlanner
An array of users which will have Planner disabled.

.PARAMETER NoOfficeOnline
An array of users which will have Office Online disabled.

.PARAMETER NoSharepoint
An array of users which will have Sharepoint disabled.

.PARAMETER NoExchange
An array of users which will have Exchange disabled.

.EXAMPLE
Enable-LicenseOptions

.NOTES
Credits    : Created by Roman Zarka at Microsoft. Available under Creative Commons Attribution 4.0 International License.

.LINK
https://blogs.technet.microsoft.com/zarkatech/2012/12/05/bulk-enable-office-365-license-options/

.LINK
https://docs.microsoft.com/en-us/microsoft-365/enterprise/assign-licenses-to-user-accounts-with-microsoft-365-powershell?view=o365-worldwide

.LINK
https://github.com/MicrosoftDocs/microsoft-365-docs/blob/public/LICENSE
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [switch]$Return,
  [string]$AccountSkuId = "STANDARDWOFFPACK",
  [switch]$KeepEnabled = $False,
  [switch]$Assign = $False,
  [array]$Users = (Get-MsolUser -All | Where-Object { $_.IsLicensed -eq $true } | Select-Object UserPrincipalName | Sort-Object UserPrincipalName),
  [array]$NoForms = (Get-ADGroupMember -Recursive -Identity "Office 365-No Forms" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoStream = (Get-ADGroupMember -Recursive -Identity "Office 365-No Stream" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoFlow = (Get-ADGroupMember -Recursive -Identity "Office 365-No Flow" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoPowerApps = (Get-ADGroupMember -Recursive -Identity "Office 365-No PowerApps" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoPlanner = (Get-ADGroupMember -Recursive -Identity "Office 365-No Planner" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoTeams = (Get-ADGroupMember -Recursive -Identity "Office 365-No Teams" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoOfficeOnline = (Get-ADGroupMember -Recursive -Identity "Office 365-No Office Online" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoSharepoint = (Get-ADGroupMember -Recursive -Identity "Office 365-No Sharepoint" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName),
  [array]$NoExchange = (Get-ADGroupMember -Recursive -Identity "Office 365-No Exchange" | ForEach-Object { Get-ADUser -Identity $_.SamAccountName } | Select-Object userPrincipalName)
)

[System.Collections.ArrayList]$Results = @()
$count = 1; $PercentComplete = 0;
ForEach ($User in $Users) {
  #Progress message
  $ActivityMessage = "Setting available licence data for users. Please wait..."
  $StatusMessage = ("Processing {0} of {1}: {2}" -f $count, @($Users).count, $User.UserPrincipalName.ToString())
  $PercentComplete = ($count / @($Users).count * 100)
  Write-Progress -Activity $ActivityMessage -Status $StatusMessage -PercentComplete $PercentComplete
  $count++

  # Mark all services as disabled.
  # Services.
  <#
Name            SKU                     Notes
Search          MICROSOFT_SEARCH        This app is assigned at the organization level. It can't be assigned per user.
RMS             RMS_S_BASIC             This app is assigned at the organization level. It can't be assigned per user.
Whiteboard      WHITEBOARD_PLAN1
Todo            BPOS_S_TODO_1
Forms           FORMS_PLAN_E1
Stream          STREAM_O365_E1
Staffhub        Deskless
Power Automate  FLOW_O365_P1
Power Apps      POWERAPPS_O365_P1
Planner         PROJECTWORKMANAGEMENT
Teams           TEAMS1
Sway            SWAY
MDM             INTUNE_O365            This app is assigned at the organization level. It can't be assigned per user.
Yammer          YAMMER_ENTERPRISE
Office Online   SHAREPOINTWAC
Skyper          MCOSTANDARD
Sharepoint      SHAREPOINTSTANDARD
Exchange        EXCHANGE_S_STANDARD
#>

  $Services = @{}
  If ($KeepEnabled) {
    (Get-MsolUser -UserPrincipalName $User.UserPrincipalName).Licenses | Where-Object AccountSkuId -like "*:$AccountSkuId" | ForEach-Object {

      ForEach-Object {
        # Mark currently enabled licenses services as enabled.
        # Comment out the lines for services you wish to force disable.
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "WHITEBOARD_PLAN1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Whiteboard = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "BPOS_S_TODO_1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Todo = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "FORMS_PLAN_E1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Forms = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "STREAM_O365_E1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Stream = $True }
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "Deskless" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.StaffHub = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "FLOW_O365_P1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Flow = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "POWERAPPS_O365_P1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.PowerApps = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "PROJECTWORKMANAGEMENT" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Planner = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "TEAMS1" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Teams = $True }
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "SWAY" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Sway = $True }
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "YAMMER_ENTERPRISE" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Yammer = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "SHAREPOINTWAC" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.OfficeOnline = $True }
        # If ($_.ServiceStatus.ServicePlan.ServiceName -eq "MCOSTANDARD" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Skype = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "SHAREPOINTSTANDARD" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Sharepoint = $True }
        If ($_.ServiceStatus.ServicePlan.ServiceName -eq "EXCHANGE_S_STANDARD" -and $_.ServiceStatus.ProvisioningStatus -ne "Disabled") { $Services.Exchange = $True }
      }
    }
  }

  # Services you wish to enable by default.
  $Services.Todo = $True
  $Services.Forms = $True
  $Services.Stream = $True
  $Services.Flow = $True
  $Services.PowerApps = $True
  $Services.Planner = $True
  $Services.Teams = $True
  $Services.OfficeOnline = $True
  $Services.Sharepoint = $True
  $Services.Exchange = $True

  # Disabling services for members of corrosponding group.
  $SearchUpn = "*" + $User.UserPrincipalName + "*"
  If ($NoForms -like $SearchUpn) { $Services.Forms = $False }
  If ($NoStream -like $SearchUpn) { $Services.Stream = $False }
  If ($NoFlow -like $SearchUpn) { $Services.Flow = $False }
  If ($NoPowerApps -like $SearchUpn) { $Services.PowerApps = $False }
  If ($NoPlanner -like $SearchUpn) { $Services.Planner = $False }
  If ($NoTeams -like $SearchUpn) { $Services.Teams = $False }
  If ($NoOfficeOnline -like $SearchUpn) { $Services.OfficeOnline = $False }
  If ($NoSharepoint -like $SearchUpn) { $Services.Sharepoint = $False }
  If ($NoExchange -like $SearchUpn) { $Services.Exchange = $False }

  # Disable services still marked as disabled
  $DisabledOptions = @()
  If (!$Services.Whiteboard) { $DisabledOptions += "WHITEBOARD_PLAN1" }
  If (!$Services.Todo) { $DisabledOptions += "BPOS_S_TODO_1" }
  If (!$Services.Forms) { $DisabledOptions += "FORMS_PLAN_E1" }
  If (!$Services.Stream) { $DisabledOptions += "STREAM_O365_E1" }
  If (!$Services.StaffHub) { $DisabledOptions += "Deskless" }
  If (!$Services.Flow) { $DisabledOptions += "FLOW_O365_P1" }
  If (!$Services.PowerApps) { $DisabledOptions += "POWERAPPS_O365_P1" }
  If (!$Services.Planner) { $DisabledOptions += "PROJECTWORKMANAGEMENT" }
  If (!$Services.Teams) { $DisabledOptions += "TEAMS1" }
  If (!$Services.Sway) { $DisabledOptions += "SWAY" }
  If (!$Services.Intune) { $DisabledOptions += "INTUNE_O365" }
  If (!$Services.Yammer) { $DisabledOptions += "YAMMER_ENTERPRISE" }
  If (!$Services.OfficeOnline) { $DisabledOptions += "SHAREPOINTWAC" }
  If (!$Services.Skype) { $DisabledOptions += "MCOSTANDARD" }
  If (!$Services.Sharepoint) { $DisabledOptions += "SHAREPOINTSTANDARD" }
  If (!$Services.Exchange) { $DisabledOptions += "EXCHANGE_S_STANDARD" }

  if ($PSCmdlet.ShouldProcess($User.UserPrincipalName, "Enable-LicenseOptions")) {
    If ($Assign) {
      Set-MsolUser -UserPrincipalName $User.UserPrincipalName -UsageLocation CA
      Start-Sleep -Seconds 5
      $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
      $License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value ((Get-AzureADSubscribedSku | Where-Object SkuPartNumber -eq STANDARDWOFFPACK).SkuPartNumber) -EQ).SkuID
      $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
      $LicensesToAssign.AddLicenses = $License
      Set-AzureADUserLicense -ObjectId $User.UserPrincipalName -AssignedLicenses $LicensesToAssign
      Start-Sleep -Seconds 2
    }
    $LicenseOptions = New-MsolLicenseOptions -AccountSkuId ((Get-MsolAccountSku | Where-Object AccountSkuId -like *$AccountSkuId).AccountSkuId) -DisabledPlans $DisabledOptions
    Set-MsolUserLicense -User $User.UserPrincipalName -LicenseOptions $LicenseOptions
  }
  $Result = [PSCustomObject]@{
    Upn          = $User.UserPrincipalName
    Whiteboard   = $Services.Whiteboard
    Todo         = $Services.Todo
    Forms        = $Services.Forms
    Stream       = $Services.Stream
    StaffHub     = $Services.StaffHub
    Flow         = $Services.Flow
    PowerApps    = $Services.PowerApps
    Planner      = $Services.Planner
    Teams        = $Services.Teams
    Sway         = $Services.Sway
    Intune       = $Services.Intune
    Yammer       = $Services.Yammer
    OfficeOnline = $Services.OfficeOnline
    Skype        = $Services.Skype
    Sharepoint   = $Services.Sharepoint
    Exchange     = $Services.Exchange
  }
  $Results += $Result
}
If ($Return) { Return $Results }
}
function Enable-NestedVm {
<#PSScriptInfo

.VERSION 1.3.2

.GUID 528bfa6d-27a7-4612-9092-faae014e3917

.AUTHOR Jason Cook Drew Cross | Microsoft Services

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
Checks VM for nesting comatability and configures if not properly setup.

.PARAMETER VMName
Which VM should nesting be enabled for?

.EXAMPLE
Enable-NestedVm -VmName MyVM

.NOTES
Credits    : Created by Drew Cross at Microsoft. Available under Creative Commons Attribution 4.0 International License.

.LINK
https://github.com/MicrosoftDocs/Virtualization-Documentation/blob/main/hyperv-tools/Nested/Enable-NestedVm.ps1

.LINK
https://github.com/MicrosoftDocs/Virtualization-Documentation/blob/main/LICENSE
#>

param([string]$vmName)

if ([string]::IsNullOrEmpty($vmName)) {
    Write-Host "No VM name passed"
    Exit;
}

$4GB = 4294967296

$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);

$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;

if ($myWindowsPrincipal.IsInRole($adminRole)) {
    # We are running as an administrator, so change the title and background colour to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)";

}
else {
    # We are not running as an administrator, so relaunch as administrator

    # Create a new process object that starts PowerShell
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter with added scope and support for scripts with spaces in it's path
    $newProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess) | Out-Null;

    # Exit from the current, unelevated, process
    Exit;
}

$vm = Get-VM -Name $vmName

$vmInfo = New-Object PSObject

Add-Member -InputObject $vmInfo NoteProperty -Name "ExposeVirtualizationExtensions" -Value $false
Add-Member -InputObject $vmInfo NoteProperty -Name "DynamicMemoryEnabled" -Value $vm.DynamicMemoryEnabled
Add-Member -InputObject $vmInfo NoteProperty -Name "SnapshotEnabled" -Value $false
Add-Member -InputObject $vmInfo NoteProperty -Name "State" -Value $vm.State
Add-Member -InputObject $vmInfo NoteProperty -Name "MacAddressSpoofing" -Value ((Get-VmNetworkAdapter -VmName $vmName).MacAddressSpoofing)
Add-Member -InputObject $vmInfo NoteProperty -Name "MemorySize" -Value (Get-VMMemory -VmName $vmName).Startup

$vmInfo.ExposeVirtualizationExtensions = (Get-VMProcessor -VM $vm).ExposeVirtualizationExtensions

Write-Host "This script will set the following for $vmName in order to enable nesting:"
$prompt = $false;

if ($vmInfo.State -eq 'Saved') {
    Write-Host "\tSaved state will be removed"
    $prompt = $true
}
if ($vmInfo.State -ne 'Off' -or $vmInfo.State -eq 'Saved') {
    Write-Host "Vm State:" $vmInfo.State
    Write-Host "    $vmName will be turned off"
    $prompt = $true
}
if ($vmInfo.ExposeVirtualizationExtensions -eq $false) {
    Write-Host "    Virtualization extensions will be enabled"
    $prompt = $true
}
if ($vmInfo.DynamicMemoryEnabled -eq $true) {
    Write-Host "    Dynamic memory will be disabled"
    $prompt = $true
}
if ($vmInfo.MacAddressSpoofing -eq 'Off') {
    Write-Host "    Optionally enable mac address spoofing"
    $prompt = $true
}
if ($vmInfo.MemorySize -lt $4GB) {
    Write-Host "    Optionally set vm memory to 4GB"
    $prompt = $true
}

if (-not $prompt) {
    Write-Host "    None, vm is already setup for nesting"
    Exit;
}

Write-Host "Input Y to accept or N to cancel:" -NoNewline

$char = Read-Host

while (-not ($char.StartsWith('Y') -or $char.StartsWith('N'))) {
    Write-Host "Invalid Input, Y or N"
    $char = Read-Host
}

if ($char.StartsWith('Y')) {
    if ($vmInfo.State -eq 'Saved') {
        Remove-VMSavedState -VMName $vmName
    }
    if ($vmInfo.State -ne 'Off' -or $vmInfo.State -eq 'Saved') {
        Stop-VM -VMName $vmName
    }
    if ($vmInfo.ExposeVirtualizationExtensions -eq $false) {
        Set-VMProcessor -VMName $vmName -ExposeVirtualizationExtensions $true
    }
    if ($vmInfo.DynamicMemoryEnabled -eq $true) {
        Set-VMMemory -VMName $vmName -DynamicMemoryEnabled $false
    }

    # Optionally turn on mac spoofing
    if ($vmInfo.MacAddressSpoofing -eq 'Off') {
        Write-Host "Mac Address Spoofing isn't enabled (nested guests won't have network)." -ForegroundColor Yellow
        Write-Host "Would you like to enable MAC address spoofing? (Y/N)" -NoNewline
        $Read = Read-Host

        if ($Read -eq 'Y') {
            Set-VMNetworkAdapter -VMName $vmName -MacAddressSpoofing on
        }
        else {
            Write-Host "Not enabling Mac address spoofing."
        }

    }

    if ($vmInfo.MemorySize -lt $4GB) {
        Write-Host "VM memory is set less than 4GB, without 4GB or more, you may not be able to start VMs." -ForegroundColor Yellow
        Write-Host "Would you like to set Vm memory to 4GB? (Y/N)" -NoNewline
        $Read = Read-Host

        if ($Read -eq 'Y') {
            Set-VMMemory -VMName $vmName -StartupBytes $4GB
        }
        else {
            Write-Host "Not setting Vm Memory to 4GB."
        }
    }
    Exit;
}

if ($char.StartsWith('N')) {
    Write-Host "Exiting..."
    Exit;
}

Write-Host 'Invalid input'
}
function Export-AdUsersToAssetPanda {
<#PSScriptInfo

.VERSION 1.0.4

.GUID d201566e-c0d9-4dc4-9d3f-5f846c16c2a9

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
Export AD user for Asset Panda
#>

param(
    [string]$SearchBase,
    [string]$Filter = "*",
    [array]$Properties = ("Surname", "GivenName", "EmailAddress", "Department", "telephoneNumber", "ipPhone", "MobilePhone", "Office", "Created"),
    [string]$Server
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Arguments = @{}
if ($SearchBase) { $Arguments.SearchBase = $SearchBase }
if ($Filter) { $Arguments.Filter = $Filter }
if ($Filter) { $Arguments.Filter = $Filter }
if ($Properties) { $Arguments.Properties = $Properties }
if ($Server) { $Arguments.Server = $Server }

[System.Collections.ArrayList]$Results = @()

Get-ADUser @Arguments | ForEach-Object {
    $Result = [PSCustomObject]@{
        "Last Name"      = $_.Surname
        "First Name"     = $_.GivenName
        "Email"          = $_.EmailAddress
        "Department"     = $_.Department
        "Work Phone"     = ([regex]::Match($_.telephoneNumber, "^((?:\+1)? ?(?:\d{10}|\d{7}))(?:.*)$")).Groups[1].Value
        "Work Extension" = $_.ipPhone
        "Cell Phone"     = $_.MobilePhone
        "Office"         = $_.Office
        "Hire Date"      =	$_.Created
        "Status"         = "Full Time"
    }
    $Results += $Result
}
return $Results
}
function Export-FortiClientConfig {
<#PSScriptInfo

.VERSION 1.2.8

.GUID 6604b9e8-5c58-4524-b094-07b549c2dad8

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
This will export the current Forti Client configuration.

.PARAMETER Path
The location the configuration will be exported to.

.EXAMPLE
Export-FortiClientConfig -Path backup.conf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    $Path = "backup.conf",
    [ValidateScript( { Test-Path -Path $_ })]$FCConfig = 'C:\Program Files\Fortinet\FortiClient\FCConfig.exe',
    [SecureString]$Password
)

$Arguments = ("-m all", ("-f " + $Path), "-o export", "-i 1")
if ($Password) { $Arguments += "-p $([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)))" }

if ($PSCmdlet.ShouldProcess($Path, "Export FortiClient Config")) {
    Start-Process -FilePath $FCConfig -ArgumentList $Arguments -NoNewWindow -Wait
}
}
function Export-MatchingCertificates {
<#PSScriptInfo

.VERSION 1.0.3

.GUID 31c7075a-49f8-4f99-ad29-aa9d83ab8dc3

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
This script will fetch all certificates matching the chosen template.

.DESCRIPTION
This script will fetch all certificates matching the chosen template. Usefull for adding certificate to Trusted Publishers.

.PARAMETER Path
The location the certificates will be exported to.

.PARAMETER CertificationAuthority
The servername of the certification authority which issued the certificates.

.PARAMETER Date
Filter based on expiry date. By default, the current date will be used.

.PARAMETER Templates
A list of the templates to search for.

.LINK
https://github.com/PKISolutions/PSPKI
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateScript( { Test-Path $_ })][string]$Path = (Get-Location),
  [string]$CertificationAuthority = ((Get-CA | Select-Object Computername).Computername),
  $Date = (Get-Date),
  $Templates
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
Requires -Modules PSPKI

if (-not $Templates) { throw "You must specify the templates to search for." }
$Templates | Foreach-Object {
  Write-Verbose "Searching for $_"
  Get-IssuedRequest -CertificationAuthority $CertificationAuthority -Property RequestID, RawCertificate, Request.RequesterName, CertificateTemplate -Filter "NotAfter -ge $Date", "CertificateTemplate -eq $_" | ForEach-Object {
    $OutPath = Join-Path -Path $Path -ChildPath ("$($_.RequestID)-$($_.CommonName).crt")
    Write-Verbose "Found $($_.RequestID)-$($_.CommonName). Writing to $OutPath"
    Set-Content -Path $OutPath -Value ("-----BEGIN CERTIFICATE-----`n" + $_.RawCertificate + "-----END CERTIFICATE-----")

    $OutPath = (Get-Item $OutPath).FullName # Needed for use with PS drives
    $Thumbprint = (New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $OutPath).Thumbprint
    $Destination = Join-Path -Path (Split-Path -Path $OutPath -Parent) -ChildPath ("\$($_.RequestID)-$($_.CommonName)-$Thumbprint.crt")
    Write-Verbose "Moving file from $OutPath to $Destination"
    Move-Item -Path $OutPath -Destination $Destination
  }
}
}
function Find-EmptyOu {
<#PSScriptInfo
.VERSION 1.0.0
.GUID a1800752-6b26-44fe-8056-573c7434ff1d

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
This script will find all empty organizational units.
#>
Get-ADOrganizationalUnit -filter * -Properties Description -PipelineVariable pv |
Select-Object DistinguishedName, Name, Description,
@{Name = "Children"; Expression = {
        Get-ADObject -filter * -SearchBase $pv.distinguishedname |
        Where-Object { $_.objectclass -ne "organizationalunit" } |
        Measure-Object | Select-Object -ExpandProperty Count }
} | Where-Object { $_.children -eq 0 } |
ForEach-Object {
    Set-ADOrganizationalUnit -Identity $_.distinguishedname -ProtectedFromAccidentalDeletion $False -PassThru -whatif |
    Remove-ADOrganizationalUnit -Recursive -whatif
}
}
function Get-AdComputerInfo {
<#PSScriptInfo

.VERSION 1.0.4

.GUID fc558d38-77a0-4b50-bd45-9f81aaf54984

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
The script will get information about computers from Active Directory.

.PARAMETER Filter
Filters the search based on the spesified parameters.

.PARAMETER Properties
The properties to return from the search.

.PARAMETER SortKey
The sort key to use when sorting the results. By default, this is the first property selected.

.PARAMETER SearchBase
Specifies the search base for the command.
#>

param(
    [string]$Filter = "*",
    $Properties = @("CN", "Enabled", "LastLogonDate", "Created", "Modified", "OperatingSystem", "OperatingSystemVersion", "OperatingSystemServicePack", "PasswordLastSet"),
    $SortKey = $Properties[0],
    [string]$SearchBase
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Test-Admin -Warn -Message "You are not running as an admin. Results may be incomplete."

if ($SearchBase) {
    $Computers = Get-ADComputer -Filter $Filter -SearchBase $SearchBase -Properties $Properties
}
else {
    $Computers = Get-ADComputer -Filter $Filter -Properties $Properties
}

return $Computers # | Sort-Object $SortKey | Select-Object $Properties
}
function Get-ADInfo {
<#PSScriptInfo

.VERSION 1.0.3

.GUID 868aac51-6c72-482e-8b54-42a3c5f87596

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
The script can list and update UPN information for users.

.PARAMETER ListUpn
List the UPN for each user. Can be combined with -Filter.

.PARAMETER LikeUpn
Filters for a specific UPN. Must be used in conjunction with -ListUpn. This overrides -Filter.

.PARAMETER Filter
Filters the search based on the spesified parameters.

.PARAMETER updateUpnSuffix
Updates the Upn. Must be used with -OldUpn and -NewUpn. Can be combined with -SearchBase

.PARAMETER oldUpnSuffix
Specifes the UPN to be changed from. If unspecified, will use "*@koinonia.local".

.PARAMETER newUpnSuffix
Spesified the UPN to change to.  If unspecified, will use "*@***REMOVED***".

.PARAMETER SearchBase
Specifies the search base for the command.

.EXAMPLE
Get-ADInfo.ps1 -listUpn
name       UserPrincipalName
----       -----------------
Jane Doe   Jane.Doe@domain1.com
John Doe   John.Doe@domain2.com

.EXAMPLE
Get-ADInfo.ps1 -listUpn -likeUpn domain2
name       UserPrincipalName
----       -----------------
John Doe   John.Doe@domain2.com

#>

param(
  [string]$Filter,
  [switch]$ListUpn,
  [string]$likeUpn,
  [switch]$updateUpnSuffix,
  [string]$oldUpnSuffix,
  [string]$newUpnSuffix,
  [string]$SearchBase
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Test-Admin -Warn -Message "You are not running as an admin. Results may be incomplete."

Requires ActiveDirectory

If ($ListUpn) {
  If ($likeUpn) { $UpnFilter = "*" + $likeUpn + "*" }
  Elseif ($Filter) { $UpnFilter = $Filter }
  Else { $UpnFilter = "*" }

  Write-Verbose "Listing all users with a UPN like $UpnFilter. Sorting by UPN"
  return Get-ADUser -Filter { UserPrincipalName -like $UpnFilter } -Properties distinguishedName, UserPrincipalName | Select-Object name, UserPrincipalName | Sort-Object -Property UserPrincipalName
}

If ($updateUpnSuffix) {
  Write-Verbose "Setting old UPN, new UPN, and Search Base if not specified."
  $OldUpnSearch = "*" + $oldUpnSuffix
  Write-Verbose "Starting update..."
  checkAdmin
  Write-Information -MessageData "Changing UPN to $newUpnSuffix for all uses with a $oldUpnSuffix UPN in $searchBase." -InformationAction Continue
  Get-ADUser -Filter { UserPrincipalName -like $OldUpnSearch } -SearchBase $searchBase |
  ForEach-Object {
    $OldUpn = $_.UserPrincipalName
    $Upn = $_.UserPrincipalName -ireplace [regex]::Escape($oldUpnSuffix), $newUpnSuffix
    Set-ADUser -identity $_ -UserPrincipalName $Upn
    $NewUpn = $_.UserPrincipalName
    Write-Verbose "Changed $OldUpn to $NewUpn"
  }
}
}
function Get-AdminCount {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 11e3b42b-44ff-41e2-b70d-2ec61685f52f

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
This script will list all users with the AdminAcount attribute set.

.LINK
https://docs.microsoft.com/en-us/windows/win32/adschema/a-admincount
#>
Get-ADUser -Filter { AdminCount -ne "0" } -Properties AdminCount | Select-Object name, AdminCount
}
function Get-AdUserInfo {
<#PSScriptInfo

.VERSION 1.0.5

.GUID 2102c95e-5402-43a2-ba4f-356a89fff4ca

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
The script will get information about users from Active Directory.

.PARAMETER Filter
Filters the search based on the spesified parameters.

.PARAMETER Properties
The properties to return from the search.

.PARAMETER SortKey
The sort key to use when sorting the results. By default, this is the first property selected.

.PARAMETER SearchBase
Specifies the search base for the command.
#>

param(
    [string]$Filter = "*",
    $Properties = @("SamAccountName", "DisplayName", "GivenName", "Surname", "Description", "Enabled", "LastLogonDate", "whenCreated" , "PasswordLastSet", "PasswordNeverExpires", "EmailAddress", "Title", "Department", "Company", "Organization", "Manager", "Office", "MobilePhone", "HomeDirectory"),
    $SortKey = $Properties[0],
    [string]$SearchBase
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Test-Admin -Warn -Message "You are not running as an admin. Results may be incomplete."

if ($SearchBase) {
    $Users = Get-ADUser -Filter $Filter -SearchBase $SearchBase -Properties $Properties
}
else {
    $Users = Get-ADUser -Filter $Filter -Properties $Properties
}

return $Users # | Sort-Object $SortKey | Select-Object $Properties
}
function Get-AdUserSid {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 0e4e3ea4-6fe3-4b89-98f0-a09f40baafed

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
Find the user matching the given SID.

.PARAMETER Sid
The SID to search for.
#>

param(
    [Parameter(Mandatory = $true)][string]$Sid
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

return [ADSI]"LDAP://<SID=$Sid>"
}
function Get-AzureAdMfaStatus {
<#PSScriptInfo

.VERSION 1.0.6

.GUID 036c4b38-9023-4f7b-9254-e8d7683f56e2

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
The script will get information about MFA setup from Azure Active Directory.

.PARAMETER Filter
Filters the AAD query based on the spesified parameters.

.PARAMETER WhereObject
Filters the returned results based on the spesified parameters.

.PARAMETER Properties
The properties to return from the search.

.PARAMETER SortKey
The sort key to use when sorting the results. By default, this is the first property selected.
#>

param(
    [string]$Filter,
    $Properties = @("UserPrincipalName", "DisplayName", "FirstName", "LastName", @{N = "MFA Status"; E = { if ( $null -ne $_.StrongAuthenticationRequirements.State) { $_.StrongAuthenticationRequirements.State } else { "Disabled" } } }),
    $SortKey = $Properties[0]
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

return Get-MsolUser -All  | Sort-Object $SortKey | Select-Object $Properties
}
function Get-AzureAdUserInfo {
<#PSScriptInfo

.VERSION 1.0.5

.GUID 3af068df-1f2d-4e6b-b1a7-e18e09311471

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
The script will get information about users from Azure Active Directory.

.PARAMETER Filter
Filters the AAD query based on the spesified parameters.

.PARAMETER WhereObject
Filters the returned results based on the spesified parameters.

.PARAMETER Properties
The properties to return from the search.

.PARAMETER SortKey
The sort key to use when sorting the results. By default, this is the first property selected.
#>

param(
    [string]$Filter,
    $Properties = @("UserPrincipalName", "DisplayName", "GivenName", "Surname", "UserType", "AccountEnabled", "PhysicalDeliveryOfficeName", "TelephoneNumber", "Mobile", "Mail", "MailNickName"),
    $WhereObject = { $_.DirSyncEnabled -ne $true },
    $SortKey = $Properties[0]
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

return Get-AzureADUser -Filter $Filter | Where-Object $WhereObject | Sort-Object $SortKey | Select-Object $Properties
}
function Get-BiosProductKey {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 8ccdb627-b33f-4be2-b6e0-f9cb992ee398

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
Return the product key stored in the UEFI bios.
#>
return (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
}
function Get-BitlockerStatus {
<#PSScriptInfo

.VERSION 1.1.2

.GUID 674855a4-1cd1-43b7-8e41-fea3bc501f61

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
This commands checks the Bitlocker status and returns it in a human readable format.

.DESCRIPTION
This commands checks the Bitlocker status and returns it in a human readable format.

.PARAMETER Drive
The drive to check for protection on. If unspesified, the System Drive will be used.
#>
param (
  [ValidateScript( { Test-Path $_ })][string]$Drive = $env:SystemDrive
)

If (!(Test-Path $Drive)) {
  Write-Error "$Drive is not valid. Please choose a valid path."
  Break
}

switch ((Get-WmiObject -Namespace ROOT\CIMV2\Security\Microsoftvolumeencryption -Class Win32_encryptablevolume -Filter "DriveLetter = `'$( Split-Path -Path $Drive -Qualifier)`'" -ErrorAction Stop).protectionStatus) {
  ("0") { $protectans = "Unprotected" }
  ("1") { $protectans = "Protected" }
  ("2") { $protectans = "Unknown" }
  default { $protectans = "NoReturn" }
}
$protectans
}
function Get-ExchangePhoto {
<#PSScriptInfo

.VERSION 1.0.3

.GUID 10b98a61-ebf3-499f-847f-4aa18b41a9dd

.AUTHOR Jason Cook Rajeev Buggaveeti

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
This will download all profile photos from Office 365.

.DESCRIPTION
This will download all profile photos from Office 365. This can be used along with Set-AdPhotos to syn photos with Active Directory

.PARAMETER Return
Whether to return what options have been set. If unspesified, this is False.

.PARAMETER Users
Array of users to run the command against. If unspesified, will run against all Exchange mailboxes.

.PARAMETER PhotoDirectory
The directory where downloaded photos will be saved to.

.PARAMETER CroppedPhotoDirectory
The directory where cropped photos will be saved to.

.PARAMETER ResultsFile
A csv file to save the results to.

.EXAMPLE
Get-ExchangePhotos

.LINK
https://blogs.technet.microsoft.com/rajbugga/2017/05/16/picture-sync-from-office-365-to-ad-powershell-way/
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [switch]$Return,
    [array]$Users = (Get-Mailbox -ResultSize Unlimited),
    [string]$Path = (Get-Location).ProviderPath,
    [string]$CroppedPath = $Path + "\Cropped\",
    [string]$ResultsFile
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Results = @()

Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $Path -ItemType Directory -Force -Confirm:$false | Out-Null
Get-ChildItem -Path $CroppedPath -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $CroppedPath -ItemType Directory -Force -Confirm:$false | Out-Null

foreach ($User in $Users) {
    $count++ ; Progress -Index $count -Total $Users.count -Activity "Downloading users photos." -Name $User.UserPrincipalName.ToString()

    $Result = @{}

    $PhotoPath = $Path + "\" + $User.Alias + ".jpg"
    $CroppedPhotoPath = $CroppedPath + $User.Alias + ".jpg"
    $Photo = Get-UserPhoto -Identity $User.UserPrincipalName -ErrorAction SilentlyContinue

    If ($null -ne $Photo.PictureData) {
        If ($PSCmdlet.ShouldProcess("$User", "Get-ExchangePhoto")) {
            [io.file]::WriteAllBytes($PhotoPath, $Photo.PictureData)
            Resize-Image -InputFile $PhotoPath -Width 96 -Height 96 -OutputFile $CroppedPhotoPath
            Write-Verbose "Profile photo downloaded for $($User.Alias)."
        }
        $Result.Add("PhotoStatus", $true)
    }
    else {
        Write-Warning "$User does not have a profile photo."
        $Result.Add("PhotoStatus", $false)
    }

    $Result.Add("DisplayName", $user.DisplayName)
    $Result.Add("UserPrincipalName", $user.UserPrincipalName)
    $Result.Add("RecipientType", $user.RecipientType)
    $Result.Add("Alias", $user.Alias)
    $Results += New-Object PSObject -Property $Result
}

If ($ResultsFile) { $Results | Export-CSV $ResultsFile -NoTypeInformation -Encoding UTF8 }
Return $Results
}
function Get-FirmwareType {
<#PSScriptInfo

.VERSION 1.1.1

.GUID d15ce592-4b3e-4d42-82b6-d4a2dd5f15f2

.AUTHOR Jason Cook Chris Warwick

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
This script shows three methods to determine the underlying system firmware (BIOS) type - either UEFI or Legacy BIOS.

.DESCRIPTION
This script shows three methods to determine the underlying system firmware (BIOS) type - either UEFI or Legacy BIOS.

The first method relies on the fact that Windows setup detects the firmware type as a part of the Windows installation
routine and records its findings in the setupact.log file in the \Windows\Panther folder.  It's a trivial task to use
Select-String to extract the relevent line from this file and to pick off the (U)EFI or BIOS keyword it contains.

To do a proper job there are two choices; both involve using Win32 APIs which we call from PowerShell through a compiled
(Add-Type) class using P/Invoke.

For Windows 7/Server 2008R2 and above, the GetFirmwareEnvironmentVariable Win32 API (designed to extract firmware environment
variables) can be used.  This API is not supported on non-UEFI firmware and will fail in a predictable way when called - this
will identify a legacy BIOS.  On UEFI firmware, the API can be called with dummy parameters, and while it will still fail
(probably!) the resulting error code will be different from the legacy BIOS case.

For Windows 8/Server 2012 and above there's a more elegant solution in the form of the GetFirmwareType() API.  This
returns an enum (integer) indicating the underlying firmware type.

Chris Warwick, @cjwarwickps,  September 2013

.EXAMPLE
Get-FirmwareType

.NOTES
Credits    : Created by ChrisWarwick. Available under MIT License | https://opensource.org/licenses/MIT

.LINK
https://github.com/ChrisWarwick/GetUEFI/blob/master/GetFirmwareBIOSorUEFI.psm1

.LINK
https://github.com/ChrisWarwick/GetUEFI/blob/master/LICENSE

.LINK
https://opensource.org/licenses/MIT
 #>

(Select-String 'Detected boot environment' C:\Windows\Panther\setupact.log -AllMatches ).line -replace '.*:\s+'

<#
Second method, use the GetFirmwareEnvironmentVariable Win32 API.

From MSDN (http://msdn.microsoft.com/en-ca/library/windows/desktop/ms724325%28v=vs.85%29.aspx):

"Firmware variables are not supported on a legacy BIOS-based system. The GetFirmwareEnvironmentVariable function will
always fail on a legacy BIOS-based system, or if Windows was installed using legacy BIOS on a system that supports both
legacy BIOS and UEFI.

"To identify these conditions, call the function with a dummy firmware environment name such as an empty string ("") for
the lpName parameter and a dummy GUID such as "{00000000-0000-0000-0000-000000000000}" for the lpGuid parameter.
On a legacy BIOS-based system, or on a system that supports both legacy BIOS and UEFI where Windows was installed using
legacy BIOS, the function will fail with ERROR_INVALID_FUNCTION. On a UEFI-based system, the function will fail with
an error specific to the firmware, such as ERROR_NOACCESS, to indicate that the dummy GUID namespace does not exist."

From PowerShell, we can call the API via P/Invoke from a compiled C# class using Add-Type.  In Win32 any resulting
API error is retrieved using GetLastError(), however, this is not reliable in .Net (see
blogs.msdn.com/b/adam_nathan/archive/2003/04/25/56643.aspx), instead we mark the pInvoke signature for
GetFirmwareEnvironmentVariableA with SetLastError=true and use Marshal.GetLastWin32Error()

Note: The GetFirmwareEnvironmentVariable API requires the SE_SYSTEM_ENVIRONMENT_NAME privilege.  In the Security
Policy editor this equates to "User Rights Assignment": "Modify firmware environment values" and is granted to
Administrators by default.  Because we don't actually read any variables this permission appears to be optional.
#>

Function IsUEFI {

    <#
.Synopsis
   Determines underlying firmware (BIOS) type and returns True for UEFI or False for legacy BIOS.
.DESCRIPTION
   This function uses a complied Win32 API call to determine the underlying system firmware type.
.EXAMPLE
   If (IsUEFI) { # System is running UEFI firmware... }
.OUTPUTS
   [Bool] True = UEFI Firmware; False = Legacy BIOS
.FUNCTIONALITY
   Determines underlying system firmware type
#>

    [OutputType([Bool])]
    Param ()

    Add-Type -Language CSharp -TypeDefinition @'

    using System;
    using System.Runtime.InteropServices;

    public class CheckUEFI
    {
        [DllImport("kernel32.dll", SetLastError=true)]
        static extern UInt32
        GetFirmwareEnvironmentVariableA(string lpName, string lpGuid, IntPtr pBuffer, UInt32 nSize);

        const int ERROR_INVALID_FUNCTION = 1;

        public static bool IsUEFI()
        {
            // Try to call the GetFirmwareEnvironmentVariable API.  This is invalid on legacy BIOS.

            GetFirmwareEnvironmentVariableA("","{00000000-0000-0000-0000-000000000000}",IntPtr.Zero,0);

            if (Marshal.GetLastWin32Error() == ERROR_INVALID_FUNCTION)

                return false;     // API not supported; this is a legacy BIOS

            else

                return true;      // API error (expected) but call is supported.  This is UEFI.
        }
    }
'@

    [CheckUEFI]::IsUEFI()
}

<#

Third method, use GetFirmwareTtype() Win32 API.

In Windows 8/Server 2012 and above there's an API that directly returns the firmware type and doesn't rely on a hack.
GetFirmwareType() in kernel32.dll (http://msdn.microsoft.com/en-us/windows/desktop/hh848321%28v=vs.85%29.aspx) returns
a pointer to a FirmwareType enum that defines the following:

typedef enum _FIRMWARE_TYPE {
  FirmwareTypeUnknown  = 0,
  FirmwareTypeBios     = 1,
  FirmwareTypeUefi     = 2,
  FirmwareTypeMax      = 3
} FIRMWARE_TYPE, *PFIRMWARE_TYPE;

Once again, this API call can be called in .Net via P/Invoke.  Rather than defining an enum the function below
just returns an unsigned int.
#>

Function Get-BiosType {

    <#
.Synopsis
   Determines underlying firmware (BIOS) type and returns an integer indicating UEFI, Legacy BIOS or Unknown.
   Supported on Windows 8/Server 2012 or later
.DESCRIPTION
   This function uses a complied Win32 API call to determine the underlying system firmware type.
.EXAMPLE
   If (Get-BiosType -eq 1) { # System is running UEFI firmware... }
.EXAMPLE
    Switch (Get-BiosType) {
        1       {"Legacy BIOS"}
        2       {"UEFI"}
        Default {"Unknown"}
    }
.OUTPUTS
   Integer indicating firmware type (1 = Legacy BIOS, 2 = UEFI, Other = Unknown)
.FUNCTIONALITY
   Determines underlying system firmware type
#>

    [OutputType([UInt32])]
    Param()

    Add-Type -Language CSharp -TypeDefinition @'

    using System;
    using System.Runtime.InteropServices;

    public class FirmwareType
    {
        [DllImport("kernel32.dll")]
        static extern bool GetFirmwareType(ref uint FirmwareType);

        public static uint GetFirmwareType()
        {
            uint firmwaretype = 0;
            if (GetFirmwareType(ref firmwaretype))
                return firmwaretype;
            else
                return 0;   // API call failed, just return 'unknown'
        }
    }
'@

    [FirmwareType]::GetFirmwareType()
}
}
function Get-GroupMembershipReport {
<#PSScriptInfo

.VERSION 1.0.2

.GUID b2ff192c-1106-4c52-ab8c-b7cab4524cc9

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
Gets group membership information for the specified groups.

.PARAMETER Filter
Filters the search based on the spesified parameters.

.PARAMETER SearchBase
The LDAP search base.
#>

param (
    $Filter = "*",
    $SearchBase
)
$Results = @()
Get-ADGroup -SearchBase $SearchBase -Filter * -Properties Description | ForEach-Object {
    $MembersString = (Get-ADGroupMember -Identity $_.DistinguishedName).Name -join ";"
    $Result = [PSCustomObject]@{
        Name          = $_.Name
        Description   = $_.Description
        MembersString = $MembersString
        Members       = (Get-ADGroupMember -Identity $_.DistinguishedName).Name
    }
    $Results += $Result
}
return $Results
}
function Get-ipPhone {
<#PSScriptInfo

.VERSION 1.0.3

.GUID 51e2066f-785d-4ab1-b889-904c387fb2f9

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
Export all ipPhone information.

.PARAMETER Path
The location to export to.

.PARAMETER Filter
How to filter the AD query. By default, it will filter out any user which doesn't have the ipPhone attribute set.

.LINK
https://docs.microsoft.com/en-us/windows/win32/adschema/a-admincount
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateScript( { Test-Path ((Get-Item $_).parent) })][string]$Path,
    $Filter = "ipphone -like `"*`""
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Results = Get-ADUser -Properties name, ipPhone, Company, Title, Department, DistinguishedName -Filter $Filter | Where-Object msExchHideFromAddressLists -ne $true | Select-Object name, ipPhone, Company, Title, Department | Sort-Object -Property Company, name
if ($Path) { $Results | Export-Csv -NoTypeInformation -Path $Path }
return $Results
}
function Get-LapsInfo {
<#PSScriptInfo

.VERSION 1.0.3

.GUID 2a3f5ec5-e6c3-4a0b-a8ca-67f98b359144

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
Shows the percentage of machines which have LAPS configured.

.PARAMETER Details
If set, will show which computers have a password set.

.PARAMETER Filter
Filters the search based on the spesified parameters.

.PARAMETER ShowPasswords
Will also output passwords.
#>
param(
    [string]$Filter = "*",
    [switch]$Details,
    [string]$Show
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Results = @()
Get-ADComputer -Filter $Filter -Properties ms-Mcs-AdmPwd | Sort-Object ms-Mcs-AdmPwd, Name | ForEach-Object {
    if ($Show) { $Password = $_.'ms-Mcs-AdmPwd' } else { $Password = '********' }
    if ($_.'ms-Mcs-AdmPwd') { $Status = $true } else { $Status = $false }
    $Result = [PSCustomObject]@{
        Name     = $_.Name
        Status   = $Status
        Password = $Password
    }
    $Results += $Result
}
if ($Details) { return $Results } else {

    $EnabledCount = ($Results | Where-Object Status -eq $true).Count
    $DisabledCount = ($Results | Where-Object Status -eq $false).Count
    $TotalCount = $Results.count

    return [PSCustomObject]@{
        Enabled         = $EnabledCount
        Disabed         = $DisabledCount
        Total           = $TotalCount
        PercentComplete = $EnabledCount / $TotalCount * 100
    }
}
}
function Get-MailboxAddresses {
<#PSScriptInfo

.VERSION 1.0.2

.GUID f3ba5497-54b4-4b33-8c6f-33a678f5551c

.AUTHOR Jason Cook Laeeq Qazi - www.HostingController.com

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
This script will get all email addresses for the organization.

.DESCRIPTION
This script will get all email addresses for the organization. It is based on the answer located here: https://social.technet.microsoft.com/Forums/exchange/en-US/a234ba3b-37b4-4333-8954-5f46885c5e20/how-to-list-email-addresses-and-aliases-for-each-user?forum=exchangesvrgenerallegacy

.LINK
https://social.technet.microsoft.com/Forums/exchange/en-US/a234ba3b-37b4-4333-8954-5f46885c5e20/how-to-list-email-addresses-and-aliases-for-each-user?forum=exchangesvrgenerallegacy
#>

Get-Mailbox | ForEach-Object {
	$host.UI.Write("Blue", $host.UI.RawUI.BackgroundColor, "'nUser Name: " + $$.DisplayName + "'n")
	For ($i = 0; $i -lt $_.EmailAddresses.Count; $i++) {
		$Address = $_.EmailAddresses[$i]
		$host.UI.Write("Blue", $host.UI.RawUI.BackGroundColor, $address.AddressString.ToString() + "`t")
		If ($Address.IsPrimaryAddress) {
			$host.UI.Write("Green", $host.UI.RawUI.BackGroundColor, "Primary Email Address`n")
		}
		Else {
			$host.UI.Write("Green", $host.UI.RawUI.BackGroundColor, "Alias`n")
		}
	}
}
}
function Get-MemoryType {
<#PSScriptInfo

.VERSION 1.1.4

.GUID 4625bce9-661a-4a70-bb4e-46ea09333f33

.AUTHOR Jason Cook Microsoft

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
This script will output the amount of memory and the type using WMI information.

.DESCRIPTION
This script will output the amount of memory and the type using WMI information. Type information is taken from here: https://msdn.microsoft.com/en-us/library/aa394347(v=vs.85).aspx

.EXAMPLE
Get-MemoryType
moduleCapacityMB : {8192, 8192}
moduleCapacityGB : {8, 8}
totalCapacityMB  : 16384
totalCapacityGB  : 16
Dimm             : {24, 24}
DimmType         : DDR3

.NOTES
Credits    : Created by Microsoft. Available under Creative Commons Attribution 4.0 International License.

.LINK
https://msdn.microsoft.com/en-us/library/aa394347(v=vs.85).aspx

.LINK
https://github.com/MicrosoftDocs/win32/blob/docs/desktop-src/CIMWin32Prov/win32-physicalmemory.md

.LINK
https://github.com/MicrosoftDocs/win32/blob/docs/LICENSE
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = "False positive")]
param()
$PhysicalMemory = Get-CimInstance -Class Win32_PhysicalMemory | Select-Object MemoryType, Capacity
$PhysicalMemory | ForEach-Object {
	If ( $_.MemoryType -eq '0' ) { $DimmType = 'Unknown' }
	ElseIf ( $_.MemoryType -eq '1' ) { $DimmType = 'Other' }
	ElseIf ( $_.MemoryType -eq '2' ) { $DimmType = 'DRAM' }
	ElseIf ( $_.MemoryType -eq '3' ) { $DimmType = 'Synchronous DRAM' }
	ElseIf ( $_.MemoryType -eq '4' ) { $DimmType = 'Cache DRAM' }
	ElseIf ( $_.MemoryType -eq '5' ) { $DimmType = 'EDO' }
	ElseIf ( $_.MemoryType -eq '6' ) { $DimmType = 'EDRAM' }
	ElseIf ( $_.MemoryType -eq '6' ) { $DimmType = 'VRAM' }
	ElseIf ( $_.MemoryType -eq '8' ) { $DimmType = 'SRAM' }
	ElseIf ( $_.MemoryType -eq '9' ) { $DimmType = 'RAM' }
	ElseIf ( $_.MemoryType -eq '10' ) { $DimmType = 'ROM' }
	ElseIf ( $_.MemoryType -eq '11' ) { $DimmType = 'Flash' }
	ElseIf ( $_.MemoryType -eq '12' ) { $DimmType = 'EEPROM' }
	ElseIf ( $_.MemoryType -eq '13' ) { $DimmType = 'FEPROM' }
	ElseIf ( $_.MemoryType -eq '14' ) { $DimmType = 'EPROM' }
	ElseIf ( $_.MemoryType -eq '15' ) { $DimmType = 'CDRAM' }
	ElseIf ( $_.MemoryType -eq '16' ) { $DimmType = '3DRAM' }
	ElseIf ( $_.MemoryType -eq '17' ) { $DimmType = 'SDRAM' }
	ElseIf ( $_.MemoryType -eq '18' ) { $DimmType = 'SGRAM' }
	ElseIf ( $_.MemoryType -eq '19' ) { $DimmType = 'RDRAM' }
	ElseIf ( $_.MemoryType -eq '20' ) { $DimmType = 'DDR' }
	ElseIf ( $_.MemoryType -eq '21' ) { $DimmType = 'DDR2' }
	ElseIf ( $_.MemoryType -eq '22' ) { $DimmType = 'DDR2 FB-DIMM' }
	ElseIf ( $_.MemoryType -eq '24' ) { $DimmType = 'DDR3' }
	ElseIf ( $_.MemoryType -eq '25' ) { $DimmType = 'FBD2' }
	$TotalCapacity += $_.Capacity
}
$Result = [PSCustomObject]@{
	moduleCapacityMB = $PhysicalMemory | ForEach-Object { $_.Capacity / 1MB }
	moduleCapacityGB = $PhysicalMemory | ForEach-Object { $_.Capacity / 1GB }
	totalCapacityMB  = $TotalCapacity / 1MB
	totalCapacityGB  = $TotalCapacity / 1GB
	Dimm             = $PhysicalMemory.MemoryType
	DimmType         = $DimmType
}
Return $Result
}
function Get-MfpEmails {
<#PSScriptInfo

.VERSION 2.0.4

.GUID 9ee43161-d2de-4792-a59e-19ff0ef0717e

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
This script will output the email addresses needed for the scan to email function on MFPs.

.PARAMETER Path
The location where the results will be exported to.

.PARAMETER Properties
The properties to export.

.PARAMETER SearchBase
The base OU to search from.

.PARAMETER Filter
How should the AD results be filtered?
#>

param(
    [ValidateSet("Canon", "KonicaMinolta")][string]$Vendor,
    [ValidateSet("csv", "abk")][string]$Format = "csv",
    [ValidateScript( { Test-Path (Split-Path $_ -Parent) })][string]$Path,
    [array]$Properties = ("name", "DisplayName", "mail", "enabled", "msExchHideFromAddressLists"),
    [array]$AdditionalUsers,
    [string]$SearchBase,
    $WhereObject = { $null -ne $_.mail -and $_.Enabled -ne $false -and $_.msExchHideFromAddressLists -ne $true },
    [string]$Server,
    [string]$Filter = "*"
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Arguments = @{}
if ($Properties) { $Arguments.Properties = $Properties }
if ($SearchBase) { $Arguments.SearchBase = $SearchBase }
if ($Server) { $Arguments.Server = $Server }
if ($Filter) { $Arguments.Filter = $Filter }

Write-Verbose "Searching AD"
$Users = Get-ADUser @Arguments

Write-Verbose "Searching for additional users"
if ($AdditionalUsers) {
    $Arguments.Remove("SearchBase")
    $AdditionalUsers | ForEach-Object {
        $Arguments.Identity = $_
        $Users += Get-ADUser @Arguments
    }
}

Write-Verbose "Sorting results"
$Users = $Users | Where-Object $WhereObject | Select-Object $Properties | Sort-Object $Properties[0]

if ($Vendor -eq "Canon") {
    $Results = @()
    $Index = 200
    if ($Format -eq "csv") {
        Write-Verbose "Starting export for Canon CSV"
        $Users | ForEach-Object {
            $Index++
            $Result = [PSCustomObject]@{
                objectclass       = "email"
                cn                = $_.DisplayName
                cnread            = $_.DisplayName
                cnshort           = $null
                subdbid           = 1
                mailaddress       = $_.mail
                dialdata          = $null
                uri               = $null
                url               = $null
                path              = $null
                protocol          = "smtp"
                username          = $null
                pwd               = $null
                member            = $null
                indxid            = $Index
                enablepartial     = "off"
                sub               = $null
                faxprotocol       = $null
                ecm               = $null
                txstartspeed      = $null
                commode           = $null
                lineselect        = $null
                uricommode        = $null
                uriflag           = $null
                pwdinputflag      = $null
                ifaxmode          = $null
                transsvcstr1      = $null
                transsvcstr2      = $null
                ifaxdirectmode    = $null
                documenttype      = $null
                bwpapersize       = $null
                bwcompressiontype = $null
                bwpixeltype       = $null
                bwbitsperpixel    = $null
                bwresolution      = $null
                clpapersize       = $null
                clcompressiontype = $null
                clpixeltype       = $null
                clbitsperpixel    = $null
                clresolution      = $null
                accesscode        = 0
                uuid              = $null
                cnreadlang        = "en"
                enablesfp         = $null
                memberobjectuuid  = $null
                loginusername     = $null
                logindomainname   = $null
                usergroupname     = $null
                personalid        = $null
            }
            $Results += $Result
        }
        If ($Path) {

            $Results | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
            $(
                "# Canon AddressBook CSV version: 0x0002
"
            (Get-Content $Path -Raw) -replace "`"", ""
            ) | Out-File $Path -Encoding UTF8
        }
    }
    elseif ($Format -eq "abk") {
        Write-Verbose "Starting export for Canon ABK"
        $Results = "# Canon AddressBook version: 1
`# CharSet: WCP1252
`# SubAddressBookName: Cambridge Users
`# DB Version: 0x0108"
        $Users | ForEach-Object {
            $Index++
            Write-Verbose "$($_.DisplayName + ": " + $_.Enabled)"
            $Results += "

subdbid: 1
dn: $Index
cn: $($_.DisplayName)
cnread: $($_.DisplayName)
mailaddress: $($_.mail)
enablepartial: false
accesscode: 0
protocol: smtp
objectclass: top
objectclass: extensibleobject
objectclass: email"
        }

        If ($Path) { [IO.File]::WriteAllLines($Path, $Results) }
    }

}
elseif ($Vendor -eq "KonicaMinolta") {
    Write-Verbose "Starting export for KonicaMinolta"
    $Users = $Users | Select-Object name, mail
    $Users | ForEach-Object { $_.name = "$($_.name[0..23] -join '')" }
    $Results = $Users
    if ($Path) { $Results | Export-Csv -NoTypeInformation -Path $Path }
}
elseif ($Null -eq $Vendor) { throw "Vendor must be specified" }
else { throw "Vendor `'$Vendor`' not supported" }

Write-Verbose "Finished"
return $Results
}
function Get-NewIP {
<#PSScriptInfo

.VERSION 1.1.2

.GUID 9eea8e22-18f9-4cf7-b019-602c7d71dcf8

.AUTHOR Jason Cook Aman Dhally - amandhally@gmail.com

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
This powershell script will renew DHCP leaces on all network interfaces with DHCP enabled.

.DESCRIPTION
This powershell script will renew DHCP leaces on all network interfaces with DHCP enabled. Based off of a script by Aman Dhally located here https://newdelhipowershellusergroup.blogspot.ca/2012/04/ip-address-release-renew-using.html

.LINK
https://newdelhipowershellusergroup.blogspot.ca/2012/04/ip-address-release-renew-using.html

.EXAMPLE
.\Get-NewIP.ps1
Get-NewIP: Flushing IP addresses for Intel(R) Dual Band Wireless-AC 8260
Get-NewIP: Renewing IP Addresses
Get-NewIP: Lease on 192.168.2.18 fe80::24b7:e4ab:2901:6688 expires in 21 hours 2935 minutes on May 2, 2017 9:44:03 AM

.LINK
http://www.amandhally.net/blog

.LINK
https://newdelhipowershellusergroup.blogspot.com/2012/04/ip-address-release-renew-using.html
#>

$Ethernet = Get-CimInstance -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IpEnabled -eq $true -and $_.DhcpEnabled -eq $true }
foreach ($lan in $ethernet) {
	$lanDescription = $lan.Description
	Write-Output "Flushing IP addresses for $lanDescription"
	Start-Sleep 2
	$lan | Invoke-CimMethod -MethodName ReleaseDHCPLease | Out-Null
	Write-Output "Renewing IP Addresses"
	$lan | Invoke-CimMethod -MethodName RenewDHCPLease | Out-Null
	#$lan | select Description, ServiceName, IPAddress,  IPSubnet, DefaultIPGateway, DNSServerSearchOrder, DNSDomain, DHCPLeaseExpires, DHCPServer, MACAddress

	#$expireTime = [datetime]::ParseExact($lan.DHCPLeaseExpires,'yyyyMMddHHmmss.000000-300',$null)
	$expireTime = $lan.DHCPLeaseExpires
	$expireTimeFormated = Get-Date -Date $expireTime -Format F
	$expireTimeUntil = New-TimeSpan -Start (Get-Date) -End $expireTime
	$days = [Math]::Floor($expireTimeUntil.TotalDays)
	$hours = [Math]::Floor($expireTimeUntil.TotalHours) - $days * 24
	$minutes = [Math]::Floor($expireTimeUntil.TotalMinutes) - $hours * 60
	$expireTimeUntilFormated = $null
	If ( $days -gt 1 ) { $expireTimeUntilFormated = $days + ' days ' } ElseIf ( $days -gt 0 ) { $expireTimeUntilFormated = $days + ' day ' }
	If ( $hours -gt 1 ) { $expireTimeUntilFormated = -join ($expireTimeUntilFormated, $hours) + ' hours ' } ElseIf ( $hours -gt 0 ) { $expireTimeUntilFormated = -join ($expireTimeUntilFormated, $hours) + ' hour ' }
	If ( $minutes -gt 1 ) { $expireTimeUntilFormated = -join ($expireTimeUntilFormated, $minutes) + ' minutes' } ElseIf ( $minutes -gt 0 ) { $expireTimeUntilFormated = -join ($expireTimeUntilFormated, $minutes) + ' minute' }
	$Ip = $lan.IPAddress
	Write-Output "Lease on $Ip expires in $expireTimeUntilFormated on $expireTimeFormated"
}
}
function Get-OrphanedGPO {
<#PSScriptInfo

.VERSION 1.0.3

.GUID 4ec63b79-6484-43eb-90f8-bef7e2642564

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
This script will find all orphaned GPOs.

.LINK
https://4sysops.com/archives/find-orphaned-active-directory-gpos-in-the-sysvol-share-with-powershell/
#>

[CmdletBinding()]
param (
    [string]$ForestName = (Get-ADForest).Name,
    $Domains = (Get-AdForest -Identity $ForestName | Select-Object -ExpandProperty Domains)
)

try {
    ## Find all domains in the forest

    $gpoGuids = @()
    $sysvolGuids = @()
    foreach ($domain in $Domains) {
        $gpoGuids += Get-GPO -All -Domain $domain | Select-Object @{ n = 'GUID'; e = { $_.Id.ToString() } } | Select-Object -ExpandProperty GUID
        foreach ($guid in $gpoGuids) {
            $polPath = "\\$domain\SYSVOL\$domain\Policies"
            $polFolders = Get-ChildItem $polPath -Exclude 'PolicyDefinitions' | Select-Object -ExpandProperty name
            foreach ($folder in $polFolders) {
                $sysvolGuids += $folder -replace '{|}'
            }
        }
    }

    Compare-Object -ReferenceObject $sysvolGuids -DifferenceObject $gpoGuids | Select-Object -ExpandProperty InputObject
}
catch {
    $PSCmdlet.ThrowTerminatingError($_)
}
}
function Get-RecentEvents {
<#PSScriptInfo

.VERSION 1.0.1

.GUID 05dad3a6-57cf-4747-b3bd-57bc12b7628e

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
This script will search the event log for events a specified number of minutes before or after a given time.

.DESCRIPTION
This script will search the event log for events a specified number of minutes before or after a given time.

.PARAMETER Before
To search before -Time. Either -Before or -After must be spesified. -Before will take precedence if both are set.

.PARAMETER After
To search after -Time. Either -Before or -After must be spesified. -Before will take precedence if both are set.

.PARAMETER Time
The number of minutes from now to begin the search. This paramater is required.

.EXAMPLE
.\Get-RecentEvents.ps1 -After -Time -1

   Index Time          EntryType   Source                 InstanceID Message
   ----- ----          ---------   ------                 ---------- -------
   31568 Sep 05 12:18  Information Service Control M...   1073748864 The start type of the Background Intelligent Transfer Service service was changed from auto start to demand start.
#>
param(
  [Parameter(Mandatory = $true)][string]$Time,
  [switch]$Before,
  [switch]$After
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Test-Admin -Message "You are not running this script with Administrator rights. Some events may be missing." | Out-Null

If ($Before -eq $True) { Get-EventLog System -Before (Get-Date).AddMinutes($Time) }
ElseIf ($After -eq $True) { Get-EventLog System -After (Get-Date).AddMinutes($Time) }
Else { Write-Error "You must specify either -Before or -After" }
}
function Get-SecureBoot {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 421f45c1-3a42-4c17-83a8-bb109f412a19

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
This script with gather information about  Secure Boot from the specified marchines.

.DESCRIPTION
This script with gather information about TPM and Secure Boot from the spesified specified. It can request information from just the local computer or from a list of remote computers. It can also export the results as a CSV file.

.PARAMETER ComputerList
This can be used to select a text file with a list of computers to run this command against. Each device must appear on a new line. If unspesified, it will run againt the local machine.

.PARAMETER ReportFile
This can be used to export the results to a CSV file.

.EXAMPLE
Get-TPMInfo
System Information for: localhost
Secure Boot Status: TRUE
#>
param(
  [string]$ComputerList,
  [string]$ReportFile
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Function Get-SystemInfo($ComputerSystem) {
  If (-NOT (Test-Connection -ComputerName $ComputerSystem -Count 1 -ErrorAction SilentlyContinue)) {
    Write-Warning "$ComputerSystem is not accessible."
    $script:Report += New-Object psobject -Property @{
      RunAgainst         = $ComputerSystem;
      Satus              = "Offline"
      ComputerSecureBoot = "Offline";
    }
    Return
		}
  $ComputerSecureBoot = Invoke-Command -ComputerName $ComputerSystem -ScriptBlock { Confirm-SecureBootUEFI }
  "System Information for: " + $ComputerSystem
  "Secure Boot Status: " + $ComputerSecureBoot
  ""
  ""
  $script:Report += New-Object psobject -Property @{
    RunAgainst         = $ComputerSystem;
    Satus              = "Online"
    ComputerSecureBoot = $ComputerSecureBoot;
  }
  If ($script:ReportFile) { $script:Report | Export-Csv $script:ReportFile }
}

$script:Report = @()
If ($ComputerList) { foreach ($ComputerSystem in Get-Content $ComputerList) { Get-SystemInfo -ComputerSystem $ComputerSystem } }
Else { Get-SystemInfo -ComputerSystem $env:COMPUTERNAME }
If ($ReportFile) { $Report | Export-Csv $ReportFile }
}
function Get-Spns {
<#PSScriptInfo

.VERSION 1.0.3

.GUID 086f7358-170c-4f90-ab37-9b06888cd963

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
List all SPNs in Active Directory

.LINK
https://social.technet.microsoft.com/wiki/contents/articles/18996.active-directory-powershell-script-to-list-all-spns-used.aspx
#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
param()
Clear-Host
$search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
$search.filter = "(servicePrincipalName=*)"
$results = $search.Findall()

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
}
function Get-StaleAADGuestAccounts {
<#PSScriptInfo

.VERSION 1.1.3

.GUID 66f102b7-1405-45dc-8df3-0d1b8459f4de

.AUTHOR Jason Cook Darren J Robinson

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
FIND State/Dormant B2B Accounts and Stale/Dormant B2B Guest Invitations

.DESCRIPTION
Get all AAD Accounts which haven't signed in, in the last XX Days, or haven't accepted a B2B Guest Invitation in last XX Days. This is based on the blog post from Darren Robinson.

.LINK
https://blog.darrenjrobinson.com/finding-stale-azure-ad-b2b-guest-accounts-based-on-lastsignindatetime/

.PARAMETER TenantId
Microsoft 365 Tenant ID

.PARAMETER Credential
Registered AAD App ID and Secret

.PARAMETER StaleDays
Number of days over which an Azure AD Account that hasn't signed in is considered stale'

.PARAMETER StaleDate
Spesify a date to use as stale before which all sign ins are considered stale. This overrides the StaleDays oparameter

.PARAMETER GetLastSignIn
Should we find the last sign in date for stale users? This will take longer to process

.EXAMPLE
Get-StaleAADGuestAccounts
#>

param (
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]$TenantId , # Tenant ID
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCredential]$Credential, # Registered AAD App ID and Secret
	$StaleDays = '90', # Number of days over which an Azure AD Account that hasn't signed in is considered stale'
	$StaleDate = (get-date).AddDays( - "$($StaleDays)").ToString('yyyy-MM-dd'), #Or spesify a spesific date to use as stale
	[switch]$GetLastSignIn
)

Requires -Modules MSAL.PS

$StaleGuests = GetAADSignIns -date $StaleDate | Select-Object | Where-Object { $_.userType -eq 'Guest' }
Write-Host -ForegroundColor Green "$($StaleGuests.count) Guest accounts haven't signed in since $($StaleDate)"
Write-Host -ForegroundColor Yellow "    $(($StaleGuests | Select-Object | Where-Object { $_.accountEnabled -eq $false }).Count) Guest accounts haven't signed in since $($StaleDate) and are flagged as 'Account Disabled'."

$PendingGuests = GetAADPendingGuests
Write-Host -ForegroundColor Green "$($PendingGuests.count) Guest accounts are still 'pending' B2B Guest invitation acceptance."
$StalePendingGuests = $PendingGuests | Select-Object | Where-Object { [datetime]$_.externalUserStateChangeDateTime -le [datetime]"$($StaleDate)T00:00:00Z" }
Write-Host -ForegroundColor Yellow "    $($StalePendingGuests.count) Guest accounts were invited before '$($StaleDate)'"

$StaleAndPendingGuests = $null
$StaleAndPendingGuests += $StaleGuests
$StaleAndPendingGuests += $StalePendingGuests
Write-Host -ForegroundColor Green "$($StaleAndPendingGuests.count) Guest accounts are still 'pending' B2B Guest invitation acceptance or haven't signed in since '$($StaleDate)'."

If ($GetLastSignIn) {
	# Add lastSignInDateTime to the User PowerShell Object
	foreach ($Guest in $StaleGuests) {
		#Progress message
		$count++ ; Progress -Index $count -Total $StaleGuests.count -Activity "Getting last sign in for stale guests." -Name $Guest.UserPrincipalName.ToString()
		$signIns = $null
		$signIns = GetAADUserSignInActivity -ID $Guest.id
		$Guest | Add-Member -Type NoteProperty -Name "lastSignInDateTime" -Value $signIns.signInActivity.lastSignInDateTime
	}
}

$defaultProperties = @("mail", "accountEnabled", "creationType", "externalUserState", "userType")
If ($GetLastSignIn) { $defaultProperties += "lastSignInDateTime" }
$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$defaultProperties)
$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
$StaleAndPendingGuests | Add-Member MemberSet PSStandardMembers $PSStandardMembers
return $StaleAndPendingGuests
}
function Get-TermsOfUse {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 7c954769-1a02-4bbb-b1e0-8e9ea3dbb0c8

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
Get AAD Terms of Use details.
#>

Requires -Module AzureADPreview
[System.Collections.ArrayList]$Results = @()

Get-AzureADAuditDirectoryLogs -Filter "loggedByService eq 'Terms Of Use'" | ForEach-Object {
  $Result = [PSCustomObject]@{
    PolicyName  = $_.TargetResources[0].DisplayName
    DisplayName = $_.TargetResources[1].DisplayName
    Upn         = $_.TargetResources[1].UserPrincipalName
    Activity    = $_.ActivityDisplayName
    Date        = $_.ActivityDateTime
    NotesKey    = $_.AdditionalDetails.Key
    NotesValue  = $_.AdditionalDetails.Value
  }
  $Results += $Result
}
return $Results
}
function Get-TpmInfo {
<#PSScriptInfo

.VERSION 1.0.3

.GUID 14062539-2775-4450-bb0b-a3406d1db091

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
This script with gather information about TPM and Secure Boot from the spesified marchines.

.DESCRIPTION
This script with gather information about TPM and Secure Boot from the spesified marchines. It can request information from just the local computer or from a list of remote computers. It can also export the results as a CSV file.

.PARAMETER ComputerList
This can be used to select a text file with a list of computers to run this command against. Each device must appear on a new line. If unspesified, it will run againt the local machine.

.PARAMETER ReportFile
This can be used to export the results to a CSV file.

.EXAMPLE
Get-TPMInfo
System Information for: XXXX
Manufacturer: LENOVO
Model: 20ETXXXX
Serial Number: XXXX
Bios Version: LENOVO - 500
Bios Type: UEFI
Secure Boot Status: TRUE
TPM Version: 1.2
TPM: \\XXXX\root\CIMV2\Security\MicrosoftTpm:Win32_Tpm=@
GPT: @{Name=Disk #0, Partition #1; Index=1; Bootable=True; BootPartition=True; PrimaryPartition=True; SizeInMB=100}
Operating System: Microsoft Windows 10 Pro, Service Pack: 0
Total Memory in Gigabytes: 15.8858337402344
User logged In: XXXX\XXXX
Last Reboot: 08/31/2018 17:23:03
#>
param(
  [string]$ComputerList,
  [string]$ReportFile
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Function Get-SystemInfo($ComputerSystem) {
  If (-NOT (Test-Connection -ComputerName $ComputerSystem -Count 1 -ErrorAction SilentlyContinue)) {
    Write-Warning "$ComputerSystem is not accessible."
    $script:Report += New-Object psobject -Property @{
      RunAgainst          = $ComputerSystem;
      Satus               = "Offline"
      ComputerName        = "";
      Manufacturer        = "";
      Model               = "";
      Serial              = "";
      BiosVersion         = "";
      BiosType            = "";
      GptName             = "";
      GptIndex            = "";
      GptBootable         = "";
      GptBootPartition    = "";
      GptPrimaryPartition = "";
      GptSizeInMB         = "";
      ComputerSecureBoot  = "";
      TpmVersion          = "";
      OperatingSystem     = "";
      ServicePack         = "";
      MemoryGB            = "";
      LastSignIn          = "";
    }
    Return
		}

  $ComputerInfo = Get-CimInstance -ComputerName $ComputerSystem Win32_ComputerSystem
  $ComputerGptSystem = Get-CimInstance -ComputerName $ComputerSystem -query 'Select * from Win32_DiskPartition Where Type = "GPT: System"' | Select-Object Name, Index, Bootable, BootPartition, PrimaryPartition, @{n = "SizeInMB"; e = { $_.Size / 1MB } }
  $ComputerBios = Get-CimInstance -ComputerName $ComputerSystem Win32_BIOS
  $ComputerBiosType = Invoke-Command -ComputerName $ComputerSystem -ScriptBlock { if (Test-Path $env:windir\Panther\setupact.log) { (Select-String 'Detected boot environment' -Path "$env:windir\Panther\setupact.log"  -AllMatches).line -replace '.*:\s+' } else { if (Test-Path HKLM:\System\CurrentControlSet\control\SecureBoot\State) { "UEFI" } else { "BIOS" } } }
  $ComputerBiosType2 = Invoke-Command -ComputerName $ComputerSystem -ScriptBlock {
    Try {
      Confirm-SecureBootUEFI -ErrorVariable ProcessError
      $ComputerBiosType2 = "UEFI"
    }
    Catch { $ComputerBiosType2 = "BIOS" }
    Return $ComputerBiosType2
  }
  If ($ComputerBiosType2[1] -eq "I") {
    $ComputerBiosType2Output = $ComputerBiosType2
    $ComputerSecureBoot = $False
  }
  Else {
    $ComputerBiosType2Output = $ComputerBiosType2[1]
    $ComputerSecureBoot = $ComputerBiosType2[0]
  }
  $ComputerOs = Get-CimInstance -ComputerName $ComputerSystem Win32_OperatingSystem
  # $Tpm = Get-WmiObject -class Win32_Tpm -namespace root\CIMV2\Security\MicrosoftTpm -ComputerName $ComputerSystem -Authentication PacketPrivacy
  $Tpm = Get-CimInstance -class Win32_Tpm -namespace root\CIMV2\Security\MicrosoftTpm -ComputerName $ComputerSystem
  "System Information for: " + $ComputerInfo.Name
  "Manufacturer: " + $ComputerInfo.Manufacturer
  "Model: " + $ComputerInfo.Model
  "Serial Number: " + $ComputerBios.SerialNumber
  "Bios Version: " + $ComputerBios.Version
  "Bios Type: " + $ComputerBiosType
  "Bios Type (New Method): " + $ComputerBiosType2Output
  "Secure Boot Status: " + $ComputerSecureBoot
  "TPM Version: " + $Tpm.PhysicalPresenceVersionInfo
  "TPM: " + $Tpm
  "GPT: " + $ComputerGptSystem
  "Operating System: " + $ComputerOs.caption + ", Service Pack: " + $ComputerOs.ServicePackMajorVersion
  "Total Memory in Gigabytes: " + $ComputerInfo.TotalPhysicalMemory / 1gb
  "User logged In: " + $ComputerInfo.UserName
  "Last Reboot: " + $ComputerOs.LastBootUpTime
  ""
  ""
  $script:Report += New-Object psobject -Property @{
    RunAgainst          = $ComputerSystem;
    Satus               = "Online"
    ComputerName        = $ComputerInfo.Name;
    Manufacturer        = $ComputerInfo.Manufacturer;
    Model               = $ComputerInfo.Model;
    Serial              = $ComputerBios.SerialNumber;
    BiosVersion         = $ComputerBios.Version;
    BiosType            = $ComputerBiosType2Output;
    GptName             = $ComputerGptSystem.Name;
    GptIndex            = $ComputerGptSystem.Index;
    GptBootable         = $ComputerGptSystem.Bootable;
    GptBootPartition    = $ComputerGptSystem.BootPartition;
    GptPrimaryPartition = $ComputerGptSystem.PrimaryPartition;
    GptSizeInMB         = $ComputerGptSystem.SizeInMB;
    ComputerSecureBoot  = $ComputerSecureBoot;
    TpmVersion          = $Tpm.PhysicalPresenceVersionInfo;
    OperatingSystem     = $ComputerOs.caption;
    ServicePack         = $ComputerOs.ServicePackMajorVersion;
    MemoryGB            = $ComputerInfo.TotalPhysicalMemory / 1gb;
    LastSignIn          = $ComputerInfo.UserName;
    LastReboot          = $ComputerOs.LastBootUpTime
  }
  If ($script:ReportFile) { $script:Report | Export-Csv $script:ReportFile }
}

$script:Report = @()
If ($ComputerList) { foreach ($ComputerSystem in Get-Content $ComputerList) { Get-SystemInfo -ComputerSystem $ComputerSystem } }
Else { Get-SystemInfo -ComputerSystem $env:COMPUTERNAME }
If ($ReportFile) { $Report | Export-Csv $ReportFile }
}
function Get-UserInfo {
<#PSScriptInfo

.VERSION 1.0.3

.GUID c64f1f09-036c-471d-898c-c9b3da6f53a8

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
Shows the percentage of machines which have LAPS configured.

.PARAMETER Details
If set, will show which computers have a password set.

.PARAMETER Filter
Filters the search based on the spesified parameters.

.PARAMETER ShowPasswords
Will also output passwords.
#>
param(
    [string]$Filter = "*",
    [switch]$Details,
    [string]$Show
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

function ParseDate {
    param ($Date)
    if ($null -ne $Date -and $Date -ne 0) { return [datetime]::FromFileTime($Date) }
}

$Results = @()
Get-ADUser -Filter * -Properties name, givenName, sn, mail, title, department, company, lastLogonTimestamp, pwdLastSet, whenCreated, whenChanged | `
    Select-Object name, givenName, sn, mail, title, department, company, lastLogonTimestamp, pwdLastSet, whenCreated, whenChanged | `
    Sort-Object lastLogonTimestamp, name | ForEach-Object {

    $Result = [PSCustomObject]@{
        Name            = $_.name
        FirstName       = $_.givenName
        LastName        = $_.sn
        Email           = $_.mail
        Title           = $_.title
        Department      = $_.department
        Company         = $_.company
        LastLogon       = ParseDate $_.lastLogonTimestamp
        PasswordLastSet = ParseDate $_.pwdLastSet
        Created         = $_.whenCreated
        Changed         = $_.whenChanged
    }
    $Results += $Result
}
return $Results
}
function Get-Wallpaper {
<#PSScriptInfo

.VERSION 1.0.3

.GUID b30e98ad-cd0c-4f83-a10d-d5d976221b66

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
Download the latest wallpaper and add to the system wallpaper folder.

.PARAMETER Path
The location the file will be downloaded to.

.PARAMETER Uri
The location from from which to download the wallpaper.
#>
param(
    [string]$Path = "C:\Windows\Web\Wallpaper\Windows\CurrentBackground.jpg",
    [Parameter(Mandatory = $true)][uri]$Uri
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Test-Admin -Warn -Message "You do not have Administrator rights to run this script! This may not work correctly." | Out-Null
Invoke-WebRequest -OutFile $Path -Uri $Uri -ErrorAction SilentlyContinue
}
function Grant-Matching {
<#PSScriptInfo

.VERSION 1.0.8

.GUID 8e42dd4d-c91c-420c-99f5-7b233590ae2c

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
This powershell script will grant NTFS permissions on folders where the username and folder name match.

.DESCRIPTION
This powershell script will grant NTFS permissions on folders where the username and folder name match. It accepts three parameters, AccessRights, Domain, and Folder.
This script requires the NTFSSecurity module: https://github.com/raandree/NTFSSecurity

.LINK
https://github.com/raandree/NTFSSecurity

.PARAMETER AccessRights
This can be used to set the access right on the child folders. If unspecified, it will give FullControl. See documentation of the NTFSSecurity module for options.

.PARAMETER Domain
This can be used to set the domain of the users. If unspecified, it will use the 'KOINONIA' domain.

.PARAMETER Folder
This can be used to select a folder in which to run these commands on. If unspecified, it will run in the PowerShell has active.

.EXAMPLE
.\Grant-Matching.ps1 -AccessRights FullControl -Folder C:\Users
Grant-Matching: Granting DOMAIN\user FullControl on C:\Users\user
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
	$Path = (Get-ChildItem | Where-Object { $_.PSISContainer }),
	[string]$AccessRights = 'FullControl',
	[string]$Domain = $Env:USERDOMAIN
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Requires -Modules NTFSSecurity

foreach ($UserFolder in $Path) {
	$Account = $Domain + '\' + $UserFolder
	$count++ ; Progress -Index $count -Total $Path.count -Activity "Granting $Account $AccessRights." -Name $UserFolder.FullName
	If ($PSCmdlet.ShouldProcess("$($UserFolder.FullName)", "Add-NTFSAccess")) {
		Add-NTFSAccess -Path $UserFolder.FullName -Account $Account -AccessRights $AccessRights
	}
}
}
function Import-FortiClientConfig {
<#PSScriptInfo

.VERSION 1.2.8

.GUID 309e82fe-9a41-4ba2-afb4-8ef85e0fe38d

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
This will import the current Forti Client configuration.

.PARAMETER Path
The location the configuration will be imported from.

.EXAMPLE
Import-FortiClientConfig -Path backup.conf

.LINK
https://getmodern.co.uk/automating-the-install-of-forticlient-vpn-via-mem-intune
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    $Path = "backup.conf",
    [ValidateScript( { Test-Path -Path $_ })]$FCConfig = 'C:\Program Files\Fortinet\FortiClient\FCConfig.exe',
    [SecureString]$Password
)

$Arguments = ("-m all", ("-f " + $Path), "-o import", "-i 1")
if ($Password) { $Arguments += "-p $([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)))" }

if ($PSCmdlet.ShouldProcess($Path, "Import FortiClient Config")) {
    Start-Process -FilePath $FCConfig -ArgumentList $Arguments -NoNewWindow -Wait
}
}
function Initialize-OneDrive {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 983e1108-74f9-41a5-8de9-f12145fbeffc

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
This will remove and reinstall OneDrive.
#>
Write-Verbose "Uninstalling OneDrive..."
Start-Process -FilePath C:\Windows\SysWOW64\OneDriveSetup.exe -NoNewWindow -Wait -Args "/uninstall"
Write-Verbose "Installing OneDrive..."
Start-Process -FilePath C:\Windows\SysWOW64\OneDriveSetup.exe -NoNewWindow
}
function Initialize-Workstation {
<#PSScriptInfo

.VERSION 1.2.15

.GUID 8ab0507b-8af2-4916-8de2-9457194fb454

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
This script will install the neccesary applications and services on a given machine.

.DESCRIPTION
This script will install the neccesary applications and services on a given machine. It will also check for updates to third-party applications. This script will also configure certain items not able to be configured by Group Policy,

.PARAMETER Action
An array of actions to run.
    Rename: Rename the computer. Use -HostNamePrefix to set a prefix.
    LabelDrive: Label the drive, by default, the $env:SystemDrive will be labelled "Windows". Use -DriveToLabel to change the drive and -DriveLabel to change the label.
    ProvisioningPackage: Install a provisioning package. Use -ProvisioningPackage to select the appropriate pacakge.
    JoinDomain: Join the current computer to a domain. Specify the domain with -Domain
    BitLocker: Enable BitLocker. You can overridde the defaults using -BitLockerProtector and -BitlockerEncryptionMethod.
    Office: Install Microsoft Office. You can override the version using -Office.
    RSAT: Install Remote Server Administration Tools.
    NetFX3: Install .Net 3.0
    Ninte: Run Ninite.
    Winget: Install the spesified packages and update existing applications using Winget. Use -Winget to select the appropriate package.
    RemoveDesktopShortcuts: Remove all desktop shortcuts from the Public desktop.
    Reboot: Reboot the machine.

.PARAMETER HostNamePrefix
The prefix to use for the hostname.

.PARAMETER BitLockerProtector
Enable BitLocker using the spesified protector. If unspecified, TPM will be used. Valid options are TPM, Pin, Password, and USB. You can also pass Disable to disable BitLocker

.PARAMETER BitLockerEncryptionMethod
Used to specify the encryption method for BitLocker. If unspecified, XtsAes256 will be used.

.PARAMETER BitLockerUSB
If the USB protector is spesified, use this to specify the USB drive to use.

.PARAMETER DriveLabel
This specifies what the drive will be labeled as. If unspecified, "Windows" will be used.

.PARAMETER DriveToLabel
This specifies which drive to label. If unspecified, the system drive will be used.

.PARAMETER Ninite
If specified, Ninite will be run and install the default third party applications.

.PARAMETER InstallTo
Specifies the defgault install device type for Ninite. Will use Ninite's default if unspecified.

.PARAMETER NetFX3
If specified, ".NET Framework 3.5 (includes .NET 2.0 and 3.0)" will be installed.

.PARAMETER ProvisioningPackage
The path to the Provisioning Package to be installed.

.PARAMETER RSAT
If specified, Remote Server Administrative Tools will be installed.

.PARAMETER OfficeVersion
Specifes the version of Office to install. If unspecified, Office will not be installed.

.PARAMETER WingetPackages
A hashtable of winget packages to install. The key is the package name and the value are any custom options required.

#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [int]$Step,
  [ValidateSet("Rename", "LabelDrive", "ProvisioningPackage", "JoinDomain", "BitLocker", "Office", "Wallpaper", "RSAT", "NetFX3", "Ninite", "Winget", "RemoveDesktopShortcuts", "Reboot")][array]$Action,
  [string]$HostNamePrefix,
  [string]$Domain,
  [ValidateSet("TPM", "Password", "Pin", "USB")][string]$BitLockerProtector = "TPM",
  [hashtable]$WingetPackages,
  [string]$OfficeVersion = "2019",
  [ValidateScript({ Test-Path $_ })][string]$Wallpapers,
  [ValidateScript({ Test-Path $_ })][string]$ProvisioningPackage,
  [switch]$Ninite,
  [string]$NiniteInstallTo = "Workstation",
  [ValidateScript({ Test-Path $_ })][string]$BitLockerUSB,
  [string]$BitLockerEncryptionMethod = "XtsAes256",
  [string]$DriveLabel = "Windows",
  [string]$DriveToLabel = ($env:SystemDrive.Substring(0, 1))
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Test-Admin -Throw | Out-Null
Requires ***REMOVED***IT

if ($Step -eq 1) { $Action = @("Rename", "LabelDrive", "Wallpaper", "Winget") }
if ($Step -eq 2) { $Action = @("BitLocker", "Office", "", "Reboot") }

if ($Action -contains "Rename") { Set-ComputerName -Prefix $HostNamePrefix }

if ($Action -contains "LabelDrive") {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Set-Volume -DriveLetter $DriveToLabel -NewFileSystemLabel $DriveLabel")) {
    Set-Volume -DriveLetter $DriveToLabel -NewFileSystemLabel $DriveLabel
  }
}

if ($Action -contains "ProvisioningPackage" -or $ProvisioningPackage) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install-ProvisioningPackage -QuietInstall -PackagePath $ProvisioningPackage")) {
    If (Test-Path -PathType Leaf -Path $ProvisioningPackage) { Install-ProvisioningPackage -QuietInstall -PackagePath $ProvisioningPackage }
    else { Write-Warning "The provisioning file specified is not valid." }
  }
}

if ($Action -contains "JoinDomain") { Add-Computer -DomainName $DomainName -JoinDomain }

if ($Action -contains "BitLocker") {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Enable-Bitlocker with `'$BitLockerProtector`' protector using $BitLockerEncryptionMethod")) {
    If ($BitLockerProtector -eq "Disable") { Disable-BitLocker -MountPoint $env:SystemDrive }
    Else {
      Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -RecoveryPasswordProtector
      $BLV = Get-BitLockerVolume -MountPoint $env:SystemDrive
      $RecoveryPassword = $BLV.KeyProtector | Where-Object KeyProtectorType -eq "RecoveryPassword"
      Backup-BitLockerKeyProtector -MountPoint $env:SystemDrive -KeyProtectorId $RecoveryPassword.KeyProtectorId | Out-Null
      If ($BitLockerProtector -eq "TPM") {
        Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod $BitLockerEncryptionMethod -TpmProtector
      }
      ElseIf ($BitLockerProtector -eq "Password") {
        $BitLockerSecurePassword = Read-Host -Prompt "Enter Password" -AsSecureString
        Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod $BitLockerEncryptionMethod -PasswordProtector -Password $BitLockerSecurePassword
      }
      ElseIf ($BitLockerProtector -eq "Pin") {
        $BitLockerSecurePin = Read-Host -Prompt "Enter PIN" -AsSecureString
        Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod $BitLockerEncryptionMethod -TPMandPinProtector -Pin $BitLockerSecurePin
      }
      ElseIf ($BitLockerProtector -eq "USB") {
        Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod $BitLockerEncryptionMethod -StartupKeyProtector -StartupKeyPath $BitLockerUSB
      }
      Else {
        Write-Warning "No valid protector spesified. BitLocker will NOT be enabled."
      }
    }
  }
}

if ($Action -contains "Office") {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install Office $OfficeVersion")) {
    Install-MicrosoftOffice -Version $OfficeVersion
  }
}

if ($Action -contains "Wallpaper") { Set-DefaultWallpapers -SourcePath $Wallpapers ; Set-WallPaper }

if ($Action -contains "RSAT") {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install Remote Server Administrative Tools")) {
    Write-Verbose "Install Remote Server Administrative Tools"
    Get-WindowsCapability -Online -Name "RSAT*" | Add-WindowsCapability -Online
  }
}

if ($Action -contains "NetFX3") {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install .NET Framework 3.5 (includes .NET 2.0 and 3.0)")) {
    Write-Verbose "Installing .NET Framework 3.5 (includes .NET 2.0 and 3.0)"
    Get-WindowsCapability -Online -Name NetFx3* | Add-WindowsCapability -Online
  }
}

if ($Action -contains "Ninite") {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername) $NiniteInstallTo", "Install apps using Ninite")) {
    Write-Verbose "Running Ninite"
    $parent = Split-Path $script:MyInvocation.MyCommand.Path
    & $parent\..\Ninite\Ninite.ps1 -Local -InstallTo $NiniteInstallTo
  }
}

if ($Action -contains "winget") {
  if ($null -ne $WingetPackages) {
    $WingetPackages.Keys | ForEach-Object {
      $Arguments = @( "install $_", "--accept-package-agreements", "--accept-source-agreements" )
      if ($null -ne $WingetPackages[$_]) { $Arguments += $WingetPackages[$_] }
      if ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install $_ with arguments: $Arguments")) {
        Start-Process -Wait -NoNewWindow -FilePath winget -ArgumentList $Arguments
      }
    }
  }

  if ($PsCmdlet.ShouldProcess("localhost ($env:computername)", "Upgrading packages with winget")) {
    Start-Process -Wait -NoNewWindow -FilePath winget -ArgumentList "upgrade --all"
  }
}

if ($Action -contains "RemoveDesktopShortcuts") { Get-ChildItem C:\Users\Public\Desktop\*.lnk | Remove-Item }

Write-Verbose "Checking for reboot."
If ( $Reboot -or $Action -contains "Reboot" -or (Test-Path "HKLM:\SOFTWARE­\Microsoft­\Windows­\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") ) {
  Write-Verbose "A reboot is required. Reboot now?"
  Restart-Computer -Confirm
}
}
function Install-GCPW {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 24dd6c1f-cc9a-44a4-b8e8-dd831d7a51b4

.AUTHOR Jason Cook Google

.COMPANYNAME ***REMOVED*** Google

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
This script downloads Google Credential Provider for Windows from https://tools.google.com/dlpage/gcpw/, then installs and configures it. Windows administrator access is required to use the script.

.DESCRIPTION
This script downloads Google Credential Provider for Windows from https://tools.google.com/dlpage/gcpw/, then installs and configures it. Windows administrator access is required to use the script.

.PARAMETER DomainsAllowedToLogin
Set the following key to the domains you want to allow users to sign in from.

For example: Install-GCPW -DomainsAllowedToLogin "acme1.com,acme2.com"

.LINK
https://support.google.com/a/answer/9250996?hl=en
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [ValidatePattern("^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+([a-zA-Z0-9-]{2,63})$", ErrorMessage = "{0} is not a valid domain name.")][Parameter(Mandatory = $true)][string]$DomainsAllowedToLogin
)

if ($PSCmdlet.ShouldProcess($DomainsAllowedToLogin, 'Install Google Cloud Credential Provider for Windows')) {

    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName PresentationFramework

    #If (!(Test-Admin -Warn)) { Break }

    <# Choose the GCPW file to download. 32-bit and 64-bit versions have different names #>
    if ([Environment]::Is64BitOperatingSystem) {
        $gcpwFileName = 'gcpwstandaloneenterprise64.msi'
    }
    else {
        $gcpwFileName = 'gcpwstandaloneenterprise.msi'
    }

    <# Download the GCPW installer. #>
    $gcpwUri = 'https://dl.google.com/credentialprovider/' + $gcpwFileName

    Write-Host 'Downloading GCPW from' $gcpwUri
    Invoke-WebRequest -Uri $gcpwUri -OutFile $gcpwFileName

    <# Run the GCPW installer and wait for the installation to finish #>

    Write-Output "Installing Office 2019"
    $run = $InstallPath + 'Office Deployment Tool\setup.exe'
    $Arguments = "/configure `"" + $InstallPath + "Office Deployment Tool\***REMOVED***-2019-ProPlus-Default.xml"
    Start-Process -FilePath $run -ArgumentList $Arguments -NoNewWindow -Wait

    $arguments = "/i `"$gcpwFileName`""
    $installProcess = (Start-Process msiexec.exe -ArgumentList $arguments -PassThru -Wait)

    <# Check if installation was successful #>
    if ($installProcess.ExitCode -ne 0) {
        [System.Windows.MessageBox]::Show('Installation failed!', 'GCPW', 'OK', 'Error')
        exit $installProcess.ExitCode
    }
    else {
        [System.Windows.MessageBox]::Show('Installation completed successfully!', 'GCPW', 'OK', 'Info')
    }

    <# Set the required registry key with the allowed domains #>
    $registryPath = 'HKEY_LOCAL_MACHINE\Software\Google\GCPW'
    $name = 'domains_allowed_to_login'
    [microsoft.win32.registry]::SetValue($registryPath, $name, $domainsAllowedToLogin)

    $domains = Get-ItemPropertyValue HKLM:\Software\Google\GCPW -Name $name

    if ($domains -eq $domainsAllowedToLogin) {
        [System.Windows.MessageBox]::Show('Configuration completed successfully!', 'GCPW', 'OK', 'Info')
    }
    else {
        [System.Windows.MessageBox]::Show('Could not write to registry. Configuration was not completed.', 'GCPW', 'OK', 'Error')

    }
}
}
function Install-MicrosoftOffice {
<#PSScriptInfo

.VERSION 1.2.4

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
}
function Install-RSAT {
<#PSScriptInfo

.VERSION 1.2.2

.GUID 44daac91-76d4-41f5-a2ab-688d548ad0d1

.AUTHOR Jason Cook Martin Bengtsson

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
Install RSAT features for Windows 10 1809 or 1903

.DESCRIPTION
Install RSAT features for Windows 10 1809 or 1903. All features are installed online from Microsoft Update thus the script requires Internet access

.PARAMETER All
Installs all the features within RSAT. This takes several minutes, depending on your Internet connection

.PARAMETER Basic
Installs ADDS, DHCP, DNS, GPO, ServerManager

.PARAMETER ServerManager
Installs ServerManager

.PARAMETER Uninstall
Uninstalls all the RSAT features

.LINK
https://gist.github.com/PeterUpfold/0c83c5ad0bfa821c8a6948eeef5cd932

.LINK
https://www.imab.dk

.LINK
https://twitter.com/mwbengtsson
#>

[CmdletBinding()]
param(
    [parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [switch]$All,
    [parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [switch]$Basic,
    [parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [switch]$ServerManager,
    [parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [switch]$Uninstall
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

if (-NOT([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning -Message "The script requires elevation"
    break
}

$1809Build = "17763"
$1903Build = "18362"
$WindowsBuild = (Get-WmiObject -Class Win32_OperatingSystem).BuildNumber

if (($WindowsBuild -eq $1809Build) -OR ($WindowsBuild -eq $1903Build)) {
    Write-Verbose -Verbose "Running correct Windows 10 build number for installing RSAT with Features on Demand. Build number is: $WindowsBuild"
    if ($PSBoundParameters["All"]) {
        Write-Verbose -Verbose "Script is running with -All parameter. Installing all available RSAT features"
        $Install = Get-WindowsCapability -Online | Where-Object { $_.Name -like "Rsat*" -AND $_.State -eq "NotPresent" }
        if ($null -ne $Install) {
            foreach ($Item in $Install) {
                $RsatItem = $Item.Name
                Write-Verbose -Verbose "Adding $RsatItem to Windows"
                try {
                    Add-WindowsCapability -Online -Name $RsatItem
                }
                catch [System.Exception] {
                    Write-Verbose -Verbose "Failed to add $RsatItem to Windows"
                    Write-Warning -Message $_.Exception.Message
                }
            }
        }
        else {
            Write-Verbose -Verbose "All RSAT features seems to be installed already"
        }
    }

    if ($PSBoundParameters["Basic"]) {
        Write-Verbose -Verbose "Script is running with -Basic parameter. Installing basic RSAT features"
        # Querying for what I see as the basic features of RSAT. Modify this if you think something is missing. :-)
        $Install = Get-WindowsCapability -Online | Where-Object { $_.Name -like "Rsat.ActiveDirectory*" -OR $_.Name -like "Rsat.DHCP.Tools*" -OR $_.Name -like "Rsat.Dns.Tools*" -OR $_.Name -like "Rsat.GroupPolicy*" -AND $_.State -eq "NotPresent" }
        if ($null -ne $Install) {
            foreach ($Item in $Install) {
                $RsatItem = $Item.Name
                Write-Verbose -Verbose "Adding $RsatItem to Windows"
                try {
                    Add-WindowsCapability -Online -Name $RsatItem
                }
                catch [System.Exception] {
                    Write-Verbose -Verbose "Failed to add $RsatItem to Windows"
                    Write-Warning -Message $_.Exception.Message
                }
            }
        }
        else {
            Write-Verbose -Verbose "The basic features of RSAT seems to be installed already"
        }
    }

    if ($PSBoundParameters["ServerManager"]) {
        Write-Verbose -Verbose "Script is running with -ServerManager parameter. Installing Server Manager RSAT feature"
        $Install = Get-WindowsCapability -Online | Where-Object { $_.Name -like "Rsat.ServerManager*" -AND $_.State -eq "NotPresent" }
        if ($null -ne $Install) {
            $RsatItem = $Install.Name
            Write-Verbose -Verbose "Adding $RsatItem to Windows"
            try {
                Add-WindowsCapability -Online -Name $RsatItem
            }
            catch [System.Exception] {
                Write-Verbose -Verbose "Failed to add $RsatItem to Windows"
                Write-Warning -Message $_.Exception.Message ; break
            }
        }

        else {
            Write-Verbose -Verbose "$RsatItem seems to be installed already"
        }
    }

    if ($PSBoundParameters["Uninstall"]) {
        Write-Verbose -Verbose "Script is running with -Uninstall parameter. Uninstalling all RSAT features"
        # Querying for installed RSAT features first time
        $Installed = Get-WindowsCapability -Online | Where-Object { $_.Name -like "Rsat*" -AND $_.State -eq "Installed" -AND $_.Name -notlike "Rsat.ServerManager*" -AND $_.Name -notlike "Rsat.GroupPolicy*" -AND $_.Name -notlike "Rsat.ActiveDirectory*" }
        if ($null -ne $Installed) {
            Write-Verbose -Verbose "Uninstalling the first round of RSAT features"
            # Uninstalling first round of RSAT features - some features seems to be locked until others are uninstalled first
            foreach ($Item in $Installed) {
                $RsatItem = $Item.Name
                Write-Verbose -Verbose "Uninstalling $RsatItem from Windows"
                try {
                    Remove-WindowsCapability -Name $RsatItem -Online
                }
                catch [System.Exception] {
                    Write-Verbose -Verbose "Failed to uninstall $RsatItem from Windows"
                    Write-Warning -Message $_.Exception.Message
                }
            }
        }
        # Querying for installed RSAT features second time
        $Installed = Get-WindowsCapability -Online | Where-Object { $_.Name -like "Rsat*" -AND $_.State -eq "Installed" }
        if ($null -ne $Installed) {
            Write-Verbose -Verbose "Uninstalling the second round of RSAT features"
            # Uninstalling second round of RSAT features
            foreach ($Item in $Installed) {
                $RsatItem = $Item.Name
                Write-Verbose -Verbose "Uninstalling $RsatItem from Windows"
                try {
                    Remove-WindowsCapability -Name $RsatItem -Online
                }
                catch [System.Exception] {
                    Write-Verbose -Verbose "Failed to remove $RsatItem from Windows"
                    Write-Warning -Message $_.Exception.Message
                }
            }
        }
        else {
            Write-Verbose -Verbose "All RSAT features seems to be uninstalled already"
        }
    }
}
else {
    Write-Warning -Message "Not running correct Windows 10 build: $WindowsBuild"

}
}
function Invoke-TickleMailRecipients {
<#PSScriptInfo

.VERSION 1.2.3

.GUID ece98adc-3c44-4a02-a254-d4e7f2888f4f

.AUTHOR Jason Cook Joseph Palarchio

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
Address Lists in Exchange Online do not automatically populate during provisioning and there is no "Update-AddressList" cmdlet.  This script "tickles" mailboxes, mail users and distribution groups so the Address List populates.

.DESCRIPTION
Address Lists in Exchange Online do not automatically populate during provisioning and there is no "Update-AddressList" cmdlet.  This script "tickles" mailboxes, mail users and distribution groups so the Address List populates.

Usage: Additional information on the usage of this script can found at the following blog post:  http://blogs.perficient.com/microsoft/?p=25536

Disclaimer:  This script is provided AS IS without any support. Please test in a lab environment prior to production use.

.LINK
http://blogs.perficient.com/microsoft/?p=25536
#>
param(
  $Mailboxes = (Get-Mailbox -Resultsize Unlimited),
  $MailUsers = (Get-MailUser -Resultsize Unlimited),
  $DistributionGroups = (Get-DistributionGroup -Resultsize Unlimited)
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

foreach ($Mailbox in $Mailboxes) {
  $count1++ ; Progress -Index $count1 -Total $Mailboxes.count -Activity "Tickling mailboxes. Step 1 of 3" -Name $Mailbox.alias
  Set-Mailbox $Mailbox.alias -SimpleDisplayName $Mailbox.SimpleDisplayName -WarningAction silentlyContinue
}

foreach ($MailUser in $MailUsers) {
  $count2++ ; Progress -Index $count2 -Total $MailUsers.count -Activity "Tickling mail users. Step 2 of 3" -Name $Mailuser.alias
  Set-MailUser $Mailuser.alias -SimpleDisplayName $Mailuser.SimpleDisplayName -WarningAction silentlyContinue
}

foreach ($DistributionGroup in $DistributionGroups) {
  $count3++ ; Progress -Index $count3 -Total $DistributionGroups.count -Activity "Tickling distribution groups. Step 3 of 3" -Name $DistributionGroup.alias
  Set-DistributionGroup $DistributionGroup.alias -SimpleDisplayName $DistributionGroup.SimpleDisplayName -WarningAction silentlyContinue
}
}
function Measure-AverageDuration {
<#PSScriptInfo

.VERSION 1.0.1

.GUID f4c6b8ab-e5d2-4967-b803-a410619bd191

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
This will run the specified command several times and report the average duration for execution.

.PARAMETER Command
The command that will be run.

.PARAMETER Times
How many times the command will be repeated

.PARAMETER Name
The name or description to use in the progress bar.
#>
param(
    [string]$Command,
    [ValidateRange(1, [int]::MaxValue)][int]$Times = 100,
    [string]$Name = $Command

)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

1..$Times | ForEach-Object {
    Write-Progress -Id 1 -Activity $Name -PercentComplete $_
    $Duration += (Measure-Command {
            pwsh -noprofile -command $Command
        }).TotalMilliseconds
}
Write-Progress -id 1 -Activity $Name -Completed
return @{
    Average = $Duration / 100
    Total   = $Duration
}
}
function Move-ArchiveEventLogs {
<#PSScriptInfo

.VERSION 1.0.4

.GUID f12cad80-f34f-402f-aa4a-e92d80f725a9

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
Archive Windows Event logs.

.PARAMETER Path
The location log files should be moved to.

.PARAMETER EventPath
The location log files should be moved from.

.PARAMETER IgnoreHostname
Exclude the hostname from the path when moving the log files.

.EXAMPLE
Move-ArchiveEventLogs -Path \\server\logs
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateScript({ Test-Path $_ })][string]$Path,
    [ValidateScript({ Test-Path $_ })][string]$EventPath = (Join-Path -Path $Env:windir -ChildPath "\System32\winevt\Logs"),
    [switch]$IgnoreHostname
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

if (-not $IgnoreHostname) {
    $NewPath = (Join-Path -Path $Path -ChildPath $Env:computername)
    New-Item -Path $NewPath -ItemType Directory -Force | Out-Null
    $Path = $NewPath
}

Write-Verbose "Moving log files to $Path"
$Files = Get-ChildItem -Path $EventPath -Filter "Archive-*.evtx" -File | Sort-Object -Property LastWriteTime
$Files | ForEach-Object {
    $count++ ; Progress -Index $count -Total $Files.count -Activity "Moving archive event logs." -Name $_.Name
    Move-Item -Path $_.FullName -Destination $Path -ErrorAction Stop
}
}
function New-FortiClientConfig {
<#PSScriptInfo

.VERSION 1.0.5

.GUID 93f5aa38-3ef7-4d57-8225-1ba9e7167243

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
Used to generate a config file for FortiClient VPN.

.PARAMETER Path
Where should the config file be saved?

.PARAMETER Locations
A hastable of the location names and gateways.

.PARAMETER AllGateways
The name of the VPN conections to create containing all gateways.

.PARAMETER Start
The start of the XML file.

.PARAMETER End
The end of the XML file, after all the connections are created.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(ValueFromPipeline = $true)][string]$Path,
    [Parameter(ValueFromPipeline = $true)][hashtable]$Locations,
    [Parameter(ValueFromPipeline = $true)][string]$AllGateways,
    $Start = '
<?xml version="1.0" encoding="UTF-8" ?>
<forticlient_configuration>
    <forticlient_version>6.0.10.297</forticlient_version>
    <version>6.0.10</version>
    <exported_by_version>6.0.10.0297</exported_by_version>
    <date>2022/07/05</date>
    <partial_configuration>0</partial_configuration>
    <os_version>windows</os_version>
    <os_architecture>x64</os_architecture>
    <system>
        <ui>
            <disable_backup>0</disable_backup>
            <ads>1</ads>
            <default_tab>VPN</default_tab>
            <flashing_system_tray_icon>1</flashing_system_tray_icon>
            <hide_system_tray_icon>0</hide_system_tray_icon>
            <suppress_admin_prompt>0</suppress_admin_prompt>
            <password />
            <hide_user_info>0</hide_user_info>
            <culture_code>os-default</culture_code>
            <gpu_rendering>0</gpu_rendering>
            <replacement_messages>
                <quarantine>
                    <title>
                        <title>
                            <![CDATA[EncX B3BE58EB0FD91B6B866DF7E9459BEB7F0697746CE89427F20469594DB893779458DFF6A49EFC8898C44D4C37309DCB818B9D6EB3174F8CF2676EF458E1AADA1C0E9852D7E752091EAA4F1FE80044]]>
                        </title>
                    </title>
                    <statement>
                        <remediation>
                            <![CDATA[EncX D902BBB4D91522281CB2C525118B12D7790277C80142DE997D307E083A62FD471E58C7F0CCF1]]>
                        </remediation>
                    </statement>
                    <remediation>
                        <remediation>
                            <![CDATA[EncX 8484E04F33E964972BED5802A862373493F46245F243FC580640A599612B7705E42ABE874CBC76EECB4BB5BB96EAF652BD28F128F0D16B5E258BBB8A7099F96BE16D3B48EDC03159C3C61C87AECACC3D44D311D323DD5048D03F9640882166805562E45B5D89A6B0249CAA2ADC208E838AECF2]]>
                        </remediation>
                    </remediation>
                </quarantine>
            </replacement_messages>
        </ui>
        <log_settings>
            <onnet_local_logging>1</onnet_local_logging>
            <level>6</level>
            <log_events>ipsecvpn,sslvpn,scheduler,update,firewall</log_events>
            <remote_logging>
                <log_upload_enabled>0</log_upload_enabled>
                <log_upload_server />
                <log_upload_ssl_enabled>1</log_upload_ssl_enabled>
                <log_retention_days>90</log_retention_days>
                <log_upload_freq_minutes>60</log_upload_freq_minutes>
                <log_generation_timeout_secs>900</log_generation_timeout_secs>
                <netlog_categories>0</netlog_categories>
                <log_protocol>faz</log_protocol>
                <netlog_server />
            </remote_logging>
        </log_settings>
        <proxy>
            <update>0</update>
            <online_scep>0</online_scep>
            <type>http</type>
            <address />
            <port>80</port>
            <username>
                <![CDATA[Enc c3576adf25674d0e8657f64357e0eca3c8ff8f09ad4a07ce]]>
            </username>
            <password>
                <![CDATA[Enc 715ec34363eda0d92f180c6926fa6e7e19f18b19ae60b178]]>
            </password>
        </proxy>
        <update>
            <use_custom_server>0</use_custom_server>
            <restrict_services_to_regions />
            <server />
            <port>80</port>
            <timeout>60</timeout>
            <failoverport />
            <fail_over_to_fdn>1</fail_over_to_fdn>
            <use_proxy_when_fail_over_to_fdn>1</use_proxy_when_fail_over_to_fdn>
            <auto_patch>0</auto_patch>
            <submit_virus_info_to_fds>1</submit_virus_info_to_fds>
            <submit_vuln_info_to_fds>1</submit_vuln_info_to_fds>
            <update_action>download_and_install</update_action>
            <scheduled_update>
                <enabled>1</enabled>
                <type>interval</type>
                <daily_at>06:09</daily_at>
                <update_interval_in_hours>6</update_interval_in_hours>
            </scheduled_update>
        </update>
        <fortiproxy>
            <enabled>1</enabled>
            <enable_https_proxy>1</enable_https_proxy>
            <http_timeout>60</http_timeout>
            <client_comforting>
                <pop3_client>1</pop3_client>
                <pop3_server>1</pop3_server>
                <smtp>1</smtp>
            </client_comforting>
            <selftest>
                <enabled>1</enabled>
                <last_port>65535</last_port>
                <notify>1</notify>
            </selftest>
        </fortiproxy>
        <certificates>
            <crl>
                <ocsp>
                    <enabled>0</enabled>
                    <server />
                    <port />
                </ocsp>
            </crl>
            <hdd />
            <ca />
        </certificates>
    </system>
    <endpoint_control>
        <enabled>1</enabled>
        <socket_connect_timeouts>1:5</socket_connect_timeouts>
        <system_data>Enc 0dae8cf21fd55eea5d2961a1418235552038b0c924af92486ca781f294b60b765aa6926a792f8f91a177d2975d5b32aed2145e67f1f764d2331451a73b0378c16bcb11a1e63534dfd3201a9e</system_data>
        <disable_unregister>0</disable_unregister>
        <disable_fgt_switch>0</disable_fgt_switch>
        <show_bubble_notifications>1</show_bubble_notifications>
        <avatar_enabled>1</avatar_enabled>
        <ui>
            <display_antivirus>0</display_antivirus>
            <display_webfilter>0</display_webfilter>
            <display_firewall>0</display_firewall>
            <display_vpn>1</display_vpn>
            <display_vulnerability_scan>0</display_vulnerability_scan>
            <display_sandbox>0</display_sandbox>
            <display_compliance>0</display_compliance>
            <hide_compliance_warning>0</hide_compliance_warning>
            <registration_dialog>
                <show_profile_details>1</show_profile_details>
            </registration_dialog>
        </ui>
        <onnet_addresses>
            <address />
        </onnet_addresses>
        <onnet_mac_addresses />
        <alerts>
            <notify_server>1</notify_server>
            <alert_threshold>1</alert_threshold>
        </alerts>
        <fortigates>
            <fortigate>
                <serial_number />
                <name />
                <registration_password />
                <addresses />
            </fortigate>
        </fortigates>
        <local_subnets_only>0</local_subnets_only>
        <notification_server />
        <nac>
            <processes>
                <process id="" rule="present">
                    <signature name="" />
                </process>
            </processes>
            <files>
                <path id="" />
            </files>
            <registry>
                <path id="" />
            </registry>
        </nac>
    </endpoint_control>
    <vpn>
        <options>
            <autoconnect_tunnel />
            <autoconnect_only_when_offnet>0</autoconnect_only_when_offnet>
            <keep_running_max_tries>0</keep_running_max_tries>
            <disable_internet_check>0</disable_internet_check>
            <suppress_vpn_notification>0</suppress_vpn_notification>
            <minimize_window_on_connect>1</minimize_window_on_connect>
            <allow_personal_vpns>1</allow_personal_vpns>
            <disable_connect_disconnect>0</disable_connect_disconnect>
            <show_vpn_before_logon>1</show_vpn_before_logon>
            <use_windows_credentials>1</use_windows_credentials>
            <use_legacy_vpn_before_logon>0</use_legacy_vpn_before_logon>
            <show_negotiation_wnd>0</show_negotiation_wnd>
            <vendor_id />
        </options>
        <sslvpn>
            <options>
                <enabled>1</enabled>
                <prefer_sslvpn_dns>1</prefer_sslvpn_dns>
                <dnscache_service_control>0</dnscache_service_control>
                <use_legacy_ssl_adapter>0</use_legacy_ssl_adapter>
                <preferred_dtls_tunnel>1</preferred_dtls_tunnel>
                <block_ipv6>0</block_ipv6>
                <no_dhcp_server_route>0</no_dhcp_server_route>
                <no_dns_registration>0</no_dns_registration>
                <disallow_invalid_server_certificate>0</disallow_invalid_server_certificate>
            </options>
            <connections>',
    $End = '
            </connections>
        </sslvpn>
        <ipsecvpn>
            <options>
                <enabled>1</enabled>
                <beep_if_error>0</beep_if_error>
                <usewincert>1</usewincert>
                <use_win_current_user_cert>1</use_win_current_user_cert>
                <use_win_local_computer_cert>1</use_win_local_computer_cert>
                <block_ipv6>1</block_ipv6>
                <uselocalcert>0</uselocalcert>
                <usesmcardcert>1</usesmcardcert>
                <enable_udp_checksum>0</enable_udp_checksum>
                <disable_default_route>0</disable_default_route>
                <show_auth_cert_only>0</show_auth_cert_only>
                <check_for_cert_private_key>0</check_for_cert_private_key>
                <enhanced_key_usage_mandatory>0</enhanced_key_usage_mandatory>
            </options>
            <connections />
        </ipsecvpn>
    </vpn>
</forticlient_configuration>
'
)

function BuildConfig {
    Param(
        [ValidateLength(1, 31)][string]$Name,
        [ValidatePattern('(?m)^(?:\w|.)*:[1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5]')][string]$Gateway
    )
    return "
    <connection>
        <name>$Name</name>
        <description />
        <server>$Gateway</server>
        <username />
        <single_user_mode>0</single_user_mode>
        <ui>
            <show_remember_password>0</show_remember_password>
            <show_alwaysup>0</show_alwaysup>
        </ui>
        <password />
        <warn_invalid_server_certificate>1</warn_invalid_server_certificate>
        <prompt_certificate>0</prompt_certificate>
        <prompt_username>1</prompt_username>
        <on_connect>
            <script>
                <os>windows</os>
                <script>
                    <![CDATA[]]>
                </script>
            </script>
        </on_connect>
        <on_disconnect>
            <script>
                <os>windows</os>
                <script>
                    <![CDATA[]]>
                </script>
            </script>
        </on_disconnect>
    </connection>"
}

$Mid = ""
if ($AllGateways) { $Mid += BuildConfig -Name $AllGateways -Gateway ($Locations.Values -join ";") }
$Locations.Keys | ForEach-Object { $Mid += BuildConfig -Name $_ -Gateway $Locations[$_] }
$Config = ($Start + $Mid + $End)
If ($PSCmdlet.ShouldProcess("$Path", "Create-FortiClientConfig")) { Set-Content -Path $Path -Value $Config }
else { return $Config }
}
function New-Password {
<#PSScriptInfo

.VERSION 1.0.3

.GUID 1591ca01-1cf9-4683-9d24-fbd1f746f44c

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
This will return a random password which meets Active Directory's complexity requirements.
.PARAMETER Lenght
The lenght of the password to return. The default is 8 characters.

.PARAMETER Symbols
The number of symbols to include in the password. The default is 2 symbols.

.LINK
http://woshub.com/generating-random-password-with-powershell/

.LINK
https://docs.microsoft.com/en-us/dotnet/api/system.web.security.membership.generatepassword?view=netframework-4.8

#>
param (
  [int]$Lenght = 8,
  [int]$Symbols = 2
)

Add-Type -AssemblyName System.Web

do {
  $Password = [System.Web.Security.Membership]::GeneratePassword($Lenght, $Symbols)
  If (     ($Password -cmatch "[A-Z\p{Lu}\s]") `
      -and ($Password -cmatch "[a-z\p{Ll}\s]") `
      -and ($Password -match "[\d]") `
      -and ($Password -match "[^\w]")
  ) { $Complex = $True }
} While (-not $Complex)

return $Password
}
function New-RandomCharacters {
<#PSScriptInfo

.VERSION 1.0.1

.GUID 9f443ca7-e536-40ee-a774-7d94c5d3c569

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
This will return random characters.

.PARAMETER Lenght
The number of characters to return.

.PARAMETER Characters
A string of characters to use.
#>
param (
  [ValidateRange(1, [int]::MaxValue)][int]$Length = 1,
  $Characters = "abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!@#$%^&*()_+-=[]\{}|;:,./<>?"
)

$Random = 1..$Length | ForEach-Object { Get-Random -Maximum $Characters.length }
$private:ofs = ""
return [String]$Characters[$Random]
}
function Ping-Hosts {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 0603a3ee-bff9-464a-aa86-44903c476fe9

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
Ping a list of hosts

.LINK
https://geekeefy.wordpress.com/2015/07/16/powershell-fancy-test-connection/
#>
Param
(
    [Parameter(position = 0)] $Hosts,
    [Parameter] $ToCsv
)

Function MakeSpace($l, $Maximum) {
    $space = ""
    $s = [int]($Maximum - $l) + 1
    1..$s | ForEach-Object { $space += " " }

    return [String]$space
}
$LengthArray = @()
$Hosts | ForEach-Object { $LengthArray += $_.length }

$Maximum = ($LengthArray | Measure-object -Maximum).maximum
$Count = $hosts.Count

$Success = New-Object int[] $Count
$Failure = New-Object int[] $Count
$Total = New-Object int[] $Count
Clear-Host
while ($true) {

    $i = 0 #Index number of the host stored in the array
    $out = "| HOST$(MakeSpace 4 $Maximum)| STATUS | SUCCESS  | FAILURE  | ATTEMPTS  |"
    $Firstline = ""
    1..$out.length | ForEach-Object { $firstline += "_" }

    #output the Header Row on the screen
    Write-Host $Firstline
    Write-host $out -ForegroundColor White -BackgroundColor Black

    $Hosts | ForEach-Object {
        $total[$i]++
        If (Test-Connection $_ -Count 1 -Quiet -ErrorAction SilentlyContinue) {
            $success[$i] += 1
            #Percent calclated on basis of number of attempts made
            $SuccessPercent = $("{0:N2}" -f (($success[$i] / $total[$i]) * 100))
            $FailurePercent = $("{0:N2}" -f (($Failure[$i] / $total[$i]) * 100))

            #Print status UP in GREEN if above condition is met
            Write-Host "| $_$(MakeSpace $_.Length $Maximum)| UP$(MakeSpace 2 4)  | $SuccessPercent`%$(MakeSpace ([string]$SuccessPercent).length 6) | $FailurePercent`%$(MakeSpace ([string]$FailurePercent).length 6) | $($Total[$i])$(MakeSpace ([string]$Total[$i]).length 9)|" -BackgroundColor Green
        }
        else {
            $Failure[$i] += 1

            #Percent calclated on basis of number of attempts made
            $SuccessPercent = $("{0:N2}" -f (($success[$i] / $total[$i]) * 100))
            $FailurePercent = $("{0:N2}" -f (($Failure[$i] / $total[$i]) * 100))

            #Print status DOWN in RED if above condition is met
            Write-Host "| $_$(MakeSpace $_.Length $Maximum)| DOWN$(MakeSpace 4 4)  | $SuccessPercent`%$(MakeSpace ([string]$SuccessPercent).length 6) | $FailurePercent`%$(MakeSpace ([string]$FailurePercent).length 6) | $($Total[$i])$(MakeSpace ([string]$Total[$i]).length 9)|" -BackgroundColor Red
        }
        $i++

    }

    #Pause the loop for few seconds so that output
    #stays on screen for a while and doesn't refreshes

    Start-Sleep -Seconds 4
    Clear-Host
}
}
function Remove-AuthenticodeSignature {
<#PSScriptInfo

.VERSION 1.0.7

.GUID 3262ca7f-d1f0-4539-9fee-90fb4580623b

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
This script will sign remove all authenicode signatures from a file.

.LINK
http://psrdrgz.github.io/RemoveAuthenticodeSignature/#:~:text=%20Removing%20Authenticode%20Signatures%20%201%20Open%20the,the%20bottom.%203%20Save%20the%20file.%20More%20

.LINK
https://stackoverflow.com/questions/1928158/how-can-i-remove-signing-from-powershell

.EXAMPLE
Remove-AuthenticodeSignature -File Script.ps1
#>

[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    [Alias('Path')]
    [system.io.fileinfo[]]$FilePath
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

If ($PSCmdlet.ShouldProcess($FilePath, "Remove-AuthenticodeSignature")) {
    try {
        $Content = Get-Content $FilePath
        $SignatureLineNumber = (Get-Content $FilePath | select-string "SIG # Begin signature block").LineNumber
        if ($null -eq $SignatureLineNumber -or $SignatureLineNumber -eq 0) {
            Write-Warning "No signature found. Nothing to do."
        }
        else {
            $Content = Get-Content $FilePath
            $Content[0..($SignatureLineNumber - 2)] | Set-Content $FilePath
        }

    }
    catch {
        Write-Error "Failed to remove signature. $($_.Exception.Message)"
    }
}
}
function Remove-BlankLines {
<#PSScriptInfo

.VERSION 1.0.1

.GUID c0df5582-8e43-491d-92ce-410392bb9912

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
This will remove superfluous blank lines from a string.
#>

param([string]$String)
while ($String.Contains("`r`n`r`n`r`n")) { $String = ($String -replace "`r`n`r`n`r`n", "`r`n`r`n").Trim() }
return $String
}
function Remove-CachedWallpaper {
<#PSScriptInfo
.VERSION 1.0.1
.GUID 2a1c91e6-58fd-4f37-9daf-370b954c31e4

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.SYNOPSIS
This script removes the caches wallpaper.

.DESCRIPTION
This script removes the caches wallpaper by deleting %appdata%\Microsoft\Windows\Themes\TranscodedWallpaper

.EXAMPLE
Remove-CachedWallpaper
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param ()
Remove-Item "$Env:appdata\Microsoft\Windows\Themes\TranscodedWallpaper" -ErrorAction SilentlyContinue
Remove-Item "$Env:appdata\Microsoft\Windows\Themes\CachedFiles\*.*" -ErrorAction SilentlyContinue
}
function Remove-GroupEmail {
<#PSScriptInfo

.VERSION 1.0.5

.GUID 214ed066-0271-4c0b-8210-8554f8de4f4a

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
Remove an email address to an existing Microsoft 365 group.

.DESCRIPTION
Remove an email address to an existing Microsoft 365 group. You can also use this to set the primary address for the group.

.PARAMETER Identity
The identity of the group you wish to change.

.PARAMETER EmailAddress
The email address you whish to Remove.

.PARAMETER SetPrimary
If set, this will set the email adress you specified as the primary address for the group.

.EXAMPLE
Remove-GroupEmail -Identity staff -EmailAddress staff@example.com
#>

param (
  [string]$GroupName,
  [string]$EmailAddress
)

Set-UnifiedGroup -Identity $GroupName -EmailAddresses: @{Remove = $EmailAddress }
}
function Remove-MailboxOrphanedSids {
<#PSScriptInfo

.VERSION 1.0.1

.GUID fc0d9531-8d08-4b67-8247-7ade678c2d31

.AUTHOR Jason Cook CarlosDZRZ

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
Remove Mailbox Orphaned_SIDs Access Control Lists (ACLs) and Access Control Entries (ACEs)

.DESCRIPTION
Remove Mailbox Orphaned_SIDs Access Control Lists (ACLs) and Access Control Entries (ACEs)

.PARAMETER  Alias
The Alias parameter specifies the alias (mail nickname) of the user.

.PARAMETER  PathFolder
Specifies a path to log folder location.The default location is $env:USERPROFILE+'\EXCH_RemoveSIDs\'

.EXAMPLE
Remove-MailboxOrphaned_SIDs -Alias test_mailbox

.EXAMPLE
Get-Mailbox test_mailbox | Remove-MailboxOrphaned_SIDs

.EXAMPLE
$mailboxes = Get-Mailbox -ResultSize 0
$mailboxes | Remove-MailboxOrphaned_SIDs

.OUTPUTS
Log file.

.NOTES
Date Created: 04/08/2016

.LINK
https://technet.microsoft.com/es-es/library/aa998218(v=exchg.160).aspx

.LINK
https://technet.microsoft.com/en-us/library/hh360993.aspx

#>
[CmdletBinding()]
Param
(
	[parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string[]]$Alias,
	[string]$PathFolder = $env:USERPROFILE + '\EXCH_RemoveSIDs\'
)
Begin {
	$date = (Get-Date).Day.ToString() + "-" + (Get-Date).Month.ToString() + "-" + (Get-Date).Year.ToString()
	$filename = "RemoveSIDs_" + $date
	Write-Verbose $PathFolder
	if (!(Test-Path -Path $PathFolder -PathType Container)) {
		New-Item -Path $PathFolder  -ItemType directory
		Write-Host -ForegroundColor Green "create a new folder"
	}
	$filepath = $PathFolder + $filename + '.log'
	$stream = [System.IO.StreamWriter] $filepath
	$usrs_access = ""
	$usr_access = ""
}
Process {
	foreach ($Aliasmbx in $Alias) {
		$writelog = $false
		$SID_AccessRights = $null
		$SID_SendAs = $null
		$usrs_access = Get-MailboxPermission $Aliasmbx | Where-Object { ($_.isinherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF") } | Select-Object User, AccessRights
		foreach ($usr_access in $usrs_access) {
			if ($usr_access.User -like 'S-1-5-21*') {
				$writelog = $true
				Remove-MailboxPermission $Aliasmbx -User $usr_access.User -AccessRights $usr_access.AccessRights -Confirm:$false
				Write-Verbose "SID to delete:  $($usr_access.User) with the following permissions: $($usr_access.AccessRights) on $Aliasmbx mailbox"
				$SID_AccessRights += "SID to delete:  $($usr_access.User) with the following permissions: $($usr_access.AccessRights) `r`n"
			}
		}
		# $usrs_SendAs = Get-Mailbox $Aliasmbx | Get-ADPermission | Where-Object {($_.ExtendedRights -like "*-As*") -and -not ($_.User -like "NT AUTHORITY\SELF")}
		foreach ($usr_SendAs in $usrs_SendAs) {
			if ($usr_SendAs.User -like 'S-1-5-21*') {
				$writelog = $true
				Remove-AdPermission $Aliasmbx -User $usr_SendAs.User -ExtendedRights $usr_SendAs.ExtendedRights -Confirm:$false
				Write-Verbose "SID to delete:  $($usr_SendAs.User) with the permission $($usr_SendAs.ExtendedRights) on $Aliasmbx mailbox"
				$SID_SendAs += "SID to delete:  $($usr_SendAs.User) with the permission $($usr_SendAs.ExtendedRights) `r`n"
			}
		}
		if ($writelog) {
			$stream.WriteLine("============================================================================")
			$stream.WriteLine("Buzon: $Aliasmbx")
			if ($null -ne $SID_AccessRights) { $stream.WriteLine($SID_AccessRights) }
			if ($null -ne $SID_SendAs) { $stream.WriteLine($SID_SendAs) }
			$stream.WriteLine("============================================================================")
		}
	}
}#End Process
End {
	$stream.close()
}
}
function Remove-OldFolders {
<#PSScriptInfo

.VERSION 1.0.2

.GUID cb98c8e9-cb35-4db2-9fe8-33afb9eb2272

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
This script will trim the spesified folder to the number of items specified.

.DESCRIPTION
This script will trim the spesified folder to the number of items specified.

.PARAMETER Path
This can be used to select a folder in which to run these commands on. If unspecified, it will run in the current folder.

.PARAMETER Keep
This is the number of files to keep in the folder. If unspecified, it will keep 10 copies.

.EXAMPLE
Remove-OldFolders -Folder C:\Backups\ -Keep 10
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript( { Test-Path $_ })][string]$Path = (Get-Location),
  [ValidateRange(1, [int]::MaxValue)][int]$Keep = 10
)

Get-ChildItem $Path -Directory | Sort-Object CreationTime -Descending | Select-Object -Skip $Keep | ForEach-Object {
  If ($PSCmdlet.ShouldProcess("$_", "Trim-Folder -Keep $Keep")) {
    Remove-Item -Path $_ -Recurse -Force
  }
}
}
function Remove-OldModuleVersions {
<#PSScriptInfo

.VERSION 0.0.12

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

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
Requires -Version 2.0 -Modules PowerShellGet

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
}
function Remove-UserPASSWD_NOTREQD {
<#PSScriptInfo

.VERSION 1.0.5

.GUID 6309e154-81f6-4bd1-aff7-deaea3274934

.AUTHOR Jason Cook Robin Granberg (robin.granberg@microsoft.com)

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
Search for user accounts with "ADS_UF_PASSWD_NOTREQD" enabled and remove the flag

.NOTES
TODO Build better help
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", Scope = "Function", Target = "*")]
param([string]$Path,
    [string]$Server,
    [switch]$Subtree,
    [string]$LogFile,
    [switch]$help)

function funHelp() {
    Clear-Host
    $helpText = @"
THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR
FITNESS FOR A PARTICULAR PURPOSE.

This sample is not supported under any Microsoft standard support program or service.
The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
implied warranties including, without limitation, any implied warranties of merchantability
or of fitness for a particular purpose. The entire risk arising out of the use or performance
of the sample and documentation remains with you. In no event shall Microsoft, its authors,
or anyone else involved in the creation, production, or delivery of the script be liable for
any damages whatsoever (including, without limitation, damages for loss of business profits,
business interruption, loss of business information, or other pecuniary loss) arising out of
the use of or inability to use the sample or documentation, even if Microsoft has been advised

DESCRIPTION:
NAME: RemoveUserPASSWD_NOTREQD.ps1
Search for user accounts with "ADS_UF_PASSWD_NOTREQD" enabled and remove the flag
This script requires Active Directory Module for Windows PowerShell.
Run "import-module activedirectory" before running the script.

SYSTEM REQUIREMENTS:

- Windows Powershell

- Active Directory Module for Windows PowerShell

- Connection to a Active Directory Domain

- Modify User Object Permissions in Active Directory

PARAMETERS:

-Path          Where to start search, DistinguishedName within quotation mark (")
-Server        Name of Domain Controller
-Subtree       Do a subtree search (Optional)
-help          Prints the HelpFile (Optional)

SYNTAX:
 -------------------------- EXAMPLE 1 --------------------------

.\RemoveUserPASSWD_NOTREQD.ps1 -Server DC1 -Path "OU=Sales,DC=contoso,DC=com"

 Description
 -----------
 This command will remove "ADS_UF_PASSWD_NOTREQD" on all user accounts under OU=Sales,DC=contoso,DC=com.

 -------------------------- EXAMPLE 2 --------------------------

.\RemoveUserPASSWD_NOTREQD.ps1 -Server DC1 -Path "OU=Sales,DC=contoso,DC=com" -subtree

 Description
 -----------
 This command will remove "ADS_UF_PASSWD_NOTREQD" on all user accounts under OU=Sales,DC=contoso,DC=com and in all sub OU's.

 -------------------------- EXAMPLE 3 --------------------------

.\RemoveUserPASSWD_NOTREQD.ps1 -Server DC1 -Path "OU=Sales,DC=contoso,DC=com" -subtree -logfile c:\log.txt

 Description
 -----------
 This command will remove "ADS_UF_PASSWD_NOTREQD" on all user accounts under OU=Sales,DC=contoso,DC=com and in all sub OU's.
 The output will also be put in a logfile.

 -------------------------- EXAMPLE 4 --------------------------

.\RemoveUserPASSWD_NOTREQD.ps1  -help

 Description
 -----------
 Displays the help topic for the script

"@
    write-host $helpText
    exit
}
function reqHelp() {
    Clear-Host
    $helpText = @"
THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR
FITNESS FOR A PARTICULAR PURPOSE.

This sample is not supported under any Microsoft standard support program or service.
The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
implied warranties including, without limitation, any implied warranties of merchantability
or of fitness for a particular purpose. The entire risk arising out of the use or performance
of the sample and documentation remains with you. In no event shall Microsoft, its authors,
or anyone else involved in the creation, production, or delivery of the script be liable for
any damages whatsoever (including, without limitation, damages for loss of business profits,
business interruption, loss of business information, or other pecuniary loss) arising out of
the use of or inability to use the sample or documentation, even if Microsoft has been advised

DESCRIPTION:
NAME: RemoveUserPASSWD_NOTREQD.ps1
Search for user accounts with "ADS_UF_PASSWD_NOTREQD" enabled and remove the flag
This script requires Active Directory Module for Windows PowerShell.
Run "import-module activedirectory" before running the script.

SYSTEM REQUIREMENTS:

- Windows Powershell

- Active Directory Module for Windows PowerShell

- Connection to a Active Directory Domain

- Modify User Object Permissions in Active Directory

"@
    write-host $helpText
    exit
}
if ($null -eq $(Get-Module | Where-Object { $_.name -eq "activedirectory" })) {
    reqHelp
    exit
}
$script:ErrCtrlrActionPreference = "SilentlyContinue"
Function GetUserAccCtrlStatus ($userDN) {

    $objUser = get-aduser -server $Server $userDN -properties useraccountcontrol

    [string] $strStatus = ""

    if ($objUser.useraccountcontrol -band 2)
    { $strStatus = $strStatus + ",ADS_UF_ACCOUNT_DISABLE" }
    if ($objUser.useraccountcontrol -band 8)
    { $strStatus = $strStatus + ",ADS_UF_HOMEDIR_REQUIRED" }
    if ($objUser.useraccountcontrol -band 16)
    { $strStatus = $strStatus + ",ADS_UF_LOCKOUT" }
    if ($objUser.useraccountcontrol -band 32)
    { $strStatus = $strStatus + ",ADS_UF_PASSWD_NOTREQD" }
    if ($objUser.useraccountcontrol -band 64)
    { $strStatus = $strStatus + ",ADS_UF_PASSWD_CANT_CHANGE" }
    if ($objUser.useraccountcontrol -band 128)
    { $strStatus = $strStatus + ",ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED" }
    if ($objUser.useraccountcontrol -band 512)
    { $strStatus = $strStatus + ",ADS_UF_NORMAL_ACCOUNT" }
    if ($objUser.useraccountcontrol -band 2048)
    { $strStatus = $strStatus + ",ADS_UF_INTERDOMAIN_TRUST_ACCOUNT" }
    if ($objUser.useraccountcontrol -band 4096)
    { $strStatus = $strStatus + ",ADS_UF_WORKSTATION_TRUST_ACCOUNT" }
    if ($objUser.useraccountcontrol -band 8192)
    { $strStatus = $strStatus + ",ADS_UF_SERVER_TRUST_ACCOUNT" }
    if ($objUser.useraccountcontrol -band 65536)
    { $strStatus = $strStatus + ",ADS_UF_DONT_EXPIRE_PASSWD" }
    if ($objUser.useraccountcontrol -band 131072)
    { $strStatus = $strStatus + ",ADS_UF_MNS_LOGON_ACCOUNT" }
    if ($objUser.useraccountcontrol -band 262144)
    { $strStatus = $strStatus + ",ADS_UF_SMARTCARD_REQUIRED" }
    if ($objUser.useraccountcontrol -band 524288)
    { $strStatus = $strStatus + ",ADS_UF_TRUSTED_FOR_DELEGATION" }
    if ($objUser.useraccountcontrol -band 1048576)
    { $strStatus = $strStatus + ",ADS_UF_NOT_DELEGATED" }
    if ($objUser.useraccountcontrol -band 2097152)
    { $strStatus = $strStatus + ",ADS_UF_USE_DES_KEY_ONLY" }
    if ($objUser.useraccountcontrol -band 4194304)
    { $strStatus = $strStatus + ",ADS_UF_DONT_REQUIRE_PREAUTH" }
    if ($objUser.useraccountcontrol -band 8388608)
    { $strStatus = $strStatus + ",ADS_UF_PASSWORD_EXPIRED" }
    if ($objUser.useraccountcontrol -band 16777216)
    { $strStatus = $strStatus + ",ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION" }
    if ($objUser.useraccountcontrol -band 33554432)
    { $strStatus = $strStatus + ",ADS_UF_NO_AUTH_DATA_REQUIRED" }
    if ($objUser.useraccountcontrol -band 67108864)
    { $strStatus = $strStatus + ",ADS_UF_PARTIAL_SECRETS_ACCOUNT" }

    [int] $index = $strStatus.IndexOf(",")
    If ($index -eq 0) {
        $strStatus = $strStatus.substring($strStatus.IndexOf(",") + 1, $strStatus.Length - 1 )
    }

    return $strStatus

}#End function

function CheckDNExist {
    Param (
        $sADobjectName
    )
    $sADobjectName = "LDAP://" + $sADobjectName
    $ADobject = [ADSI] $sADobjectName
    If ($null -eq $ADobject.distinguishedName)
    { return $false }
    else
    { return $true }

}#End function

if ($help -or !($Path) -or !($Server)) { funHelp }
if (!($LogFile -eq "")) {
    if (Test-Path $LogFile) {
        Remove-Item $LogFile
    }
}
If (CheckDNExist $Path) {
    $index = 0
    if ($Subtree) {
        $users = get-aduser -server $Server -LDAPfilter "(&(objectCategory=person)(objectClass=user)(!userAccountControl:1.2.840.113556.1.4.803:=2048)(userAccountControl:1.2.840.113556.1.4.803:=32))" -searchbase $Path -properties useraccountcontrol -SearchScope Subtree

    }
    else {
        $users = get-aduser -server $Server -LDAPfilter "(&(objectCategory=person)(objectClass=user)(!userAccountControl:1.2.840.113556.1.4.803:=2048)(userAccountControl:1.2.840.113556.1.4.803:=32))" -searchbase $Path -properties useraccountcontrol -SearchScope OneLevel
    }
    if ($users -is [array]) {
        while ($index -le $users.psbase.length - 1) {
            $global:ErrCtrl = $false
            $global:strUserDN = $users[$index]
            $objUser = [ADSI]"LDAP://$global:strUserDN"
            $global:strUserName = $objUser.cn

            & { #Try
                set-aduser -server $Server $users[$index] -PasswordNotRequired $false
            }

            Trap [SystemException] {
                $global:ErrCtrl = $true
                Write-host $users[$index].name";Failed;"$_ -Foreground red
                if (!($LogFile -eq "")) {
                    [string] $strMsg = ($global:strUserName + ";Failed;" + $_.tostring().replace("`n", ""))
                    Out-File -Append -FilePath $LogFile -inputobject $strMsg -force
                }
                ; Continue
            }

            if ($ErrCtrl -eq $false) {
                Write-host $users[$index].name";Success;Status:"(GetUserAccCtrlStatus($users[$index])) -Foreground green
                if (!($LogFile -eq "")) {
                    [string] $strUserNames = $global:strUserName
                    [string] $strUrsStatus = GetUserAccCtrlStatus($global:strUserDN)
                    [string] $strMsg = ("$strUserNames" + ";Success;Status:" + "$strUrsStatus")
                    Out-File -Append -FilePath $LogFile -inputobject $strMsg -force
                }
            }
            $index++
        }
    }
    elseif ($null -ne $users) {
        $global:ErrCtrl = $false
        $global:strUserDN = $users
        $objUser = [ADSI]"LDAP://$global:strUserDN"
        $global:strUserName = $objUser.cn

        & { #Try
            $global:ErrCtrl = $false
            set-aduser -server $Server $users -PasswordNotRequired $false

        }

        Trap [SystemException] {
            $global:ErrCtrl = $true
            Write-host $users.name";Failed;"$_ -Foreground red
            if (!($LogFile -eq "")) {
                [string] $strMsg = ($global:strUserName + ";Failed;" + $_.tostring().replace("`n", ""))
                Out-File -Append -FilePath $LogFile -inputobject $strMsg -force
            }
            ; Continue
        }

        if ($ErrCtrl -eq $false) {

            Write-host $users.name";Success;Status:"(GetUserAccCtrlStatus($users)) -Foreground green
            if (!($LogFile -eq "")) {
                [string] $strUserNames = $global:strUserName
                [string] $strUrsStatus = GetUserAccCtrlStatus($global:strUserDN)
                [string] $strMsg = ("$strUserNames" + ";Success;Status:" + "$strUrsStatus")
                Out-File -Append -FilePath $LogFile -inputobject $strMsg -force
            }
        }
    }
}
else {
    Write-host "Failed! OU does not exist or can not be connected" -Foreground red
}
}
function Remove-VsResistInstallFiles {
<#PSScriptInfo

.VERSION 1.1.3

.GUID 0775cf89-1a99-44ec-ac4e-7c80c95d87a2

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
This script removes the files leftover from a VCRedist from VC++ 2008 install.

.DESCRIPTION
This script will remove the extra files from a VCRedist from VC++ 2008 install, as per https://support.microsoft.com/en-ca/help/950683/vcredist-from-vc-2008-installs-temporary-files-in-root-directory

.LINK
https://support.microsoft.com/en-ca/help/950683/vcredist-from-vc-2008-installs-temporary-files-in-root-directory

.PARAMETER Drive
The drive from which to remove the files. If unspesified, the System Drive is used.

.EXAMPLE
Clean-VCRedist

.EXAMPLE
Clean-VCRedist.ps1 -Drive D
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [string]$Drive = $env:SystemDrive
)

$Files = "install.exe", "install.res.1028.dll", "install.res.1031.dll", "install.res.1033.dll", "install.res.1036.dll", "install.res.1040.dll", "install.res.1041.dll", "install.res.1042.dll", "install.res.2052.dll", "install.res.3082.dll", "vcredist.bmp", "globdata.ini", "install.ini", "eula.1028.txt", "eula.1031.txt", "eula.1033.txt", "eula.1036.txt", "eula.1040.txt", "eula.1041.txt", "eula.1042.txt", "eula.2052.txt", "eula.3082.txt", "VC_RED.MSI", "VC_RED.cab"
Foreach ($File in $Files) { Remove-Item $Drive\$File -ErrorAction SilentlyContinue }
}
function Repair-AdAttributes {
<#PSScriptInfo

.VERSION 1.0.4

.GUID d2351cd7-428e-4c43-ab8e-d10239bb9d23

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
Repair attributes for user in Active Directory.

.DESCRIPTION
Repair attributes for user in Active Directory. The following actions will be performed.
 - Remove legacy Exchange attributes
 - Remove legacy proxy addresses
 - Remove proxy addresses if only one proxy address exists.
 - Clear mailNickname if mail attribute is empty.
 - Set mailNickname to SamAccountName
 - Set title to mail attirubte for shared mailboxes. This is used for better display in SharePoint.
 - Clear telephoneNumber attribute if mail atrribute is empty
 - Set telephoneNumber attribute to main line and extension, if present.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [switch]$LegacyExchange,
    [switch]$LegacyProxyAddresses,
    [switch]$ExtraProxyAddresses,
    [switch]$ClearMailNickname,
    [switch]$SetMailNickname,
    [switch]$ClearTelephoneNumber,
    [switch]$SetTelephoneNumber,
    [string]$OnMicrosoft,
    [string]$DefaultPhoneNumber,
    [string]$Filter = "*",
    $LegacyExchangeAttributes = @("msExchMailboxGuid", "msexchhomeservername", "legacyexchangedn", "mailNickname", "msexchmailboxsecuritydescriptor", "msexchpoliciesincluded", "msexchrecipientdisplaytype", "msexchrecipienttypedetails", "msexchumdtmfmap", "msexchuseraccountcontrol", "msexchversion", "targetAddress"),
    $Properties = @("ProxyAddresses", "mail", "mailNickname", "ipPhone", "telephoneNumber"),
    [string]$SearchBase
)

while (!$DefaultPhoneNumber) { $DefaultPhoneNumber = Read-Host -Prompt "Enter the installer path." }

if ($SearchBase) {
    $Users = Get-ADUser -Properties $Properties -Filter $Filter -SearchBase $SearchBase
    $Groups = Get-ADGroup -Properties $Properties -Filter $Filter -SearchBase $SearchBase
}
else {
    $Users = Get-ADUser -Properties $Properties -Filter $Filter
    $Groups = Get-ADGroup -Properties $Properties -Filter $Filter
}

If ($PSCmdlet.ShouldProcess("Remove legacy exchange attributes") -and $LegacyExchange) {
    $Users | Set-ADUser -Clear $LegacyExchangeAttributes
    $Groups | Where-Object Name -notlike "Group_*" | Set-ADGroup -Clear $LegacyExchangeAttributes
}

If ($PSCmdlet.ShouldProcess("Remove legacy proxy addresses attributes") -and $LegacyProxyAddresses) {
    $Users | ForEach-Object {
        $Remove = $_.proxyaddresses | Where-Object { $_ -like "X500*" -or $_ -like "X400*" -or $_ -like $OnMicrosoft }
        ForEach ($proxyAddress in $Remove) {
            Write-Verbose "Removing $ProxyAddress from $($_.Name)"
            Set-ADUser -Identity $_.Name -Remove @{'ProxyAddresses' = $ProxyAddress }
        }
    }
    $Groups | Where-Object Name -notlike "Group_*" | ForEach-Object {
        $Remove = $_.proxyaddresses | Where-Object { $_ -like "X500*" -or $_ -like "X400*" -or $_ -like $OnMicrosoft }
        ForEach ($proxyAddress in $Remove) {
            Write-Verbose "Removing $ProxyAddress from $($_.Name)"
            Set-ADGroup -Identity $_.Name -Remove @{'ProxyAddresses' = $ProxyAddress }
        }
    }

}
If ($PSCmdlet.ShouldProcess("Clear ProxyAddresses if only one exists") -and $ExtraProxyAddresses) {
    $Users | Where-Object { $_.ProxyAddresses.Count -eq 1 } | Set-ADUser -Clear ProxyAddresses
    $Groups | Where-Object Name -notlike "Group_*" | Where-Object { $_.ProxyAddresses.Count -eq 1 } | Set-ADGroup -Clear ProxyAddresses
}

If ($PSCmdlet.ShouldProcess("Clear mailNickname if mail attribute empty") -and $ClearMailNickname) {
    $Users | Where-Object $null -eq mail | Where-Object mailNickname -ne $null | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Clear mailNickname }
    $Groups | Where-Object $null -eq mail | Where-Object mailNickname -ne $null | Where-Object Name -notlike "Group_*" | ForEach-Object { Set-ADGroup -Identity $_.SamAccountName -Clear mailNickname }
}

If ($PSCmdlet.ShouldProcess("Set mailNickname to SamAccountName") -and $SetMailNickname) {
    $Users | Where-Object $null -ne mail | Where-Object { $_.mailNickname -ne $_.SamAccountName } | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Replace @{mailNickname = $_.SamAccountName } }
    $Groups | Where-Object $null -ne mail | Where-Object { $_.mailNickname -ne $_.SamAccountName } | Where-Object Name -notlike "Group_*" | ForEach-Object { Set-ADGroup -Identity $_.SamAccountName -Replace @{mailNickname = $_.SamAccountName } }
}

If ($PSCmdlet.ShouldProcess("Clear telephoneNumber if mail empty") -and $ClearTelephoneNumber) {
    $Users | Where-Object $null -eq mail | Where-Object telephoneNumber -ne $null | Set-ADUser -Clear telephoneNumber
}

If ($PSCmdlet.ShouldProcess("Set telephoneNumber to default line and extension") -and $SetTelephoneNumber) {
    $Users | Where-Object $null -ne mail | ForEach-Object {
        if ($null -ne $_.ipphone) { $telephoneNumber = $DefaultPhoneNumber + " x" + $_.ipPhone.Substring(0, [System.Math]::Min(3, $_.ipPhone.Length)) }
        else { $telephoneNumber = $DefaultPhoneNumber }
        Set-ADUser -Identity $_.SamAccountName -Replace @{telephoneNumber = $telephoneNumber }
    }
}
}
function Repair-VmPermissions {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 8bd63288-3b9f-44dc-bc34-c25aea4b5452

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
This will repair VM permission to allow the VM to start.

.LINK
https://foxdeploy.com/2016/04/05/fix-hyper-v-account-does-not-have-permission-error/
#>

Requires -Modules NTFSSecurity

$VMs = Get-VM
ForEach ($VM in $VMs) {
    $disks = Get-VMHardDiskDrive -VMName $VM.Name
    Write-Output "This VM $($VM.Name), contains $($disks.Count) disks, checking permissions..."

    ForEach ($disk in $disks) {
        $permissions = Get-NTFSAccess -Path $disk.Path
        If ($permissions.Account -notcontains "NT Virtual Mach*") {
            $disk.Path
            Write-host "This VHD has improper permissions, fixing..." -NoNewline
            try {
                Add-NTFSAccess -Path $disk.Path -Account "NT VIRTUAL MACHINE\$($VM.VMId)" -AccessRights FullControl -ErrorAction STOP
            }
            catch {
                Write-Host -ForegroundColor red "[ERROR]"
                Write-Warning "Try rerunning as Administrator, or validate your user ID has FullControl on the above path"
                break
            }

            Write-Host -ForegroundColor Green "[OK]"

        }

    }
}
}
function Reset-CSC {
<#PSScriptInfo
.VERSION 1.0.0
.GUID a4176bef-cf00-42a8-b097-8c9be952931c

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
This will reset the CSC (offline files) cache.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param ()
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\CSC\Parameters\ -Name FormatDatabase -Value 1 -Type DWord
}
function Reset-InviteRedepmtion {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 8697df26-a171-4f10-9929-fbff1e58ab4b

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
This will reset the invite status for guest AAD users.

.PARAMETER All
If specified, all guest users will be processed.

.PARAMETER Email
The email addresses to process. This can be omitted if spesifing UPNs.

.PARAMETER UPN
The UPNs to process. By default, it will generate for the email addresses specified.

.PARAMETER RedirectURL
The URL to redirect users to after sucessfull invite redeption.

.PARAMETER SkipSendingInvitation
Whether to skip sekping the invitation.

.PARAMETER SkipResettingRedeption
Whether to skip resetting the redeption status.

.LINK
https://docs.microsoft.com/en-us/azure/active-directory/external-identities/reset-redemption-status
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$All,
    [array]$Email,
    [array]$UPN = ($Email.replace("@", "_") + "#EXT#@" + ((Get-AzureADTenantDetail).VerifiedDomains | Where-Object Initial -eq $true).Name),
    [Uri]$RecirectURL = "http://myapps.microsoft.com",
    [boolean]$SkipSendingInvitation,
    [boolean]$SkipResettingRedemtion

)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$SkipSendingInvitation = -not $SkipSendingInvitation
$SkipResettingRedemtion = -not $SkipResettingRedemtion

if ($All) {
    $UPN = (Get-AzureADUser -Filter "UserType eq 'Guest'").UserPrincipalName
    Write-Warning "This will reset invites for all guest users. Are you sure?"
    Wait-ForKey "y"

}
[System.Collections.ArrayList]$Results = @()
$UPN | ForEach-Object {
    $count++ ; Progress -Index $count -Total $UPN.count -Activity "Resetting Invite Redemption" -Name $_
    If ($PSCmdlet.ShouldProcess("$_", "Reset-InviteRedemption")) {
        $AzureAdUser = Get-AzureADUser -objectID $_
        $MsGraphUser = (New-Object Microsoft.Open.MSGraph.Model.User -ArgumentList $AzureAdUser.ObjectId)
        $Result = New-AzureADMSInvitation -InvitedUserEmailAddress $AzureAdUser.mail -SendInvitationMessage $SkipSendingInvitation -InviteRedirectUrl $RecirectURL -InvitedUser $MsGraphUser -ResetRedemption $SkipResettingRedemtion
        $Results += $Result
    }
}

Return $Results
}
function Reset-WindowsUpdate {
<#PSScriptInfo

.VERSION 1.20.1

.GUID b4f15462-2ab3-45e5-b2e2-ecb649f1f1a6

.AUTHOR Jason Cook Ryan Nemeth

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
V1.00, 05/21/2015 - Initial version
V1.10, 09/22/2016 - Fixed bug with call to sc.exe
V1.20, 11/13/2017 - Fixed environment variables

#> 

<#
.SYNOPSIS
Resets the Windows Update components

.DESCRIPTION
This script will reset all of the Windows Updates components to DEFAULT SETTINGS.

.OUTPUTS
Results are printed to the console. Future releases will support outputting to a log file.

.NOTES
Written by: Ryan Nemeth

Find me on:
* My Blog:	http://www.geekyryan.com
* Twitter:	https://twitter.com/geeky_ryan
* LinkedIn:	https://www.linkedin.com/in/ryan-nemeth-b0b1504b/
* Github:	https://github.com/rnemeth90
* TechNet:  https://social.technet.microsoft.com/profile/ryan%20nemeth/
#>

$arch = Get-WMIObject -Class Win32_Processor -ComputerName LocalHost | Select-Object AddressWidth

Write-Host "1. Stopping Windows Update Services..."
Stop-Service -Name BITS
Stop-Service -Name wuauserv
Stop-Service -Name appidsvc
Stop-Service -Name cryptsvc

Write-Host "2. Remove QMGR Data file..."
Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue

Write-Host "3. Renaming the Software Distribution and CatRoot Folder..."
Rename-Item $env:systemroot\SoftwareDistribution SoftwareDistribution.bak -ErrorAction SilentlyContinue
Rename-Item $env:systemroot\System32\Catroot2 catroot2.bak -ErrorAction SilentlyContinue

Write-Host "4. Removing old Windows Update log..."
Remove-Item $env:systemroot\WindowsUpdate.log -ErrorAction SilentlyContinue

Write-Host "5. Resetting the Windows Update Services to defualt settings..."
"sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
"sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"

Set-Location $env:systemroot\system32

Write-Host "6. Registering some DLLs..."
regsvr32.exe /s atl.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s mshtml.dll
regsvr32.exe /s shdocvw.dll
regsvr32.exe /s browseui.dll
regsvr32.exe /s jscript.dll
regsvr32.exe /s vbscript.dll
regsvr32.exe /s scrrun.dll
regsvr32.exe /s msxml.dll
regsvr32.exe /s msxml3.dll
regsvr32.exe /s msxml6.dll
regsvr32.exe /s actxprxy.dll
regsvr32.exe /s softpub.dll
regsvr32.exe /s wintrust.dll
regsvr32.exe /s dssenh.dll
regsvr32.exe /s rsaenh.dll
regsvr32.exe /s gpkcsp.dll
regsvr32.exe /s sccbase.dll
regsvr32.exe /s slbcsp.dll
regsvr32.exe /s cryptdlg.dll
regsvr32.exe /s oleaut32.dll
regsvr32.exe /s ole32.dll
regsvr32.exe /s shell32.dll
regsvr32.exe /s initpki.dll
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng.dll
regsvr32.exe /s wuaueng1.dll
regsvr32.exe /s wucltui.dll
regsvr32.exe /s wups.dll
regsvr32.exe /s wups2.dll
regsvr32.exe /s wuweb.dll
regsvr32.exe /s qmgr.dll
regsvr32.exe /s qmgrprxy.dll
regsvr32.exe /s wucltux.dll
regsvr32.exe /s muweb.dll
regsvr32.exe /s wuwebv.dll

Write-Host "7) Removing WSUS client settings..."
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v AccountDomainSid /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v PingID /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v SusClientId /f

Write-Host "8) Resetting the WinSock..."
netsh winsock reset
netsh winhttp reset proxy

Write-Host "9) Delete all BITS jobs..."
Get-BitsTransfer | Remove-BitsTransfer

Write-Host "10) Attempting to install the Windows Update Agent..."
if ($arch -eq 64) {
    wusa Windows8-RT-KB2937636-x64 /quiet
}
else {
    wusa Windows8-RT-KB2937636-x86 /quiet
}

Write-Host "11) Starting Windows Update Services..."
Start-Service -Name BITS
Start-Service -Name wuauserv
Start-Service -Name appidsvc
Start-Service -Name cryptsvc

Write-Host "12) Forcing discovery..."
wuauclt /resetauthorization /detectnow

Write-Host "Process complete. Please reboot your computer."
}
function Resize-Image {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 144cbae4-8208-4df5-a801-42316e9db97e

.AUTHOR Jason Cook Patrick Lambert - http://dendory.net

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
Resize-Image resizes an image file

.DESCRIPTION
This function uses the native .NET API to resize an image file, and optionally save it to a file or display it on the screen. You can specify a scale or a new resolution for the new image.
It supports the following image formats: BMP, GIF, JPEG, PNG, TIFF

.EXAMPLE
Resize-Image -InputFile "C:\kitten.jpg" -Display
Resize the image by 50% and display it on the screen.

.EXAMPLE
Resize-Image -InputFile "C:\kitten.jpg" -Width 200 -Height 400 -Display
Resize the image to a specific size and display it on the screen.

.EXAMPLE
Resize-Image -InputFile "C:\kitten.jpg" -Scale 30 -OutputFile "C:\kitten2.jpg"
Resize the image to 30% of its original size and save it to a new file.

.LINK
http://dendory.net
#>
Param([Parameter(Mandatory = $true)][string]$InputFile, [string]$OutputFile, [int32]$Width, [int32]$Height, [int32]$Scale, [Switch]$Display)

Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Image]::FromFile((Get-Item $InputFile))

if ($Width -gt 0) { [int32]$new_width = $Width }
elseif ($Scale -gt 0) { [int32]$new_width = $img.Width * ($Scale / 100) }
else { [int32]$new_width = $img.Width / 2 }
if ($Height -gt 0) { [int32]$new_height = $Height }
elseif ($Scale -gt 0) { [int32]$new_height = $img.Height * ($Scale / 100) }
else { [int32]$new_height = $img.Height / 2 }

$img2 = New-Object System.Drawing.Bitmap($new_width, $new_height)

$graph = [System.Drawing.Graphics]::FromImage($img2)
$graph.DrawImage($img, 0, 0, $new_width, $new_height)

if ($Display) {
    Add-Type -AssemblyName System.Windows.Forms
    $win = New-Object Windows.Forms.Form
    $box = New-Object Windows.Forms.PictureBox
    $box.Width = $new_width
    $box.Height = $new_height
    $box.Image = $img2
    $win.Controls.Add($box)
    $win.AutoSize = $true
    $win.ShowDialog()
}

if ($OutputFile -ne "") {
    $img2.Save($OutputFile);
}

Export-ModuleMember Resize-Image
}
function Save-Password {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 70496d42-6d10-460f-9e42-132a6b70e09d

.AUTHOR Jason Cook Vincent Christiansen - vincent@sameie.com

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
This will store a password to the specified file.

.PARAMETER Path
The location the password will be stored.

.EXAMPLE
Store-Password

.EXAMPLE
Store-Password -Path .\Password.txt

.LINK
http://www.sameie.com/2017/10/05/create-hashed-password-file-for-powershell-use/
#>
param(
  [string]$Path = ".\Password.txt",
  [pscredential]$credential = (Get-Credential)
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Credential.Password | ConvertFrom-SecureString | Set-Content $Path
}
function Search-Registry {
<#PSScriptInfo

.VERSION 1.0.3

.GUID 029cd8de-13e9-4169-ae20-72c021290013

.AUTHOR Rohn Edwards

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
Searches registry key names, value names, and value data (limited).

.DESCRIPTION
This function can search registry key names, value names, and value data (in a limited fashion). It outputs custom objects that contain the key and the first match type (KeyName, ValueName, or ValueData).

.PARAMETER PATH
Registry path to search

.PARAMETER Recurse
Specifies whether or not all subkeys should also be searched

.PARAMETER SearchRegex
A regular expression that will be checked against key names, value names, and value data (depending on the specified switches)

.PARAMETER KeyName
When the -SearchRegex parameter is used, this switch means that key names will be tested (if none of the three switches are used, keys will be tested)

.PARAMETER ValueName
When the -SearchRegex parameter is used, this switch means that the value data will be tested (if none of the three switches are used, value names will be tested)

.PARAMETER ValueData

.PARAMETER ValueData
When the -SearchRegex parameter is used, this switch means that the value data will be tested (if none of the three switches are used, value data will be tested)

.PARAMETER KeyNameRegex
Specifies a regex that will be checked against key names only

.PARAMETER ValueNameRegex
Specifies a regex that will be checked against value names only

.PARAMETER ValueDataRegex
Specifies a regex that will be checked against value data only

.EXAMPLE
Search-Registry -Path HKLM:\SYSTEM\CurrentControlSet\Services\* -SearchRegex "svchost" -ValueData

.EXAMPLE
Search-Registry -Path HKLM:\SOFTWARE\Microsoft -Recurse -ValueNameRegex "ValueName1|ValueName2" -ValueDataRegex "ValueData" -KeyNameRegex "KeyNameToFind1|KeyNameToFind2"

.LINK
https://stackoverflow.com/questions/42963661/use-powershell-to-search-for-string-in-registry-keys-and-values

.LINK
https://gallery.technet.microsoft.com/scriptcenter/Search-Registry-Find-Keys-b4ce08b4
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)][Alias("PsPath")][string[]] $Path,
    [switch]$Recurse,
    [Parameter(ParameterSetName = "SingleSearchString", Mandatory)][string] $SearchRegex,
    [Parameter(ParameterSetName = "SingleSearchString")][switch] $KeyName,
    [Parameter(ParameterSetName = "SingleSearchString")][switch] $ValueName,
    [Parameter(ParameterSetName = "SingleSearchString")][switch] $ValueData,
    [Parameter(ParameterSetName = "MultipleSearchStrings")][string] $KeyNameRegex,
    [Parameter(ParameterSetName = "MultipleSearchStrings")][string] $ValueNameRegex,
    [Parameter(ParameterSetName = "MultipleSearchStrings")][string] $ValueDataRegex
)

begin {
    switch ($PSCmdlet.ParameterSetName) {
        SingleSearchString {
            $NoSwitchesSpecified = -not ($PSBoundParameters.ContainsKey("KeyName") -or $PSBoundParameters.ContainsKey("ValueName") -or $PSBoundParameters.ContainsKey("ValueData"))
            if ($KeyName -or $NoSwitchesSpecified) { $KeyNameRegex = $SearchRegex }
            if ($ValueName -or $NoSwitchesSpecified) { $ValueNameRegex = $SearchRegex }
            if ($ValueData -or $NoSwitchesSpecified) { $ValueDataRegex = $SearchRegex }
        }
        MultipleSearchStrings {
            # No extra work needed
        }
    }
}

process {
    foreach ($CurrentPath in $Path) {
        Get-ChildItem $CurrentPath -Recurse:$Recurse |
        ForEach-Object {
            $Key = $_

            if ($KeyNameRegex) {
                Write-Verbose ("{0}: Checking KeyNamesRegex" -f $Key.Name)

                if ($Key.PSChildName -match $KeyNameRegex) {
                    Write-Verbose "  -> Match found!"
                    return [PSCustomObject] @{
                        Key    = $Key
                        Reason = "KeyName"
                    }
                }
            }

            if ($ValueNameRegex) {
                Write-Verbose ("{0}: Checking ValueNamesRegex" -f $Key.Name)

                if ($Key.GetValueNames() -match $ValueNameRegex) {
                    Write-Verbose "  -> Match found!"
                    return [PSCustomObject] @{
                        Key    = $Key
                        Reason = "ValueName"
                    }
                }
            }

            if ($ValueDataRegex) {
                Write-Verbose ("{0}: Checking ValueDataRegex" -f $Key.Name)

                if (($Key.GetValueNames() | ForEach-Object { $Key.GetValue($_) }) -match $ValueDataRegex) {
                    Write-Verbose "  -> Match!"
                    return [PSCustomObject] @{
                        Key    = $Key
                        Reason = "ValueData"
                    }
                }
            }
        }
    }
}
}
function Set-AdPhoto {
<#PSScriptInfo

.VERSION 1.1.2

.GUID 5dcbac67-cebe-4cb8-bf95-8ad720c25e72

.AUTHOR Jason Cook Rajeev Buggaveeti

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
This will set Active Directory thumbnailPhoto from matching files in the specified directory.

.DESCRIPTION
This will set Active Directory thumbnailPhoto from matching files in the specified directory.

.PARAMETER Path
The directory where photos will be pulled from.

.PARAMETER Users
Array of users to run the command against. If unspesified, it will run against all files in the specified directory.

.EXAMPLE
Set-AdPhoto

.LINK
https://blogs.technet.microsoft.com/rajbugga/2017/05/16/picture-sync-from-office-365-to-ad-powershell-way/
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [ValidateScript( { Test-Path $_ })][string]$Path = (Get-Location),
    [array]$Users = (Get-ChildItem $Path -File)
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Test-Admin -Warn -Message "You are not running this script as an administrator. It may not work as expected." | Out-null
foreach ($User in $Users) {
    $count++ ; Progress -Index $count -Total $Users.count -Activity "Setting users photos." -Name [System.IO.Path]::GetFileNameWithoutExtension($User.Name)

    $Account = [System.IO.Path]::GetFileNameWithoutExtension($User.Name)
    $Search = [System.DirectoryServices.DirectorySearcher]([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).GetDirectoryEntry()
    $Search.Filter = "(&(objectclass=user)(objectcategory=person)(samAccountName=$account))"
    $Result = $Search.FindOne()

    if ($null -ne $Result) {
        If ($PSCmdlet.ShouldProcess("$Account", "Set-AdPhotos")) {
            try {
                Write-Verbose "Setting photo for user `"$($UserResult.displayname)`""
                [byte[]]$Photo = Get-Content ($Path + "\" + $User) -Encoding Byte
                $UserResult = $Result.GetDirectoryEntry()
                $UserResult.put("thumbnailPhoto", $Photo)
                $UserResult.setinfo()
            }
            catch [System.Management.Automation.MethodInvocationException] {
                if (Test-Admin) { Throw "You do not have permission to make these changes." }
                else { Throw "You do not have permission to make these changes. Try running as admin." }
            }
        }
    }
    else { Write-Warning "User `"$account`" does not exist. Skipping." }
}
}
function Set-ComputerName {
<#PSScriptInfo

.VERSION 1.0.5

.GUID 0e319076-a254-46aa-948c-203373b9e47d

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
This script will rename the computer based on the prefix and serial number.

.PARAMETER Prefix
The prefix to use for the computer name.

.PARAMETER Serial
The serial nubmer to use for the computer name.

.PARAMETER PrefixLenght
The lenght of the prefix. This is used to truncate the prefix so the total length is less than 15 characters.

.PARAMETER NewName
The new name to use for the computer.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "Password")]
param (
    [string]$Prefix,
    [string]$User,
    [string]$Password,
    [string]$Serial = (Get-WmiObject win32_bios).Serialnumber,
    $PrefixLenght = ($(15 - $Serial.length), $Prefix.Length | Measure-Object -Minimum ).Minimum,
    $NewName = $Prefix.Substring(0, $PrefixLenght) + $Serial
)

if ($User -and $Password) {
    [SecureString]$SecurePassword = ($Password | ConvertTo-SecureString -AsPlainText -Force)
    [pscredential]$Credentials = (New-Object System.Management.Automation.PSCredential -ArgumentList $User, $SecurePassword)
    Write-Verbose "Renaming computer to `'$NewName`' as `'$User`'"
    return Rename-Computer -NewName $NewName -DomainCredential $Credentials
}
Write-Verbose "Renaming computer to `'$NewName`'"
return Rename-Computer -NewName $NewName
}
function Set-DefaultWallpapers {
<#PSScriptInfo

.VERSION 1.0.7

.GUID 910cea1b-4c78-4282-ac1d-7a64897475ea

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
Change the default Windows wallpaper for new users and copies wallpapers to system folder.

.PARAMETER SourcePath
The lcoation to search for images in.

.PARAMETER Images
An array of images to use. By default, this will select all *.jpg files in $SourcePath

.PARAMETER Name
The name of the folder to copy the images to. If not specified, this script will use "Defaults" and copy to $env:windir\Web\Wallpaper\$Name

.PARAMETER LockScreen
Sets the lock screen wallpaper and prevents the user from changing it.

.LINK
https://ccmexec.com/2015/08/replacing-default-wallpaper-in-windows-10-using-scriptmdtsccm/
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param (
    [ValidateScript( { Test-Path $_ })][string]$SourcePath,
    $Images = (Get-ChildItem $SourcePath -Filter *.jpg),
    [string]$Name = "Defaults",
    [switch]$LockScreen
)

Test-Admin -Throw -Message "You must be an administrator to modify the default wallpapers." | Out-Null

$DestinationPath = (Join-Path -Path $env:windir -ChildPath "Web\Wallpaper\$Name")
$SystemPath = (Join-Path -Path $env:windir -ChildPath "Web\Wallpaper\Windows")
$ResolutionPath = (Join-Path -Path $env:windir -ChildPath "Web\4K\Wallpaper\Windows")
$DefaultImagePath = (Join-Path -Path $SystemPath -ChildPath "img0.jpg")

Write-Verbose "Copying all wallpapers from $SourcePath to $DestinationPath"
try { Remove-Item -Path $DestinationPath -Recurse -Force | Out-null }
catch [System.Management.Automation.ItemNotFoundException] { Write-Verbose "$DestinationPath does not exists." }

New-Item -ItemType Directory -Path $DestinationPath -ErrorAction Stop | Out-null

$count = -1
$Images | ForEach-Object {
    $count++ ; Progress -Index $count -Total $Images.count -Activity "Copying wallpapers." -Name $_.Name
    Copy-Item -Path $_.FullName -Destination (Join-Path -Path $DestinationPath -ChildPath ("img" + $count + ".jpg")) -Force
}

Write-Verbose "Removing existing wallpapers."
Get-ChildItem -Path $SystemPath, $ResolutionPath -Recurse | ForEach-Object {
    Write-Verbose "Removing $($_.Name)"
    takeown /f $_.FullName
    icacls $($_.FullName) /Grant administrators:F
    Remove-Item $_.FullName
}
if ($Images.Count -lt 2) { $Image = $Images[0] }
else { $Image = $Images[(Get-Random -Minimum 0 -Maximum ($Images.Count - 1))] }

Write-Verbose "Setting default wallpaper to $($Image.Name)"
Copy-Item -Path $Image.FullName -Destination $DefaultImagePath

if ($LockScreen) {
    try {
        $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP\"
        $RegistryParent = (Split-Path -Path $RegistryPath -Parent)

        if (-not (Test-Path -Path $RegistryPath)) { New-Item -Path $RegistryParent -Name (Split-Path -Path $RegistryPath -Leaf) -ItemType RegistryKey }

        if (-not (Test-RegistryValue -Path $RegistryPath -Value LockScreenImagePath)) { New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP\ -Name LockScreenImagePath -Value "file:///C:\Windows\Web\Wallpaper\Windows\img0.jpg" -PropertyType "String" }
        else { Set-ItemProperty -Path $RegistryPath -Name LockScreenImagePath -Value "C:\Windows\Web\Wallpaper\Windows\img0.jpg" -Type String }

        if (-not (Test-RegistryValue -Path $RegistryPath -Value LockScreenImageUrl)) { New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP\ -Name LockScreenImageUrl -Value "file:///C:\Windows\Web\Wallpaper\Windows\img0.jpg" -PropertyType "String" }
        else { Set-ItemProperty -Path $RegistryPath -Name LockScreenImageUrl -Value "C:\Windows\Web\Wallpaper\Windows\img0.jpg" -Type String }

        if (-not (Test-RegistryValue -Path $RegistryPath -Value LockScreenImageStatus)) { New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP\ -Name LockScreenImageStatus -Value 1 -PropertyType "DWord" }
        else { Set-ItemProperty -Path $RegistryPath -Name LockScreenImageStatus -Value 1 -Type DWord }
    }
    catch {
        $_
        Write-Warning "Failed to set lockscreen wallpaper."
    }
}
}
function Set-Owner {
<#PSScriptInfo

.VERSION 1.1.1

.GUID fb1d15b5-4681-4f99-90d6-1fd44ed4219b

.AUTHOR Jason Cook Boe Prox

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
    Changes owner of a file or folder to another user or group.

.DESCRIPTION
    Changes owner of a file or folder to another user or group.

.PARAMETER Path
    The folder or file that will have the owner changed.

.PARAMETER Account
    Optional parameter to change owner of a file or folder to specified account.

    Default value is 'Builtin\Administrators'

.PARAMETER Recurse
    Recursively set ownership on subfolders and files beneath given folder.

.EXAMPLE
    Set-Owner -Path C:\temp\test.txt

    Description
    -----------
    Changes the owner of test.txt to Builtin\Administrators

.EXAMPLE
    Set-Owner -Path C:\temp\test.txt -Account 'Domain\bprox

    Description
    -----------
    Changes the owner of test.txt to Domain\bprox

.EXAMPLE
    Set-Owner -Path C:\temp -Recurse

    Description
    -----------
    Changes the owner of all files and folders under C:\Temp to Builtin\Administrators

.EXAMPLE
    Get-ChildItem C:\Temp | Set-Owner -Recurse -Account 'Domain\bprox'

    Description
    -----------
    Changes the owner of all files and folders under C:\Temp to Domain\bprox

.LINK
https://learn-powershell.net/2014/06/24/changing-ownership-of-file-or-folder-using-powershell/

.LINK
http://gallery.technet.microsoft.com/scriptcenter/Set-Owner-ff4db177
    #>
[cmdletbinding(
    SupportsShouldProcess = $True
)]
Param (
    [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    [Alias('FullName')]
    [string[]]$Path,
    [parameter()]
    [string]$Account = 'Builtin\Administrators',
    [parameter()]
    [switch]$Recurse
)
Begin {
    #Prevent Confirmation on each Write-Debug command when using -Debug
    If ($PSBoundParameters['Debug']) {
        $DebugPreference = 'Continue'
    }
    Try {
        [void][TokenAdjuster]
    }
    Catch {
        $AdjustTokenPrivileges = @"
            using System;
            using System.Runtime.InteropServices;

             public class TokenAdjuster
             {
              [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
              internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,
              ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);
              [DllImport("kernel32.dll", ExactSpelling = true)]
              internal static extern IntPtr GetCurrentProcess();
              [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
              internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr
              phtok);
              [DllImport("advapi32.dll", SetLastError = true)]
              internal static extern bool LookupPrivilegeValue(string host, string name,
              ref long pluid);
              [StructLayout(LayoutKind.Sequential, Pack = 1)]
              internal struct TokPriv1Luid
              {
               public int Count;
               public long Luid;
               public int Attr;
              }
              internal const int SE_PRIVILEGE_DISABLED = 0x00000000;
              internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
              internal const int TOKEN_QUERY = 0x00000008;
              internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
              public static bool AddPrivilege(string privilege)
              {
               try
               {
                bool retVal;
                TokPriv1Luid tp;
                IntPtr hproc = GetCurrentProcess();
                IntPtr htok = IntPtr.Zero;
                retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
                tp.Count = 1;
                tp.Luid = 0;
                tp.Attr = SE_PRIVILEGE_ENABLED;
                retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
                retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
                return retVal;
               }
               catch (Exception ex)
               {
                throw ex;
               }
              }
              public static bool RemovePrivilege(string privilege)
              {
               try
               {
                bool retVal;
                TokPriv1Luid tp;
                IntPtr hproc = GetCurrentProcess();
                IntPtr htok = IntPtr.Zero;
                retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
                tp.Count = 1;
                tp.Luid = 0;
                tp.Attr = SE_PRIVILEGE_DISABLED;
                retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
                retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
                return retVal;
               }
               catch (Exception ex)
               {
                throw ex;
               }
              }
             }
"@
        Add-Type $AdjustTokenPrivileges
    }

    #Activate necessary admin privileges to make changes without NTFS perms
    [void][TokenAdjuster]::AddPrivilege("SeRestorePrivilege") #Necessary to set Owner Permissions
    [void][TokenAdjuster]::AddPrivilege("SeBackupPrivilege") #Necessary to bypass Traverse Checking
    [void][TokenAdjuster]::AddPrivilege("SeTakeOwnershipPrivilege") #Necessary to override FilePermissions
}
Process {
    ForEach ($Item in $Path) {
        Write-Verbose "FullName: $Item"
        #The ACL objects do not like being used more than once, so re-create them on the Process block
        $DirOwner = New-Object System.Security.AccessControl.DirectorySecurity
        $DirOwner.SetOwner([System.Security.Principal.NTAccount]$Account)
        $FileOwner = New-Object System.Security.AccessControl.FileSecurity
        $FileOwner.SetOwner([System.Security.Principal.NTAccount]$Account)
        $DirAdminAcl = New-Object System.Security.AccessControl.DirectorySecurity
        $FileAdminAcl = New-Object System.Security.AccessControl.DirectorySecurity
        $AdminACL = New-Object System.Security.AccessControl.FileSystemAccessRule('Builtin\Administrators', 'FullControl', 'ContainerInherit,ObjectInherit', 'InheritOnly', 'Allow')
        $FileAdminAcl.AddAccessRule($AdminACL)
        $DirAdminAcl.AddAccessRule($AdminACL)
        Try {
            $Item = Get-Item -LiteralPath $Item -Force -ErrorAction Stop
            If (-NOT $Item.PSIsContainer) {
                If ($PSCmdlet.ShouldProcess($Item, 'Set File Owner')) {
                    Try {
                        $Item.SetAccessControl($FileOwner)
                    }
                    Catch {
                        Write-Warning "Couldn't take ownership of $($Item.FullName)! Taking FullControl of $($Item.Directory.FullName)"
                        $Item.Directory.SetAccessControl($FileAdminAcl)
                        $Item.SetAccessControl($FileOwner)
                    }
                }
            }
            Else {
                If ($PSCmdlet.ShouldProcess($Item, 'Set Directory Owner')) {
                    Try {
                        $Item.SetAccessControl($DirOwner)
                    }
                    Catch {
                        Write-Warning "Couldn't take ownership of $($Item.FullName)! Taking FullControl of $($Item.Parent.FullName)"
                        $Item.Parent.SetAccessControl($DirAdminAcl)
                        $Item.SetAccessControl($DirOwner)
                    }
                }
                If ($Recurse) {
                    [void]$PSBoundParameters.Remove('Path')
                    Get-ChildItem $Item -Force | Set-Owner @PSBoundParameters
                }
            }
        }
        Catch {
            Write-Warning "$($Item): $($_.Exception.Message)"
        }
    }
}
End {
    #Remove priviledges that had been granted
    [void][TokenAdjuster]::RemovePrivilege("SeRestorePrivilege")
    [void][TokenAdjuster]::RemovePrivilege("SeBackupPrivilege")
    [void][TokenAdjuster]::RemovePrivilege("SeTakeOwnershipPrivilege")
}
}
function Set-RoomCalendarPermissions {
<#PSScriptInfo

.VERSION 1.0.4

.GUID 9d477618-5530-413c-bdf8-3ddf1580dbfa

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
Makes Availability information available to all users.

.PARAMETER User
What user should the permissions be set for. If not specified, the DEFAULT user is used.

.PARAMETER AccessRight
The access right to set. By default, the access right is set to LimitedDetails.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    $User = "Default",
    $AccessRights = "LimitedDetails"
)

Get-Mailbox -RecipientTypeDetails RoomMailbox | ForEach-Object {
    If ($PSCmdlet.ShouldProcess("$_", "Set-RoomCalendarPermissions")) {
        Set-MailboxFolderPermission -Identity $($_.Identity + ":\Calendar") -User $User -AccessRights $AccessRights
    }
}
}
function Set-Wallpaper {
<#PSScriptInfo

.VERSION 1.0.5

.GUID 5367e6e7-1177-4f3f-a345-1633446ad628

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
Change the default Windows wallpaper for new users and copies wallpapers to system folder.

.PARAMETER SourcePath
The lcoation to search for images in.

.PARAMETER Images
An array of images to use. By default, this will select all *.jpg files in $SourcePath

.PARAMETER Name
The name of the folder to copy the images to. If not specified, this script will use "Defaults" and copy to $env:windir\Web\Wallpaper\$Name

.LINK
https://ccmexec.com/2015/08/replacing-default-wallpaper-in-windows-10-using-scriptmdtsccm/
#><#

.DESCRIPTION
Applies a specified wallpaper to the current user's desktop.

.PARAMETER Image
Provide the exact path to the image. If unspecified, it will use the default system wallpaper from $env:windir\Web\Wallpaper\Windows

.PARAMETER Style
Provide wallpaper style (Example: Fill, Fit, Stretch, Tile, Center, or Span). Default is Fit.

.EXAMPLE
Set-WallPaper -Image "C:\Wallpaper\Default.jpg"
Set-WallPaper -Image "C:\Wallpaper\Background.jpg" -Style Fit

.LINK
https://www.joseespitia.com/2017/09/15/set-wallpaper-powershell-function/

#>

param (
    [ValidateScript({ Test-Path $_ })][string]$Image = ((Get-ChildItem -Path (Join-Path -Path $env:windir -ChildPath "Web\Wallpaper\Windows"))[0].FullName),
    [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')][string]$Style = "Fit"
)

$WallpaperStyle = Switch ($Style) {
    "Fill" { "10" }
    "Fit" { "6" }
    "Stretch" { "2" }
    "Tile" { "0" }
    "Center" { "0" }
    "Span" { "22" }
}

New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
If ($Style -eq "Tile") { New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force }
Else { New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force }

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Params
{
[DllImport("User32.dll",CharSet=CharSet.Unicode)]
public static extern int SystemParametersInfo (Int32 uAction,
Int32 uParam,
String lpvParam,
Int32 fuWinIni);
}
"@

$SPI_SETDESKWALLPAPER = 0x0014
$UpdateIniFile = 0x01
$SendChangeEvent = 0x02

$fWinIni = $UpdateIniFile -bor $SendChangeEvent

exit [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)

$fWinIni = $UpdateIniFile -bor $SendChangeEvent

exit [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}
function Set-WindowsAccountAvatar {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 240b7f82-8102-45be-9080-2cf28a7c5b3d

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
Sets windows account avatar from data in Active Directory.

.LINK
http://woshub.com/how-to-set-windows-user-account-picture-from-active-directory/#h2_2

.LINK
https://www.codetwo.com/admins-blog/use-active-directory-user-photos-windows-10/
#>

[CmdletBinding(SupportsShouldProcess = $true)]Param()
function Test-Null($InputObject) { return !([bool]$InputObject) }

$ADuser = ([ADSISearcher]"(&(objectCategory=User)(SAMAccountName=$env:username))").FindOne().Properties
$ADuser_photo = $ADuser.thumbnailphoto
$ADuser_sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value

If ((Test-Null $ADuser_photo) -eq $false) {
  $img_sizes = @(32, 40, 48, 96, 192, 200, 240, 448)
  $img_mask = "Image{0}.jpg"
  $img_base = "C:\Users\Public\AccountPictures"
  $reg_base = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\{0}"
  $reg_key = [string]::format($reg_base, $ADuser_sid)
  $reg_value_mask = "Image{0}"
  If ((Test-Path -Path $reg_key) -eq $false) { New-Item -Path $reg_key }
  Try {
    ForEach ($size in $img_sizes) {
      $dir = $img_base + "\" + $ADuser_sid
      If ((Test-Path -Path $dir) -eq $false) { $(mkdir $dir).Attributes = "Hidden" }
      $file_name = ([string]::format($img_mask, $size))
      $path = $dir + "\" + $file_name
      Write-Verbose " saving: $file_name"
      $ADuser_photo | Set-Content -Path $path -Encoding Byte -Force
      $name = [string]::format($reg_value_mask, $size)
      New-ItemProperty -Path $reg_key -Name $name -Value $path -Force
    }
  }
  Catch { Write-Error "Check permissions to files or registry." }
}
}
function Show-BitlockerEncryptionStatus {
<#PSScriptInfo

.VERSION 1.0.5

.GUID 85c8702c-7117-4050-8629-51fc36de0cd8

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
Show BitLocker encryption status on a loop. Used to monitor encryption progress.

.PARAMETER Sleep
The lenght of time to sleep between checks.
#>
param(
    [ValidateRange(0, [Int32]::MaxValue)][Int32]$Sleep = 5
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

Test-Admin -Throw | Out-Null

Get-BitLockerVolume

while (Get-BitLockerVolume | Where-Object  EncryptionPercentage -ne 100) {
    $Result = Get-BitLockerVolume  | Where-Object { $_.VolumeStatus -ne "FullyEncrypted" -and $_.VolumeStatus -ne "FullyDecrypted" } | Format-Table
    Clear-Host
    (Get-Date).DateTime
    $Result
    Start-Sleep -Seconds $Sleep
}
}
function Start-KioskApp {
<#PSScriptInfo

.VERSION 1.0.4

.GUID fb250771-93be-4da0-a4ec-edad2ccf7476

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
This will run a kiosk app.

.DESCRIPTION
This will run a kiosk app. Primarily, this is used to launch a web brower however can be used to launch any application. It will periodically check if the app is running and restart if it has been closed.

.PARAMETER Path
The location of the program to run.

.PARAMETER Url
The url to open. By default, this it designed to launch a web browser.

.PARAMETER Arguments
The argumnets to be passed to the program.

.PARAMETER Sleep
How long to sleep before checking that the app is running.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript({ Test-Path $_ -PathType Leaf })][string]$Path = ${env:ProgramFiles(x86)} + "\Microsoft\Edge\Application\msedge.exe", #"\Google\Chrome\Application\chrome.exe",
  [string]$Url,
  [array]$Arguments = "--kiosk $($Url)",
  [ValidateRange(1, [int]::MaxValue)][int]$Sleep = 5

)

If ($PSCmdlet.ShouldProcess("$Path", "Starting kiosk app.")) {
  while ($true) {
    If (-Not (Get-Process | Select-Object Path | Where-Object Path -eq $Path)) { Start-Process -FilePath $Path -ArgumentList $Arguments }
    Start-Sleep -Seconds $Sleep
  }
}
}
function Start-PaperCutClient {
<#PSScriptInfo

.VERSION 1.0.1

.GUID 090b7063-ddf4-4e5f-91ab-24127dec0d57

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
This script will run the PaperCut client.

.DESCRIPTION
This script will run the PaperCut client. It will first check the network location and fall back to the local cache is that fails.

.PARAMETER SearchLocations
Specifies the folders to search for the client in.

.EXAMPLE
Start-PaperCutClient

.EXAMPLE
Start-PaperCutClient -SearchLocations "\\print\PCClient\win","C:\Cache"
#>
param (
  [string[]]$SearchLocations = @("\\print\PCClient\win", "C:\Cache")
)

$SearchLocations | ForEach-Object {
  Write-Verbose "Searching in $_"
  $NetworkPath = $_ + "\pc-client-local-cache.exe"
  If (Test-Path -PathType Leaf -Path $NetworkPath) {
    Write-Verbose "Found network file at $NetworkPath"
    Get-Process -Name pc-client -ErrorAction SilentlyContinue | Stop-Process
    Start-Process -FilePath $NetworkPath -ArgumentList "--silent"
    Break
  }
  $LocalPath = (Get-ChildItem -Path $_ -Filter "pc-client.exe*" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1).FullName + "\pc-client.exe"
  If (Test-Path -PathType Leaf -Path $LocalPath) {
    Write-Verbose "Found local file at $LocalPath"
    Get-Process -Name pc-client -ErrorAction SilentlyContinue | Stop-Process
    Start-Process -FilePath $LocalPath -ArgumentList "--silent"
  }
}
}
function Start-WindowsActivation {
<#PSScriptInfo

.VERSION 1.0.4

.GUID 625c264b-e5ec-4c6a-8478-39ec90518250

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
Activate windows using the spesified key, or fall back to the key in the BIOS.
#>

param (
    [string]$ProductKey
)

Function ActivationStatus { return (Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" |  Where-Object { $_.PartialProductKey })[0].LicenseStatus }
function ActivateWindows {
    param ([Parameter(ValueFromPipeline = $true)][ValidatePattern('^([A-Z0-9]{5}-){4}[A-Z0-9]{5}$')][string]$ProductKey)
    $Service = Get-WmiObject -query "select * from SoftwareLicensingService"
    $Service.InstallProductKey($ProductKey)
    $Service.RefreshLicenseStatus()
    return ActivationStatus
}

$Status = ActivationStatus | Out-Null
if ($Status -eq 1) { return "Windows is already activated." }

if ($ProductKey) {
    ActivateWindows $ProductKey
    $Status = ActivationStatus | Out-Null
    if ($Status -eq 1) { return "Windows was activated using the specified key." }
    Write-Error "Windows could not be activated using the specified key."
}

$BiosProductKey = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
if ($BiosProductKey) {
    ActivateWindows $BiosProductKey | Out-Null
    $Status = ActivationStatus | Out-Null
    if ($Status -eq 1) { return "Windows was activated using the BIOS key." }
    Write-Error "Windows could not be activated BIOS key."
}

Write-Error "Windows could not be activated."
}
function Stop-ForKey {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 9b9dfb07-a7ea-4afd-94ab-74a5bf2ee340

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.SYNOPSIS
This will break if the spesified key it press. Otherwise, it will continue.

.DESCRIPTION
This script will run the PaperCut client. It will first check the network location and fall back to the local cache is that fails.

.PARAMETER Key
The key that this will listen for.

.EXAMPLE
Stop-ForKey -Key q
Press q to abort, any other key to continue.: q
#>
param (
  $Key
)
$Response = Read-Host "Press $Key to abort, any other key to continue."
If ($Response -eq $Key) { Break }
}
function Sync-MailContacts {
<#PSScriptInfo

.VERSION 1.0.3

.GUID 6da14011-187b-4176-a61b-16836f8a0ad7

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
This script will sync users from one AD domain to another as Contacts.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [string]$SourceDomain,
    [string]$SourceSearchBase,

    [string]$DestinationDomain,
    [string]$DestinationOU,
    [string]$DestinationGroup,

    $WhereObject = { $null -ne $_.mail -and $_.Enabled -ne $false -and $_.msExchHideFromAddressLists -ne $true },

    [array]$SourceProperties = ("displayName", "givenName", "sn", "initials", "mail", "SamAccountName", "description", "wWWHomePage", "title", "department", "company", "manager", "telephoneNumber", "mobile", "facsimileTelephoneNumber", "homePhone", "pager", "physicalDeliveryOfficeName", "streetAddress", "l", "st", "postalCode", "co", "info"),
    [string]$SourceFilter = "*",
    [string]$DestinationFilter = "*"
)

$Source = @{}
if ($SourceSearchBase) { $Source.SearchBase = $SourceSearchBase }
if ($SourceDomain) { $Source.Server = $SourceDomain }
if ($SourceFilter) { $Source.Filter = $SourceFilter }
if ($SourceProperties) { $Source.Properties = $SourceProperties }

if ($DestinationGroup) {
    $GroupMembers = (Get-ADGroup -Identity $DestinationGroup -Properties Members).Members
    $GroupMembers | ForEach-Object {
        $i++ ; Progress -Index $i -Total $GroupMembers.count -Activity "Removing all members from $DestinationGroup." -Status "$_"
        Get-ADGroup $DestinationGroup -Server $DestinationDomain | Set-ADObject -Server $DestinationDomain -Remove @{'member' = $_ }
    }
    $i = 0
}

$SyncedUsers = Get-ADUser -Server $SourceDomain -Filter $SourceFilter -Properties $SourceProperties | Where-Object $WhereObject
$SyncedUsers | ForEach-Object {
    $i++ ; Progress -Index $i -Total $SyncedUsers.count -Activity "Syncing users from $SourceSearchBase to $DestinationOU" -Status "$_"
    $Properties = @{}
    if ($_.displayName) { $Properties.displayName = $_.DisplayName }
    if ($_.givenName) { $Properties.givenName = $_.GivenName }
    if ($_.sn) { $Properties.sn = $_.Surname }
    if ($_.initials) { $Properties.initials = $_.Initials }

    if ($_.mail) { $Properties.mail = $_.mail }
    # if ($_.SamAccountName) {$Properties.mailNickname = $_.SamAccountName}

    if ($_.description) { $Properties.description = $_.Description }
    if ($_.wWWHomePage) { $Properties.wWWHomePage = $_.wWWHomePage }

    if ($_.title) { $Properties.title = $_.Title }
    if ($_.department) { $Properties.department = $_.Department }
    if ($_.company) { $Properties.company = $_.Company }
    # if ($_.manager) { $Properties.manager = $_.Manager }

    if ($_.telephoneNumber) { $Properties.telephoneNumber = $_.TelephoneNumber }
    if ($_.mobile) { $Properties.mobile = $_.mobile }
    if ($_.facsimileTelephoneNumber) { $Properties.facsimileTelephoneNumber = $_.Fax }
    if ($_.homePhone) { $Properties.homePhone = $_.HomePhone }
    if ($_.pager) { $Properties.pager = $_.Pager }

    if ($_.physicalDeliveryOfficeName) { $Properties.physicalDeliveryOfficeName = $_.physicalDeliveryOfficeName }
    if ($_.streetAddress) { $Properties.streetAddress = $_.StreetAddress }
    if ($_.l) { $Properties.l = $_.City }
    if ($_.st) { $Properties.st = $_.State }
    if ($_.postalCode) { $Properties.postalCode = $_.PostalCode }
    if ($_.co) { $Properties.co = $_.Country }
    if ($_.info) { $Properties.info = $_.Notes }

    $ObjectPath = ( "CN=" + $_.DisplayName + ',' + $DestinationOU )
    $DisplayName = $_.DisplayName

    # Write-Verbose command occurs after the user is created to prevent logging when an error occurs.
    try {
        New-ADObject -Type "contact" -Name $_.DisplayName -Server $DestinationDomain -Path $DestinationOU -OtherAttributes $Properties
        Write-Verbose "Created contact for $DisplayName in $DestinationOU"
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] {
        try {
            Set-ADObject -Identity $ObjectPath -Server $DestinationDomain -Replace $Properties
            Write-Verbose "Updated contact for $DisplayName in $DestinationOU."
        }
        catch {
            Write-Warning "Failed to update $DisplayName in $DestinationOU"
            Write-Error $_
        }
    }

    if ($DestinationGroup) {
        Write-Verbose "Adding $($_.DisplayName) to $DestinationGroup"
        Set-ADGroup -Identity $DestinationGroup -Server $DestinationDomain -Add @{'member' = ("cn=" + $_.DisplayName + "," + $DestinationOU) }
    }
}
}
function Test-Admin {
<#PSScriptInfo

.VERSION 1.0.1

.GUID d96e4855-2468-4294-8475-4b954ad009dd

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
This will test is the we are running as an addministrator.

.DESCRIPTION
This will test is the we are running as an addministrator. If will return True or False.

.PARAMETER Message
The message that will be shown to the user. The message is only shown when -Warn or -Throw are specified.

.PARAMETER Warn
The script will present a waiting if not running as an admin.

.PARAMETER Thow
The script will throw if not running as an admin.

.EXAMPLE
Test-Admin
False
#>
param (
  [string]$Message = "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!",
  [switch]$Warn,
  [switch]$Throw
)

If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { return $true }
else {
  If ($Warn) { Write-Warning $Message }
  If ($Throw) { Throw $Message }
  return $false
}
}
function Test-DmaDevices {
<#PSScriptInfo

.VERSION 1.0.1

.GUID a2d15653-e7ac-4246-b3a4-adf73af11a06

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
This is used to test which DMA devices are blocking automatic BitLocker encryption.

.PARAMETER File
The text file where the list of devices will be saved.

.PARAMETER LastDeviceFile
The text file where the last modified device will be saved.

.PARAMETER Action
An array of actions to run.
    RemoveFirst: Remove the first entry from the list of allowed buses.
    AddLast: Re-add the most recently removed device to the list of allowed buses.
    AddAll: Add all devices to the list of allowed buses.
    Export: Export the list of all device to $File
    Reset: Remove all devices from the list of allowed buses.

.PARAMETER Path
The registry path for allowed buses.

.PARAMETER Parent
The parent of $Path

.EXAMPLE
Test-DmaDevices -Action Export,AddAll

.EXAMPLE
Test-DmaDevices -Action RemoveFirst

.EXAMPLE
Test-DmaDevices -Action AddLast

.EXAMPLE
Test-DmaDevices -Action Reset
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    $File = "DmaDevices.txt",
    $LastDeviceFile = ("$([System.IO.Path]::GetFileNameWithoutExtension($File))-last.txt"),
    [ValidateSet("RemoveFirst", "AddLast", "AddAll", "Export", "Reset")][array]$Action,
    $Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DmaSecurity\AllowedBuses",
    $Parent = (Split-Path $Path -Parent)
)
If ($(Test-Path -Path $Parent) -eq $False) { New-Item $Parent }
If ($(Test-Path -Path $Path) -eq $False) { New-Item $Path }
function ParseInstanceId {
    param([Parameter(Mandatory = $true, ValueFromPipeline = $true)][string[]]$Id)
    return ($Id -replace '&SUBSYS.*', '' -replace '\s+PCI\\', '"="PCI\\')
}

if ($Action -contains "AddAll" -or $Action -contains "Export") {
    Get-PnpDevice -InstanceId PCI\* | ForEach-Object {
        $i++
        $Name = $_.FriendlyName + " " + $i
        if ($Action -contains "AddAll") { New-ItemProperty $Path -PropertyType "String" -Force -Name $Name -Value (ParseInstanceId $_.InstanceId) }
        if ($Action -contains "Export") { Add-Content -Path $File -Value $Name }
    }
}
if ($Action -contains "RemoveFirst") {
    $CurrentDevice = (Get-Content $File -First 1)
    Write-Host $CurrentDevice
    Write-Host $LastDeviceFile
    Remove-ItemProperty $Path -Name $CurrentDevice -Force
    Set-Content -Path $LastDeviceFile -Value $CurrentDevice
    Get-Content $File | Select-Object -Skip 1 | Set-Content $File

}
if ($Action -contains "AddLast") {
    Get-PnpDevice -FriendlyName $([regex]::Match((Get-Content $LastDeviceFile), "^(.*)( \d*)$").captures.groups[1].value) | ForEach-Object {
        $i++
        $Name = $_.FriendlyName + " " + $i
        New-ItemProperty $Path -PropertyType "String" -Force -Name $Name -Value (ParseInstanceId $_.InstanceId)
    }
}
if ($Action -contains "Reset") { Remove-ItemProperty $Path -Name "*" }
}
function Test-RegistryValue {
<#PSScriptInfo

.VERSION 1.0.1

.GUID 73abfeda-2bad-4f83-a401-e34757afcbc0

.AUTHOR Jonathan Medd

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) Jonathan Medd 2014

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
Tests is a given registry key exists.

.PARAMETER Path
The registry key to test.

.PARAMETER Value
The registry value withing the key to test.

.LINK
https://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html
#>

param (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Path,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Value
)

try {
    Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
    return $true
}
catch { return $false }
}
function Test-ScriptMetadata {
<#PSScriptInfo
.VERSION 1.0.0
.GUID a0017a8d-5a3d-49a1-9c7f-5e0dbb5ee7d8

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
This is used to validate the existence of metadata on the individual scripts
#>
[System.Collections.ArrayList]$Results = @()
$SourceScripts = Get-ChildItem -Path *.ps1 -ErrorAction SilentlyContinue -Recurse | Where-Object { ($_.Name -ne "psakefile.ps1") -and ($_.Name -ne "***REMOVED***ITDefaults.ps1") -and ($_.Name -ne "Profile.ps1") }
$SourceScripts | ForEach-Object {
    try { $Info = Test-ScriptFileInfo  $_.FullName } catch { $Info = $false ; Write-Verbose "$_.Name does not have a valid PSScriptInfo block" }
    try { $Description = (Get-Help $_.FullName).Description } catch { $Description = $false ; Write-Verbose "$_.Name does not have a valid help block" }
    if ($Info) { $Info = $true } else { $Info = $False }
    if ($Description) { $Description = $true } else { $Description = $False }

    $Result = [PSCustomObject]@{
        File        = $_.Name
        Info        = $Info
        Description = $Description
    }
    $Results += $Result
}
return $Results
}
function Test-Scripts {
<#PSScriptInfo

.VERSION 1.0.1

.GUID dd50132f-8bc5-4825-918d-9fd0afd3f36b

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
Used to test LoadDefaults and ensure defaults parameters are being loaded correctly.
#>
Param(
    [string]$foo,
    [string]$bar = "bar",
    [string]$baz = "bazziest"
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
$MyInvocation

Write-Output "params"
write-output "foo: $foo"
write-output "bar: $bar"
write-output "baz: $baz"
write-output "test: $test"
}
function Test-VoipMs {
<#PSScriptInfo

.VERSION 1.2.4

.GUID 17fff57c-cce9-4977-a26d-aeded706a85f

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
This script will test the VoIP.ms servers to find one with the lowest latency.

.DESCRIPTION
This script will test the VoIP.ms servers to find one with the lowest latency. If you spesify your credentials, it will use the API to get the most current list of servers. Otherwise, it will fallback to the static list you see below.

.PARAMETER ServerList
The fallback server list used when API credentials are not spesified. You can also pass in a custom list of servers.

.LINK
https://wiki.voip.ms/article/Choosing_Server
#>

<# TODO use credential/secure string for $username and $password #>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "Password")]
param(
  [string]$Username,
  [string]$Password,
  [string]$Country = "*",
  [switch]$Fax,
  [ValidateRange(0, [int]::MaxValue)][int]$Retries = 5,
  [array]$ServerList = @("amsterdam.voip.ms", "atlanta.voip.ms", "atlanta2.voip.ms", "chicago.voip.ms", "chicago2.voip.ms", "chicago3.voip.ms", "chicago4.voip.ms", "dallas.voip.ms", "dallas2.voip.ms", "denver.voip.ms", "denver2.voip.ms", "houston.voip.ms", "houston2.voip.ms", "london.voip.ms", "losangeles.voip.ms", "losangeles2.voip.ms", "melbourne.voip.ms", "montreal.voip.ms", "montreal2.voip.ms", "montreal3.voip.ms", "montreal4.voip.ms", "montreal5.voip.ms", "montreal6.voip.ms", "montreal7.voip.ms", "montreal8.voip.ms", "newyork.voip.ms", "newyork2.voip.ms", "newyork3.voip.ms", "newyork4.voip.ms", "newyork5.voip.ms", "newyork6.voip.ms", "newyork7.voip.ms", "newyork8.voip.ms", "paris.voip.ms", "sanjose.voip.ms", "sanjose2.voip.ms", "seattle.voip.ms", "seattle2.voip.ms", "seattle3.voip.ms", "tampa.voip.ms", "tampa2.voip.ms", "toronto.voip.ms", "toronto2.voip.ms", "toronto3.voip.ms", "toronto4.voip.ms", "toronto5.voip.ms", "toronto6.voip.ms", "toronto7.voip.ms", "toronto8.voip.ms", "vancouver.voip.ms", "vancouver2.voip.ms", "washington.voip.ms", "washington2.voip.ms") #Get the list of servers into an array
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

function Progress {
  param(
    [int]$Index,
    [int]$Total,
    [string]$Name,
    [string]$Activity,
    [string]$Status = ("Processing {0} of {1}: {2}" -f $Index, $Total, $Name),
    [int]$PercentComplete = ($Index / $Total * 100)
  )
  if ($Total -gt 1) { Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete }
}

if ($Username) {
  $ApiServers = (Invoke-RestMethod -Uri ("https://voip.ms/api/v1/rest.php?api_username=" + $Username + "&api_password=" + $Password + "&method=getServersInfo")).servers
  If ($Fax) {
    $Servers = ($ApiServers | Where-Object server_hostname -Like fax*).server_hostname
  }
  else {
    $Servers = ($ApiServers | Where-Object server_hostname -NotLike fax* | Where-Object server_country -like $Country).server_hostname
  }
}
else {
  $Servers = $ServerList
}

Clear-Variable best* -Scope Global #Clear the best* variables in case you run it more than once...

ForEach ($Server in $Servers) {
  $count++ ; Progress -Index $count -Total $Servers.count -Activity "Testing server latency." -Name $Server #Add to the counting varable. Update the progress bar.

  $i = 0 #Counting variable for number of times we tried to ping a given server
  Do {
    $pingsuccess = $false #assume a failure
    $i++ #Add one to the counting variable.....1st try....2nd try....3rd try etc...
    Try {
      $currentping = (test-connection $server -Count 1 -ErrorAction Stop) #Try to ping
      if ($null -ne $currentping.Latency) { $currentping = $currentping.Latency } #PSVersion 7
      else { $currentping = $currentping.ResponseTime } #earlier versions
      $currentping
      $pingsuccess = $true #If success full, set success variable
    }
    Catch {
      $pingsuccess = $false #Catch the failure and set the success variable to false
    }
  }  While ($pingsuccess -eq $false -and $i -le $Retries)  #Try everything between Do and While up to $Retry times, or while $pingsuccess is not true

  #Compare the last ping test with the best known ping test....if there is no known best ping test, assume this one is the best $bestping = $currentping
  If ($pingsuccess -and ($currentping -lt $bestping -or (!($bestping)))) {
    #If this is the best ping...save it
    $bestserver = $server    #Save the best server
    $bestping = $currentping #Save the best ping results
  }
  write-host "tested: $server at $currentping ms after $i attempts" #write the results of the test for this server
}
write-host "`r`n The server with the best ping is: $bestserver at $bestping ms`r`n" #write the end result
Pause
}
function Uninstall-MicrosoftTeams {
<#PSScriptInfo

.VERSION 1.0.1

.GUID 81af22bb-f7a1-42a0-8570-1ac57f49e6bf

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
This script allows you to uninstall the Microsoft Teams app and remove Teams directory for a user.
.DESCRIPTION
Use this script to clear the installed Microsoft Teams application. Run this PowerShell script for each user profile for which the Teams App was installed on a machine. After the PowerShell has executed on all user profiles, Teams can be redeployed.
#>
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice("Uninstall-MicrosoftTeams", "Are you sure you want to proceed?", $choices, 1)
if ($decision -eq 0) {
    $TeamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')
    $TeamsUpdateExePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams', 'Update.exe')
    try {
        if (Test-Path -Path $TeamsUpdateExePath) { Start-Process -FilePath $TeamsUpdateExePath -ArgumentList "-uninstall -s" -PassThru -NoNewWindow -Wait }
        if (Test-Path -Path $TeamsPath) { Remove-Item -Path $TeamsPath -Recurse }
    }
    catch {
        Write-Error -ErrorRecord $_
        exit /b 1
    }
}
else { Break }
}
function Update-AadSsoKey {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 324df81c-9595-4025-b826-08aff404f533

.DESCRIPTION
This script will preform a roll over of Azure SSO Kerberos key. Run this script on the server running Azure AD Connect.

.AUTHOR
Jason Cook, Wybe Smits
http://www.wybesmits.nl

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
.RELEASENOTES
    * 1.0 - initial release 15/04/2019
#>

<#
.SYNOPSIS
This script will preform a roll over of Azure SSO Kerberos key. Run this script on the server running Azure AD Connect.

.LINK
https://docs.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-sso-faq#how-can-i-roll-over-the-kerberos-decryption-key-of-the-azureadssoacc-computer-account
#>
Import-Module $Env:ProgramFiles'\Microsoft Azure Active Directory Connect\AzureADSSO.psd1d'
New-AzureADSSOAuthenticationContext #Office 365 Global Admin
Update-AzureADSSOForest -OnPremCredentials (Get-Credential -Message "Enter Domain Admin credentials" -UserName ($env:USERDOMAIN + "\" + $env:USERNAME))
}
function Update-MicrosoftStoreApps {
<#PSScriptInfo

.VERSION 1.0.7

.GUID 4cac6972-9cb0-4755-bfc1-ae2eb6dfc0d1

.AUTHOR Tony MCP

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) Tony MCP 2016

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
Updates Microsoft Store apps. Equivalent to clicking "Check for Updates" and "Update All" in the Microsoft Store app. Tt doesn't wait for the updates to complete before returning. Check the store app for the status of the updates.

.PARAMETER DontCheckStatus
Prevents the script from opening the store app to monitor the status of the updates.

.LINK
https://social.technet.microsoft.com/Forums/windows/en-US/5ac7daa9-54e6-43c0-9746-293dcb8ef2ec/how-to-force-update-of-windows-store-apps-without-launching-the-store-app
#>

param([switch]$DontCheckStatus)
Test-Admin -Throw | Out-Null
$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_EnterpriseModernAppManagement_AppManagement01"
$wmiObj = Get-WmiObject -Namespace $namespaceName -Class $className
$wmiObj.UpdateScanMethod() | Out-Null
if (-not $DontCheckStatus) { Start-Process "ms-windows-store://downloadsandupdates" }
}
function Update-OfficeCache {
<#PSScriptInfo

.VERSION 1.0.3

.GUID 97314a7e-aba8-41e8-8b1d-ca81372ae070

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
Update the office cache for each XML file in the current folder.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    $Path = (Get-ChildItem -Filter "*.xml"),
    $Setup = ".\setup.exe"
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Path | ForEach-Object {
    If ($PSCmdlet.ShouldProcess("$($_.Name)", "Update-OfficeCache")) {
        Push-Location -Path (Split-Path -Parent -Path $_.FullName)
        Start-Process -FilePath $Setup -ArgumentList @("/download", $_.Name) -NoNewWindow -Wait
        Pop-Location
    }
}
}
function Update-PKI {
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
}
function Update-UsersAcademyStudents {
<#PSScriptInfo

.VERSION 1.0.2

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
}
function Update-UsersStaff {
<#PSScriptInfo

.VERSION 1.0.1

.GUID 120db2ff-3cb8-43ea-aa2c-f044ff52c144

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
Automatically update staff users.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
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
    If ($_.Department = "KCA") { $Company = "***REMOVED*** Christian Academy" }
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
}
function Wait-ForKey {
<#PSScriptInfo

.VERSION 1.0.2

.GUID 3642a129-3370-44a1-94ad-85fb88de7a6b

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
This will continue if the spesified key it press. Otherwise, it will break.

.PARAMETER Key
The key that this will listen for.

.EXAMPLE
Wait-ForKey -Key c
Press c to continue, any other key to abort.: c
#>
param(
    [string]$Key = "y",
    [string]$Message = "Press $Key to continue, any other key to abort."
)

try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$Response = Read-Host $Message
If ($Response -ne $Key) { Break }
}
