Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Install-OneDrive() {
    Write-Status -Types "+" -Status "Installing OneDrive..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 0
    Start-Process -FilePath "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
}

function Main() {
    Install-OneDrive
}

Main