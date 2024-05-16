Import-Module BitsTransfer
Import-Module -DisableNameChecking "$PSScriptRoot\Get-TempScriptFolder.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\Title-Templates.psm1"

function Request-FileDownload {
    [CmdletBinding()]
    [OutputType([String[]])]
    param (
        [Alias('URI')]
        [Parameter(Position = 0, Mandatory)]
        [String] $FileURI,
        [Alias('Folder', 'OutFolder')]
        [Parameter(Position = 1)]
        [String] $OutputFolder = "$(Get-TempScriptFolder)\downloads",
        [Alias('File', 'OutFile')]
        [Parameter(Position = 2, Mandatory)]
        [String] $OutputFile,
        [Alias('RelativeFolder')]
        [Parameter(Position = 3)]
        [String] $ExtendFolder
    )

    Write-Verbose "[?] I'm at: $PWD"
    Write-Verbose "[?] Downloading at: $OutputFolder + $ExtendFolder"
    Write-Verbose "START '$OutputFolder' $($OutputFolder.GetType())"

    If ($ExtendFolder) {
        $OutputFolder = Join-Path -Path $OutputFolder -ChildPath $ExtendFolder
    }

    If (!(Test-Path $OutputFolder)) {
        Write-Status -Types "@" -Status "$OutputFolder doesn't exist, creating folder..."
        $OutputFolder = New-Item -Path $OutputFolder -ItemType Directory -Force
    }

    $FileLocation = Join-Path -Path $OutputFolder -ChildPath $OutputFile

    Write-Status -Types "@" -Status "Downloading from: '$FileURI' as '$OutputFile'"
    Write-Status -Types "@" -Status "On: '$FileLocation'"
    Start-BitsTransfer -Source "$FileURI" -Destination "$FileLocation" -Dynamic -DisplayName $OutputFile -TransferType Download | Wait-Job

    Write-Verbose "END '$FileLocation' $($FileLocation.GetType())"
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
        [Alias('Folder', 'OutFolder')]
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
$FileOutput = Request-FileDownload -FileURI "https://www.example.com/download/file.exe" -OutputFile "AnotherFileName.exe"
$WSLgOutput = Get-APIFile -URI "https://api.github.com/repos/microsoft/wslg/releases/latest" -ObjectProperty "assets" -FileNameLike "*$OSArch*.msi" -PropertyValue "browser_download_url" -OutputFile "wsl_graphics_support.msi"
#>
