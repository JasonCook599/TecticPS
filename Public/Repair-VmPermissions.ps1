<#PSScriptInfo

.VERSION 1.0.1

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


.PRIVATEDATA

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
