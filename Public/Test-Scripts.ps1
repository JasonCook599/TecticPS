Param(
    [string]$foo,
    [string]$bar = "bar",
    [string]$baz = "bazziest",
    [string]$Test = { (If ($Testing) { $Testing } else { "failed test" } ) }
)
$MyInvocation
. (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation
# . (I:\Applications\Powershell\***REMOVED***It\Private\LoadDefaults.ps1 -Invocation $MyInvocation) -Invocation $MyInvocation

Write-Output "params"
write-output "foo: $foo"
write-output "bar: $bar"
write-output "baz: $baz"
write-output "test: $test"