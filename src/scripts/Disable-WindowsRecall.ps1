# This script disables the Windows Recall feature. You can run it with administrative privileges.
# To run this script, open PowerShell as an administrator and execute the following command:
# .\Disable-WindowsRecall.ps1

$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener"

if (-Not (Test-Path $registryPath)) {
    Write-Output "Registry path not found: $registryPath"
    exit
}
Set-ItemProperty -Path $registryPath -Name "Start" -Value 0
Write-Output "Windows Recall has been disabled."

