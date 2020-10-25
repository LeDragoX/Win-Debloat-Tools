# Made by LeDragoX inspired by Chris Titus Tech
Write-Output "Enabling system drive Restore Point"
mkdir "$env:SystemDrive\WinBackup"
Enable-ComputerRestore -Drive "$env:SystemDrive\WinBackup"
Checkpoint-Computer -Description "RestorePoint1" -RestorePointType "MODIFY_SETTINGS"