function AuthN {
<#
.SYNOPSIS
Authenticate to Azure AD and receieve Access and Refresh Tokens.

.DESCRIPTION
Authenticate to Azure AD and receieve Access and Refresh Tokens.

.PARAMETER tenantID
(required) Azure AD TenantID.

.PARAMETER credential
(required) ClientID and ClientSecret of the Azure AD registered application with the necessary permissions.

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
<#
.SYNOPSIS
Get AAD B2B Accounts where the inviation hasn't been accepted.

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
<#
.SYNOPSIS
Get AAD Account SignIn Activity.

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
<#
.SYNOPSIS
Get AAD Account SignIn Activity.

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
param($Name, $AltName) 
Write-Verbose "$me Installing $Name Module if missing"
If (!(Get-Module -ListAvailable -Name $Name)) {
	Install-Module $Name
}
}
function LoadDefaults {
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
function Add-BluredPillarBars {
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

.NOTES
File Name  : Add-BluredPillarBars.ps1
Version    : 1.1.1
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022

#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript( { Test-Path -Path $_ })][Parameter(Mandatory = $true)][string]$Path,
  [string]$Background,
  [string]$Format,
  [string]$Aspect = "16:9",
  [string]$Prefix = ($Aspect -Replace ":", "x") + "_",
  [string]$Suffix,
  [int]$MaxHeight,
  [switch]$Preview
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
function Add-Office365GroupEmail {
param (
    [string]$GroupName,
    [string]$EmailAddress,
    [switch]$SetPrimary
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
Set-UnifiedGroup -Identity $GroupName -EmailAddresses: @{Add = $EmailAddress }
If ($SetPrimary) { Set-UnifiedGroup -Identity $GroupName -PrimarySmtpAddress  $EmailAddress }
}
function Add-Signature {
<#
.SYNOPSIS
This script will sign Powershell scripts with the availble code signing certificate.

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

.NOTES
File Name  : Add-Signature.ps1
Version    : 1.1.2
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript( { Test-Path -Path $_ })][string]$Path = (Get-Location),
  [string]$Filter = "*.ps*1",
  [ValidateScript( { Test-Certificate $_ })][System.Security.Cryptography.X509Certificates.X509Certificate]$Certificate = ((Get-ChildItem cert:currentuser\my\ -CodeSigningCert | Sort-Object NotBefore -Descending)[0]),
  [string]$Name = "Signed by " + (([ADSISearcher]"(&(objectCategory=User)(SAMAccountName=$env:username))").FindOne().Properties).company,
  [string]$Url
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

Get-ChildItem -File -Path $Path -Filter $Filter | ForEach-Object {
  if ($PSCmdlet.ShouldProcess("$_.Name", "Add-Signature $($Certificate.Subject)")) {
    If (([System.IO.Path]::GetExtension($_.FullName) -like ".ps*1")) { Set-AuthenticodeSignature -FilePath $_.FullName -Certificate $Certificate }
    elseif ([System.IO.Path]::GetExtension($_.FullName) -eq ".exe") {
      $signString = 'Signtool.exe sign /a /d "' + $Name 
      if ($Url) { $Signtool += '" /du "' + $Url + '" ' }
      $signString += $Exe
      Write-Verbose "Signing $($_.Name): $signString"
      & $signString      
    } 
    else { Write-Error "We don't know how to handle this file type: ($([System.IO.Path]::GetExtension($_.Name))" }
  }
}
}
function Backup-MySql {
<#
.SYNOPSIS
This script will backup MySQL.

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
Backup-MySql.ps1

.NOTES
File Name  : Backup-MySql.ps1
Version    : 1.0.1
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>

param(
  [ValidateScript( { Test-Path -Path $_ -PathType Container })][string]$mySqlData = "C:\mySQL\data", #Patch to datatbases files directory
  [ValidateScript( { Test-Path -Path $_ -PathType Container })][string]$BackupLocation = "C:\Local\MySqlBackups", #Backup Directory
  [ValidateScript( { Test-Path -Path $_ -PathType Leaf })][string]$ConfigFile = ".\my.cnf", #Config file
  [ValidateScript( { Test-Path -Path $_ -PathType Leaf })][string]$mySqlDump = "C:\mySQL\bin\mysqldump.exe", #Patch to mysqldump.exe
  [switch]$NoTrim,
  [Int]$Copies = 10 #Number of copies to keep
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
Get-ADUser -Filter { AdminCount -ne "0" } -Properties AdminCount | Set-ADUser -Clear AdminCount
}
function Clear-PrintQueue {
<#
.SYNOPSIS
This script will clear all print jobs in the queue.

.DESCRIPTION
This script will delete all *.shd and .spl file in %systemroot%\system32\spool\printers\ and restart the spooler service.

.PARAMETER ComputerName
This can be used to select a computer to clear the print jobs on. This option is required.

.EXAMPLE
.\Clear-PrintQueue.ps1 -ComputerName PrintServer

.NOTES
File Name  : Clear-PrintQueue.ps1
Version    : 1.0.1
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>
param(
  [string]$ComputerName
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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

.NOTES
File Name  : Connect-Office365.ps1
Version    : 2.1.0
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
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

. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
		Import-Module Microsoft.Online.SharePoint.PowerShell | Write-Verbose
		If ($BasicAuth) { Connect-SPOService -Url https://$Tenant-admin.sharepoint.com -Credential $Credential | Write-Verbose }
		Else { Connect-SPOService -Url https://$Tenant-admin.sharepoint.com | Write-Verbose }
	}
	If ($SkypeForBusinessOnline) {
		Write-Verbose "$me Connecting to Skype For Business Online"
		Import-Module SkypeOnlineConnector | Write-Verbose
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
<#
	.SYNOPSIS
	This script will resize an image using ImageMagick.

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

	.NOTES
	File Name  : Convert-Image.ps1
	Version    : 1.0.1
	Author     : ***REMOVED***

	Copyright (c) ***REMOVED*** 2019-2021

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
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
<#
    .SYNOPSIS
    This script will convert a PFX certificate for use with various services.

    .DESCRIPTION
    This script will convert a PFX certificate for use with various services. If will also provide instructions for any system that has spesific requirements for setup. This script requires & .\openssl.exe  to be available on the computer.

    .PARAMETER Path
    This is the certificate file which will be converted. This option is required. 

    .PARAMETER Prefix
    This string appears before the filename for each converted certificate. If unspesified, will use the name if the file being resized.

    .NOTES
    File Name  : ConvertTo-EndpointCertificate.ps1  
    Version    : 1.1.1
    Author     : ***REMOVED***

    Copyright (c) ***REMOVED*** 2019-2021
  #>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateScript( { Test-Path $_ })][string]$Path = (Get-Location),
  [string]$LocalPrefix,
  [string]$Suffix,
  [string]$Filter = "*.pfx"
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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

.NOTES
File Name : ConvertTo-OutputImages.ps1
Version  : 1.1.0
Author   : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
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
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

if (-not $Json) {throw "Json file not found."}
$json
Break
ForEach ($Image in $Path) {
	$Formats = (Get-Content -Path $script:json | ConvertFrom-Json).$Type
	$count1++; $count2 = 0
	If ($Destination) { $Formats = $Formats | Where-Object Destination -Contains $Destination }
	$Formats | ForEach-Object {
		$count2++; Progress -Index $count2 -Total ([math]::Max(1, $Formats.count)) -Activity "Resizing $count1 of $($Path.count): $($Image.Name)" -Name $_.Name
		Start-Sleep -Milliseconds 500
		If ($PSCmdlet.ShouldProcess("$($Image.FullName) > $($_.Name)", "Convert-Image")) {
			Convert-Image -Force:$Force -Path $Image.FullName -OutPath $OutPath -Dimensions $_.Dimensions  -Suffix ("_" + $_.Name) -Trim:$_.Trim -OutExtension $_.OutExtension -FileSize $_.FileSize -Mode $_.Mode
		} 
	}
}
}
function Disable-NetbiosTcpIp {
<#
.SYNOPSIS
This script will disable Netbios TCP/IP on all interfaces.

.DESCRIPTION
This script will disable Netbios TCP/IP on all interfaces.

.NOTES
File Name  : Disable-NetbiosTcpIp.ps1
Version    : 1.1.0
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
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
<#
.SYNOPSIS
This script will disallows self service purchases in Microsoft 365.

.NOTES
File Name  : Disable-SelfServicePurchase.ps1
Version    : 1.0.0
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022

.LINK
https://github.com/MicrosoftDocs/microsoft-365-docs/blob/public/microsoft-365/commerce/subscriptions/allowselfservicepurchase-powershell.md
#>
Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase | ForEach-Object { Update-MSCommerceProductPolicy -PolicyId AllowSelfServicePurchase -ProductId $_.ProductID -Enabled $false }
}
function Enable-LicenseOptions {
<#
.SYNOPSIS
This script enable the spesified license options in Microsoft 365.

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
File Name  : Enable-LicenseOptions.ps1
Version    : 1.3.0
Author     : Roman Zarka | Microsoft Services and ***REMOVED***
Licence    : Creative Commons Attribution-ShareAlike 4.0 International License | https://creativecommons.org/licenses/by-sa/4.0/

by Roman Zarka | Microsoft Services
Copyright (c) ***REMOVED*** 2022

.LINK
https://blogs.technet.microsoft.com/zarkatech/2012/12/05/bulk-enable-office-365-license-options/

.LINK
https://docs.microsoft.com/en-us/microsoft-365/enterprise/assign-licenses-to-user-accounts-with-microsoft-365-powershell?view=o365-worldwide
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
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
<#
.SYNOPSIS
Checks VM for nesting comatability and configures if not properly setup.

.PARAMETER VMName
Which VM should nesting be enabled for?

.EXAMPLE
Enable-NestedVm -VmName MyVM

.NOTES
File Name  : Enable-NestedVm.ps1
Version    : 1.3.0
Author     : Drew Cross | Microsoft Services and ***REMOVED***
Credits    : Created by Microsoft. Availables under Creative Commons Attribution 4.0 International License.

Copyright (c) ***REMOVED*** 2022

.LINK
https://github.com/MicrosoftDocs/Virtualization-Documentation/blob/main/hyperv-tools/Nested/Enable-NestedVm.ps1

.LINK
https://github.com/MicrosoftDocs/Virtualization-Documentation/blob/main/LICENSE
#>



param([string]$vmName)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
<#
.SYNOPSIS
This script will fetch all certificates matching the chosen template. Usefull for adding certificate to Trusted Publishers.

.NOTES
File Name  : Export-MatchingCertificates.ps1
Version    : 1.0.0
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022

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
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

if (-not $Template) {throw "You must spesify the templates to search for."}

Import-Module PSPKI # https://github.com/PKISolutions/PSPKI
$Templates | Foreach-Object {
  Get-IssuedRequest -CertificationAuthority $CertificationAuthority -Property RequestID, RawCertificate, Request.RequesterName, CertificateTemplate -Filter "NotAfter -ge $Date", "CertificateTemplate -eq $_" | ForEach-Object { 
    Set-Content -Path (Join-Path -Path  $Path -ChildPath ("\" + $_.RequestID + "-" + $_.CommonName + ".crt")) -Value ("-----BEGIN CERTIFICATE-----`n" + $_.RawCertificate + "-----END CERTIFICATE-----") 
  }
}
}
function Find-EmptyOu {
<#
.SYNOPSIS
This script will find all empty organizational units.

.NOTES
File Name  : Find-EmptyOu.ps1
Version    : 1.0.0
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
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
function Get-AdminCount {
Get-ADUser -Filter { AdminCount -ne "0" } -Properties AdminCount | Select-Object name, AdminCount
}
function Get-BitlockerStatus {
<#
.SYNOPSIS
This commands checks the Bitlocker status and returns it in a human readable format.

.DESCRIPTION
This commands checks the Bitlocker status and returns it in a human readable format.

.PARAMETER Drive
The drive to check for protection on. If unspesified, the System Drive will be used.

.NOTES
File Name  : Get-BitlockerStatus.ps1
Version    : 1.1.1
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>
param (
  [ValidateScript( { Test-Path $_ })][string]$Drive = $env:SystemDrive
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
Get-O365Photos

.NOTES
File Name  : Get-ExchangePhoto.ps1
Version    : 1.0.1
Author     : Rajeev Buggaveeti and ***REMOVED***

by Rajeev Buggaveeti
Copyright (c) ***REMOVED*** 2022

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
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
File Name  : Get-FirmwareType.ps1
Version    : 1.1.0
Author     : Chris Warwick and ***REMOVED***
Credits    : Copyright (c) 2015 Chris Warwick. Released under the MIT License.

Copyright (c) ***REMOVED*** 2022

.LINK
https://github.com/ChrisWarwick/GetUEFI/blob/master/GetFirmwareBIOSorUEFI.psm1

.LINK
https://github.com/ChrisWarwick/GetUEFI/blob/master/LICENSE
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
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateScript( { Test-Path ((Get-Item $_).parent) })][string]$Path = ".\AD.csv",
    [array]$Filter = "ipphone -like " * "}"
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

Get-ADUser -Properties name, ipPhone, Company, Title, Department, DistinguishedName -Filter $Filter | Where-Object msExchHideFromAddressLists -ne $true | Select-Object name, ipPhone, Company, Title, Department | Sort-Object -Property Company, name | Export-Csv -NoTypeInformation -Path $Path
}
function Get-MailboxAddresses {
<#
.SYNOPSIS
This script will get all email addresses for the organization.

.DESCRIPTION
This script will get all email addresses for the organization. It is based on the answer located here: https://social.technet.microsoft.com/Forums/exchange/en-US/a234ba3b-37b4-4333-8954-5f46885c5e20/how-to-list-email-addresses-and-aliases-for-each-user?forum=exchangesvrgenerallegacy

.LINK
https://social.technet.microsoft.com/Forums/exchange/en-US/a234ba3b-37b4-4333-8954-5f46885c5e20/how-to-list-email-addresses-and-aliases-for-each-user?forum=exchangesvrgenerallegacy

.NOTES
File Name  : Get-MailboxAddresses.ps1
Version    : 1.0.1
Author     : ***REMOVED***
Author     : Laeeq Qazi - www.HostingController.com

Copyright (c) ***REMOVED*** 2022

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
<#
.SYNOPSIS
This script will output the amount of memory and the type using WMI information. 

.DESCRIPTION
This script will output the amount of memory and the type using WMI information. Type information is taken from here: https://msdn.microsoft.com/en-us/library/aa394347(v=vs.85).aspx
.LINK
https://msdn.microsoft.com/en-us/library/aa394347(v=vs.85).aspx

.EXAMPLE Get-MemoryType
moduleCapacityMB : {8192, 8192}
moduleCapacityGB : {8, 8}
totalCapacityMB  : 16384
totalCapacityGB  : 16
Dimm             : {24, 24}
DimmType         : DDR3

.NOTES
File Name  : Get-MemoryType.ps1
Version    : 1.1.3
Author     : ***REMOVED***
Credits    : Created by Microsoft. Available under Creative Commons Attribution 4.0 International License.

Copyright (c) ***REMOVED*** 2022

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
function Get-MpfEmails {
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateScript( { Test-Path ((Get-Item $_).parent) })][string]$Path = ".\AD.csv",
    [array]$Properties = ("name", "mail"),
    [string]$SearchBase ,
    [string]$Filter = "*"
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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

.NOTES
File Name  : Get-NewIP.ps1
Version    : 1.01
Author     : Aman Dhally - amandhally@gmail.com
Author     : ***REMOVED***

Copyright (c) Aman Dhally 04-04-2012
Copyright (c) ***REMOVED*** 2022


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
	$expireTimeUntil = New-TimeSpan –Start (Get-Date) –End $expireTime
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
<#
.SYNOPSIS
This script will find all orphaned GPOs.

.NOTES
File Name  : Get-OrphanedGPO.ps1
Version    : 1.0.1
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022

.LINK
https://4sysops.com/archives/find-orphaned-active-directory-gpos-in-the-sysvol-share-with-powershell/
#>
    
[CmdletBinding()]
param (
    [string]$ForestName = (Get-ADForest).Name,
    $Domains = (Get-AdForest -Identity $ForestName | Select-Object -ExpandProperty Domains)
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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

.NOTES
File Name  : Get-RecentEvents.ps1
Version    : 1.0.0
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>
param(
  [Parameter(Mandatory = $true)][string]$Time,
  [switch]$Before,
  [switch]$After
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

Test-Admin -Message "You are not running this script with Administrator rights. Some events may be missing." | Out-Null

If ($Before -eq $True) { Get-EventLog System -Before (Get-Date).AddMinutes($Time) }
ElseIf ($After -eq $True) { Get-EventLog System -After (Get-Date).AddMinutes($Time) }
Else { Write-Error "You must specify either -Before or -After" }
}
function Get-SecureBoot {
<#
.SYNOPSIS
This script with gather information about  Secure Boot from the specified marchines.

.DESCRIPTION
This script with gather information about TPM and Secure Boot from the spesified specified. It can request information from just the local computer or from a list of remote computers. It can also export the results as a CSV file.

.PARAMETER ComputerList
This can be used to select a text file with a list of computers to run this command against. Each device must appear on a new line. If unspesified, it will run againt the local machine.

.PARAMETER ReportFile
This can be used to export the results to a CSV file.

.EXAMPLE Get-TPMInfo.ps1
System Information for: XXXX
Secure Boot Status: TRUE


.NOTES
File Name  : Get-SecureBoot.ps1
Version    : 1.0.1
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>
param(
  [string]$ComputerList,
  [string]$ReportFile
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
<# 
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

	.NOTES
	File Name  : Get-StaleAADGuestAccounts.ps1
	Version    : 1.1.0
	Author     : Darren Robinson
    Author     : ***REMOVED***

	Copyright (c) ***REMOVED*** 2021-2022
#>

param (
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]$TenantId , # Tenant ID 
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)][PSCredential]$Credential, # Registered AAD App ID and Secret
	$StaleDays = '90', # Number of days over which an Azure AD Account that hasn't signed in is considered stale'
	$StaleDate = (get-date).AddDays( - "$($StaleDays)").ToString('yyyy-MM-dd'), #Or spesify a spesific date to use as stale
	[switch]$GetLastSignIn
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

<# #Requires -Modules MSAL.PS #>
Import-Module MSAL.PS 

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
<# #Requires -Module AzureADPreview #>
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

$Return = $true
If ($Return) { Return $Results }
}
function Get-TpmInfo {
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

.NOTES
File Name  : Get-TpmInfo.ps1
Version    : 1.0.1
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>
param(
  [string]$ComputerList,
  [string]$ReportFile
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
function Get-Wallpaper {
param(
    [string]$Path = "C:\Windows\Web\Wallpaper\Windows\CurrentBackground.jpg",
    [Parameter(Mandatory = $true)][string]$Uri
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

Test-Admin -Warn -Message = "You do not have Administrator rights to run this script! This may not work correctly.",
Invoke-WebRequest -OutFile $Path -Uri $Uri -ErrorAction SilentlyContinue
}
function Grant-Matching {
<#
.SYNOPSIS
This powershell script will grant NTFS permissions on folders where the username and folder name match.

.DESCRIPTION
This powershell script will grant NTFS permissions on folders where the username and folder name match. It accepts three parameters, AccessRights, Domain, and Folder.
This script required the NTFSSecurity module: https://github.com/raandree/NTFSSecurity
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

.NOTES
File Name  : Grant-Matching.ps1
Version    : 1.0.5
Requires   : NTFSSecurity module | https://github.com/raandree/NTFSSecurity
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
	$Path = (Get-ChildItem | Where-Object { $_.PSISContainer }),
	[string]$AccessRights = 'FullControl',
	[string]$Domain = $Env:USERDOMAIN 
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

Write-Debug "Importing NTFSSecurity module"
<# #Requires -Module NTFSSecurity #>
Import-Module NTFSSecurity

foreach ($UserFolder in $Path) {
	$Account = $Domain + '\' + $UserFolder
	$count++ ; Progress -Index $count -Total $Path.count -Activity "Granting $Account $AccessRights." -Name $UserFolder.FullName
	If ($PSCmdlet.ShouldProcess("$($UserFolder.FullName)", "Add-NTFSAccess")) {
		Add-NTFSAccess -Path $UserFolder.FullName -Account $Account -AccessRights $AccessRights
	}
}
}
function Initialize-OneDrive {
Write-Verbose "Uninstalling OneDrive..."
Start-Process -FilePath C:\Windows\SysWOW64\OneDriveSetup.exe -NoNewWindow -Wait -Args "/uninstall"
Write-Verbose "Installing OneDrive..."
Start-Process -FilePath C:\Windows\SysWOW64\OneDriveSetup.exe -NoNewWindow
}
function Install-GCPW {
<#
.SYNOPSIS
This script downloads Google Credential Provider for Windows from https://tools.google.com/dlpage/gcpw/, then installs and configures it. Windows administrator access is required to use the script.

.DESCRIPTION
This script downloads Google Credential Provider for Windows from https://tools.google.com/dlpage/gcpw/, then installs and configures it. Windows administrator access is required to use the script.

.PARAMETER DomainsAllowedToLogin
Set the following key to the domains you want to allow users to sign in from.

For example: Install-GCPW -DomainsAllowedToLogin "acme1.com,acme2.com"

.NOTES
File Name  : Install-GCPW.ps1
Version    : 1.0.0
Author     : Google & ***REMOVED***

.LINK
https://support.google.com/a/answer/9250996?hl=en

Copyright (c) ***REMOVED*** 2022
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [ValidatePattern("^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+([a-zA-Z0-9-]{2,63})$", ErrorMessage = "{0} is not a valid domain name.")][Parameter(Mandatory = $true)][string]$DomainsAllowedToLogin
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
<#
    .SYNOPSIS
    This script will install the specified version of Microsoft Office on the local machine.

    .DESCRIPTION
    This script will install the specified version of Microsoft Office on the local machine.

    .PARAMETER Version
    Specifes the version of Office to install. If unspecified, Office 2019 64 bit will be installed.

    .EXAMPLE Install-MicrosoftOffice

    .EXAMPLE Install-MicrosoftOffice -Version 2019Visio

    .EXAMPLE Install-MicrosoftOffice -Version 201932

    .NOTES
    File Name  : Install-MicrosoftOffice.ps1
    Version    : 1.2.1
    Author     : ***REMOVED***

    Copyright (c) ***REMOVED*** 2019-2021
    #>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [string]$Version,
    [string]$InstallerPath
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

If ($PSCmdlet.ShouldProcess("localhost ($env:computername)", "Install Office $Version")) {
    If ( $Version -eq "2007" ) {
        Write-Output "Installing Office 2007"
        $run = $InstallerPath + '2007 Pro Plus SP2\setup.exe'
        Start-Process -FilePath $run -NoNewWindow -Wait
    }
    ElseIf ( $Version -eq "2010" ) {
        Write-Output "Installing Office 2010"
        $run = $InstallerPath + '2010 Pro Plus SP2\setup.exe'
        Start-Process -FilePath $run -NoNewWindow -Wait
    }
    ElseIf ( $Version -eq "2013" ) {
        Write-Output "Installing Office 2013"
        $run = $InstallerPath + '2013 Pro Plus SP1 x86 x64\setup.exe'
        Start-Process -FilePath $run -NoNewWindow -Wait
    }
    ElseIf ( $Version -eq "2016" ) {
        Write-Output "Installing Office 2016"
        $run = $InstallerPath + '2016 Pro Plus x86 41353\setup.exe'
        Start-Process -FilePath $run -NoNewWindow -Wait
    }
    ElseIf ( $Version -eq "2019" ) {
        Write-Output "Installing Office 2019"
        $run = $InstallerPath + 'Office Deployment Tool\setup.exe'
        $Arguments = "/configure `"" + $InstallerPath + "Office Deployment Tool\***REMOVED***-2019-ProPlus-Default.xml"
        Start-Process -FilePath $run -ArgumentList $Arguments -NoNewWindow -Wait
    }
    ElseIf ( $Version -eq "201932" ) {
        Write-Output "Installing Office 2019 32 bit"
        $run = $InstallerPath + 'Office Deployment Tool\setup.exe'
        $Arguments = "/configure `"" + $InstallerPath + "Office Deployment Tool\***REMOVED***-2019-ProPlus-32-Default.xml"
        Start-Process -FilePath $run -ArgumentList $Arguments -NoNewWindow -Wait
    }
    ElseIf ( $Version -eq "2019Visio" ) {
        Write-Output "Installing Office & Visio 2019"
        $run = $InstallerPath + 'Office Deployment Tool\setup.exe'
        $Arguments = "/configure `"" + $InstallerPath + "Office Deployment Tool\***REMOVED***-2019-ProPlus-Visio.xml"
        Start-Process -FilePath $run -ArgumentList $Arguments -NoNewWindow -Wait
    }
    ElseIf ( $Version -eq "2019Sandard" ) {
        Write-Output "Installing Office 2019"
        $run = $InstallerPath + 'Office Deployment Tool\setup.exe'
        $Arguments = "/configure `"" + $InstallerPath + "Office Deployment Tool\***REMOVED***-2019-Standard-Default.xml"
        Start-Process -FilePath $run -ArgumentList $Arguments -NoNewWindow -Wait
    }
}
}
function Invoke-TickleMailRecipients {
<#
.SYNOPSIS
Address Lists in Exchange Online do not automatically populate during provisioning and there is no "Update-AddressList" cmdlet.  This script "tickles" mailboxes, mail users and distribution groups so the Address List populates.

.DESCRIPTION
Address Lists in Exchange Online do not automatically populate during provisioning and there is no "Update-AddressList" cmdlet.  This script "tickles" mailboxes, mail users and distribution groups so the Address List populates.

Usage: Additional information on the usage of this script can found at the following blog post:  http://blogs.perficient.com/microsoft/?p=25536

Disclaimer:  This script is provided AS IS without any support. Please test in a lab environment prior to production use.  

.EXTERNALHELP
http://blogs.perficient.com/microsoft/?p=25536

.NOTES
File Name  : Invoke-TickleMailRecipients.ps1
Version    : 1.2.2
Author:      Joseph Palarchio   
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>
param(
  $Mailboxes = (Get-Mailbox -Resultsize Unlimited),
  $MailUsers = (Get-MailUser -Resultsize Unlimited),
  $DistributionGroups = (Get-DistributionGroup -Resultsize Unlimited)
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
function New-RandomCharacters {
param (
  $length = 1,
  $characters = "abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!@#$%^&*()_+-=[]\{}|;:,./<>?"
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
$random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
$private:ofs = ""
return [String]$characters[$random]
}
function New-RandomPassword {
param (
  $length = 14
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
<# 
.LINK
https://geekeefy.wordpress.com/2015/07/16/powershell-fancy-test-connection/
#>

#Function Ping-Host

#Parameter Definition
Param
(
    [Parameter(position = 0)] $Hosts,
    [Parameter] $ToCsv
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
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
function Remove-CachedWallpaper {
<#
.SYNOPSIS
This script removes the caches wallpaper.

.DESCRIPTION
This script removes the caches wallpaper by deleting %appdata%\Microsoft\Windows\Themes\TranscodedWallpaper

.EXAMPLE
.\Remove-CachedWallpaper.ps1

.NOTES
File Name  : Remove-CachedWallpaper.ps1
Version    : 1.0.1
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>

Remove-Item "$Env:appdata\Microsoft\Windows\Themes\TranscodedWallpaper" -ErrorAction SilentlyContinue
Remove-Item "$Env:appdata\Microsoft\Windows\Themes\CachedFiles\*.*" -ErrorAction SilentlyContinue
}
function Remove-MailboxOrphanedSids {
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
    Name: Remove-MailboxOrphaned_SIDs
    Author: CarlosDZRZ
    DateCreated: 04/08/2016
.LINK
	https://technet.microsoft.com/es-es/library/aa998218(v=exchg.160).aspx
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
function Remove-Office365GroupEmail {
param (
  [string]$GroupName,
  [string]$EmailAddress
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
Set-UnifiedGroup -Identity $GroupName -EmailAddresses: @{Remove = $EmailAddress }
}
function Remove-OldFolders {
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
.\Trim-Folder.ps1 -Folder C:\Backups\ -Copies 10

.NOTES
File Name  : Remove-OldFolders.ps1
Version    : 1.0.1
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript( { Test-Path $_ })][string]$Path = (Get-Location),
  [Int]$Keep = 10
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

Get-ChildItem $Path -Directory | Sort-Object CreationTime -Descending | Select-Object -Skip $Keep | ForEach-Object {
  If ($PSCmdlet.ShouldProcess("$_", "Trim-Folder -Keep $Keep")) {
    Remove-Item -Path $_ -Recurse -Force
  }
}
}
function Remove-OldModuleVersions {
#requires -Version 2.0 -Modules PowerShellGet
<#
    Author: Luke Murray (Luke.Geek.NZ)
    Version: 0.1
    Purpose: Basic function to remove old PowerShell modules which are installed
    https://luke.geek.nz/powershell/remove-old-powershell-modules-versions-using-powershell/
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [array]$Modules = (Get-InstalledModule)
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
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
################################################################################################
#
#
#
################################################################################################
param([string]$Path,
    [string]$Server,
    [switch]$Subtree,
    [string]$LogFile,
    [switch]$help)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
#==========================================================================
#==========================================================================
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


#==========================================================================
#==========================================================================
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
.\Clean-VCRedist.ps1

.EXAMPLE
.\Clean-VCRedist.ps1 -Drive D

.NOTES
File Name  : Remove-VsResistInstallFiles.ps1
Version    : 1.1.2
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [string]$Drive = $env:SystemDrive
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
$Files = "install.exe", "install.res.1028.dll", "install.res.1031.dll", "install.res.1033.dll", "install.res.1036.dll", "install.res.1040.dll", "install.res.1041.dll", "install.res.1042.dll", "install.res.2052.dll", "install.res.3082.dll", "vcredist.bmp", "globdata.ini", "install.ini", "eula.1028.txt", "eula.1031.txt", "eula.1033.txt", "eula.1036.txt", "eula.1040.txt", "eula.1041.txt", "eula.1042.txt", "eula.2052.txt", "eula.3082.txt", "VC_RED.MSI", "VC_RED.cab"
Foreach ($File in $Files) { Remove-Item $Drive\$File -ErrorAction SilentlyContinue }
}
function Repair-Attributes {
[CmdletBinding(SupportsShouldProcess = $true)]
param ()
Write-Verbose "Removing legacy attributes for users"
Get-ADUser -Filter *  | Sort-Object  SamAccountName, UserPrincipalName | Set-ADUser -Clear msExchMailboxGuid, msexchhomeservername, legacyexchangedn, mailNickname, msexchmailboxsecuritydescriptor, msexchpoliciesincluded, msexchrecipientdisplaytype, msexchrecipienttypedetails, msexchumdtmfmap, msexchuseraccountcontrol, msexchversion, targetAddress
Write-Verbose "Remove legacy attributes for non-Office 365 groups"
Get-ADGroup -Filter * | Where-Object Name -notlike "Group_*" | Sort-Object  SamAccountName, UserPrincipalName | Set-ADGroup -Clear msExchMailboxGuid, msexchhomeservername, legacyexchangedn, mailNickname, msexchmailboxsecuritydescriptor, msexchpoliciesincluded, msexchrecipientdisplaytype, msexchrecipienttypedetails, msexchumdtmfmap, msexchuseraccountcontrol, msexchversion, targetAddress

Write-Verbose "Remove legacy proxy addresses for users"
Get-ADUser -Filter * -Properties ProxyAddresses | ForEach-Object { $Remove = $_.proxyaddresses | Where-Object { $_ -like "X500*" -or $_ -like "X400*" -or $_ -like "*@***REMOVED***CF.mail.onmicrosoft.com" }; ForEach ($proxyAddress in $Remove) { Write-Output "Removing $ProxyAddress"; Set-ADUser -Identity $_.Name -Remove @{'ProxyAddresses' = $ProxyAddress } } }
Write-Verbose "Remove legacy proxy addresses for non-Office 365 groups"
Get-ADGroup -Filter * -Properties ProxyAddresses | Where-Object Name -notlike "Group_*" | ForEach-Object { $Remove = $_.proxyaddresses | Where-Object { $_ -like "X500*" -or $_ -like "X400*" -or $_ -like "*@***REMOVED***CF.mail.onmicrosoft.com" }; ForEach ($proxyAddress in $Remove) { Write-Output "Removing $ProxyAddress"; Set-ADGroup -Identity $_.Name -Remove @{'ProxyAddresses' = $ProxyAddress } } }

Write-Verbose "Remove proxy addresses if only one exists for users"
Get-ADUser -Filter * -Properties ProxyAddresses | Where-Object { $_.ProxyAddresses.Count -eq 1 } | Set-ADUser -Clear ProxyAddresses
Write-Verbose "Remove proxy addresses if only one exists for non-Office 365 groups"
Get-AdGroup -Filter * -Properties ProxyAddresses | Where-Object Name -notlike "Group_*" | Where-Object { $_.ProxyAddresses.Count -eq 1 } | Set-ADGroup -Clear ProxyAddresses

Write-Verbose "Clear mailNickname if mail attribute empty for users"
Get-ADUser -Filter * -Properties mail, mailNickname | Where-Object mail -eq $null | Where-Object mailNickname -ne $null | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Clear mailNickname }
Write-Verbose "Clear mailNickname if mail attribute empty for non-Office 365 groups"
Get-ADGroup -Filter * -Properties mail, mailNickname | Where-Object mail -eq $null | Where-Object mailNickname -ne $null | Where-Object Name -notlike "Group_*" | ForEach-Object { Set-ADGroup -Identity $_.SamAccountName -Clear mailNickname }

Write-Verbose "Set mailNickname to SamAccountName for users"
Get-ADUser -Filter * -Properties mail, mailNickname | Where-Object mail -ne $null | Where-Object { $_.mailNickname -ne $_.SamAccountName } | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Replace @{mailNickname = $_.SamAccountName } }
Write-Verbose "Set mailNickname to SamAccountName for non-Office 365 groups"
Get-ADGroup -Filter * -Properties mail, mailNickname | Where-Object mail -ne $null | Where-Object { $_.mailNickname -ne $_.SamAccountName } | Where-Object Name -notlike "Group_*" | ForEach-Object { Set-ADGroup -Identity $_.SamAccountName -Replace @{mailNickname = $_.SamAccountName } }

Write-Verbose "Set title to mail attribute for general delivery mailboxes. Used to easily show address in Sharepoint"
Get-ADUser -Filter * -SearchBase 'OU=Mailboxes,OU=Mail Objects,OU=_***REMOVED***,DC=***REMOVED***,DC=local' -Properties mail | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Title $_.mail }
  
Write-Verbose "Clear telephoneNumber attribute if mail atrribute is empty"
Get-ADUser -Filter * -Properties ipPhone, mail, telephoneNumber | Where-Object mail -eq $null | Where-Object telephoneNumber -ne $null | Set-ADUser -Clear telephoneNumber
Write-Verbose "Set telephoneNumber attribute to main line if ipPhone attribute is empty"
Get-ADUser -Filter * -Properties ipPhone, mail, telephoneNumber | Where-Object mail -ne $null | Where-Object ipPhone -eq $null | ForEach-Object { Set-ADUser -Identity $_.SamAccountName -Replace @{telephoneNumber = "+1 5197447447" } }
Write-Verbose "Set telephoneNumber attribute to main line with extension if ipPhone attribute is present"
Get-ADUser -Filter * -Properties ipPhone, mail, telephoneNumber | Where-Object mail -ne $null | Where-Object ipPhone -ne $null | ForEach-Object { $telephoneNumber = "+1 5197447447 x" + $_.ipPhone.Substring(0, [System.Math]::Min(3, $_.ipPhone.Length)) ; Set-ADUser -Identity $_.SamAccountName -Replace @{telephoneNumber = $telephoneNumber } }
}
function Repair-VmPermissions {
<# 
.LINK
https://foxdeploy.com/2016/04/05/fix-hyper-v-account-does-not-have-permission-error/
 #>
#Import the NTFSSecurity Module, if not available, prompt to download it
If ((Get-Module).Name -notcontains 'NTFSSecurity') {
    Write-Warning "This script depends on the NTFSSecurity Module, by MSFT"
    if ($PSVersionTable.PSVersion.Major -ge 4) {
        Write-Output "This script can attempt to download this module for you..."
        $DownloadMod = Read-host "Continue (y/n)?"
 
        if ($DownloadMod.ToUpper() -like "Y*") {
            find-module NTFSSecurity | Install-Module
        }
        else {
            #User responded No, end
            Write-Warning "Please download the NTFSSecurity module and continue"
            break
        }
 
    }
    else {
        #Not running PowerShell v4 or higher
        Write-Warning "Please download the NTFSSecurity module and continue"
        break
    }
}
else {
    #Import the module, as it exists
    Import-Module NTFSSecurity
 
}
 
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
[CmdletBinding(SupportsShouldProcess = $true)]
param ()
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\CSC\Parameters\ -Name FormatDatabase -Value 1 -Type DWord
}
function Reset-InviteRedepmtion {
<#
 https://docs.microsoft.com/en-us/azure/active-directory/external-identities/reset-redemption-status
 #>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [array]$Email,
    [array]$UPN = ($Email.replace("@", "_") + "#EXT#@" + ((Get-AzureADTenantDetail).VerifiedDomains | Where-Object Initial -eq $true).Name),
    [Uri]$RecirectURL = "http://myapps.microsoft.com",
    [boolean]$SkipSendingInvitation,
    [boolean]$SkipResettingRedemtion,
    [switch]$All
    
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
$SkipSendingInvitation = -not $SkipSendingInvitation
$SkipResettingRedemtion = -not $SkipResettingRedemtion


if ($All) {
    $UPN = (Get-AzureADUser -Filter "UserType eq 'Guest'").UserPrincipalName
    Write-Warning "This will reset invites for all guest users. Are you sure?"
    Wait-ForKey "y"
    
}
[System.Collections.ArrayList]$Results = @()
$UPN | ForEach-Object {
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
<#
.SYNOPSIS
Reset-WindowsUpdate.ps1 - Resets the Windows Update components

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

Change Log
V1.00, 05/21/2015 - Initial version
V1.10, 09/22/2016 - Fixed bug with call to sc.exe
V1.20, 11/13/2017 - Fixed environment variables
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
Author: Patrick Lambert - http://dendory.net
#>
Param([Parameter(Mandatory = $true)][string]$InputFile, [string]$OutputFile, [int32]$Width, [int32]$Height, [int32]$Scale, [Switch]$Display)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
<#
.SYNOPSIS
This script will install the neccesary applications and services on a given machine.

.DESCRIPTION
Will prompt you for username and password, and will encrypt (to hash) the password to a txt file. This will only be the password. And you must dump the file to the location where you are going to get it from in the other script. Based on this post: http://www.sameie.com/2017/10/05/create-hashed-password-file-for-powershell-use/

.LINK
http://www.sameie.com/2017/10/05/create-hashed-password-file-for-powershell-use/

.PARAMETER File
If specified, Avast will be installed.

.EXAMPLE Store-Password.ps1

.EXAMPLE Store-Password.ps1 -File .\Password.txt

.NOTES
File Name  : Save-Password.ps1
Version    : 1.0.1
Author     : Vincent Christiansen - vincent@sameie.com
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>
param(
  [string]$File = ".\Password.txt",
  [string]$User
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
$credential = Get-Credential $User
$credential.Password | ConvertFrom-SecureString | Set-Content $File
}
function Set-AdPhoto {
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
Get-O365Photos

.NOTES
File Name  : Set-AdPhoto.ps1
Version    : 1.1.0
Author     : Rajeev Buggaveeti 
Author     : ***REMOVED***

by Rajeev Buggaveeti
Copyright (c) ***REMOVED*** 2022

.LINK
https://blogs.technet.microsoft.com/rajbugga/2017/05/16/picture-sync-from-office-365-to-ad-powershell-way/
#>
[CmdletBinding(SupportsShouldProcess = $true)]
Param(  
    [ValidateScript( { Test-Path $_ })][string]$Path = (Get-Location),
    [array]$Users = (Get-ChildItem $Path -File)
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
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
function Set-Owner {
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

.NOTES
File Name  : Set-Owner.ps1
Version    : 1.1.0
Author     : Boe Prox
Author     : ***REMOVED***

by Boe Prox
Copyright (c) ***REMOVED*** 2022

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
function Set-Path {
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true)][ValidateScript({ Test-Path -Path $_ -PathType Container })][string]$Path,
    [switch]$Machine,
    [switch]$Force,
    [int]$MaxLength = 1024
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
function Set-WindowsAccountAvatar {
<# 

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
function Start-KioskApp {
[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [ValidateScript({ Test-Path $_ -PathType Leaf })][string]$Path = ${env:ProgramFiles(x86)} + "\Microsoft\Edge\Application\msedge.exe", #"\Google\Chrome\Application\chrome.exe",
  [string]$Url,
  [string]$Arguments = "--kiosk " + $Url
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
while ($true) {
  If (-Not (Get-Process | Select-Object Path | Where-Object Path -eq $Path)) { Start-Process -FilePath $Path -ArgumentList $Arguments }
  Start-Sleep -Seconds 5
}
}
function Start-PaperCutClient {
<#
.SYNOPSIS
This script will run the PaperCut client.

.DESCRIPTION
This script will run the PaperCut client. It will first check the network location and fall back to the local cache is that fails.

.PARAMETER SearchLocations
Specifies the folders to search for the client in.

.EXAMPLE .\Start-PaperCutClient

.EXAMPLE .\Start-PaperCutClient.ps1 -SearchLocations "\\print\PCClient\win","C:\Cache"

.NOTES
File Name  : Start-PaperCutClient.ps1
Version    : 1.0.0
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>
param (
  [string[]]$SearchLocations = @("\\print\PCClient\win", "C:\Cache")
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
function Stop-ForKey {
param (
  $Key
)
$Response = Read-Host "Press $Key to abort, any other key to continue."
If ($Response -eq $Key) { Break }
}
function Test-Admin {
<#
.SYNOPSIS
This will test is the we are running as an addministrator.

.DESCRIPTION
This will test is the we are running as an addministrator. If will return True or False.

.EXAMPLE
Test-Admin
False

.NOTES
File Name  : Test-Admin.ps1
Version    : 1.0.0
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022
#>

param (
  [string]$Message = "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!",
  [switch]$Warn,
  [switch]$Throw
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
If (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Return $True }
else {
  If ($Warn) { Write-Warning $Message }
  If ($Throw) { Throw $Message }
  Return $False
}
}
function Test-Scripts {
Param(
    [string]$foo,
    [string]$bar = "bar",
    [string]$baz = "bazziest",
    [string]$Test = { (If ($Testing) { $Testing } else { "failed test" } ) }
)
$MyInvocation
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

Write-Output "params"
write-output "foo: $foo"
write-output "bar: $bar"
write-output "baz: $baz"
write-output "test: $test"
}
function Test-VoipMs {
<#
.SYNOPSIS
This script will test the VoIP.ms servers to find one with the lowest latency.

.DESCRIPTION
This script will test the VoIP.ms servers to find one with the lowest latency. If you spesify your credentials, it will use the API to get the most current list of servers. Otherwise, it will fallback to the static list you see below.

.PARAMETER ServerList
The fallback server list used when API credentials are not spesified. You can also pass in a custom list of servers.

.NOTES
Usage: Copy and paste the following code into a powershell window
To run it from a command prompt, save this file with extension ps1. Then run Powershell.exe -file "pathtothisscript.ps1"

File Name  : Test-VoipMs.ps1
Version    : 1.2.0
Author     : ***REMOVED***

Copyright (c) ***REMOVED*** 2022

.LINK
https://wiki.voip.ms/article/Choosing_Server
#>


param(
  <#   [string]$Username = "kcf.it@***REMOVED***",
  [string]$Password = "Open123!", #>
  [string]$Country = "*",
  [switch]$Fax,
  [ValidateRange(0, [int]::MaxValue)][int]$Retries = 5,
  [array]$ServerList = "localhost"
  #[array]$ServerList = @("amsterdam.voip.ms", "atlanta.voip.ms", "atlanta2.voip.ms", "chicago.voip.ms", "chicago2.voip.ms", "chicago3.voip.ms", "chicago4.voip.ms", "dallas.voip.ms", "dallas2.voip.ms", "denver.voip.ms", "denver2.voip.ms", "houston.voip.ms", "houston2.voip.ms", "london.voip.ms", "losangeles.voip.ms", "losangeles2.voip.ms", "melbourne.voip.ms", "montreal.voip.ms", "montreal2.voip.ms", "montreal3.voip.ms", "montreal4.voip.ms", "montreal5.voip.ms", "montreal6.voip.ms", "montreal7.voip.ms", "montreal8.voip.ms", "newyork.voip.ms", "newyork2.voip.ms", "newyork3.voip.ms", "newyork4.voip.ms", "newyork5.voip.ms", "newyork6.voip.ms", "newyork7.voip.ms", "newyork8.voip.ms", "paris.voip.ms", "sanjose.voip.ms", "sanjose2.voip.ms", "seattle.voip.ms", "seattle2.voip.ms", "seattle3.voip.ms", "tampa.voip.ms", "tampa2.voip.ms", "toronto.voip.ms", "toronto2.voip.ms", "toronto3.voip.ms", "toronto4.voip.ms", "toronto5.voip.ms", "toronto6.voip.ms", "toronto7.voip.ms", "toronto8.voip.ms", "vancouver.voip.ms", "vancouver2.voip.ms", "washington.voip.ms", "washington2.voip.ms") #Get the list of servers into an array
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
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
  #$ApiServers = (Invoke-RestMethod -Uri ("https://voip.ms/api/v1/rest.php?api_username=" + $Username + "&api_password=" + $Password + "&method=getServersInfo")).servers
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

#Do the following code for each server in our array
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
<#
.SYNOPSIS
    This script will preform a roll over of Azure SSO Kerberos key.
    Run this script on the server running Azure AD Connect.
.DESCRIPTION
    https://docs.microsoft.com/en-us/azure/active-directory/hybrid/how-to-connect-sso-faq#how-can-i-roll-over-the-kerberos-decryption-key-of-the-azureadssoacc-computer-account
.NOTES
    File Name: AzureAD_SSOKeyRollover.ps1
	Version: 1.0
	Version History:
		* 1.0 - initial release 
	Last Update: 15/04/2019
	Author   : Wybe Smits, http://www.wybesmits.nl
    !! Provided as-is with no warranties, use at your own risk !!
#>
Import-Module $Env:ProgramFiles'\Microsoft Azure Active Directory Connect\AzureADSSO.psd1d'
New-AzureADSSOAuthenticationContext #Office 365 Global Admin
Update-AzureADSSOForest -OnPremCredentials (Get-Credential -Message "Enter Domain Admin credentials" -UserName ($env:USERDOMAIN + "\" + $env:USERNAME))
}
function Update-PKI {
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    $Path = "./",
    $AccessToken = "",
    $OwnerName = "",
    $RepositoryName = "",
    $BranchName = "",
    [switch]$Force
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
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
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

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
param(
    [string]$Key = "y",
    [string]$Message = "Press $Key to continue, any other key to abort."
)
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation

$Response = Read-Host $Message
If ($Response -ne $Key) { Break }
}


# SIG # Begin signature block
# MIISjwYJKoZIhvcNAQcCoIISgDCCEnwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMIakBOd+tPmr0TDYqhGiIoOm
# a1Oggg7pMIIG4DCCBMigAwIBAgITYwAAAAKzQqT5ohdmtAAAAAAAAjANBgkqhkiG
# 9w0BAQsFADAiMSAwHgYDVQQDExdLb2lub25pYSBSb290IEF1dGhvcml0eTAeFw0x
# ODA0MDkxNzE4MjRaFw0yODA0MDkxNzI4MjRaMFgxFTATBgoJkiaJk/IsZAEZFgVs
# b2NhbDEYMBYGCgmSJomT8ixkARkWCEtvaW5vbmlhMSUwIwYDVQQDExxLb2lub25p
# YSBJc3N1aW5nIEF1dGhvcml0eSAxMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAwQZJAkaKEsFXEV/6i/XPyrmFiZ4uFyigwSzUBvBJ+FiXk0dX3zr5hX68
# FoxSTSJGwfWZNL1rzfMkw+ehtd1kqgCYRwJ2TZiQevSVOx2Gj5OrsaEHw1mKcbGP
# j2dboAG95ZsidwqyXqBwHDbxJW3xRSSh5jGpZpEXl5gO6IvX2nT7ATcJ8Vq+s0af
# ww/QHVPAELDXDM/mYZftoGLZz717hfDL2YwVq6sADEUSf8+qiFDgGody3JsYz2wz
# O1YxqGhFfJT7uV4wPlAyXRFBPdHFMKLkDg3l++qb1fw8zZQnvLQQ2dRK9+Nuh7Q7
# iOCVX2/ESkn1VWySq4qmRCq2IxCTSC9R/JTfHHLzZ+wTt79i4ylDyPQDIfBMTwOh
# vVzxCvpvBirqfn0JaUcDxzcAaEVr41WNFQv09O1XUYu9qw1j59ogEUc7i0IPMFbq
# reZ43bIYbEQiHWyzObjxQ6HUBxyGbtqmg5gm5X8p42egtUJLPl1EW0L05VDMKgBz
# WxVUeitCsjmuSPi78b8G2LDwGEM3EEJWI29BQov0TPBIlnddhPUxNkrps7S8ZmdS
# /FCpWUnYWPXpGVtuyKFouynpTEd25iO9vOuOH+EuXRfGDR+JGQLWFuBsaNdKpOBX
# QlRzwCwpxhATToUZ2RLH2L+t8owK/l/Mmq0qCE4hJv8utRCTsHUCAwEAAaOCAdcw
# ggHTMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTAVWX0ludkYgskUG6CXca7
# YIL5iDCBqAYDVR0gBIGgMIGdMIGaBg4rBgEEAYOGSQEBAQUBATCBhzBgBggrBgEF
# BQcCAjBUHlIAUABvAGwAaQBjAHkAIABTAHQAYQB0AGUAbQBlAG4AdAA6ACAAaAB0
# AHQAcAA6AC8ALwBwAGsAaQAuAGsAYwBmAC4AbwByAGcALwBwAGsAaQAvMCMGCCsG
# AQUFBwIBFhdodHRwOi8vcGtpLmtjZi5vcmcvcGtpLzAZBgkrBgEEAYI3FAIEDB4K
# AFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSME
# GDAWgBQ3VizjAphUZ/xTllcA4YGtLMZwvjBHBgNVHR8EQDA+MDygOqA4hjZodHRw
# Oi8vcGtpLmtjZi5vcmcvcGtpL0tvaW5vbmlhJTIwUm9vdCUyMEF1dGhvcml0eS5j
# cmwwUgYIKwYBBQUHAQEERjBEMEIGCCsGAQUFBzAChjZodHRwOi8vcGtpLmtjZi5v
# cmcvcGtpL0tvaW5vbmlhJTIwUm9vdCUyMEF1dGhvcml0eS5jcnQwDQYJKoZIhvcN
# AQELBQADggIBACwQT8YLvbK8yk1w548coVbviyabJuLR3HFflJbzNObXmeHPYC+m
# 2uF/LEvqA9azZ9ggKn61QO45BXOtu6Heif7Yn9agX0PFmQhxRlghRw9g57RHPhfN
# BdUamvcPmSGt1m+/lVxPfa9BeemqTOno7EjzhN0fN5o9oMtlnaPYurz+sg4qPgNq
# v0R1Ns5othE0rFqwfEQKwjvZZMj9gk8QiKz30897s+GU/cumShCNLRR/G3e7kCjw
# gyCmneS/T8DhMjYN4qQfVKUb5+X1pHQxCwSIhRma05GWrF4ZH4W0kbEkmlTwhbYO
# CltTSVFXlx+X/LPwaGC05TkkIjuoLubKSKzZXL/AGsCdFJDLMO3u+3UdfNtOV7/6
# UQle936nyS0eOvD0XgCtkGdU3/miVOpTPH4tE1TIMu9QYDySThWXEz9rkeP6vk4+
# evaYRa8Kfl8b5YleUyrDPeOAwRTBVcBLGL2RtUSjpz+D+PK/wbV8VrzEWmydeO0w
# eMZOOMpoEUJBCPO0skRFB6nwx7xfDAwWVQsFJ4d5DHZQNsAsXYbbOHZtdf+n+seX
# 0xzGHYs0cMQAHf1V+s2Ja/2AnO03tJ/uMnRqqFJG1HqG0R/T5YV7h7X1/LVbebwO
# LZZi0w82sFtyETySRo8AGQEKF7WLY3WJyG6RdVgLxvcIUhi2Dc5x6IjtMIIIATCC
# BemgAwIBAgITIgAADHxZeZBscIM3YQAAAAAMfDANBgkqhkiG9w0BAQsFADBYMRUw
# EwYKCZImiZPyLGQBGRYFbG9jYWwxGDAWBgoJkiaJk/IsZAEZFghLb2lub25pYTEl
# MCMGA1UEAxMcS29pbm9uaWEgSXNzdWluZyBBdXRob3JpdHkgMTAeFw0yMTExMTUx
# NjM4NDdaFw0yMjExMTUxNjM4NDdaMIHFMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwx
# GDAWBgoJkiaJk/IsZAEZFghLb2lub25pYTESMBAGA1UECwwJX0tvaW5vbmlhMQ4w
# DAYDVQQLEwVVc2VyczEVMBMGA1UECxMMQmxvb21pbmdkYWxlMQ8wDQYDVQQLEwZD
# aHVyY2gxDjAMBgNVBAsTBVN0YWZmMRMwEQYDVQQDEwpKYXNvbiBDb29rMSEwHwYJ
# KoZIhvcNAQkBFhJKYXNvbi5Db29rQGtjZi5vcmcwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQDwN91V292vy9GcOuBoPPYpHSeEhqOyWlmxWUdGFRDPv3ST
# FextzADS19BiV/werFJyS32viu1le9hFwORP/+K8ABGAoso3caaq69vAo5Erqd7x
# +gcNM9B7ItgQLIfCGHiN54bBNwWT1BJr/I56rTG92jXCYTHdN8RI+GAxdb3+xkuu
# drCyuLUExIkmzY5q9MiHX6rlNsdkDP6f6aMxVW+U0sOhXR+fxCMkgXFqCTvlhjAP
# z2mxYqEBmJb9nwdSov5n3lu6YEuCo1ddsATeHPDhYdgPoKIKFq9NauZGB/m7vCSd
# E7qEGNdbENHEnflDKwVSeYBL45acenlAU5Rau/dsDQ6s1PsG5q4U0jYXwW0hV45B
# h123Kg6MAb3/CiudVxD9sNBvDJJL1k15RN3sOB0xdQYO+zuPy972eBPFobvtANTD
# dxxCOnKPuwXRiRU6xaoU5AVgpgp1snBhyyBRhMjY+jLdqtnIlezgoJ7oBH5lmm4W
# N/jHZCJIjyD0FQnIT2nswk5m5Mt8sV07ZvNAhQ83Cv3UpuJ2CoWI7DA+9NA15P4V
# QvzFluEWbfEP7B7UTKmBy9iZKBjZkQ/K5Q5npgHLbEfyYjZUhTZF+u9wu1ZE2N3P
# OBiIFNLQJzCs1wQdNW9j3Lh927q4/UYzmHSW/TXLTLpO0sAlYgYgMZ7V9XaU0QID
# AQABo4ICVDCCAlAwOwYJKwYBBAGCNxUHBC4wLAYkKwYBBAGCNxUIgZbgd/3wcIWZ
# lTeEqo0lg7DnY3jI7VKCoqVGAgFkAgEhMD8GA1UdJQQ4MDYGCCsGAQUFBwMEBgor
# BgEEAYI3CgMEBggrBgEFBQcDAwYIKwYBBQUHAwIGCisGAQQBgjdDAQEwCwYDVR0P
# BAQDAgSwME8GCSsGAQQBgjcVCgRCMEAwCgYIKwYBBQUHAwQwDAYKKwYBBAGCNwoD
# BDAKBggrBgEFBQcDAzAKBggrBgEFBQcDAjAMBgorBgEEAYI3QwEBMEQGCSqGSIb3
# DQEJDwQ3MDUwDgYIKoZIhvcNAwICAgCAMA4GCCqGSIb3DQMEAgIAgDAHBgUrDgMC
# BzAKBggqhkiG9w0DBzAdBgNVHQ4EFgQU+GvN2GPT7Nzos4/UvTXojcu3GpswHwYD
# VR0jBBgwFoAUwFVl9JbnZGILJFBugl3Gu2CC+YgwTgYDVR0fBEcwRTBDoEGgP4Y9
# aHR0cDovL3BraS5rY2Yub3JnL3BraS9Lb2lub25pYSUyMElzc3VpbmclMjBBdXRo
# b3JpdHklMjAxLmNybDBZBggrBgEFBQcBAQRNMEswSQYIKwYBBQUHMAKGPWh0dHA6
# Ly9wa2kua2NmLm9yZy9wa2kvS29pbm9uaWElMjBJc3N1aW5nJTIwQXV0aG9yaXR5
# JTIwMS5jcnQwQQYDVR0RBDowOKAiBgorBgEEAYI3FAIDoBQMEmphc29uLmNvb2tA
# a2NmLm9yZ4ESSmFzb24uQ29va0BrY2Yub3JnMA0GCSqGSIb3DQEBCwUAA4ICAQCO
# x749r4EodqxVpIwBz+LxP//goz0n42hUQsD+BGQ5ohsMA4GczB+/zmrhq6xnF5bE
# qOZETG69WIsMj85PENJKpcA0xIM57F6zuBRaicZHL1WC003XodecT+/QnmUaJjzl
# 5A35fogYvl5RaluYZ89OGVUMx3bkBOkt3u0zfsW+bnXikJW9tUOmepeongzU7/OC
# L9msflFZDFxSLkumx8W/sfWNKUNeByoaWwUCp9noGW0gBAEiM/I1xWRkPMSNcbnI
# 8bk/6kAWzPe012uc/rXMDq/xJKQeD+OiV9nRMnKBGNRZELP8QSR4bAqFkhaY3M1y
# 9xgerRDCkOpXTAy1Ht0Oz0xI/Tyh1jNwH93Xynneu84FFjKgtUvAXXo3MWf7nd7H
# ZIcTkf0biYCJI3Qij4kKbJa8I4NJoICa9nzF9ef1AAsen3iuXSlau+YskqDKJJmM
# mQINbNllX9GS2N6kH0pnyUgSNXfZmb9d+5pZApavZtKoRdZr2Z/xhKsWNoLnDW8Q
# JDXTKkQODY4gBxrH2T9qNfHZ5SuF6zxekluWD0dhfqyljaWOIjIqXRHbqGMcrr3S
# MqLmcnh72nO5kAIdDumQ0tQGq1sWiBn9fFRBKQosIavTWkZVyVDRDDq9rIb9GKMT
# 1w3EwXuPdqq+APlFZ06PLOFLVAwWoaqiMruKB9owizGCAxAwggMMAgEBMG8wWDEV
# MBMGCgmSJomT8ixkARkWBWxvY2FsMRgwFgYKCZImiZPyLGQBGRYIS29pbm9uaWEx
# JTAjBgNVBAMTHEtvaW5vbmlhIElzc3VpbmcgQXV0aG9yaXR5IDECEyIAAAx8WXmQ
# bHCDN2EAAAAADHwwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKEC
# gAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwG
# CisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFAiUzPuD7UB91dH7iTSjh9j6fRqm
# MA0GCSqGSIb3DQEBAQUABIICACun8Nc4GfifYF5gAU0vwW1noWcGz9pankroVJx6
# aw+17o+9g4lq6OPP0LG0n/gv9YFvJAoU+Rxx18xw+CSGew/BA2DFQvyLEIDEujDs
# heS+G8w9DwmKqqbfnLsW//heD0nD3j3avj53TxmWfNuE/OAC5H/cKO1jRU2AAbW1
# 6sEixuPqVk9L1GEjSrFxNhums/C1TZP2o81KjyajccPaiN12HNYYKYz2qf/gXMt6
# JwbtosSCXZiiHNaEf8dHGFHAh9b0SHI71umblVJORdvJyF8x8+LR2Csg5nmNTCCK
# 5PU8Lx2qQ3O7MTvWyWlrr0k/U5Ky3USNqIhigrs+pc5Ipk/RJcgI8Wx3ftcMho+B
# fP8vNbkCe5QDS4guWEXLt6i/uiQbm9S+Z6BkG8fxkIkHCO9zxaSA7EjdBbRdUOyB
# qP2Q+RQgOLMLVzBX9x7osz4P99XT7lyxMh51oKFVQ3BO5f+6G1sgjknO2EfgP3Mp
# XjRiQbYVlxQrusWictPYJMkW4NwBHp6zQ8pjGIv7qUxyNPRFB9ig7v2TTXNLuHEE
# 9lziPZlsIoWtwDteMpdQmHTdFkpJ6TgpPH9d5ZbI5AgESfxxlTZ8zQ3nUDd7+chP
# HVUjkr6sjWJJcGTO/9nmXY4UQVc1QQpDMgHJfuv41RJ1fbeZIt3h4rIlzx1P4M5Z
# Iqeq
# SIG # End signature block
