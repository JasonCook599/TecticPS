Task default -depends ImportModule, TestDuplicateGuids, UpdatePSScriptInfo, ExportToPsm1, UpdateManifest, TestModule
Task quick -depends ExportToPsm1, UpdateManifest

$ModuleName = "TecticPS"
$ModuleFile = "dist\$ModuleName.psm1"
$ModuleManifest = "dist\$ModuleName.psd1"
$SourceModules = Get-ChildItem -Path .\src\*.psm1 -ErrorAction SilentlyContinue -Recurse
$SourceScripts = Get-ChildItem -Path .\src\*.ps1 -ErrorAction SilentlyContinue -Recurse 

Task UpdatePSScriptInfo {
  $count = 0
  $SourceScripts | ForEach-Object {
    $count++ ; Progress -Index $count -Total $SourceScripts.count -Activity "Checking scripts for changes" -Name $_.Name

    Write-Debug "[$($_.Name)] Checking if file changed."
    $GitStatus = git status $_.FullName -s --ignored
    if ($null -ne $GitStatus) {
      Write-Verbose "[$($_.Name)] File has changed. Incrementing build number."

      Write-Debug "[$($_.Name)] Getting script info."
      $PSScriptFileInfo = $null
      $PSScriptFileInfo = Get-PSScriptFileInfo -Path $_.FullName

      
      Write-Debug "[$($_.Name)] Incrementing build number.."
      [version]$Version = $PSScriptFileInfo.ScriptMetadataComment.Version.ToString()
      [version]$Version = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1)

      Write-Debug "[$($_.Name)] Updating copyright year to current year"
      $Copyright = (Get-PSScriptFileInfo  $_.FullName).ScriptMetadataComment.Copyright -replace "^Copyright \(c\) Tectic(.*)$", "Copyright (c) Tectic $((Get-Date).Year)" -replace "^Copyright \(c\) Tectic(.*)$", "Copyright (c) Tectic $((Get-Date).Year)"
      $CopyrightString = $Copyright -join "`n"

      Write-Verbose "[$($_.Name)] Updating script info"
      Update-PSScriptFileInfo -Path $_.FullName -Version $Version -Copyright $CopyrightString

      Write-Debug "$($_.Name): Removing superfluous blank lines"
      $ScriptContent = Remove-BlankLines -String (Get-Content $_ -Raw)
      Clear-Content $_.FullName -ErrorAction SilentlyContinue
      Add-Content $ScriptContent -Path $_.FullName
    }
    Write-Debug "[$($_.Name)] Finished."
  }
}

Task TestDuplicateGuids {
  $ScriptsWithErrors = @()
  $ScriptFileInfo | ForEach-Object {
    $DuplicateGuids = ($ScriptFileInfo.Guid -match $_.Guid).count
    if ($_.Error -or $DuplicateGuids -gt 1 ) {
      $Result = New-Object PSObject
      $Result | Add-Member -NotePropertyName Name -NotePropertyValue $_.Name
      $Result | Add-Member -NotePropertyName Error -NotePropertyValue $_.Error
      $Result | Add-Member -NotePropertyName Guid -NotePropertyValue $_.Guid
      if ($DuplicateGuids -gt 1) { $Result | Add-Member -NotePropertyName DuplicateGuid -NotePropertyValue $DuplicateGuids }
      $ScriptsWithErrors += $Result

    }
  }
  if ($ScriptsWithErrors) {
    Write-Output "The following scripts have duplicate guids:"
    $ScriptsWithErrors | Select-Object -Property Name, Error, Guid, DuplicateGuid | Format-Table
    throw "Scripts with errors or duplicate guids"
  }
}

Task ExportToPsm1 {
  $ModuleContent = ""

  Write-Verbose "Exporting psm1 files"
  $SourceModules | ForEach-Object { $ModuleContent += ((Get-Content $_ -Raw) -replace "\n# .*").Trim() }

  Write-Verbose "Exporting ps1 files"
  $LoadDefaultsString = "try { . (LoadDefaults -Invocation `$MyInvocation) -Invocation `$MyInvocation } catch { Write-Warning `"Failed to load defaults for `$(`$MyInvocation.MyCommand.Name). Is the module loaded?`" }"
  $SourceScripts | ForEach-Object {
    $ScriptContent = (Get-Content $_ -Raw)
    if ( -not ($ScriptContent -match "(?mi)^.*#+.*SkipLoadDefaults:.*True.*$")) {
      Write-Debug "[$($_.Name)] adding LoadDefaults"
      $ScriptContent = $ScriptContent -replace '(?m)(param\(\s*$(?:.*$\n)*\))', "`$1`r`n`r`n$LoadDefaultsString"
    }
    else { Write-Debug "[$($_.Name)] skipping LoadDefaults" }
    
    Write-Debug "[$($_.Name)] Removing single line comments and superfluous blank lines"
    $ScriptContent = ($ScriptContent -replace "\n#[^>].*").Trim() -replace "\n\n\n", "`r`n`r`n" 

    Write-Debug "[$($_.Name)] Adding function statement."
    $ModuleContent += "function $($_.basename) {`n"
    $ModuleContent += $ScriptContent
    $ModuleContent += "`n}`n"
  }

  Write-Debug "Removing superfluous blank lines"
  while ($ModuleContent.Contains("`r`n`r`n`r`n")) { $ModuleContent = $ModuleContent -replace "`r`n`r`n`r`n", "`r`n`r`n" }

  Write-Debug "Clearing module file content."
  Clear-Content $ModuleFile -ErrorAction SilentlyContinue

  Write-Verbose "Writing module to file"
  Add-Content $ModuleContent.Trim() -Path $ModuleFile
}

Task UpdateManifest {
  # RegEx matches files like Verb-Noun.ps1 only, not psakefile.ps1 or *-*.Tests.ps1
  $FunctionNames = (Get-ChildItem -Path src\Public\*.ps1 -Recurse | Where-Object { $_.Name -match "^[^\.]+-[^\.]+\.ps1$" }).BaseName
  $FunctionNames += (Get-ChildItem -Path src\Private\*.ps1 -Recurse | Where-Object { $_.Name -match "^^[^\.]+\.ps1$" }).BaseName
  $FunctionNames += $SourceModules | ForEach-Object {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref] $null, [ref] $null)
    if ($ast.EndBlock.Statements.Name) {
      $ast.EndBlock.Statements.Name
    }
  }
  [version]$Version = (Import-PowerShellDataFile $ModuleManifest).ModuleVersion
  [version]$Version = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1)
  Write-Verbose "Using functions $FunctionNames"
  Update-ModuleManifest -Path $ModuleManifest -FunctionsToExport $FunctionNames -ModuleVersion $Version
}

Task TestModule { Invoke-Pester -Path ./Tests }

Task ImportModule { Import-Module (Join-Path -Path (Get-Location) -ChildPath $ModuleManifest) -Force -Verbose:$false }