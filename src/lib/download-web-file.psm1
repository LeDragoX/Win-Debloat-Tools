Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Request-FileDownload {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Position = 0, Mandatory)]
        [String] $FileURI,
        [Parameter(Position = 1)]
        [String] $OutputFolder,
        [Parameter(Position = 2, Mandatory)]
        [String] $OutputFile
    )

    Write-Verbose "[?] I'm at: $PWD"
    If (!(Test-Path "$PSScriptRoot\..\tmp")) {
        Write-Status -Types "@" -Status "$PSScriptRoot\..\tmp doesn't exist, creating folder..."
        New-Item -Path "$PSScriptRoot\..\tmp"
    }

    $FileLocation = $(Join-Path -Path "$PSScriptRoot\..\tmp\" -ChildPath "$OutputFile")

    If ($OutputFolder) {
        If (!(Test-Path "$PSScriptRoot\..\tmp\$OutputFolder")) {
            Write-Status -Types "@" -Status "$PSScriptRoot\..\tmp\$OutputFolder doesn't exist, creating folder..."
            New-Item -Path "$PSScriptRoot\..\tmp\$OutputFolder"
        }

        $FileLocation = $(Join-Path -Path "$PSScriptRoot\..\tmp\" -ChildPath "$OutputFolder\$OutputFile")
    }

    Import-Module BitsTransfer
    Write-Host
    Write-Status -Types "@" -Status "Downloading from: '$FileURI' as '$OutputFile'"
    Write-Status -Types "@" -Status "On: '$FileLocation'"
    Start-BitsTransfer -Dynamic -RetryTimeout 60 -TransferType Download -Source $FileURI -Destination $FileLocation

    return "$FileLocation"
}

function Get-APIFile {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [String] $URI,
        [Parameter(Position = 1, Mandatory)]
        [String] $ObjectProperty,
        [Parameter(Position = 2, Mandatory)]
        [String] $FileNameLike,
        [Parameter(Position = 3, Mandatory)]
        [String] $PropertyValue,
        [Parameter(Position = 4)]
        [String] $OutputFolder,
        [Parameter(Position = 5, Mandatory)]
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
