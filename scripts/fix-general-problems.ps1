Write-Host "Current Script Folder $PSScriptRoot"

Write-Host "<==========================================>"
Write-Host "          Resetting the Hosts file"
Write-Host "<==========================================>"
Write-Host ""

$RestoreHosts = "# Copyright (c) 1993-2009 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host

# localhost name resolution is handled within DNS itself.
#    127.0.0.1       localhost
#    ::1             localhost"

Push-Location "$env:SystemRoot\System32\drivers\etc"
    Write-Output $RestoreHosts > .\hosts
Pop-Location

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