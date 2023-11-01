Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-ItemVerified.psm1"

function Remove-TemporaryFiles() {
    $TweakType = "Temp"

    Write-Status -Types "+", $TweakType -Status "Cleaning the $env:SystemRoot\Temp\ folder..."
    Remove-ItemVerified -Path "$env:SystemRoot\Temp\*" -Recurse -Force
    Write-Status -Types "+", $TweakType -Status "Cleaning the $env:TEMP\ folder..."
    Remove-ItemVerified -Path "$env:TEMP\*" -Recurse -Force
}

Remove-TemporaryFiles
