Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

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
        Write-Mandatory "$PSScriptRoot\..\tmp doesn't exist, creating folder..."
        mkdir "$PSScriptRoot\..\tmp" | Out-Null
    }

    $FileLocation = "$PSScriptRoot\..\tmp\$OutputFile"

    If ($OutputFolder) {
        If (!(Test-Path "$PSScriptRoot\..\tmp\$OutputFolder")) {
            Write-Mandatory "$PSScriptRoot\..\tmp\$OutputFolder doesn't exist, creating folder..."
            mkdir "$PSScriptRoot\..\tmp\$OutputFolder"
        }
        $FileLocation = "$PSScriptRoot\..\tmp\$OutputFolder\$OutputFile"
    }

    Import-Module BitsTransfer
    Write-Host
    Write-Mandatory "Downloading from: '$FileURI' as '$OutputFile'"
    Write-Mandatory "On: '$FileLocation'"
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