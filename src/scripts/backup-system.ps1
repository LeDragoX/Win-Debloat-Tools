Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function New-RestorePoint() {
    Write-Status -Types "+", $TweakType -Status "Enabling system drive Restore Point..."
    Enable-ComputerRestore -Drive "$env:SystemDrive\"
    Checkpoint-Computer -Description "Win 10+ SDT Restore Point" -RestorePointType "MODIFY_SETTINGS"
}

function Backup-HostsFile() {
    $PathToHostsFile = "$env:SystemRoot\System32\drivers\etc"

    Write-Status -Types "+", $TweakType -Status "Doing Backup on Hosts file..."
    $Date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    Push-Location "$PathToHostsFile"

    If (!(Test-Path "$PathToHostsFile\Hosts_Backup")) {
        Write-Status -Types "?", $TweakType -Status "Backup folder not found! Creating a new one..." -Warning
        mkdir -Path "$PathToHostsFile\Hosts_Backup"
    }
    Push-Location "Hosts_Backup"

    Copy-Item -Path ".\..\hosts" -Destination "hosts_$Date"

    Pop-Location
    Pop-Location
}

function Main() {
    $Script:TweakType = "Backup"
    New-RestorePoint # This makes a restoration point before the script begins
    Backup-HostsFile # Backup the Hosts file found on "X:\Windows\System32\drivers\etc" of the current system
}

Main