Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function RepairWindows() {

  Section1 -Text "Resetting the Hosts file"

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
  
  Push-Location -Path "$env:SystemRoot\System32\drivers\etc\"
  Write-Output $RestoreHosts > .\hosts
  Pop-Location
  
  Section1 -Text "Resetting the MS Store"
  
  Start-Process wsreset -NoNewWindow
  
  Section1 -Text "Fix Windows Taskbar"
  
  Push-Location -Path "$env:SystemRoot\System32\"
  .\Regsvr32.exe /s msimtf.dll 
  .\Regsvr32.exe /s msctf.dll
  Start-Process -Verb RunAs .\ctfmon.exe
  Pop-Location
  
  Section1 -Text "Remove 'Test Mode' Watermark"
  bcdedit -set TESTSIGNING OFF
  
  Section1 -Text "Fix Windows Registry and Image"
  
  sfc /scannow
  dism.exe /online /cleanup-image /restorehealth
  
  Section1 -Text "Re-register all your apps"
  
  taskkill /F /IM explorer.exe
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableXamlStartMenu" -Type Dword -Value 0
  Get-AppXPackage -AllUsers | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" }
  Start-Process explorer
  
  Section1 -Text "Solving Network problems"
  
  ipconfig /release
  ipconfig /release6
  Caption1 -Text "'ipconfig /renew6 *Ethernet*' - YOUR INTERNET MAY FALL DURING THIS, be patient..."
  ipconfig /renew6 *Ethernet*
  Caption1 -Text "'ipconfig /renew *Ethernet*' - THIS MAY TAKE A TIME, be patient..."
  ipconfig /renew *Ethernet*
  
  Caption1 -Text "Flushing DNS..."
  ipconfig /flushdns
  
  Caption1 -Text "Resetting Winsock..."
  netsh winsock reset

}

function Main() {

  RepairWindows

}

Main