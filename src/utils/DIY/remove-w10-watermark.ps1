function Quick-PrivilegesElevation() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function Main() {

    Quick-PrivilegesElevation

    Write-Host "[-] Removing the annoying message..."
    Write-Host "[-][Services] Stopping sppsvc..."
    Stop-Service -Name "sppsvc" -Force
    Write-Host "[-][Services] Disabling sppsvc at Startup..."
    Set-Service -Name "sppsvc" -StartupType Disabled

    bcdedit -set TESTSIGNING OFF
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\sppsvc" -Name "Start" -Type DWord -Value 4
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "DisplayNotRet" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "PaintDesktopVersion" -Type DWord -Value 0

}

Main