# Adapted from this ChrisTitus script:  https://github.com/ChrisTitusTech/win10script

Function RunDebloatSoftwares() {
        
    if (!(Test-Path "$PSScriptRoot\..\tmp")) {
        Write-Host "[+] Folder $PSScriptRoot\..\tmp doesn't exist, creating..."
        mkdir "$PSScriptRoot\..\tmp" | Out-Null
    }

    Push-Location -Path "$PSScriptRoot\..\tmp"

    Write-Host "[+] Running AdwCleaner to do a Quick Virus/Adware Scan..."
    Invoke-WebRequest -Uri "https://downloads.malwarebytes.com/file/adwcleaner" -OutFile "adwcleaner.exe"
    Start-Process -FilePath ".\adwcleaner.exe" -ArgumentList "/eula", "/clean", "/noreboot" -Wait
    Remove-Item ".\adwcleaner.exe" -Force

    Pop-Location
    Push-Location -Path "$PSScriptRoot\..\lib\debloat-softwares\"
    Push-Location -Path "ShutUp10\"
    
    Write-Host "[+] Running ShutUp10 and applying Recommended settings..."
    Invoke-WebRequest -Uri "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -OutFile "OOSU10.exe"
    Start-Process -FilePath ".\OOSU10.exe" -ArgumentList "ooshutup10.cfg", "/quiet" -Wait   # Wait until the process closes
    Remove-Item "*.*" -Exclude "*.cfg" -Force                                               # Leave no traces
    
    Pop-Location
    Pop-Location
    
}

RunDebloatSoftwares # [AUTOMATED] ShutUp10 with personal configs and AdwCleaner for Virus Scanning.