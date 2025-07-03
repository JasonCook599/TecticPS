<#PSScriptInfo

.VERSION 1.0.5

.GUID 5670f368-b618-4475-8d45-8aebdee0456b

.AUTHOR Jason Cook

.COMPANYNAME Tectic

.COPYRIGHT Copyright (c) Tectic 2025

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#> 





<#
.DESCRIPTION
Set the photo for a Vantagepoint employee.
#>

return hello


function Set-VantagepointEmployeeImage {
  param(
    [string]$Path = "C:\Users\JCook\Dennis Group\IT Department - General\Images\Types\IT-Square.jpg",
    [string]$Employee,
    [string]$Company,
    [string]$EmployeeKey,
    $BaseUri = $global:Vantagepoint.BaseUri,
    $Headers = @{
      "Content-Type"  = "application/json"
      "Authorization" = "Bearer $global:VantagepointToken"
    }
  )

  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Content-Type", "multipart/form-data")
  $headers.Add("Authorization", "Bearer  $($Vantagepoint.Token)")

  $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
  $multipartFile = $Path
  $FileStream = [System.IO.FileStream]::new($multipartFile, [System.IO.FileMode]::Open)
  $fileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
  $fileHeader.Name = "files[]"
  $fileHeader.FileName = "file"
  $fileContent = [System.Net.Http.StreamContent]::new($FileStream)
  $fileContent.Headers.ContentDisposition = $fileHeader
  $multipartContent.Add($fileContent)

  $body = $multipartContent

  $response = Invoke-RestMethod 'https://dennisgroup.deltekfirst.com/dennisgroup/api/employee/01458/photo' -Method 'POST' -Headers $headers -Body $body
  $response | ConvertTo-Json
}

function Set-VantagepointEmployeeImageV2 {
  param(
    [string]$Path = "C:\Users\JCook\Dennis Group\IT Department - General\Images\Types\IT-Square.jpg",
    [string]$Employee,
    [string]$Company,
    [string]$EmployeeKey,
    $Headers = @{
      "Content-Type"  = "application/json"
      "Authorization" = "Bearer $($Vantagepoint.Token)"
    }
  )
  $Headers."Content-Type" = "multipart/form-data"

  $File = Get-Item -Path $Path
  $FileContentType = switch ($File.Extension) {
    '.jpe' { 'image/jpeg' }
    '.jpeg' { 'image/jpeg' }
    '.jpg' { 'image/jpeg' }
    '.js' { 'application/javascript' }
    '.json' { 'application/json' }
    Default { 'application/octet-stream' }
  }

		$FormTemplate = @'
--{0}
Content-Disposition: form-data; name="files[]"; filename="{1}"
Content-Type: {2}

{3}
--{0}--
'@

  $Encoding = [System.Text.Encoding]::GetEncoding("iso-8859-1")
  $Boundary = [guid]::NewGuid().Guid
  $Bytes = [System.IO.File]::ReadAllBytes($File.FullName)
  $Data = $Encoding.GetString($Bytes)
  $Body = $FormTemplate -f $Boundary, "blob", $FileContentType, $Data
  $FormContentType = "multipart/form-data; boundary=$boundary"

  $response = Invoke-RestMethod -Uri "$BaseUri/employee/01458/Photo" -Method "POST" -Headers $Headers -ContentType $FormContentType -Body $Body -SkipHttpErrorCheck
  $response | ConvertTo-Json
}
