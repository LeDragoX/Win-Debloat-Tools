Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Repair-Windows() {

    Write-Section -Text "Resetting the Hosts file"

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

    Write-Section -Text "Resetting the MS Store"

    Start-Process wsreset -NoNewWindow | Out-Host

    Write-Section -Text "Fix Windows Taskbar"

    Push-Location -Path "$env:SystemRoot\System32\"
    .\Regsvr32.exe /s msimtf.dll | Out-Host
    .\Regsvr32.exe /s msctf.dll | Out-Host
    Start-Process -Verb RunAs .\ctfmon.exe | Out-Host
    Pop-Location

    Write-Section -Text "Remove 'Test Mode' Watermark"
    bcdedit -set TESTSIGNING OFF | Out-Host

    Write-Section -Text "Fix Windows Registry and Image"

    sfc /scannow | Out-Host
    dism.exe /online /cleanup-image /restorehealth | Out-Host

    Write-Section -Text "Re-register all your apps"

    taskkill /F /IM explorer.exe
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableXamlStartMenu" -Type Dword -Value 0
    Get-AppXPackage -AllUsers | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" }
    Start-Process explorer

    Write-Section -Text "Solving Network problems"

    ipconfig /release | Out-Host
    ipconfig /release6 | Out-Host
    Write-Caption -Text "'ipconfig /renew6 *Ethernet*' - YOUR INTERNET MAY FALL DURING THIS, be patient..."
    ipconfig /renew6 *Ethernet* | Out-Host
    Write-Caption -Text "'ipconfig /renew *Ethernet*' - THIS MAY TAKE A TIME, be patient..."
    ipconfig /renew *Ethernet* | Out-Host

    Write-Caption -Text "Flushing DNS..."
    ipconfig /flushdns | Out-Host

    Write-Caption -Text "Resetting Winsock..."
    netsh winsock reset | Out-Host

}

function Main() {

    Repair-Windows

}

Main