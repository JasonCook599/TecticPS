<#PSScriptInfo

.VERSION 1.0.3

.GUID dd50132f-8bc5-4825-918d-9fd0afd3f36b

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2024

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

# . (I:\Applications\Powershell\TecticPS\Private\LoadDefaults.ps1 -Invocation $MyInvocation) -Invocation $MyInvocation

Write-Output "params"
write-output "foo: $foo"
write-output "bar: $bar"
write-output "baz: $baz"
write-output "test: $test"
