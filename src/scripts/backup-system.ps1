# Made by LeDragoX inspired by Chris Titus Tech
function MakeRestorePoint() {

    Write-Host "[+][Backup] Enabling system drive Restore Point..."
    Enable-ComputerRestore -Drive "$env:SystemDrive\" 
    Checkpoint-Computer -Description "RestorePoint1" -RestorePointType "MODIFY_SETTINGS"
    
}

function BackupHostsFile() {

    $PathToHostsFile = "$env:SystemRoot\System32\drivers\etc"
    
    Write-Host "[+][Backup] Doing Backup on Hosts file..."
    $Date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    Push-Location "$PathToHostsFile"
    
    If (!(Test-Path "$PathToHostsFile\Hosts_Backup")) {
        Write-Warning "[?][Backup] Backup folder not found! Creating a new one..."
        mkdir -Path "$PathToHostsFile\Hosts_Backup"
    }
    Push-Location "Hosts_Backup"
    Copy-Item -Path ".\..\hosts" -Destination "hosts_".Insert(6, $Date)
    Pop-Location
    Pop-Location
    
}

function Main() {
    
    MakeRestorePoint # This makes a restoration point before the script begins
    BackupHostsFile  # Backup the Hosts file found on "X:\Windows\System32\drivers\etc" of the current system

}

Main