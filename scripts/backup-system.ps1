# Made by LeDragoX inspired by Chris Titus Tech
Write-Output "Enabling system drive Restore Point"
Enable-ComputerRestore -Drive "$env:SystemDrive\" 
Checkpoint-Computer -Description "RestorePoint1" -RestorePointType "MODIFY_SETTINGS"