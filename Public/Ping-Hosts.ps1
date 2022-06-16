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