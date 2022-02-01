Task default -depends ExportToPsm1, FunctionsToExport, SignModule, ImportModule

$ModuleName = Get-Item . | ForEach-Object BaseName
$ModuleFile = $ModuleName + ".psm1"

Task ExportToPsm1 {
    $ModuleContent = ""  
    
    #Export psm1 files
    foreach ($File in (Get-ChildItem -Path *.psm1 -ErrorAction SilentlyContinue -Recurse | Where-Object Name -ne $ModuleFile)) {
        $ModuleContent += ((Get-Content $File -Raw) -replace "\n# .*").Trim()
    }

    #Export ps1 files
    foreach ($File in (Get-ChildItem -Path *.ps1 -ErrorAction SilentlyContinue -Recurse | Where-Object Name -ne "psakefile.ps1")) {
        $FunctionName = $File.basename
        $ModuleContent += "function $FunctionName {`n"
        $ModuleContent += ((Get-Content $File -Raw) -replace "\n# .*").Trim()
        $ModuleContent += "`n}`n"
    }

    Clear-Content ".\$($ModuleName).psm1"
    Add-Content $ModuleContent -Path ".\$($ModuleName).psm1"
}

Task FunctionsToExport {
    # RegEx matches files like Verb-Noun.ps1 only, not psakefile.ps1 or *-*.Tests.ps1
    $FunctionNames = (Get-ChildItem -Recurse | Where-Object { $_.Name -match "^[^\.]+-[^\.]+\.ps1$" }).BaseName
    $FunctionNames += Get-ChildItem -Path *.psm1 -ErrorAction SilentlyContinue -Recurse | Where-Object Name -ne $ModuleFile -PipelineVariable file | ForEach-Object {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref] $null, [ref] $null)
        if ($ast.EndBlock.Statements.Name) {
            $ast.EndBlock.Statements.Name
        }
    }
    Write-Output "Using functions $FunctionNames"
    Update-ModuleManifest -Path ".\$($ModuleName).psd1" -FunctionsToExport $FunctionNames
}

Task SignModule {
    [System.Security.Cryptography.X509Certificates.X509Certificate]$Certificate = ((Get-ChildItem cert:currentuser\my\ -CodeSigningCert | Sort-Object NotBefore -Descending)[0])
    Set-AuthenticodeSignature -FilePath ".\$($ModuleName).psd1" -Certificate $Certificate
    Set-AuthenticodeSignature -FilePath ".\$($ModuleName).psm1" -Certificate $Certificate
}

Task ImportModule { Import-Module ".\$($ModuleName).psm1" -Force -Verbose:$false }