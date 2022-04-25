function AuthN {
<#PSScriptInfo
.VERSION 1.0.0
.GUID fe011093-6980-4847-aa9c-f7a7b47a3a5b

.AUTHOR
Jason Cook
Darren J Robinson

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
if (!(Get-Command Get-MsalToken)) { Install-Module -name MSAL.PS -Force -AcceptLicense }
try { return (Get-MsalToken -ClientId $credential.UserName -ClientSecret $credential.Password -TenantId $tenantID) } # Authenticate and Get Tokens
catch { Write-Error $_ }
}
function GetAADPendingGuests {
<#PSScriptInfo
.VERSION 1.0.0
.GUID d2231470-2326-4498-80d2-0456b0018d0a

.AUTHOR
Jason Cook
Darren J Robinson

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
.VERSION 1.0.0
.GUID e5758f99-a57e-4bcf-af21-30e5fd176e51

.AUTHOR
Jason Cook
Darren J Robinson

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
.VERSION 1.0.0
.GUID b444ff47-447f-4196-90eb-08723fa0fbaf

.AUTHOR
Jason Cook
Darren J Robinson

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
.VERSION 1.0.0
.GUID 10ba8c03-4333-4f67-b11b-b25fef85943b

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
.VERSION 1.0.0
.GUID 73e8a944-8951-4a89-9a54-d51db3f9afac

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
Load default parameters for various functions.
#>
param(
    [Parameter(Mandatory = $true)] $Invocation, 
    $DefaultsScripts = "***REMOVED***ITDefaults.ps1"
)

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
.VERSION 1.0.0
.GUID d410b890-4003-4030-8a47-ee4b5d91a254

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
if ($Total -gt 1) { Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete }
}
function Requires {
<#PSScriptInfo

.VERSION 2.0.1

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


.PRIVATEDATA

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
        If (Get-Module -ListAvailable -Name $Module) { Import-Module $Module } else {
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
}
function Add-AllowedDmaDevices {
<#PSScriptInfo

.VERSION 1.0.4

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
foreach ($Device in $AllowedDevices.GetEnumerator()) {
    New-ItemProperty -Path $Path -Name $Device.Name -Value $Device.Value -PropertyType "String" -Force -WhatIf
}
}
function Add-BluredPillarBars {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 6ee394c8-c592-49d5-b16c-601955ef4d2f

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

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
function Add-GroupEmail {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 772c6454-68cf-42aa-89b9-dd6dc5939e1b

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
Set-UnifiedGroup -Identity $-Identity -EmailAddresses: @{Add = $EmailAddress }
If ($SetPrimary) { Set-UnifiedGroup -Identity $-Identity -PrimarySmtpAddress  $EmailAddress }
}
function Add-Path {
<#PSScriptInfo
.VERSION 1.0.0
.GUID bcbc3792-1f34-4100-867c-6fcf09230520

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

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
.VERSION 1.1.3
.GUID 9be6c147-e71b-44c4-b265-1b685692e411

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

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
.VERSION 1.0.1
.GUID 401b32f3-314a-47cf-b910-04c7f2492db2

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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

.VERSION 1.0.2

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


.PRIVATEDATA

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

.VERSION 2.1.1

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


.PRIVATEDATA

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
.VERSION
1.0.1

.GUID
717cb6fa-eb4d-4440-95e3-f00940faa21e

.AUTHOR
Jason Cook
Another Author

.COMPANYNAME
***REMOVED***
Another Company

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
	[ValidateScript( { Test-Path $_ })][array]$Path = (Get-Location),
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
	[string]$Filter,
	[switch]$Force,
	[ValidateScript( { Test-Path -Path $_ -PathType Leaf })][string]$Magick = ((Get-Command magick).Source)
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

If (!(Get-Command magick -ErrorAction SilentlyContinue)) {
	Write-Error "magick.exe is not available in your PATH."
	Break
}
	
[System.Collections.ArrayList]$Results = @()

$Images = Get-ChildItem -File -Path $Path -Filter $Filter
ForEach ($Image in $Images) {
	$count++ ; Progress -Index $count -Total $Images.count -Activity "Resizing images." -Name $Image.Name

	$Arguments = $null		
	If (!$OutExtension) { $ImageOutExtension = [System.IO.Path]::GetExtension($Image.Name) } #If OutExtension not set, use current
	Else { $ImageOutExtension = $OutExtension } #Otherwise use spesified extension
	$OutName += $Prefix + [io.path]::GetFileNameWithoutExtension($Image.Name) + $Suffix + $ImageOutExtension #Out file name
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
.VERSION 1.1.1
.GUID c3469cd9-dc7e-4a56-88f2-d896c9baeb21

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
  [string]$LocalPrefix,
  [string]$Suffix,
  [string]$Filter = "*.pfx"
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$count = 1; $PercentComplete = 0;
$Certificates = Get-ChildItem -File -Path $Path -Filter $Filter
ForEach ($Certificate in $Certificates) {
  #Progress message
  $ActivityMessage = "Converting Certificates. Please wait..."
  $StatusMessage = ("Processing {0} of {1}: {2}" -f $count, @($Certificates).count, $Certificate.Name)
  $PercentComplete = ($count / @($Certificates).count * 100)
  Write-Progress -Activity $ActivityMessage -Status $StatusMessage -PercentComplete $PercentComplete
  $count++

  $Password = Read-Host "Enter Password"
  If ($PSCmdlet.ShouldProcess("$OutName", "Convert-Certificate")) {  
    $LocalPrefix = $Prefix + [System.IO.Path]::GetFileNameWithoutExtension($Certificate.FullName) + "_"
    $Path = $Certificate.FullName
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -out "$LocalPrefix`PEM.txt" -nodes 
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nocerts -out "$LocalPrefix`PEM_Key.txt" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nokeys -out "$LocalPrefix`PEM_Cert.txt" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nokeys -out "$LocalPrefix`PEM_Cert_NoNodes.txt"
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nokeys -out "$LocalPrefix`PEM_Cert.cer" -nodes
    openssl.exe pkcs12 -passin "pass:$Password" -export -in "$LocalPrefix`PEM_Cert.txt" -inkey "$LocalPrefix`PEM_Key.txt" -certfile "$LocalPrefix`PEM_Cert.txt" -out "$LocalPrefix`Unifi.p12" -name unifi -password pass:aircontrolenterprise
        
    openssl.exe pkcs12 -passin "pass:$Password" -in "$Path" -nocerts -nodes | openssl.exe  rsa -out "$LocalPrefix`RSA_Key.txt"
    openssl.exe rsa  -passin "pass:$Password" -in "$LocalPrefix`PEM.txt" -pubout -out "$LocalPrefix`RSA_Pub.txt"
    Write-Output ""

    Write-Output "To import to Windows run the following commands.`n`$mypwd = Get-Credential -UserName 'Enter password below' -Message 'Enter password below'`nImport-PfxCertificate -FilePath C:\Local\Web.pfx -CertStoreLocation Cert:\LocalMachine\My -Password `$mypwd.Password`n"

    New-Item -Force -Type Directory -Name AlwaysUp | Out-Null
    Copy-Item "$LocalPrefix`PEM_Cert.txt" AlwaysUp\ctc-self-signed-certificate-exp-2024.pem
    Copy-Item "$LocalPrefix`PEM_Key.txt" AlwaysUp\ctc-self-signed-certificate-exp-2024-key.pem
    Write-Output "Always Up: Copy files to C:\Program Files (x86)\AlwaysUpWebService\certificates`n"

    New-Item -Force -Type Directory -Name CiscoSG300 | Out-Null
    Copy-Item "$LocalPrefix`PEM_Cert.txt" CiscoSG300\Cert.txt
    Copy-Item "$LocalPrefix`RSA_Pub.txt" CiscoSG300\RSA_Pub.txt
    Copy-Item "$LocalPrefix`RSA_Key.txt" CiscoSG300\RSA_Key.txt
    Write-Output "Cisco SG300: Use RSA Key, RSA Pub, and PEM Cert`nFor RSA Pub, remove the first 32 characters and change BEGIN/END PUBLIC KEY to BEGIN/END RSA PUBLIC KEY. Use only the primary certificate, not the entire chain. When importing, edit HTML to allow more than 2046 characters in certificate feild.`nInstructions from: https://severehalestorm.net/?p=54`n"

    New-Item -Force -Type Directory -Name PaperCutMobility | Out-Null
    Copy-Item "$LocalPrefix`PEM_Cert.txt" PaperCutMobility\tls.cer
    Copy-Item "$LocalPrefix`PEM_Key.txt" PaperCutMobility\tls.pem
    Write-Output "PaperCut Mobility: `n"

    New-Item -Force -Type Directory -Name Spiceworks | Out-Null
    Copy-Item "$LocalPrefix`PEM_Cert.txt" Spiceworks\ssl-cert.pem
    Copy-Item "$LocalPrefix`PEM_Key.txt" Spiceworks\ssl-private-key.pem
    Write-Output "Spiceworks: Copy files to C:\Program Files (x86)\Spiceworks\httpd\ssl`n"

    New-Item -Force -Type Directory -Name UnifiCloudKey | Out-Null
    Write-Verbose "Instructions from here: https://community.ubnt.com/t5/UniFi-Wireless/HOWTO-Install-Signed-SSL-Certificate-on-Cloudkey-and-use-for/td-p/1977049"
    Write-Output "Unifi Cloud Key: Copy files to '/etc/ssl/private' on the Cloud Key and run the following commands.`ncd /etc/ssl/private`nkeytool -importkeystore -srckeystore unifi.p12 -srcstoretype PKCS12 -srcstorepass aircontrolenterprise -destkeystore unifi.keystore.jks -storepass aircontrolenterprise`nkeytool -list -v -keystore unifi.keystore.jks`ntar cf cert.tar cloudkey.crt cloudkey.key unifi.keystore.jks`ntar tvf cert.tar`nchown root:ssl-cert cloudkey.crt cloudkey.key unifi.keystore.jks cert.tar`nchmod 640 cloudkey.crt cloudkey.key unifi.keystore.jks cert.tar`nnginx -t`n/etc/init.d/nginx restart; /etc/init.d/unifi restart`n"
    Copy-Item "$LocalPrefix`PEM_Cert.txt" UnifiCloudKey\cloudkey.crt
    Copy-Item "$LocalPrefix`PEM_Key.txt" UnifiCloudKey\cloudkey.key
    Copy-Item "$LocalPrefix``unifi.p12" UnifiCloudKey\unifi.p12

    New-Item -Force -Type Directory -Name UnifiCore | Out-Null
    Write-Output "Unifi Cloud Key: Copy files to '/data/unifi-core/config' on the Cloud Key and run the following commands.`n`nsystemctl restart unifi-core.service`n"
    Copy-Item "$LocalPrefix`PEM_Cert_NoNodes.txt" UnifiCore\unifi-core.crt
    Copy-Item "$LocalPrefix`RSA_Key.txt" UnifiCore\unifi-core.key

    New-Item -Force -Type Directory -Name USG | Out-Null
    Copy-Item "$LocalPrefix`PEM.txt" server.pem
    Write-Output "Edge Router or USG: Copy the PEM file to '/etc/lighttpd/server.pem' and run the following commands."
    Write-Output "kill -SIGINT `$(cat /var/run/lighttpd.pid)"
    Write-Output "/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf"
    Write-Output ""

    Write-Output "IIS Management: Add PFX certificate to server and run the following commanges in Powershell"
    Write-Output "`$mypwd = Get-Credential -UserName 'Enter password below' -Message 'Enter password below'>"
    Write-Output "Import-PfxCertificate -FilePath '.\***REMOVED*** Web.pfx' -CertStoreLocation Cert:\LocalMachine\My -Password `$mypwd.Password"
    Write-Output "`$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {`$_.subject -like `"****REMOVED****`"} | Where-Object {`$_.NotAfter -gt (Get-Date)} | Select-Object -ExpandProperty Thumbprint"
    Write-Output "Import-Module WebAdministration"
    Write-Output "Remove-Item -Path IIS:\SslBindings\0.0.0.0!8172"
    Write-Output "Get-Item -Path `"cert:\localmachine\my\`$cert`" | New-Item -Force -Path IIS:\SslBindings\0.0.0.0!8172"
    Write-Output "https://support.microsoft.com/en-us/help/3206898/enabling-iis-manager-and-web-deploy-after-disabling-ssl3-and-tls-1-0"
    Write-Output ""

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
.VERSION 1.1.0
.GUID 5c162a3a-dc4b-43d5-af07-7991ae41d03b

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.SYNOPSIS
This script will resize the spesified images to the spesifications detailed in a json file.

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
	[ValidateScript( { Test-Path $_ })][array]$Path = (Get-ChildItem -File -Filter $Filter),
	[ValidateScript( { Test-Path $_ })][string]$OutPath = (Get-Location),
	[switch]$Force,
	[string]$Destination,
	[string]$Prefix,
	[switch]$All
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

if (-not $Json) { throw "Json file not found." }
ForEach ($Image in $Path) {
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
.VERSION 1.1.0
.GUID 460f5844-8755-46df-8fb5-a12fa88bf413

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
.VERSION 1.3.0
.GUID 61ab8232-0c28-495f-9e44-3c511c2634ea

.AUTHOR
Jason Cook
Roman Zarka | Microsoft Services

.DESCRIPTION
This script enable the spesified license options in Microsoft 365.

.COMPANYNAME
***REMOVED***
Microsoft Services

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
.LICENSEURI https://github.com/MicrosoftDocs/microsoft-365-docs/blob/public/LICENSE
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
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

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
.VERSION 1.3.0
.GUID 528bfa6d-27a7-4612-9092-faae014e3917

.AUTHOR
Jason Cook
Drew Cross | Microsoft Services

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

if ([string]::IsNullOrEmpty($vmName)) {
    Write-Host "No VM name passed"
    Exit;
}

$4GB = 4294967296

#
#

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

#
#

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
function Export-MatchingCertificates {
<#PSScriptInfo

.VERSION 1.0.1

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


.PRIVATEDATA

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
Requires -Modules PSPKI
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

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
function Get-ADInfo {
<#PSScriptInfo

.VERSION 1.0.1

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


.PRIVATEDATA

#> 



<#
.SYNOPSIS
The script will get information about users, groups, and computers from Active Directory.

.DESCRIPTION
The script will get information about users, groups, and computers from Active Directory.

.PARAMETER ListUpn
List the UPN for each user. Can be combined with -Filter.

.PARAMETER LikeUpn
Filters for a specific UPN. Must be used in conjunction with -ListUpn. This overrides -Filter.

.PARAMETER ListHomeDirectory
List the home directory for each user.  Can be combined with -Filter.

.PARAMETER Filter
Filters the search based on the spesified parameters.

.PARAMETER ListComputerPasswords
List the local admin password. Can be combined with -Filter.

.PARAMETER UpdateUpn
Updates the Upn. Must be used with -OldUpn and -NewUpn. Can be combined with -SearchBase

.PARAMETER OldUpn
Specifes the UPN to be changed from. If unspecified, will use "*@koinonia.local".

.PARAMETER NewUpn
Spesified the UPN to change to.  If unspecified, will use "*@***REMOVED***".

.PARAMETER SearchBase
Specifies the search base for the command.

.PARAMETER ListComputers
List the computers in the organization.  Can be combined with -Filter.

.PARAMETER Export
Export to a CSV file using the hard-coded search parameters. If no file specified, will use .\AD Users.csv

.PARAMETER Sid
Matches the specified SID to a user.

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

.EXAMPLE
Get-ADInfo.ps1 -listHomeDirectory
name      homeDirectory                           profilePath
----      -------------                           -----------
Jane Doe  \\server.domain1.com\Profile\Jane.Doe\
John Doe  \\server.domain2.com\Profile\John.Doe\

.EXAMPLE
Get-ADInfo.ps1 -ListComputerPasswords
name            ms-Mcs-AdmPwd
----            -------------
JANEDOE-LAPTOP  *TVCiN#8bMVOW
JOHNDOE-LAPTOP  r4o1eY747KXN6Ty
#>

param(
  [string]$Filter,
  [switch]$ListUpn,
  [string]$likeUpn,
  [switch]$updateUpnSuffix,
  [string]$oldUpnSuffix,
  [string]$newUpnSuffix,
  [string]$SearchBase,
  [switch]$ListHomeDirectory,
  [switch]$ListComputers,
  [switch]$ListComputerPasswords,
  [switch]$ListExtensions,
  [switch]$Export,
  [string]$Sid
)

$meActual = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$me = "${meActual}:"
$parent = Split-Path $script:MyInvocation.MyCommand.Path

Function checkAdmin {
  If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
		}
}

If (!(Get-Module ActiveDirectory)) { Import-Module ActiveDirectory }

If ($ListUpn) {
  If ($likeUpn) {
    $UpnFilter = "*" + $likeUpn + "*"
  }
  Elseif ($Filter) {
    $UpnFilter = $Filter
  }
  Else {
    $UpnFilter = "*"
  }
  Write-Verbose "$me Listing all users with a UPN like $filter. Sorting by UPN"
  Get-ADUser -Filter { UserPrincipalName -like $UpnFilter } -Properties distinguishedName, UserPrincipalName | Select-Object name, UserPrincipalName | Sort-Object -Property UserPrincipalName | Format-Table
}

If ($updateUpnSuffix) {
  Write-Verbose "$me Setting old UPN, new UPN, and Search Base if not specified."
  If (!$oldUpnSuffix) { $oldUpnSuffix = "@koinonia.local" }
  $OldUpnSearch = "*" + $oldUpnSuffix
  If (!$newUpnSuffix) { $newUpnSuffix = "@***REMOVED***" }
  If (!$searchBase) { $searchBase = "DC=koinonia,DC=local" }
  Write-Verbose "$me Starting update..."
  checkAdmin
  Write-Information -MessageData "$me Changing UPN to $newUpnSuffix for all uses with a $oldUpnSuffix UPN in $searchBase." -InformationAction Continue
  Get-ADUser -Filter { UserPrincipalName -like $OldUpnSearch } -SearchBase $searchBase |
  ForEach-Object {
    $OldUpn = $_.UserPrincipalName
    $Upn = $_.UserPrincipalName -ireplace [regex]::Escape($oldUpnSuffix), $newUpnSuffix
    Set-ADUser -identity $_ -UserPrincipalName $Upn
    $NewUpn = $_.UserPrincipalName
    Write-Verbose "$me Changed $OldUpn to $NewUpn"
  }
}

If ($ListHomeDirectory) {
  If (!$filter) { $filter = "*" }
  Write-Verbose "$me Listing all users with their Home Directory and Profile Path. Sorting by Home Directory"
  Get-ADUser -Filter $filter -Properties homeDirectory, profilePath  | Select-Object name, homeDirectory, profilePath | Sort-Object -Property homeDirectory -Descending | Format-Table
}

If ($ListComputers) {
  If (!$filter) { $filter = "*" }
  Write-Verbose "$me Getting OS Versions"
  Get-ADComputer -Filter * -Property Name, OperatingSystem, OperatingSystemVersion, operatingSystemServicePack | Sort-Object @{Expression = 'OperatingSystem'; Ascending = $true }, @{Expression = 'operatingSystemVersion'; Ascending = $false }, @{Expression = 'Name'; Ascending = $true } | Format-Table Name, OperatingSystem, OperatingSystemVersion, operatingSystemServicePack -Wrap -Auto
}

Function listComputerPasswords {
  param([string]$Filter, [string]$Message)
  If (!$filter) { $filter = "*" }
  checkAdmin
  Write-Information -MessageData "$Message" -InformationAction Continue
  Get-ADComputer -Filter $Filter -Properties ms-Mcs-AdmPwd | Select-Object name, ms-Mcs-AdmPwd | Sort-Object -Property ms-Mcs-AdmPwd -Descending | Format-Table
}
If ($ListComputerPasswords -AND $Filter) {
  listComputerPasswords -Message "$me Computers matching $filter." -Filter $Filter
}
Elseif ($ListComputerPasswords) {
  listComputerPasswords -Message "$me Non-mac passwords." -Filter 'Name -notlike "*-DM" -and Name -notlike "*-LM" -and Enabled -eq $True'
  listComputerPasswords -Message "$me Mac passwords." -Filter 'Name -like "*-DM" -or Name -like "*-LM" -and Enabled -eq $True'
  listComputerPasswords -Message "$me Disabled computer accounts." -Filter 'Enabled -eq $False'
}
  


If ($ListExtensions) {
  If (!$filter) { $filter = "*" }
  Write-Verbose "$me Getting ipPhone"
  Get-ADUser -LDAPFilter "(ipPhone=*)" -Properties ipPhone  | Select-Object name, ipPhone | Sort-Object -Property ipPhone
}

If ($Export) {
  #File Location
  If ($Export) { $ExportFile = $Export }
  If (!$ExportFile) { $ExportFile = $parent + "\AD Users.csv" }
  Write-Verbose "$me Writing to $ExportFile"

  #Set the domain to search at the Server parameter. Run powershell as a user with privilieges in that domain to pass different credentials to the command.
  #Searchbase is the OU you want to search. By default the command will also search all subOU's. To change this behaviour, change the searchscope parameter. Possible values: Base, onelevel, subtree
  #Ignore the filter and properties parameters

  $ADUserParams = @{
    'Server'      = 'KCFAD01.***REMOVED***.local'
    'Searchbase'  = 'OU=_***REMOVED***,DC=***REMOVED***,DC=local'
    'Searchscope' = 'Subtree'
    'Filter'      = '*'
    'Properties'  = '*'
  }

  #This is where to change if different properties are required.
  $SelectParams = @{
    'Property' = 'SAMAccountname', 'CN', 'title', 'DisplayName', 'Description', 'EmailAddress', 'mobilephone', @{name = 'businesscategory'; expression = { $_.businesscategory -join '; ' } }, 'office', 'officephone', 'state', 'streetaddress', 'city', 'employeeID', 'Employeenumber', 'enabled', 'lockedout', 'lastlogondate', 'badpwdcount', 'passwordlastset', 'created'
  }

  Get-ADUser @ADUserParams | Select-Object @SelectParams | Export-Csv $ExportFile
}

If ($Sid) {
  If (!$Sid) { Write-Error "Please specify a SID using the -SID paramater" }
  $Sid = [ADSI]"LDAP://<SID=$Sid>"
  Write-Output $Sid
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
.VERSION 1.1.1
.GUID 674855a4-1cd1-43b7-8e41-fea3bc501f61

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

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
.VERSION 1.0.1
.GUID 10b98a61-ebf3-499f-847f-4aa18b41a9dd

.AUTHOR
Jason Cook
Rajeev Buggaveeti

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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

#Download all user profile pictures from Office 365:
Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $Path -ItemType Directory -Force -Confirm:$false | Out-Null
#Output to store Resized images#
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
.VERSION 1.1.0
.GUID d15ce592-4b3e-4d42-82b6-d4a2dd5f15f2

.AUTHOR
Jason Cook
Chris Warwick

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022.
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
function Get-ipPhone {
<#PSScriptInfo

.VERSION 1.0.1

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


.PRIVATEDATA

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
function Get-LapsStatus {
<#PSScriptInfo

.VERSION 1.0.1

.GUID 2a3f5ec5-e6c3-4a0b-a8ca-67f98b359144

.AUTHOR Jason Cook

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) ***REMOVED*** 2022

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
.VERSION 1.0.1
.GUID f3ba5497-54b4-4b33-8c6f-33a678f5551c

.AUTHOR
Jason Cook
Laeeq Qazi - www.HostingController.com

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
.VERSION 1.1.3
.GUID 4625bce9-661a-4a70-bb4e-46ea09333f33

.AUTHOR
Jason Cook
Microsoft

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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

.VERSION 1.0.1

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


.PRIVATEDATA

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
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateScript( { Test-Path ((Get-Item $_).parent) })][string]$Path = ".\AD.csv",
    [array]$Properties = ("name", "mail"),
    [string]$SearchBase ,
    [string]$Filter = "*"
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

If ($SearchBase) { $Result = Get-ADUser -Properties $Properties -Filter $Filter -SearchBase $SearchBase | Where-Object Enabled -eq $true }
else { $Result = Get-ADUser -Properties $Properties -Filter $Filter | Where-Object Enabled -eq $true }
$Result += Get-ADUser -Properties $Properties -Identity "koinonia"
$Result += Get-ADUser -Properties $Properties -Identity "kcfit"
$Result = $Result | Where-Object msExchHideFromAddressLists -ne $true | Select-Object name, mail | Sort-Object -Property Company, name
$Result | ForEach-Object { $_.name = "$($_.name[0..23] -join '')" } #Trim lenght for import.
$Result | Export-Csv -NoTypeInformation -Path $Path
Return $Result
}
function Get-NewIP {
<#PSScriptInfo
.VERSION 1.01
.GUID 9eea8e22-18f9-4cf7-b019-602c7d71dcf8

.AUTHOR
Jason Cook
Aman Dhally - amandhally@gmail.com

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022. Copyright (c) Aman Dhally 04-04-2012
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
	$expireTimeUntil = New-TimeSpan �Start (Get-Date) �End $expireTime
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
.VERSION 1.0.1
.GUID 4ec63b79-6484-43eb-90f8-bef7e2642564

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

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
.VERSION 1.0.0
.GUID 05dad3a6-57cf-4747-b3bd-57bc12b7628e

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
.VERSION 1.0.1
.GUID 421f45c1-3a42-4c17-83a8-bb109f412a19

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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

.VERSION 1.0.2

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


.PRIVATEDATA

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
}
function Get-StaleAADGuestAccounts {
<#PSScriptInfo

.VERSION 1.1.1

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


.PRIVATEDATA

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
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

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

.VERSION 1.0.1

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


.PRIVATEDATA

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
.VERSION 1.0.1
.GUID 14062539-2775-4450-bb0b-a3406d1db091

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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

.VERSION 1.0.1

.GUID c64f1f09-036c-471d-898c-c9b3da6f53a8

.AUTHOR Jason Cook

.COMPANYNAME ***REMOVED***

.COPYRIGHT Copyright (c) ***REMOVED*** 2022

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

.VERSION 1.0.1

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


.PRIVATEDATA

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

.VERSION 1.0.6

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


.PRIVATEDATA

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
function Initialize-OneDrive {
<#PSScriptInfo

.VERSION 1.0.1

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


.PRIVATEDATA

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

.VERSION 1.2.7

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


.PRIVATEDATA

#> 

<#
.SYNOPSIS
This script will install the neccesary applications and services on a given machine.

.DESCRIPTION
This script will install the neccesary applications and services on a given machine. It will also check for updates to third-party applications. This script will also configure certain items not able to be configured by Group Policy,

.PARAMETER BitLockerProtector
If a protector is specified, BitLocker will be enabled using that protector. Valid options are TPM, Pin, Password, and USB. You can also pass Disable to disable BitLocker

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
Choose a Provisioning Package to be installed.

.PARAMETER RSAT
If specified, Remote Server Administrative Tools will be installed.

.PARAMETER Office
Specifes the version of Office to install. If unspecified, Office will not be installed.
  
.EXAMPLE
Install.ps1 -BitLocker -Office 2019

#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateSet("TPM", "Password", "Pin", "USB")][string]$BitLockerProtector,
  [string]$Office,
  [switch]$RSAT,
  [string]$ProvisioningPackage,
  [switch]$NetFX3,
  [switch]$Ninite,
  [string]$NiniteInstallTo = "Workstation",
  [ValidateScript({ Test-Path $_ })][string]$BitLockerUSB,
  [string]$BitLockerEncryptionMethod = "XtsAes256",
  [string]$DriveLabel = "Windows",
  [string]$DriveToLabel = ($env:SystemDrive.Substring(0, 1))
)

$meActual = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$me = "${meActual}:"
$parent = Split-Path $script:MyInvocation.MyCommand.Path

Import-Module $parent\***REMOVED***It\***REMOVED***IT.psm1 -Force
If (!(Test-Admin -Warn)) { Break }

If ($BitLockerProtector) {
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

If ($NetFX3) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install .NET Framework 3.5 (includes .NET 2.0 and 3.0)")) {
    Write-Verbose "Installing .NET Framework 3.5 (includes .NET 2.0 and 3.0)"
    Get-WindowsCapability -Online -Name NetFx3* | Add-WindowsCapability -Online
  }
}

If ($RSAT) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install Remote Server Administrative Tools")) {
    Write-Verbose "Install Remote Server Administrative Tools"
    Get-WindowsCapability -Online -Name "RSAT*" | Add-WindowsCapability -Online
  }
}
If ($Ninite) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername) $NiniteInstallTo", "Install apps using Ninite")) {
    Write-Verbose "Running Ninite"
    & $parent\..\Ninite\Ninite.ps1 -Local -InstallTo $NiniteInstallTo
  }
}

If ($Office) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install Office $Office")) {
    Install-MicrosoftOffice -Version $Office
  }
}


If ($ProvisioningPackage) {
  If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install-ProvisioningPackage -QuietInstall -PackagePath $ProvisioningPackage")) {
    If (Test-Path -PathType Leaf -Path $ProvisioningPackage) { Install-ProvisioningPackage -QuietInstall -PackagePath $ProvisioningPackage }
    else { Write-Warning "$me The provisioning file specified is not valid." }
  }
}

If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Set-Volume -DriveLetter $DriveToLabel -NewFileSystemLabel $DriveLabel")) {
  Set-Volume -DriveLetter $DriveToLabel -NewFileSystemLabel $DriveLabel
  Write-Verbose "$me Checking for reboot."
  Import-Module $parent\Modules\pendingreboot.0.9.0.6\pendingreboot.psm1
  If ((Test-Path "HKLM:\SOFTWARE­\Microsoft­\Windows­\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") -or (Test-PendingReboot -SkipConfigurationManagerClientCheck).IsRebootPending) {
    Write-Verbose "A reboot is required. Reboot now?"
    Restart-Computer -Confirm
  }
}
}
function Install-GCPW {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 24dd6c1f-cc9a-44a4-b8e8-dd831d7a51b4

.AUTHOR
Jason Cook
Google

.COMPANYNAME
***REMOVED***
Google

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

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
function Install-MicrosoftOffice {
<#PSScriptInfo

.VERSION 1.2.2

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


.PRIVATEDATA

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
}
function Install-RSAT {
<#PSScriptInfo

.VERSION 1.2.1

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


.PRIVATEDATA

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

if (-NOT([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning -Message "The script requires elevation"
    break
}

$1809Build = "17763"
$1903Build = "18362"
$WindowsBuild = (Get-WmiObject -Class Win32_OperatingSystem).BuildNumber
#$runningDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

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
.VERSION 1.2.2
.GUID ece98adc-3c44-4a02-a254-d4e7f2888f4f

.AUTHOR
Jason Cook
Joseph Palarchio

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
.VERSION 1.0.0
.GUID f4c6b8ab-e5d2-4967-b803-a410619bd191

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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

.VERSION 1.0.3

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


.PRIVATEDATA

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
function New-RandomCharacters {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 9f443ca7-e536-40ee-a774-7d94c5d3c569

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
$Random = 1..$Length | ForEach-Object { Get-Random -Maximum $Characters.length }
$private:ofs = ""
return [String]$Characters[$Random]
}
function New-RandomPassword {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 1591ca01-1cf9-4683-9d24-fbd1f746f44c

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.SYNOPSIS
This will return a random password.

.DESCRIPTION
This will return a random password. The format of the password will be half lowercase, half uppercase, two numbers, and two symbols.

.PARAMETER Lenght
The lenght of the password to return.

.PARAMETER Characters
A string of characters to use.
#>
param (
  $length = 14
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }

$LengthAlpha = $Length - 4
$LengthLower = [math]::Max(0, $LengthAlpha / 2)
$LengthUpper = [math]::Max(0, $LengthAlpha - $LengthLower)
$Password = Get-RandomCharacters -length $LengthLower -characters "abcdefghiklmnoprstuvwxyz"
$Password += Get-RandomCharacters -length $LengthUpper -characters "ABCDEFGHKLMNOPRSTUVWXYZ"
$Password += Get-RandomCharacters -length 2 -characters "1234567890"
$Password += Get-RandomCharacters -length 2 -characters "!@#$%^&*()_+-=[]\{}|;:,./<>?"
Return $Password
}
function Ping-Hosts {
<#PSScriptInfo
.VERSION 1.0.0
.GUID 0603a3ee-bff9-464a-aa86-44903c476fe9

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
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
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
#Funtion to make space so that formatting looks good
Function MakeSpace($l, $Maximum) {
    $space = ""
    $s = [int]($Maximum - $l) + 1
    1..$s | ForEach-Object { $space += " " }

    return [String]$space
}
#Array Variable to store length of all hostnames
$LengthArray = @() 
$Hosts | ForEach-Object { $LengthArray += $_.length }

#Find Maximum length of hostname to adjust column witdth accordingly
$Maximum = ($LengthArray | Measure-object -Maximum).maximum
$Count = $hosts.Count

#Initializing Array objects 
$Success = New-Object int[] $Count
$Failure = New-Object int[] $Count
$Total = New-Object int[] $Count
Clear-Host
#Running a never ending loop
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

.VERSION 1.0.4

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
