Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"

# Adapted from: https://github.com/ChrisTitusTech/win10script

function Repair-WindowsSystem() {
    Write-Title "Repair major Windows problems"

    Write-Section "Reset Windows Hosts file"
    $RestoreHosts = "# Copyright (c) 1993-2009 Microsoft Corp.`n#`n# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.`n#`n# This file contains the mappings of IP addresses to host names. Each`n# entry should be kept on an individual line. The IP address should`n# be placed in the first column followed by the corresponding host name.`n# The IP address and the host name should be separated by at least one`n# space.`n#`n# Additionally, comments (such as these) may be inserted on individual`n# lines or following the machine name denoted by a '#' symbol.`n#`n# For example:`n#`n#      102.54.94.97     rhino.acme.com          # source server`n#       38.25.63.10     x.acme.com              # x client host`n`n# localhost name resolution is handled within DNS itself.`n#    127.0.0.1       localhost`n#    ::1             localhost"

    Push-Location -Path "$env:SystemRoot\System32\drivers\etc\"
    Write-Caption "Restoring default hosts file..."
    Write-Output $RestoreHosts > .\hosts
    Pop-Location

    Write-Section "Fix missing Power Plans"
    Write-Caption "Restoring default Power Plans..."
    powercfg -RestoreDefaultSchemes

    Write-Section "Fix MS Store"
    Write-Caption "Running wsreset..."
    Start-Process wsreset -NoNewWindow | Out-Host

    Write-Section "Fix Windows Taskbar"
    Write-Caption "Restoring Windows Taskbar DLL links..."
    Start-Process -FilePath "$env:SystemRoot\System32\Regsvr32.exe" -ArgumentList "/s $env:SystemRoot\System32\msimtf.dll" | Out-Host
    Start-Process -FilePath "$env:SystemRoot\System32\Regsvr32.exe" -ArgumentList "/s $env:SystemRoot\System32\msctf.dll" | Out-Host
    Start-Process -Verb RunAs "$env:SystemRoot\System32\ctfmon.exe" | Out-Host

    Write-Section "Remove 'Test Mode' Watermark"
    Write-Caption "Disabling TestSigning on bcdedit..."
    bcdedit -set TESTSIGNING OFF | Out-Host

    Write-Section "Remove BITS stuck jobs"
    Write-Caption "Removing all BITS transfers..."
    Get-BitsTransfer | Remove-BitsTransfer

    Write-Section "Fix Windows Registry and Image"
    Write-Caption "Running SFC repair (This may take some time)..."
    SFC -ScanNow | Out-Host
    Write-Caption "Running DISM repair (This may take some time)..."
    DISM -Online -CleanUp-Image -RestoreHealth | Out-Host

    Write-Section "Re-register all your apps"
    Write-Caption "Closing Windows Explorer..."
    taskkill /F /IM explorer.exe
    Write-Caption "Re-registering all Windows Apps via AppXManifest.xml ..."
    Set-ItemPropertyVerified -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableXamlStartMenu" -Type Dword -Value 0
    Get-AppxPackage -AllUsers | ForEach-Object {
        Write-Status -Types "@" -Status "Trying to register package: $($_.InstallLocation)"
        Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
    }
    Write-Caption "Restarting Windows Explorer..."
    Start-Process explorer

    Write-Section "Solving Network problems"
    Write-Caption "Resetting IPv4 and IPv6 addresses..."
    Write-Status -Types "?" -Status "Your internet may fall during the process, please be patient..." -Warning
    ipconfig -Release | Out-Host
    ipconfig -Release6 | Out-Host
    Write-Caption "Renewing IPv4 address..."
    Write-Status -Types "?" -Status "This may take time, please be patient..." -Warning
    ipconfig -Renew *Ethernet* | Out-Host
    Write-Caption "Renewing IPv6 address..."
    ipconfig -Renew6 *Ethernet* | Out-Host

    Write-Caption "Flushing DNS..."
    ipconfig -FlushDns | Out-Host

    Write-Caption "Resetting Winsock..."
    netsh winsock reset | Out-Host
}

Repair-WindowsSystem
