Write-Host "Original Folder $PSScriptRoot"

Write-Host "<============================================>"
Write-Host "Fix windows explorer opening with no reason [Optional]"
Write-Host "<============================================>"
Write-Host ""

sfc /scannow
dism.exe /online /cleanup-image /restorehealth

Write-Host "<==========================================>"
Write-Host "Resetting the MS Store [Optional]"
Write-Host "<==========================================>"
Write-Host ""

Start-Process wsreset

Write-Host "<==========================================>"
Write-Host "This will Fix your Start Menu not opening [Optional]"
Write-Host "<==========================================>"
Write-Host ""

taskkill /F /IM explorer.exe
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableXamlStartMenu" -Type Dword -Value 0
Get-AppXPackage -AllUsers | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
Start-Process explorer

Write-Host "Solving Network problems..."
ipconfig /release
ipconfig /release6
Clear-Host
Write-Host "'ipconfig /renew6 *Ethernet*' - YOUR INTERNET MAY FALL DURING THIS, be patient..."
ipconfig /renew6 *Ethernet*
Clear-Host
Write-Host "'ipconfig /renew *Ethernet*' - THIS MAY TAKE A TIME, be patient..."
ipconfig /renew *Ethernet*
ipconfig /flushdns
Write-Host "DNS flushed!"