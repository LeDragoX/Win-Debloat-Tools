Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"manage-software.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"title-templates.psm1"

function Install-UWPWindowsMediaPlayer() {
    Write-Status -Types "*", "Apps" -Status "Installing Windows Media Player (UWP)..."
    Install-Software -Name "Windows Media Player (UWP)" -Packages @("9WZDNCRFJ3PT") -ViaMSStore
}

Install-UWPWindowsMediaPlayer