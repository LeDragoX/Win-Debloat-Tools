Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function WSLPreviewInstall() {
    $TweakType = "WSL"

    Try {
        Write-Status -Symbol "?" -Type $TweakType "Installing WSL Preview from MS Store for Windows 11+ ..." -Warning
        Write-Host "[?] Press 'Y' and ENTER to continue if stuck (Winget bug) ..." -ForegroundColor Magenta -BackgroundColor Black
        $CheckExistenceBlock = { winget install --source "msstore" --id 9P9TQF7MRM4R --accept-package-agreements }
        $err = $null
        $err = (Invoke-Expression "$CheckExistenceBlock") | Out-Host
        If (($LASTEXITCODE)) { throw $err } # 0 = False, 1 = True

        Write-Status -Symbol "+" -Type $TweakType -Status "WSL Preview (Win 11+) successfully installed!"
        Write-Status -Symbol "-" -Type $TweakType -Status "Uninstalling WSL from Optional Features ..."
        Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" | Where-Object State -Like "Enabled" | Disable-WindowsOptionalFeature -Online -NoRestart

        Write-Mandatory "Updating WSL (if possible) ..."
        wsl --update
    }
    Catch {
        Write-Status -Symbol "?" -Type $TweakType -Status "Couldn't install WSL Preview, you must be at least on Windows 11 ..." -Warning
    }
}

function Main {
    WSLPreviewInstall
}

Main