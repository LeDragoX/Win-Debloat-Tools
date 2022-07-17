function Main() {
    Clear-Host
    Request-AdminPrivilege # Check admin rights
    Get-ChildItem -Recurse $PSScriptRoot\*.ps*1 | Unblock-File

    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"open-file.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"set-console-style.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"show-dialog-window.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"start-logging.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"title-templates.psm1" -Force

    Set-ConsoleStyle   # Makes the console look cooler
    Start-Logging -File (Split-Path -Path $PSCommandPath -Leaf).Split(".")[0]
    Write-Caption "$((Split-Path -Path $PSCommandPath -Leaf).Split('.')[0]) v$((Get-Item "$(Split-Path -Path $PSCommandPath -Leaf)").LastWriteTimeUtc | Get-Date -Format "yyyy-MM-dd")"
    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Root Folder $PSScriptRoot"
    Use-WindowsForm
    Open-Script        # Run all scripts inside 'scripts' folder
    Stop-Logging
    Write-ScriptLogo   # Thanks Figlet
    Request-PcRestart  # Prompt options to Restart the PC
}

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
        "optimize-task-scheduler.ps1",
        "optimize-services.ps1",
        "remove-bloatware-apps.ps1",
        "optimize-privacy.ps1",
        "optimize-performance.ps1",
        "personal-tweaks.ps1",
        "optimize-security.ps1",
        #"remove-onedrive.ps1",
        "optimize-windows-features.ps1"
    )

    Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage -OpenFromGUI $false
}

Main