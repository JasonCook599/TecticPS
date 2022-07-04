<#PSScriptInfo

.VERSION 2.0.1

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
