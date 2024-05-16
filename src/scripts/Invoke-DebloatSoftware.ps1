Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-TempScriptFolder.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Request-FileDownload.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-ItemVerified.psm1"

# Adapted from this ChrisTitus script: https://github.com/ChrisTitusTech/win10script

function Invoke-DebloatSoftware() {
    [CmdletBinding()]
    param (
        [Switch] $Revert
    )

    If (!$Revert) {
        $AdwCleanerDl = "https://downloads.malwarebytes.com/file/adwcleaner"
        [String] $AdwCleanerOutput = (Request-FileDownload -FileURI $AdwCleanerDl -ExtendFolder "adwcleaner" -OutputFile "adwcleaner.exe")
        Write-Status -Types "+" -Status "Running MalwareBytes AdwCleaner scanner..."
        Start-Process -FilePath "$AdwCleanerOutput" -ArgumentList "/eula", "/clean", "/noreboot" -Wait
        Remove-ItemVerified (Split-Path -Path $AdwCleanerOutput) -Force -Recurse
    }

    Copy-Item -Path "$PSScriptRoot\..\configs\shutup10" -Destination "$(Get-TempScriptFolder)\downloads" -Recurse -Force
    $ShutUpDl = "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe"
    [String] $ShutUpOutput = Request-FileDownload -FileURI $ShutUpDl -ExtendFolder "shutup10" -OutputFile "OOSU10.exe"
    Push-Location -Path (Split-Path -Path $ShutUpOutput)

    If ($Revert) {
        Write-Status -Types "*" -Status "Running ShutUp10 and REVERTING to default settings..."
        Start-Process -FilePath "$ShutUpOutput" -ArgumentList "ooshutup10-default.cfg", "/quiet" -Wait # Wait until the process closes #
    } Else {
        Write-Status -Types "+" -Status "Running ShutUp10 and applying Recommended settings..."
        Start-Process -FilePath "$ShutUpOutput" -ArgumentList "ooshutup10.cfg", "/quiet" -Wait # Wait until the process closes #
    }

    Pop-Location
    Remove-ItemVerified (Split-Path -Path $ShutUpOutput) -Force -Recurse # Leave no extra files
}

If (!$Revert) {
    Invoke-DebloatSoftware # [AUTOMATED] ShutUp10 with recommended configs and AdwCleaner for Adware/Virus Scanning.
} Else {
    Invoke-DebloatSoftware -Revert
}

