<#PSScriptInfo

.VERSION 1.0.2

.GUID 401b32f3-314a-47cf-b910-04c7f2492db2

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
This script will backup MySQL.

.PARAMETER mySqlData
Specifies the MySql Data folder. If unspecified C:\mySQL\data will be used.

.PARAMETER BackupLocation
Specifies the backup location. If unspecified C:\Local\MySqlBackups will be used.

.PARAMETER ConfigFile
Specifies the config file used to connect to MySql Data folder. If unspecified .\my.cnf will be used. Below is an example config file.
[client]
user="User"
password="password"

[mysqldump]
single-transaction
add-drop-database
add-drop-table

.PARAMETER mySqlDump
Specifies the MySqlDump.exe location. If unspecified C:\mySQL\bin\mysqldump.exe will be used.

.PARAMETER NoTrim
This script will prevent trimming the number of backups to the specified number.

.PARAMETER Copies
This is the number of files to keep in the folder. If unspecified, it will keep 10 copies.

.EXAMPLE
Backup-MySql
#>

param(
  [ValidateScript( { Test-Path -Path $_ -PathType Container })][string]$mySqlData = "C:\mySQL\data", #Patch to datatbases files directory
  [ValidateScript( { Test-Path -Path $_ -PathType Container })][string]$BackupLocation = "C:\Local\MySqlBackups", #Backup Directory
  [ValidateScript( { Test-Path -Path $_ -PathType Leaf })][string]$ConfigFile = ".\my.cnf", #Config file
  [ValidateScript( { Test-Path -Path $_ -PathType Leaf })][string]$mySqlDump = "C:\mySQL\bin\mysqldump.exe", #Patch to mysqldump.exe
  [switch]$NoTrim,
  [ValidateRange(1, [int]::MaxValue)][int]$Copies = 10 #Number of copies to keep
)

Write-Verbose "Get only names of the databases folders"
$sqlDbDirList = Get-ChildItem -path $mySqlData | Where-Object { $_.PSIsContainer } | Select-Object Name

Write-Verbose "Starting Backup"
Foreach ($dbDir in $sqlDbDirList) {
  Write-Verbose "Starting on $dbDir"
  $dbBackupDir = $BackupLocation + "\" + $dbDir.Name
  Write-Verbose "Checking if $dbDir exits. Create if needed."
  If (!(Test-Path -path $dbBackupDir -PathType Container)) { New-Item -Path $dbBackupDir -ItemType Directory }
  $dbBackupFile = $dbBackupDir + "\" + $dbDir.Name + "_" + (Get-Date -format "yyyyMMdd_HHmmss")
  $sqlFile = $dbBackupFile + ".sql"
  Write-Verbose "Dumping to $sqlFile"
  & $mysqldump --defaults-extra-file=$ConfigFile -B $dbDir.Name -r $sqlFile
}

If (!$NoTrim) {
  Write-Verbose "Trimming backups. Keeping newest $Copies copies."
  Get-ChildItem $BackupLocation -Recurse | Where-Object { $_.PsIsContainer } | Sort-Object CreationTime -Descending | Select-Object -Skip $Copies | Remove-Item -Force
}
