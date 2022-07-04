<#PSScriptInfo

.VERSION 1.0.1

.GUID 029cd8de-13e9-4169-ae20-72c021290013

.AUTHOR Rohn Edwards

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
Searches registry key names, value names, and value data (limited). 

.DESCRIPTION 
This function can search registry key names, value names, and value data (in a limited fashion). It outputs custom objects that contain the key and the first match type (KeyName, ValueName, or ValueData). 

.PARAMETER PATH
Registry path to search 

.PARAMETER Recurse
Specifies whether or not all subkeys should also be searched 

.PARAMETER SearchRegex
A regular expression that will be checked against key names, value names, and value data (depending on the specified switches) 

.PARAMETER KeyName
When the -SearchRegex parameter is used, this switch means that key names will be tested (if none of the three switches are used, keys will be tested) 

.PARAMETER ValueName
When the -SearchRegex parameter is used, this switch means that the value data will be tested (if none of the three switches are used, value names will be tested) 

.PARAMETER ValueData

.PARAMETER ValueData
When the -SearchRegex parameter is used, this switch means that the value data will be tested (if none of the three switches are used, value data will be tested) 

.PARAMETER KeyNameRegex
Specifies a regex that will be checked against key names only 

.PARAMETER ValueNameRegex
Specifies a regex that will be checked against value names only

.PARAMETER ValueDataRegex
Specifies a regex that will be checked against value data only

.EXAMPLE 
Search-Registry -Path HKLM:\SYSTEM\CurrentControlSet\Services\* -SearchRegex "svchost" -ValueData 

.EXAMPLE 
Search-Registry -Path HKLM:\SOFTWARE\Microsoft -Recurse -ValueNameRegex "ValueName1|ValueName2" -ValueDataRegex "ValueData" -KeyNameRegex "KeyNameToFind1|KeyNameToFind2" 

.LINK
https://stackoverflow.com/questions/42963661/use-powershell-to-search-for-string-in-registry-keys-and-values

.LINK
https://gallery.technet.microsoft.com/scriptcenter/Search-Registry-Find-Keys-b4ce08b4
#> 
[CmdletBinding()] 
param( 
    [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)][Alias("PsPath")][string[]] $Path, 
    [switch]$Recurse, 
    [Parameter(ParameterSetName = "SingleSearchString", Mandatory)][string] $SearchRegex, 
    [Parameter(ParameterSetName = "SingleSearchString")][switch] $KeyName, 
    [Parameter(ParameterSetName = "SingleSearchString")][switch] $ValueName, 
    [Parameter(ParameterSetName = "SingleSearchString")][switch] $ValueData, 
    [Parameter(ParameterSetName = "MultipleSearchStrings")][string] $KeyNameRegex, 
    [Parameter(ParameterSetName = "MultipleSearchStrings")][string] $ValueNameRegex, 
    [Parameter(ParameterSetName = "MultipleSearchStrings")][string] $ValueDataRegex 
) 

begin { 
    switch ($PSCmdlet.ParameterSetName) { 
        SingleSearchString { 
            $NoSwitchesSpecified = -not ($PSBoundParameters.ContainsKey("KeyName") -or $PSBoundParameters.ContainsKey("ValueName") -or $PSBoundParameters.ContainsKey("ValueData")) 
            if ($KeyName -or $NoSwitchesSpecified) { $KeyNameRegex = $SearchRegex } 
            if ($ValueName -or $NoSwitchesSpecified) { $ValueNameRegex = $SearchRegex } 
            if ($ValueData -or $NoSwitchesSpecified) { $ValueDataRegex = $SearchRegex } 
        } 
        MultipleSearchStrings { 
            # No extra work needed 
        } 
    } 
} 

process { 
    foreach ($CurrentPath in $Path) { 
        Get-ChildItem $CurrentPath -Recurse:$Recurse |  
        ForEach-Object { 
            $Key = $_ 

            if ($KeyNameRegex) {  
                Write-Verbose ("{0}: Checking KeyNamesRegex" -f $Key.Name)  

                if ($Key.PSChildName -match $KeyNameRegex) {  
                    Write-Verbose "  -> Match found!" 
                    return [PSCustomObject] @{ 
                        Key    = $Key 
                        Reason = "KeyName" 
                    } 
                }  
            } 

            if ($ValueNameRegex) {  
                Write-Verbose ("{0}: Checking ValueNamesRegex" -f $Key.Name) 

                if ($Key.GetValueNames() -match $ValueNameRegex) {  
                    Write-Verbose "  -> Match found!" 
                    return [PSCustomObject] @{ 
                        Key    = $Key 
                        Reason = "ValueName" 
                    } 
                }  
            } 

            if ($ValueDataRegex) {  
                Write-Verbose ("{0}: Checking ValueDataRegex" -f $Key.Name) 

                if (($Key.GetValueNames() | ForEach-Object { $Key.GetValue($_) }) -match $ValueDataRegex) {  
                    Write-Verbose "  -> Match!" 
                    return [PSCustomObject] @{ 
                        Key    = $Key 
                        Reason = "ValueData" 
                    } 
                } 
            } 
        } 
    } 
} 
