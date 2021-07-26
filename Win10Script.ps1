function QuickPrivilegesElevation() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function LoadLibs() {

    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Current Folder $PSScriptRoot"
    Write-Host ""
    Push-Location -Path "$PSScriptRoot"
	
    Push-Location -Path "src\lib\"
    Get-ChildItem -Recurse *.ps*1 | Unblock-File

    #Import-Module -DisableNameChecking .\"check-os-info.psm1"      # Not Used
    Import-Module -DisableNameChecking .\"count-n-seconds.psm1"
    Import-Module -DisableNameChecking .\"set-script-policy.psm1"
    Import-Module -DisableNameChecking .\"setup-console-style.psm1" # Make the Console look how i want
    Import-Module -DisableNameChecking .\"simple-message-box.psm1"
    Import-Module -DisableNameChecking .\"title-templates.psm1"
    Pop-Location

}

function PromptPcRestart() {

    $Ask = "If you want to see the changes restart your computer!
    Do you want to Restart now?"
    
    switch (ShowQuestion -Title "Read carefully" -Message $Ask) {
        'Yes' {
            Write-Host "You choose Yes."
            Restart-Computer        
        }
        'No' {
            Write-Host "You choose to Restart later"
            Write-Host "You choose No. (No = Cancel)"
        }
        'Cancel' {
            # With Yes, No and Cancel, the user can press Esc to exit
            Write-Host "You choose to Restart later"
            Write-Host "You choose Cancel. (Cancel = No)"
        }
    }
    
}

function RunScripts() {

    Push-Location -Path "src\scripts\"

    Get-ChildItem -Recurse *.ps*1 | Unblock-File
        
    Clear-Host
    $Scripts = @(
        # [Recommended order] List of Scripts
        "backup-system.ps1"
        "silent-debloat-softwares.ps1"
        "optimize-scheduled-tasks.ps1"
        "optimize-services.ps1"
        "remove-bloatware-apps.ps1"
        "optimize-privacy-and-performance.ps1"
        "personal-optimizations.ps1"
        "optimize-security.ps1"
        "enable-optional-features.ps1"
        "remove-onedrive.ps1"
        "install-package-managers.ps1"
    )
        
    ForEach ($FileName in $Scripts) {
        Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
        PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"$FileName"
        # pause ### FOR DEBUGGING PURPOSES
    }

    $Ask = "This part is OPTIONAL, only do this if you want to repair your Windows.
        Do you want to continue?"

    switch (ShowQuestion -Title "Read carefully" -Message $Ask) {
        'Yes' {
            Write-Host "You choose Yes."

            $Scripts = @(
                # [Recommended order] List of Scripts
                "repair-windows.ps1"
            )
            ForEach ($FileName in $Scripts) {
                Title2 -Text "$FileName"
                PowerShell -NoProfile -ExecutionPolicy Bypass -file .\"$FileName"
                # pause ### FOR DEBUGGING PURPOSES
            }
        }
        'No' {
            Write-Host "You choose No. (No = Cancel)"
        }
        'Cancel' {
            # With Yes, No and Cancel, the user can press Esc to exit
            Write-Host "You choose Cancel. (Cancel = No)"
        }
    }

    Pop-Location
}

function Main() {
    
    QuickPrivilegesElevation    # Check admin rights
    LoadLibs                    # Import modules from lib folder
    UnrestrictPermissions       # Unlock script usage
    SetupConsoleStyle           # Just fix the font on the PS console
    Write-Host ""
    RunScripts                  # Run all scripts inside 'scripts' folder
    Write-Host ""
    RestrictPermissions         # Lock script usage
    Write-Host ""
    
    PromptPcRestart             # Prompt options to Restart the PC
    
    Taskkill /F /IM $PID        # Kill this task by PID because it won't exit with the command 'exit'
    
}

Main