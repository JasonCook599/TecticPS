<#PSScriptInfo
.VERSION 1.2.2
.GUID 17fff57c-cce9-4977-a26d-aeded706a85f

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.SYNOPSIS
This script will test the VoIP.ms servers to find one with the lowest latency.

.DESCRIPTION
This script will test the VoIP.ms servers to find one with the lowest latency. If you spesify your credentials, it will use the API to get the most current list of servers. Otherwise, it will fallback to the static list you see below.

.PARAMETER ServerList
The fallback server list used when API credentials are not spesified. You can also pass in a custom list of servers.

.LINK
https://wiki.voip.ms/article/Choosing_Server
#>

<# TODO use credential/secure string for $username and $password #>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "Password")]
param(
  [string]$Username,
  [string]$Password,
  [string]$Country = "*",
  [switch]$Fax,
  [ValidateRange(0, [int]::MaxValue)][int]$Retries = 5,
  [array]$ServerList = @("amsterdam.voip.ms", "atlanta.voip.ms", "atlanta2.voip.ms", "chicago.voip.ms", "chicago2.voip.ms", "chicago3.voip.ms", "chicago4.voip.ms", "dallas.voip.ms", "dallas2.voip.ms", "denver.voip.ms", "denver2.voip.ms", "houston.voip.ms", "houston2.voip.ms", "london.voip.ms", "losangeles.voip.ms", "losangeles2.voip.ms", "melbourne.voip.ms", "montreal.voip.ms", "montreal2.voip.ms", "montreal3.voip.ms", "montreal4.voip.ms", "montreal5.voip.ms", "montreal6.voip.ms", "montreal7.voip.ms", "montreal8.voip.ms", "newyork.voip.ms", "newyork2.voip.ms", "newyork3.voip.ms", "newyork4.voip.ms", "newyork5.voip.ms", "newyork6.voip.ms", "newyork7.voip.ms", "newyork8.voip.ms", "paris.voip.ms", "sanjose.voip.ms", "sanjose2.voip.ms", "seattle.voip.ms", "seattle2.voip.ms", "seattle3.voip.ms", "tampa.voip.ms", "tampa2.voip.ms", "toronto.voip.ms", "toronto2.voip.ms", "toronto3.voip.ms", "toronto4.voip.ms", "toronto5.voip.ms", "toronto6.voip.ms", "toronto7.voip.ms", "toronto8.voip.ms", "vancouver.voip.ms", "vancouver2.voip.ms", "washington.voip.ms", "washington2.voip.ms") #Get the list of servers into an array
)
try { . (LoadDefaults -Invocation $MyInvocation) -Invocation $MyInvocation } catch { Write-Warning "Failed to load defaults. Is the module loaded?" }
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
  $ApiServers = (Invoke-RestMethod -Uri ("https://voip.ms/api/v1/rest.php?api_username=" + $Username + "&api_password=" + $Password + "&method=getServersInfo")).servers
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
