<#PSScriptInfo

.VERSION 1.0.6

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
