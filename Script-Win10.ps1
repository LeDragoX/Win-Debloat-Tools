Function QuickPrivilegesElevation {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

Import-Module -DisableNameChecking $PSScriptRoot\lib\count-n-seconds.psm1
Import-Module -DisableNameChecking $PSScriptRoot\lib\setup-console-style.psm1
Import-Module -DisableNameChecking $PSScriptRoot\lib\simple-message-box.psm1

Write-Output "Original Folder $PSScriptRoot"
Write-Output ""
Push-Location $PSScriptRoot
Function UnrestrictPermissions {
    Set-ExecutionPolicy Unrestricted -Force -Scope Process
    Set-ExecutionPolicy Unrestricted -Force -Scope CurrentUser
    Set-ExecutionPolicy Unrestricted -Force -Scope LocalMachine
    Get-ExecutionPolicy -List
    Write-Output ""
}

Function RestrictPermissions {
    Set-ExecutionPolicy Restricted -Force -Scope Process
    Set-ExecutionPolicy Restricted -Force -Scope CurrentUser
    Set-ExecutionPolicy Restricted -Force -Scope LocalMachine
    Get-ExecutionPolicy -List
    Write-Output ""
}

Function RunScripts {
    
    Clear-Host
    Write-Output "========================================================================================="
    Write-Output "      Improve and Optimize Windows 10 (Made by Plínio Larrubia A.K.A. LeDragoX)"
    Write-Output "========================================================================================="
    Write-Output ""
    
    Push-Location .\scripts
    ls -Recurse *.ps*1 | Unblock-File
    
    Clear-Host
    Write-Output "|==================== backup-system.ps1 ====================|" ""
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"backup-system.ps1"
    Clear-Host
    Write-Output "|==================== all-in-one-tweaks.ps1 ====================|" ""
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"all-in-one-tweaks.ps1"
    Clear-Host
    Write-Output "|==================== block-telemetry.ps1 ====================|" ""
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"block-telemetry.ps1"
    Clear-Host
    Write-Output "|==================== disable-services.ps1 ====================|" ""
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"disable-services.ps1"
    Clear-Host
    Write-Output "|==================== fix-privacy-settings.ps1 ====================|" ""
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"fix-privacy-settings.ps1"
    Clear-Host
    Write-Output "|==================== optimize-user-interface.ps1 ====================|" ""
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"optimize-user-interface.ps1"
    Clear-Host
    Write-Output "|==================== optimize-windows-update.ps1 ====================|" ""
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"optimize-windows-update.ps1"
    Clear-Host
    Write-Output "|==================== remove-default-apps.ps1 ====================|" ""
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"remove-default-apps.ps1"
    Clear-Host
    Write-Output "|==================== remove-onedrive.ps1 ====================|" ""
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"remove-onedrive.ps1"
    Clear-Host
    Write-Output "|==================== fix-general-problems.ps1 ====================|" ""
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"fix-general-problems.ps1"
    
    Pop-Location
}
# Your script here

QuickPrivilegesElevation # Check admin rights
UnrestrictPermissions # Unlock script usage
SetupConsoleStyle # Give a new face to the Powershell console
Write-Output ""
RunScripts # Run all scripts inside 'scripts' folder
Write-Output ""
RestrictPermissions # Lock script usage
CountNseconds