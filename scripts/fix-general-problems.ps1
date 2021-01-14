Write-Host "Original Folder $PSScriptRoot"

Write-Host "<==========================================>"
Write-Host "            Resetting the MS Store"
Write-Host "<==========================================>"
Write-Host ""

Start-Process wsreset

Write-Host "<============================================>"
Write-Host "             Fix Windows Taskbar"
Write-Host "<============================================>"
Write-Host ""

Push-Location "$env:SystemRoot\System32"
    .\Regsvr32.exe /s msimtf.dll | .\Regsvr32.exe /s msctf.dll | Start-Process -Verb RunAs .\ctfmon.exe
Pop-Location

Write-Host "<============================================>"
Write-Host "        Fix Windows Registry and Image"
Write-Host "<============================================>"
Write-Host ""

sfc /scannow
dism.exe /online /cleanup-image /restorehealth

Write-Host "<==========================================>"
Write-Host " This will Re-register all your apps"
Write-Host "<==========================================>"
Write-Host ""

taskkill /F /IM explorer.exe
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableXamlStartMenu" -Type Dword -Value 0
Get-AppXPackage -AllUsers | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
Start-Process explorer

Write-Host "<==========================================>"
Write-Host "           Solving Network problems"
Write-Host "<==========================================>"
Write-Host ""

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