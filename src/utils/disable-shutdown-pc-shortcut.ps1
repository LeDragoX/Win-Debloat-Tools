Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"new-shortcut.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Main() {
    $DesktopPath = [Environment]::GetFolderPath("Desktop");

    Write-Status -Symbol "@" -Status "Removing the shortcut to shutdown the computer on the Desktop..." -Warning
    Remove-Item -Path "$DesktopPath\Shutdown Computer.lnk"
}

Main