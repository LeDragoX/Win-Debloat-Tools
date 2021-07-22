# Adapted from this ChrisTitus script:  https://github.com/ChrisTitusTech/win10script

Import-Module BitsTransfer # To enable file downloading

Function RunDebloatSoftwares {
        
    # If changing the programs folder move here!!!
    Push-Location -Path "..\lib\debloat-softwares\"

    Write-Host "[+] Running ShutUp10 and applying Recommended settings..."

    Push-Location -Path "ShutUp10\"

    Start-BitsTransfer -Source "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -Destination "OOSU10.exe"
    Start-Process -FilePath ".\OOSU10.exe" -ArgumentList "ooshutup10.cfg", "/quiet" -Wait   # Wait until the process closes
    Remove-Item "*.*" -Exclude "*.cfg" -Force                                               # Leave no traces
    
    Pop-Location

    Write-Host "[+] Running AdwCleaner to do a Quick Virus/Adware Scan..."
    Start-BitsTransfer -Source "https://downloads.malwarebytes.com/file/adwcleaner" -Destination "adwcleaner.exe"
    Start-Process -FilePath ".\adwcleaner.exe" -ArgumentList "/eula", "/clean", "/noreboot" -Wait
    Remove-Item ".\adwcleaner.exe" -Force

    Pop-Location
    
}

RunDebloatSoftwares # [AUTOMATED] ShutUp10 with personal configs and AdwCleaner for Virus Scanning.