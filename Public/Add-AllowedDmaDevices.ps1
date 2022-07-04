<#PSScriptInfo

.VERSION 1.0.2

.GUID a684ddd1-559b-48e2-bbdf-a85a3d50d3f6

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
.SYNOPSIS
This script will Allow spesific devices to the list of Allowed Buses.

.DESCRIPTION
This script will Allow spesific devices to the list of Allowed Buses. The primary use if for automatic BitLocker encryption.

.PARAMETER ComputerInfo
The Manufacturer and Model of the current device.

.PARAMETER Path
The registry path for AllowedBuses

.PARAMETER DeviceList
A hashtable of all the address of allowed devices in the format of Manufactuer.Model.Name.

.PARAMETER AllowedDevices
An list of all the devices allowed on this spesific device.
#>
param(
    $ComputerInfo = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Manufacturer, Model),
    $Path = "HKLM:\SYSTEM\CurrentControlSet\Control\DmaSecurity\AllowedBuses",
    $DeviceList = @{
        Lenovo = @{
            "20YG003FUS" = @{
                "PCI Express Root Port A" = "PCI\VEN_1022&DEV_1634"
                "PCI Express Root Port B" = "PCI\VEN_1022&DEV_1635"
                "PCI standard ISA bridge" = "PCI\VEN_1022&DEV_790E"
            }
        }
    },
    $AllowedDevices = $DeviceList.$($ComputerInfo.Manufacturer).$($ComputerInfo.Model)
)
foreach ($Device in $AllowedDevices.GetEnumerator()) {
    New-ItemProperty -Path $Path -Name $Device.Name -Value $Device.Value -PropertyType "String" -Force -WhatIf
}
