function Request-PrivilegesElevation() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function Use-Scripts() {

    $DoneTitle = "Done"
    $DoneMessage = "Process Completed!"

    Push-Location -Path "src\scripts\"

    Get-ChildItem -Recurse *.ps*1 | Unblock-File

    Clear-Host
    $Scripts = @(
        # [Recommended order]
        "backup-system.ps1",
        "install-package-managers.ps1",
        "silent-debloat-softwares.ps1",
        "optimize-scheduled-tasks.ps1",
        "optimize-services.ps1",
        "remove-bloatware-apps.ps1",
        "optimize-privacy-and-performance.ps1",
        "personal-tweaks.ps1",
        "optimize-security.ps1",
        "remove-onedrive.ps1",
        "optimize-optional-features.ps1"
    )

    ForEach ($FileName in $Scripts) {
        Write-TitleCounter -Text "$FileName" -MaxNum $Scripts.Length
        PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"$FileName"
    }
    Pop-Location

    Show-Message -Title "$DoneTitle" -Message "$DoneMessage"

}

function Main() {

    Request-PrivilegesElevation # Check admin rights

    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Root Folder $PSScriptRoot"
    Get-ChildItem -Recurse $PSScriptRoot\*.ps*1 | Unblock-File
    
    Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\set-console-style.psm1"
    Set-ConsoleStyle            # Makes the console look cooler
    Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\set-script-policy.psm1"
    Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\show-message-box.psm1"
    Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\title-templates.psm1"

    Set-UnrestrictedPermissions # Unlock script usage
    Use-Scripts                 # Run all scripts inside 'scripts' folder
    Set-RestrictedPermissions   # Lock script usage
    Write-ASCIIScriptName       # Thanks Figlet
    Request-PcRestart           # Prompt options to Restart the PC

}

Main