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
$MyInvocation

# . (I:\Applications\Powershell\***REMOVED***It\Private\LoadDefaults.ps1 -Invocation $MyInvocation) -Invocation $MyInvocation

Write-Output "params"
write-output "foo: $foo"
write-output "bar: $bar"
write-output "baz: $baz"
write-output "test: $test"
