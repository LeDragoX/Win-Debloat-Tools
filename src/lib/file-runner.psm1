Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-message-box.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Open-PowerShellFilesOnGUI {
    param (
        [String] $RelativeLocation,
        [Array]  $Scripts,
        [String] $DoneTitle,
        [String] $DoneMessage
    )

    Push-Location -Path "$PSScriptRoot\..\..\$RelativeLocation"
    Get-ChildItem -Recurse *.ps*1 | Unblock-File

    ForEach ($FileName in $Scripts) {
        Write-TitleCounter -Text "$FileName" -MaxNum $Scripts.Length
        Import-Module -DisableNameChecking .\"$FileName" -Force
    }

    Pop-Location
    Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
}
function Open-RegFiles {
    param (
        [String] $RelativeLocation,
        [Array]  $Scripts,
        [String] $DoneTitle,
        [String] $DoneMessage
    )

    Push-Location -Path "$PSScriptRoot\..\..\$RelativeLocation"

    ForEach ($FileName in $Scripts) {
        Write-TitleCounter -Text "$FileName" -MaxNum $Scripts.Length
        regedit /s "$FileName"
    }

    Pop-Location
    Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
}