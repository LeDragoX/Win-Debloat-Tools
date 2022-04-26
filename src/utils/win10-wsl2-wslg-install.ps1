Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"download-web-file.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"get-hardware-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function WSLwithGraphicsInstall() {
    $OSArchList = Get-OSArchitecture

    If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
        # 1607 needs developer mode to be enabled for older Windows 10 versions
        Write-Host "[+] Enabling Development mode w/out license and trusted apps (Win 10 1607)"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
    }

    Write-Host "[+][Features] Installing Microsoft-Windows-Subsystem-Linux..."
    Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart
    Write-Host "[+][Features] Installing VirtualMachinePlatform..."
    Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart

    ForEach ($OSArch in $OSArchList) {
        If ($OSArch -like "x64" -or "arm64") {
            $WSLOutput = Request-FileDownload -FileURI "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_$OSArch.msi" -OutputFile "wsl_update.msi"
            Write-Host "[+] Installing WSL Update ($OSArch)..."
            Start-Process -FilePath $WSLOutput -ArgumentList "/passive" -Wait
            Remove-Item -Path $WSLOutput

            wsl --set-default-version 2 | Out-Host

            $WSLgOutput = Get-APIFile -URI "https://api.github.com/repos/microsoft/wslg/releases/latest" -APIObjectContainer "assets" -FileNameLike "*$OSArch*.msi" -APIProperty "browser_download_url" -OutputFile "wsl_graphics_support.msi"
            Write-Host "[+] Installing WSL Graphics update (Insider only) ($OSArch)..."
            Start-Process -FilePath $WSLgOutput -ArgumentList "/passive" -Wait
            Remove-Item -Path $WSLgOutput

            Write-Mandatory "Updating WSL (if possible)..."
            wsl --update
        }
        Else {
            Write-Host "[?] $OSArch is NOT supported!" -ForegroundColor Yellow -BackgroundColor Black
            Break
        }
    }
}

function Main() {
    WSLwithGraphicsInstall
}

Main