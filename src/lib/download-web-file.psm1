function Request-FileDownload {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [String] $FileURI,
        [Parameter(Mandatory = $false)]
        [String] $OutputFolder,
        [String] $OutputFile
    )

    Write-Verbose "[?] I'm at: $PWD"
    If (!(Test-Path "$PSScriptRoot\..\tmp")) {
        Write-Host "[@] $PSScriptRoot\..\tmp doesn't exist, creating folder..." -ForegroundColor White
        mkdir "$PSScriptRoot\..\tmp" | Out-Null
    }

    $FileLocation = "$PSScriptRoot\..\tmp\$OutputFile"

    If ($OutputFolder) {
        If (!(Test-Path "$PSScriptRoot\..\tmp\$OutputFolder")) {
            Write-Host "[@] $PSScriptRoot\..\tmp\$OutputFolder doesn't exist, creating folder..." -ForegroundColor White
            mkdir "$PSScriptRoot\..\tmp\$OutputFolder"
        }
        $FileLocation = "$PSScriptRoot\..\tmp\$OutputFolder\$OutputFile"
    }

    Import-Module BitsTransfer
    Write-Host "`n[@] Downloading from '$FileURI' as '$OutputFile'`n[@] On '$FileLocation'" -ForegroundColor White
    Start-BitsTransfer -Dynamic -RetryTimeout 60 -TransferType Download -Source $FileURI -Destination $FileLocation

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
$FileOutput = Request-FileDownload -FileURI "https://www.example.com/download/file.exe" -OutputFile "AnotherFileName.exe" # File will download on src\tmp
$WSLgOutput = Get-APIFile -URI "https://api.github.com/repos/microsoft/wslg/releases/latest" -APIObjectContainer "assets" -FileNameLike "*$OSArch*.msi" -APIProperty "browser_download_url" -OutputFile "wsl_graphics_support.msi"
#>