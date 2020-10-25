Write-Output "============================================"
Write-Output ""
Write-Output "Fix windows explorer opening with no reason"
Write-Output ""
Write-Output "============================================"
Write-Output ""

sfc /scannow
dism.exe /online /cleanup-image /restorehealth

Write-Output "=========================================="
Write-Output ""
Write-Output "This will Fix your Start Menu not opening"
Write-Output ""
Write-Output "=========================================="
Write-Output ""

taskkill /F /IM explorer.exe

REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V EnableXamlStartMenu /T REG_DWORD /D 0 /F
Get-AppXPackage -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

Start-Process explorer

Write-Output "Restart your Computer!" | Msg * /time:3