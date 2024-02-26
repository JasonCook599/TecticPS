<#PSScriptInfo

.VERSION 1.0.3

.GUID 98d059e8-6686-4643-bf07-2a2fd9729ca6

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) TectTectic

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
Returns any pending file renames present in the PendingFileRenameOperations registry key.

.PARAMETER IgnoreDeletes
Ignore any delete options and only return file neames.

.LINK
https://stackoverflow.com/questions/47867949/how-can-i-check-for-a-pending-reboot/68627581#68627581

.LINK
https://forensicatorj.wordpress.com/2014/06/25/interpreting-the-pendingfilerenameoperations-registry-key-for-forensics/

.LINK
https://learn.microsoft.com/en-us/sysinternals/downloads/pendmoves#movefile-usage

#>

[OutputType('bool')]
[CmdletBinding()]
param(
    [switch]$IgnoreDeletes
)
$Operations = (Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\').GetValue('PendingFileRenameOperations')
if ($null -eq $Operations) {
    return $false
}
else {
    $OperationsCount = $Operations.Length / 2
    $Renames = [System.Collections.Generic.Dictionary[string, string]]::new($OperationsCount)
    for ($i = 0; $i -ne $OperationsCount; $i++) {
        $OperationSource = $Operations[$i * 2]
        $operationDestination = $Operations[$i * 2 + 1]
        if ($IgnoreDeletes -and $operationDestination.Length -eq 0) {
            Write-Verbose "Ignoring pending file delete '$OperationSource'"
        }
        else {
            Write-Host "Found a true pending file rename (as opposed to delete). Source '$OperationSource'; Dest '$operationDestination'"
            $Renames[$Operationsource] = $operationDestination
        }
    }
    return $Renames
}
