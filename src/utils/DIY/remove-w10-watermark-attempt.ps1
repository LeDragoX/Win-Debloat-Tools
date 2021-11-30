function Request-PrivilegesElevation() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function Main() {

    Request-PrivilegesElevation

    Write-Host "[-] Removing the annoying message..."
    Write-Host "[-][Services] Disabling sppsvc..."
    Get-Service -Name "sppsvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    Stop-Service "sppsvc" -Force -NoWait

    bcdedit -set TESTSIGNING OFF
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\sppsvc" -Name "Start" -Type DWord -Value 4
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "DisplayNotRet" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "PaintDesktopVersion" -Type DWord -Value 0

}

Main