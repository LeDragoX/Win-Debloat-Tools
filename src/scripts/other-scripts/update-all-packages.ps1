Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"title-templates.psm1"

function Update-AllPackage() {
    Write-Section "Upgrade all Packages"
    Try {
        Write-Caption "Winget"
        winget upgrade --all --silent | Out-Host
    } Catch {
        Write-Status -Types "!" -Status "Failed to upgrade packages through Winget (maybe it's uninstalled?)" -Warning
    }

    Try {
        Write-Caption "Chocolatey"
        choco upgrade all --ignore-dependencies --yes | Out-Host
    } Catch {
        Write-Status -Types "!" -Status "Failed to upgrade packages through Chocolatey (maybe it's uninstalled?)" -Warning
    }

    Try {
        Write-Caption "WSL"
        wsl --update | Out-Host
    } Catch {
        Write-Status -Types "!" -Status "Failed to upgrade packages through WSL (maybe it's uninstalled?)" -Warning
    }
}

Update-AllPackage