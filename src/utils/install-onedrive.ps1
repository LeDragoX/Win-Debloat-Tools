function InstallOneDrive() {

    Write-Host "[+] Installing OneDrive..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 0
    Start-Process -FilePath "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"

}

function Main() {

    InstallOneDrive

}

Main