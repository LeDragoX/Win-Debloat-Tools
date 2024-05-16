Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\ui\Show-MessageDialog.psm1"

function Remove-WindowsOld() {
    $TweakType = "Windows.old"

    Write-Status -Types "+", $TweakType -Status "Cleaning up Old Windows Installation (Windows.old)..."
    Start-Process cleanmgr.exe -ArgumentList "/d $env:SystemDrive", "/AUTOCLEAN" -Wait
    Remove-ItemVerified -Path "$env:SystemDrive\Windows.old\" -Recurse -Force
}

$Ask = "Are you sure you want to remove $env:SystemDrive\Windows.old?`nOnly do this AFTER you have moved all your data from there.`n`nList from a few folders:`n- $env:SystemDrive\Windows.old\Users\$env:USERNAME\[...]`n   - AppData`n   - Desktop`n   - Documents`n   - Downloads`n   - Music`n   - Pictures`n   - Videos`n- $env:SystemDrive\Windows.old\ProgramData"

switch (Show-Question -Title "Warning" -Message $Ask -BoxIcon "Warning") {
    'Yes' {
        Remove-WindowsOld
    }
    'No' {
        Write-Host "Aborting..."
    }
    'Cancel' {
        Write-Host "Aborting..." # With Yes, No and Cancel, the user can press Esc to exit
    }
}
