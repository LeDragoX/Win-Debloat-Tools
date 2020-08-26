Write-Output "===================================="
Write-Output "This will Fix your Start Menu click"
Write-Output "===================================="

taskkill /F /IM explorer.exe

PowerShell Set-ExecutionPolicy Unrestricted
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V EnableXamlStartMenu /T REG_DWORD /D 0 /F
Get-AppXPackage -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
PowerShell Set-ExecutionPolicy Restricted


start explorer