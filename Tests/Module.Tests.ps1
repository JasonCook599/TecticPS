Describe 'Public Scripts' {
  $Files = Get-ChildItem (Join-Path -Path $PSScriptRoot -ChildPath "../src/Public/") -Recurse -File
  Context 'Test <_.Name>' -ForEach $Files {
    It 'uses a noun-verb pair' {
      $_.Name.ToString() -match '^(\w*)-(\w*)\.ps1$' | Should -Be $true
    }
    It 'uses an approved verb' {
      $_.Name.ToString() -match '^(\w*)-(\w*)\.ps1$' 
      $Matches[1].ToString() | Should -BeIn (Get-Verb).Verb
    }
    It 'is valid PowerShell' {
      $FileContent = Get-Content -Path $_ -ErrorAction Stop
      $Errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($FileContent, [ref]$Errors)
      $Errors.Count | Should -Be 0
    }
    It 'has valid comment-based metadata' {
      # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.psresourceget/test-psscriptfileinfo
      Test-PSScriptFileInfo -Path $_ | Should -be $true
    }
    It 'has a copyright statement' {
      (Get-PSScriptFileInfo -Path $_).ScriptMetadataComment.Copyright | SHould -Not -BeNullOrEmpty
    }
  }
}

Describe 'Module' {
  It 'Should import without errors' {
    $ModuleManifest = Test-ModuleManifest (Join-Path -Path $PSScriptRoot -ChildPath "../dist/TecticPS/TecticPS.psd1")
    { Import-Module -Name $ModuleManifest.Path -ErrorAction Stop } | Should -Not -Throw 
    Get-Module -Name $ModuleManifest.Name | Should -Not -BeNullOrEmpty
  }
  It 'Should have more than 180 commands' {
    (Get-Module TecticPS).ExportedCommands.Count | Should -BeGreaterThan 150
  }
  It 'Should have as many commands as files' {
    [string[]]$Paths = @(
      (Join-Path -Path $PSScriptRoot -ChildPath "../src/Public/"),
      (Join-Path -Path $PSScriptRoot -ChildPath "../src/Private/")
    )

    [int]$Files = (Get-ChildItem $Paths -Recurse -File).Count
    (Get-Module TecticPS).ExportedCommands.Count | Should -BeExactly $Files
  }
  $Files = Get-ChildItem (Join-Path -Path $PSScriptRoot -ChildPath "../dist/TecticPS")
  Context 'Test <_.Name>' -ForEach $Files {
    It 'is valid PowerShell' {
      $FileContent = Get-Content -Path $_ -ErrorAction Stop
      $Errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($FileContent, [ref]$Errors)
      $Errors.Count | Should -Be 0
    }
  }
}