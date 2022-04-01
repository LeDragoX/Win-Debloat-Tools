Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function WSLPreviewInstall() {
    Try {
        Write-Warning "[?] Installing WSL Preview from MS Store for Windows 11+..."
        Write-Warning "[?] PRESS 'Y' AND ENTER TO CONTINUE IF STUCK (Winget bug)..."
        $CheckExistenceBlock = { winget install --source "msstore" --id 9P9TQF7MRM4R --accept-package-agreements }
        $err = $null
        $err = (Invoke-Expression "$CheckExistenceBlock") | Out-Host
        If (($LASTEXITCODE)) { throw $err } # 0 = False, 1 = True

        Write-Caption -Text "[+][Features] WSL Preview (Win 11) successfully installed!"
        Write-Host "[-][Features] Uninstalling WSL from Optional Features..."
        Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" | Where-Object State -Like "Enabled" | Disable-WindowsOptionalFeature -Online -NoRestart

        Write-Host "[@] Updating WSL (if possible)..."
        wsl --update
    }
    Catch {
        Write-Warning "[?] Couldn't install WSL Preview, you must be at least on Windows 11..."
    }
}

function Main {
    WSLPreviewInstall
}

Main