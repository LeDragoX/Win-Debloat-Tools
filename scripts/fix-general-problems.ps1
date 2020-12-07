Write-Host "Original Folder $PSScriptRoot"

Write-Host "<============================================>"
Write-Host "Fix windows explorer opening with no reason"
Write-Host "<============================================>"
Write-Host ""

sfc /scannow
dism.exe /online /cleanup-image /restorehealth

Write-Host "<==========================================>"
Write-Host "This will Fix your Start Menu not opening"
Write-Host "<==========================================>"
Write-Host ""

taskkill /F /IM explorer.exe

REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V EnableXamlStartMenu /T REG_DWORD /D 0 /F
Get-AppXPackage -AllUsers | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

Start-Process explorer