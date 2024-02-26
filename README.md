# TecticPS

## Introduction

This is a collection of scripts used for day to day management of IT resources.

## Custom Defaults

Many functions have a sensible default value set for each parameters. However, some parameters will be unique to your environment and will remain constant. To support this, most functions functions allow you to change the default by modifying your [PowerShell profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles).

The variable should be set in this format: `$ModuleName.FunctionWithoutDashes.Parameter`. For example, to configure the Microsoft 365 tenant, you would add the the following line `$TecticPS.ConnectOffice365.Tenant = "tenant"` The function will use this as the new default, but will be overridden when explicitly passing the parameter at runtime.

Functions that do not support loading defaults will contain a comment between the help block and parameter block saying `SkipLoadDefaults: True`.

For more information, see the [example profile](Examples/Profile.ps1)
