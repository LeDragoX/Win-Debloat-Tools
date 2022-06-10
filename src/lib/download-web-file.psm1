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
        Write-Status -Types "@" -Status "$PSScriptRoot\..\tmp doesn't exist, creating folder..."
        mkdir "$PSScriptRoot\..\tmp" | Out-Null
    }

    $FileLocation = "$PSScriptRoot\..\tmp\$OutputFile"

    If ($OutputFolder) {
        If (!(Test-Path "$PSScriptRoot\..\tmp\$OutputFolder")) {
            Write-Status -Types "@" -Status "$PSScriptRoot\..\tmp\$OutputFolder doesn't exist, creating folder..."
            mkdir "$PSScriptRoot\..\tmp\$OutputFolder"
        }
        $FileLocation = "$PSScriptRoot\..\tmp\$OutputFolder\$OutputFile"
    }

    Import-Module BitsTransfer
    Write-Host
    Write-Status -Types "@" -Status "Downloading from: '$FileURI' as '$OutputFile'"
    Write-Status -Types "@" -Status "On: '$FileLocation'"
    Start-BitsTransfer -Dynamic -RetryTimeout 60 -TransferType Download -Source $FileURI -Destination $FileLocation

    return $FileLocation
}

function Get-APIFile {
    [CmdletBinding()]
    param (
        [String] $URI,
        [String] $ObjectProperty,
        [String] $FileNameLike,
        [String] $PropertyValue,
        [Parameter(Mandatory = $false)]
        [String] $OutputFolder,
        [String] $OutputFile
    )

    $Response = Invoke-RestMethod -Method Get -Uri $URI | ForEach-Object $ObjectProperty | Where-Object name -like $FileNameLike
    $FileURI = $Response."$PropertyValue"

    If ($OutputFolder) {
        return Request-FileDownload -FileURI $FileURI -OutputFolder $OutputFolder -OutputFile $OutputFile
    } Else {
        return Request-FileDownload -FileURI $FileURI -OutputFile $OutputFile
    }
}

<#
Example:
$FileOutput = Request-FileDownload -FileURI "https://www.example.com/download/file.exe" -OutputFile "AnotherFileName.exe" # File will download on src\tmp
$WSLgOutput = Get-APIFile -URI "https://api.github.com/repos/microsoft/wslg/releases/latest" -ObjectProperty "assets" -FileNameLike "*$OSArch*.msi" -PropertyValue "browser_download_url" -OutputFile "wsl_graphics_support.msi"
#>