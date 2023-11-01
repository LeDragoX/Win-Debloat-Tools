Import-Module -DisableNameChecking "$PSScriptRoot\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\ui\Show-MessageDialog.psm1"

function Open-PowerShellFilesCollection {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [String]   $RelativeLocation,
        [Parameter(Position = 1, Mandatory)]
        [String[]] $Scripts,
        [String]   $DoneTitle,
        [String]   $DoneMessage,
        [Bool]     $OpenFromGUI = $true,
        [Switch]   $NoDialog
    )

    Push-Location -Path $(Join-Path -Path "$PSScriptRoot\..\.." -ChildPath "$RelativeLocation")
    Get-ChildItem -Recurse *.ps*1 | Unblock-File

    ForEach ($FileName in $Scripts) {
        $LastAccessUtc = "$((Get-Item "$FileName").LastWriteTimeUtc | Get-Date -Format "yyyy.MM.dd")"
        $Private:Counter = Write-TitleCounter "$FileName | $LastAccessUtc" -Counter $Counter -MaxLength $Scripts.Length
        If ($OpenFromGUI) {
            Import-Module .\"$FileName" -Force
        } Else {
            PowerShell -NoProfile -ExecutionPolicy Bypass -File .\"$FileName"
        }
    }

    Pop-Location

    If (!($NoDialog)) {
        Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
    }
}

function Open-RegFilesCollection {
    [CmdletBinding()]
    param (
        [String] $RelativeLocation,
        [Array]  $Scripts,
        [String] $DoneTitle,
        [String] $DoneMessage,
        [Switch] $NoDialog
    )

    Push-Location -Path $(Join-Path -Path "$PSScriptRoot\..\.." -ChildPath "$RelativeLocation")

    ForEach ($FileName in $Scripts) {
        $LastAccessUtc = "$((Get-Item "$FileName").LastWriteTimeUtc | Get-Date -Format "yyyy.MM.dd")"
        $Private:Counter = Write-TitleCounter "$FileName ($LastAccessUtc)" -Counter $Counter -MaxLength $Scripts.Length
        Start-Process -FilePath "regedit" -ArgumentList "/s", "$FileName" -Wait
    }

    Pop-Location

    If (!($NoDialog)) {
        Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
    }
}

<#
Example:
Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts "script.ps1" -NoDialog
Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("script1.ps1", "script2.ps1") -DoneTitle "Title" -DoneMessage "Message" -OpenFromGUI $false
Open-RegFilesCollection -RelativeLocation "src\scripts" -Scripts "script.reg" -NoDialog
Open-RegFilesCollection -RelativeLocation "src\scripts" -Scripts @("script1.reg", "script2.reg") -DoneTitle "Title" -DoneMessage "Message"
#>
