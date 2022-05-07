Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"new-shortcut.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Main() {
    $DesktopPath = [Environment]::GetFolderPath("Desktop");

    $SourcePath = "$env:SystemRoot\System32\shutdown.exe"
    $ShortcutPath = "$DesktopPath\Shutdown Computer.lnk"
    $Description = "Turns off the computer without any prompt"
    $IconLocation = "$env:SystemRoot\System32\shell32.dll, 27"
    $Arguments = "-s -f -t 0"
    $Hotkey = "CTRL+ALT+F12"

    Write-Status -Symbol "@" -Status "Creating a shortcut to shutdown the computer on the Desktop..."
    New-Shortcut -SourcePath $SourcePath -ShortcutPath $ShortcutPath -Description $Description -IconLocation $IconLocation -Arguments $Arguments -Hotkey $Hotkey
}

Main