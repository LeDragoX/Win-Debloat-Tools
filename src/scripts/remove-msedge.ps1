Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Main() {
    $Ask = "Are you sure you want to remove Microsoft Edge from Windows?`nYou can reinstall it anytime."

    switch (Show-Question -Title "Warning" -Message $Ask -BoxIcon "Warning") {
        'Yes' {
            Remove-MSEdge
        }
        'No' {
            Write-Host "Aborting..."
        }
        'Cancel' {
            Write-Host "Aborting..." # With Yes, No and Cancel, the user can press Esc to exit
        }
    }
}

function Remove-MSEdge() {
    Start-Process -FilePath "$env:SystemDrive\Program Files (x86)\Microsoft\Edge\Application\*\Installer\setup.exe" -ArgumentList "--uninstall", "--system-level", "--verbose-logging", "--force-uninstall" -Wait
    Start-Process -FilePath "$env:SystemDrive\Program Files (x86)\Microsoft\EdgeCore\*\Installer\setup.exe" -ArgumentList "--uninstall", "--system-level", "--verbose-logging", "--force-uninstall" -Wait
    Remove-Item -Path "$env:LOCALAPPDATA\Packages\Microsoft.MicrosoftEdge*_*" -Confirm -Recurse | Out-Host
}

Main