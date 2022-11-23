Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"download-web-file.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from this ChrisTitus script: https://github.com/ChrisTitusTech/win10script

function Use-DebloatSoftware() {
    [CmdletBinding()]
    param (
        [Switch] $Revert
    )

    If (!$Revert) {
        $AdwCleanerDl = "https://downloads.malwarebytes.com/file/adwcleaner"
        $AdwCleanerOutput = Request-FileDownload -FileURI $AdwCleanerDl -OutputFile "adwcleaner.exe"
        Write-Status -Types "+" -Status "Running MalwareBytes AdwCleaner scanner..."
        Start-Process -FilePath $AdwCleanerOutput -ArgumentList "/eula", "/clean", "/noreboot" -Wait
        Remove-Item $AdwCleanerOutput -Force
    }

    $ShutUpDl = "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe"
    $ShutUpOutput = Request-FileDownload -FileURI $ShutUpDl -OutputFolder "ShutUp10" -OutputFile "OOSU10.exe"
    $ShutUpFolder = "$PSScriptRoot\..\tmp\ShutUp10"
    Push-Location -Path $ShutUpFolder

    If ($Revert) {
        Write-Status -Types "*" -Status "Running ShutUp10 and REVERTING to default settings..."
        Start-Process -FilePath $ShutUpOutput -ArgumentList "ooshutup10-default.cfg", "/quiet" -Wait # Wait until the process closes #
    } Else {
        Write-Status -Types "+" -Status "Running ShutUp10 and applying Recommended settings..."
        Start-Process -FilePath $ShutUpOutput -ArgumentList "ooshutup10.cfg", "/quiet" -Wait # Wait until the process closes #
    }

    Remove-Item "$ShutUpOutput" -Force # Leave no extra files
    Pop-Location
}

function Main() {
    If (!$Revert) {
        Use-DebloatSoftware # [AUTOMATED] ShutUp10 with recommended configs and AdwCleaner for Adware/Virus Scanning.
    } Else {
        Use-DebloatSoftware -Revert
    }
}

Main
