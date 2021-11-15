function Quick-PrivilegesElevation() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function Load-Libs() {

    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Root Folder $PSScriptRoot"
    Push-Location -Path "$PSScriptRoot"

    Push-Location -Path "src\lib\"
    Get-ChildItem -Recurse *.ps*1 | Unblock-File

    Import-Module -DisableNameChecking .\"set-script-policy.psm1"
    Import-Module -DisableNameChecking .\"setup-console-style.psm1"
    Import-Module -DisableNameChecking .\"simple-message-box.psm1"
    Import-Module -DisableNameChecking .\"title-templates.psm1"

    Pop-Location
}

function Run-Scripts() {

    $DoneTitle = "Done"
    $DoneMessage = "Process Completed!"

    Push-Location -Path "src\scripts\"

    Get-ChildItem -Recurse *.ps*1 | Unblock-File

    Clear-Host
    $Scripts = @(
        # [Recommended order]
        "backup-system.ps1",
        "silent-debloat-softwares.ps1",
        "optimize-scheduled-tasks.ps1",
        "optimize-services.ps1",
        "remove-bloatware-apps.ps1",
        "optimize-privacy-and-performance.ps1",
        "personal-tweaks.ps1",
        "optimize-security.ps1",
        "optimize-optional-features.ps1",
        "remove-onedrive.ps1",
        "install-package-managers.ps1"
    )

    ForEach ($FileName in $Scripts) {
        Write-TitleCounter -Text "$FileName" -MaxNum $Scripts.Length
        PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"$FileName"
    }
    Pop-Location

    Show-Message -Title "$DoneTitle" -Message "$DoneMessage"

}

function Main() {

    Quick-PrivilegesElevation   # Check admin rights
    Load-Libs                   # Import modules from lib folder
    Unrestrict-Permissions      # Unlock script usage
    Setup-ConsoleStyle          # Make the console look cooler
    Run-Scripts                 # Run all scripts inside 'scripts' folder
    Restrict-Permissions        # Lock script usage
    Prompt-PcRestart            # Prompt options to Restart the PC

}

Main