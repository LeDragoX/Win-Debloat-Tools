function Request-AdminPrivilege() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function Open-Script() {
    $DoneTitle = "Information"
    $DoneMessage = "Process Completed!"

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
        "optimize-optional-features.ps1",
        "win11-wsl-preview-install.ps1"
    )

    Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage -OpenFromGUI $false
}

function Main() {
    Request-AdminPrivilege # Check admin rights
    Get-ChildItem -Recurse $PSScriptRoot\*.ps*1 | Unblock-File

    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"file-runner.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"set-console-style.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"set-script-policy.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"show-dialog-window.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"start-logging.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"title-templates.psm1"

    Start-Logging -File $PSCommandPath.Split("\")[-1].Split(".")[-2]
    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Root Folder $PSScriptRoot"
    Set-ConsoleStyle   # Makes the console look cooler
    Unlock-ScriptUsage
    Use-WindowsForm
    Open-Script        # Run all scripts inside 'scripts' folder
    Stop-Logging
    Block-ScriptUsage
    Write-ScriptLogo   # Thanks Figlet
    Request-PcRestart  # Prompt options to Restart the PC
}

Main