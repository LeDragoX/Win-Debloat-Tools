Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Repair-System() {
    Write-Section -Text "Resetting the Hosts file"
    $RestoreHosts = "# Copyright (c) 1993-2009 Microsoft Corp.`n#`n# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.`n#`n# This file contains the mappings of IP addresses to host names. Each`n# entry should be kept on an individual line. The IP address should`n# be placed in the first column followed by the corresponding host name.`n# The IP address and the host name should be separated by at least one`n# space.`n#`n# Additionally, comments (such as these) may be inserted on individual`n# lines or following the machine name denoted by a '#' symbol.`n#`n# For example:`n#`n#      102.54.94.97     rhino.acme.com          # source server`n#       38.25.63.10     x.acme.com              # x client host`n`n# localhost name resolution is handled within DNS itself.`n#    127.0.0.1       localhost`n#    ::1             localhost"

    Push-Location -Path "$env:SystemRoot\System32\drivers\etc\"
    Write-Output $RestoreHosts > .\hosts
    Pop-Location

    Write-Section -Text "Resetting the MS Store"
    Start-Process wsreset -NoNewWindow | Out-Host

    Write-Section -Text "Fix Windows Taskbar"
    Start-Process -FilePath "$env:SystemRoot\System32\Regsvr32.exe" -ArgumentList "/s $env:SystemRoot\System32\msimtf.dll" | Out-Host
    Start-Process -FilePath "$env:SystemRoot\System32\Regsvr32.exe" -ArgumentList "/s $env:SystemRoot\System32\msctf.dll" | Out-Host
    Start-Process -Verb RunAs "$env:SystemRoot\System32\ctfmon.exe" | Out-Host

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
    Repair-System
}

Main