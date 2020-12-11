Function QuickPrivilegesElevation {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

Import-Module -DisableNameChecking $PSScriptRoot\lib\count-n-seconds.psm1
Import-Module -DisableNameChecking $PSScriptRoot\lib\setup-console-style.psm1
Import-Module -DisableNameChecking $PSScriptRoot\lib\simple-message-box.psm1

Write-Host "Original Folder $PSScriptRoot"
Write-Host ""
Push-Location $PSScriptRoot
Function UnrestrictPermissions {
    Set-ExecutionPolicy Unrestricted -Scope Process -Force
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
    Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
    Get-ExecutionPolicy -List
    Write-Host ""
}

Function RestrictPermissions {
    Set-ExecutionPolicy Restricted -Scope Process -Force
    Set-ExecutionPolicy Restricted -Scope CurrentUser -Force
    Set-ExecutionPolicy Restricted -Scope LocalMachine -Force
    Get-ExecutionPolicy -List
    Write-Host ""
}

Function RunScripts {
    
    Clear-Host
    Write-Host "<=========================================================================================>"
    Write-Host "        Improve and Optimize Windows 10 (Made by Plínio Larrubia A.K.A. LeDragoX)"
    Write-Host "<=========================================================================================>"
    Write-Host ""
    
    Push-Location .\scripts
    Get-ChildItem -Recurse *.ps*1 | Unblock-File
    
    Clear-Host
    Write-Host "<==================== backup-system.ps1 ====================>"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"backup-system.ps1"
    Clear-Host
    Write-Host "<==================== all-in-one-tweaks.ps1 ====================>"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"all-in-one-tweaks.ps1"
    Clear-Host
    Write-Host "<==================== block-telemetry.ps1 ====================>"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"block-telemetry.ps1"
    Clear-Host
    Write-Host "<==================== disable-services.ps1 ====================>"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"disable-services.ps1"
    Clear-Host
    Write-Host "<==================== fix-privacy-settings.ps1 ====================>"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"fix-privacy-settings.ps1"
    Clear-Host
    Write-Host "<==================== optimize-user-interface.ps1 ====================>"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"optimize-user-interface.ps1"
    Clear-Host
    Write-Host "<==================== optimize-windows-update.ps1 ====================>"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"optimize-windows-update.ps1"
    Clear-Host
    Write-Host "<==================== remove-default-apps.ps1 ====================>"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"remove-default-apps.ps1"
    Clear-Host
    Write-Host "<==================== remove-onedrive.ps1 ====================>"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"remove-onedrive.ps1"
    Clear-Host
    Write-Host "<==================== install-gaming-features.ps1 ====================>"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"install-gaming-features.ps1"
    
    Write-Host "Updating Local Group Policies without a restart"
    gpupdate

    ShowMessage -Title "Read carefully" -Message "This part is OPTIONAL, you can close the script now"
    CountNseconds -Time 10 -Msg "The script will try to repair your Windows image in (e.g. Blue Screen)"
    Clear-Host
    Write-Host "<==================== fix-general-problems.ps1 ====================>"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"fix-general-problems.ps1"
    ShowMessage -Title "A message for you" -Message "Restart your computer!"
    
    Pop-Location
}
# Your script here

QuickPrivilegesElevation # Check admin rights
UnrestrictPermissions # Unlock script usage
SetupConsoleStyle # Give a hacky face to the Powershell console
Write-Host ""
RunScripts # Run all scripts inside 'scripts' folder
Write-Host ""
RestrictPermissions # Lock script usage
CountNseconds
exit