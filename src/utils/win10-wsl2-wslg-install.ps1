Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"get-os-info.psm1"

function WSLwithGraphicsInstall() {
    $OSArchList = Get-OSArchitecture

    If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
        # 1607 needs developer mode to be enabled for older Windows 10 versions
        Write-Host "[+] Enabling Development mode w/out license and trusted apps (Win10 1607)"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
    }

    Write-Host "[+][Features] Installing Microsoft-Windows-Subsystem-Linux..."
    Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart
    Write-Host "[+][Features] Installing VirtualMachinePlatform..."
    Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart

    foreach ($OSArch in $OSArchList) {
        if ($OSArch -like "x64" -or "arm64") {
            $WSLDownload = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_$OSArch.msi"
            $GitWSLgAsset = Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/microsoft/wslg/releases/latest" | ForEach-Object assets | Where-Object name -like "*$OSArch*.msi"
        }
        Else {
            Write-Warning "[?] $OSArch is NOT supported! But trying anyway..."
            $WSLDownload = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_$OSArch.msi"
            $GitWSLgAsset = Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/microsoft/wslg/releases/latest" | ForEach-Object assets | Where-Object name -like "*$OSArch*.msi"
        }
        $WSLOutput = "$PSScriptRoot\..\tmp\wsl_update.msi"

        Write-Host "[+] Downloading and Installing WSL 2 update ($OSArch) from: $WSLDownload"
        Invoke-WebRequest -Uri $WSLDownload -OutFile $WSLOutput
        Start-Process -FilePath $WSLOutput -ArgumentList "/passive" -Wait
        Remove-Item -Path $WSLOutput

        wsl --set-default-version 2 | Out-Host

        $WSLgDownload = $GitWSLgAsset.browser_download_url
        $WSLgOutput = "$PSScriptRoot\..\tmp\wsl_graphics_support.msi"

        Write-Host "[+] Downloading and Installing WSL Graphics update ($OSArch) from: $WSLgDownload"
        Invoke-WebRequest -Uri $WSLgDownload -OutFile $WSLgOutput
        Start-Process -FilePath $WSLgOutput -ArgumentList "/passive" -Wait
        Remove-Item -Path $WSLgOutput

        Write-Host "[@] Updating WSL (if possible)..."
        wsl --update
    }
}

function Main() {
    WSLwithGraphicsInstall
}

Main