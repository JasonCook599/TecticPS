<#PSScriptInfo
.VERSION 1.0.0
.GUID 10ba8c03-4333-4f67-b11b-b25fef85943b

.AUTHOR
Jason Cook

.COMPANYNAME
***REMOVED***

.COPYRIGHT
Copyright (c) ***REMOVED*** 2022
#>

<#
.DESCRIPTION
Install module if not pressent.
#>
param($Name, $AltName) 
Write-Verbose "$me Installing $Name Module if missing"
If (!(Get-Module -ListAvailable -Name $Name)) {
	Install-Module $Name
}

