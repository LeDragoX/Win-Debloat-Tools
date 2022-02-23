function Request-FileDownload {
    param (
        [String] $FileURI,
        [Parameter(Mandatory = $false)]
        [String] $OutputFolder,
        [String] $OutputFile
    )

    if (!(Test-Path "$PSScriptRoot\..\tmp")) {
        Write-Host "[@] $PSScriptRoot\..\tmp doesn't exist, creating folder..." -ForegroundColor White
        mkdir "$PSScriptRoot\..\tmp" | Out-Null
    }

    $FileLocation = "$PSScriptRoot\..\tmp\$OutputFile"

    If ($OutputFolder) {
        $FileLocation = "$PSScriptRoot\..\tmp\$OutputFolder\$OutputFile"
    }

    Write-Host "[@] Downloading '$OutputFile' on '$FileLocation' `n[@] From: '$FileURI'" -ForegroundColor White
    Invoke-WebRequest -Uri $FileURI -OutFile $FileLocation

    return $FileLocation
}

function Get-APIFile {

    [CmdletBinding()]
    param (
        [String] $URI,
        [String] $APIObjectContainer,
        [String] $FileNameLike,
        [String] $APIProperty,
        [String] $OutputFile
    )

    $APIResponse = Invoke-RestMethod -Method Get -Uri $URI | ForEach-Object $APIObjectContainer | Where-Object name -like $FileNameLike
    $FileURI = $APIResponse."$APIProperty"

    return Request-FileDownload -FileURI $FileURI -OutputFile $OutputFile
}

<#
Example:
$FileOutput = Request-FileDownload -FileURI "https://www.example.com/download/file.exe" -OutputFile "AnotherFileName.exe"
$WSLgOutput = Get-APIFile -URI "https://api.github.com/repos/microsoft/wslg/releases/latest" -APIObjectContainer "assets" -FileNameLike "*$OSArch*.msi" -APIProperty "browser_download_url" -OutputFile "wsl_graphics_support.msi"
#>