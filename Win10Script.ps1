Function QuickPrivilegesElevation {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

Function PrepareRun {
    Import-Module -DisableNameChecking $PSScriptRoot\lib\Count-N-Seconds.psm1
    Import-Module -DisableNameChecking $PSScriptRoot\lib\Setup-Console-Style.psm1
    Import-Module -DisableNameChecking $PSScriptRoot\lib\Simple-Message-Box.psm1
    Import-Module -DisableNameChecking $PSScriptRoot\lib\Title-Templates.psm1

    Write-Host "Original Folder $PSScriptRoot"
    Write-Host ""
    Push-Location $PSScriptRoot
}

Function UnrestrictPermissions {
    Write-Host "Receiving permissions to run scripts"
    Set-ExecutionPolicy Unrestricted -Scope Process -Force
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
    Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
    Get-ExecutionPolicy -List
    Write-Host ""
}

Function RestrictPermissions {
    Write-Host "Denying permissions to run scripts"
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
    SimpleTitleTemplate -Text "backup-system.ps1"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"backup-system.ps1"
    # pause ### FOR DEBUGGING PURPOSES
    Clear-Host
    SimpleTitleTemplate -Text "all-in-one-tweaks.ps1"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"all-in-one-tweaks.ps1"
    # pause ### FOR DEBUGGING PURPOSES
    Clear-Host
    SimpleTitleTemplate -Text "fix-privacy-settings.ps1"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"fix-privacy-settings.ps1"
    # pause ### FOR DEBUGGING PURPOSES
    Clear-Host
    SimpleTitleTemplate -Text "optimize-user-interface.ps1"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"optimize-user-interface.ps1"
    # pause ### FOR DEBUGGING PURPOSES
    Clear-Host
    SimpleTitleTemplate -Text "optimize-windows-update.ps1"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"optimize-windows-update.ps1"
    # pause ### FOR DEBUGGING PURPOSES
    Clear-Host
    SimpleTitleTemplate -Text "remove-onedrive.ps1"
    PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"remove-onedrive.ps1"
    # pause ### FOR DEBUGGING PURPOSES
    
    $Question = "This part is OPTIONAL, only do this if you want to repair your Windows.
    Do you want to continue?"

    switch (ShowQuestion -Title "Read carefully" -Message $Question) {
        'Yes' {
            Write-Host "You choose Yes."

            Clear-Host
            SimpleTitleTemplate -Text "fix-general-problems.ps1"
            PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"fix-general-problems.ps1"
        }
        'No' {
            Write-Host "You choose No. (No = Cancel)"
        }
        'Cancel' { # With Yes, No and Cancel, the user can press Esc to exit
            Write-Host "You choose Cancel. (Cancel = No)"
        }
    }

    ShowMessage -Title "A message for you" -Message "If you want to see the changes restart your computer!"
    
    Pop-Location
}
# Your script here

QuickPrivilegesElevation # Check admin rights
PrepareRun # Import modules from lib and Push to the script directory
UnrestrictPermissions # Unlock script usage
SetupConsoleStyle # Give a hacky face to the Powershell console
Write-Host ""
RunScripts # Run all scripts inside 'scripts' folder
Write-Host ""
RestrictPermissions # Lock script usage
Write-Host ""
CountNseconds # Count 3 seconds (default) then exit
Taskkill /F /IM $PID # Kill this task by PID because it won't exit with the command 'exit'