Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"check-os-info.psm1"

function Main() {

    $OSArch = CheckOSArchitecture

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


    Write-Host "[+] Downloading and Installing WSL 2 update ($OSArch)..."
    if ($OSArch -like "64-bits") {
        $WSLDownload = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    }
    ElseIf ($Architecture -like "ARM64") {
        $WSLDownload = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_arm64.msi"
    }
    Else {
        Write-Warning "[?] $OSArch is not supported!"
    }

    $WSLOutput = "$PSScriptRoot\..\tmp\wsl_update.msi"

    Invoke-WebRequest -Uri $WSLDownload -OutFile $WSLOutput
    Start-Process -FilePath $WSLOutput -ArgumentList "/passive" -Wait
    Remove-Item -Path $WSLOutput

    wsl --set-default-version 2 | Out-Host

}

Main