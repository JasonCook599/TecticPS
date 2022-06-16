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