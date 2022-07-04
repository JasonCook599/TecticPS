# Introduction

This is a collection of scripts used for day to day management of ***REMOVED***'s IT Resources.

# Custom Defaults

Many functions have a default set for the parameters. However, some parameters will be unique to your environment and will remain constant. To support this, all functions allow you to change the default by modifying your [PowerShell profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles).

The function will use this as the new default, but will be overridden when passing the parameter at runtime.

The variable should be set in this format: `$ModuleName.FunctionWithoutDashes.Parameter`. For example, to configure the Microsoft 365 tenant, you would add the the following line `$***REMOVED***IT.ConnectOffice365.Tenant = "tenant"`

For more information, see the [example profile](Examples/Profile.ps1)
