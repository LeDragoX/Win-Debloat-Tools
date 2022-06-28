Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Main() {
    Write-Section "Upgrade all Packages"
    Write-Caption "Winget"
    winget upgrade --all --silent | Out-Host
    Write-Caption "Chocolatey"
    choco upgrade all --ignore-dependencies --yes | Out-Host
    Write-Caption "WSL"
    wsl --update | Out-Host
}

Main