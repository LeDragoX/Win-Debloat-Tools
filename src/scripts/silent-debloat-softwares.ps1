# Adapted from this ChrisTitus script: https://github.com/ChrisTitusTech/win10script

function Run-SilentDebloatSoftwares() {

    if (!(Test-Path "$PSScriptRoot\..\tmp")) {
        Write-Host "[+] Folder $PSScriptRoot\..\tmp doesn't exist, creating one..."
        mkdir "$PSScriptRoot\..\tmp" | Out-Null
    }

    $AdwCleanerDl = "https://downloads.malwarebytes.com/file/adwcleaner"
    $AdwCleanerOutput = "$PSScriptRoot\..\tmp\adwcleaner.exe"

    Write-Host "[+] Downloading and Running AdwCleaner from: $AdwCleanerDl"
    Invoke-WebRequest -Uri $AdwCleanerDl -OutFile $AdwCleanerOutput
    Start-Process -FilePath $AdwCleanerOutput -ArgumentList "/eula", "/clean", "/noreboot" -Wait
    Remove-Item $AdwCleanerOutput -Force

    $ShutUpOutput = "OOSU10.exe"
    $ShutUpDl = "https://dl5.oo-software.com/files/ooshutup10/$ShutUpOutput"
    $ShutUpFolder = "$PSScriptRoot\..\tmp\ShutUp10"

    Push-Location -Path $ShutUpFolder

    Write-Host "[+] Downloading and Running ShutUp10 from: $ShutUpDl and applying Recommended settings"
    Invoke-WebRequest -Uri $ShutUpDl -OutFile $ShutUpOutput
    Start-Process -FilePath $ShutUpOutput -ArgumentList "ooshutup10.cfg", "/quiet" -Wait # Wait until the process closes
    Remove-Item "$ShutUpOutput" -Force                                                   # Leave no traces

    Pop-Location
}

function Main() {

    Run-SilentDebloatSoftwares # [AUTOMATED] ShutUp10 with recommended configs and AdwCleaner for Virus Scanning.

}

Main