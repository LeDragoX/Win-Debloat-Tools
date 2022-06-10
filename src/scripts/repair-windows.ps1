Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://github.com/ChrisTitusTech/win10script

function Repair-System() {
    Write-Title -Text "Repair major Windows problems"

    Write-Section -Text "Reset Windows Hosts file"
    $RestoreHosts = "# Copyright (c) 1993-2009 Microsoft Corp.`n#`n# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.`n#`n# This file contains the mappings of IP addresses to host names. Each`n# entry should be kept on an individual line. The IP address should`n# be placed in the first column followed by the corresponding host name.`n# The IP address and the host name should be separated by at least one`n# space.`n#`n# Additionally, comments (such as these) may be inserted on individual`n# lines or following the machine name denoted by a '#' symbol.`n#`n# For example:`n#`n#      102.54.94.97     rhino.acme.com          # source server`n#       38.25.63.10     x.acme.com              # x client host`n`n# localhost name resolution is handled within DNS itself.`n#    127.0.0.1       localhost`n#    ::1             localhost"

    Push-Location -Path "$env:SystemRoot\System32\drivers\etc\"
    Write-Caption -Text "Restoring default hosts file..."
    Write-Output $RestoreHosts > .\hosts
    Pop-Location

    Write-Section -Text "Fix missing Power Plans"
    Write-Caption -Text "Restoring default Power Plans..."
    powercfg -RestoreDefaultSchemes

    Write-Section -Text "Fix MS Store"
    Write-Caption -Text "Running wsreset..."
    Start-Process wsreset -NoNewWindow | Out-Host

    Write-Section -Text "Fix Windows Taskbar"
    Write-Caption -Text "Restoring Windows Taskbar DLL links..."
    Start-Process -FilePath "$env:SystemRoot\System32\Regsvr32.exe" -ArgumentList "/s $env:SystemRoot\System32\msimtf.dll" | Out-Host
    Start-Process -FilePath "$env:SystemRoot\System32\Regsvr32.exe" -ArgumentList "/s $env:SystemRoot\System32\msctf.dll" | Out-Host
    Start-Process -Verb RunAs "$env:SystemRoot\System32\ctfmon.exe" | Out-Host

    Write-Section -Text "Remove 'Test Mode' Watermark"
    Write-Caption -Text "Disabling TestSigning on bcdedit..."
    bcdedit -set TESTSIGNING OFF | Out-Host

    Write-Section -Text "Remove BITS stuck jobs"
    Write-Caption -Text "Removing all BITS transfers..."
    Get-BitsTransfer | Remove-BitsTransfer

    Write-Section -Text "Fix Windows Registry and Image"
    Write-Caption -Text "Running SFC repair (This may take some time)..."
    SFC -ScanNow | Out-Host
    Write-Caption -Text "Running DISM repair (This may take some time)..."
    DISM -Online -CleanUp-Image -RestoreHealth | Out-Host

    Write-Section -Text "Re-register all your apps"
    Write-Caption -Text "Closing Windows Explorer..."
    taskkill /F /IM explorer.exe
    Write-Caption -Text "Re-registering all Windows Apps via AppXManifest.xml ..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableXamlStartMenu" -Type Dword -Value 0
    Get-AppxPackage -AllUsers | ForEach-Object {
        Write-Status -Types "@" -Status "Trying to register package: $($_.InstallLocation)"
        Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
    }
    Write-Caption -Text "Restarting Windows Explorer..."
    Start-Process explorer

    Write-Section -Text "Solving Network problems"
    Write-Caption -Text "Resetting IPv4 and IPv6 addresses..."
    Write-Status -Types "?" -Status "Your internet may fall during the process, please be patient..." -Warning
    ipconfig -Release | Out-Host
    ipconfig -Release6 | Out-Host
    Write-Caption -Text "Renewing IPv4 address..."
    Write-Status -Types "?" -Status "This may take time, please be patient..." -Warning
    ipconfig -Renew *Ethernet* | Out-Host
    Write-Caption -Text "Renewing IPv6 address..."
    ipconfig -Renew6 *Ethernet* | Out-Host

    Write-Caption -Text "Flushing DNS..."
    ipconfig -FlushDns | Out-Host

    Write-Caption -Text "Resetting Winsock..."
    netsh winsock reset | Out-Host
}

function Main() {
    Repair-System
}

Main
