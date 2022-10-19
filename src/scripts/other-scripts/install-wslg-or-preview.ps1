Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"download-web-file.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"get-hardware-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"manage-software.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"set-windows-feature-state.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"title-templates.psm1"

function Install-WSLPreview() {
    [CmdletBinding()] param()

    $TweakType = "WSL"

    Write-Status -Types "+", $TweakType -Status "Enabling Install updates to other Microsoft products (auto-update WSL and other products)..."
    # [@] (0 = Do not install updates to other Microsoft products , 1 = Install updates to other Microsoft products)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AllowMUUpdateService" -Type DWord -Value 1

    Set-OptionalFeatureState -Enabled -OptionalFeatures @("VirtualMachinePlatform", "HypervisorPlatform") # VM Platform / Hypervisor Platform from Windows

    Try {
        Write-Status -Types "?", $TweakType "Installing WSL Preview from MS Store for Windows 11+..." -Warning
        $CheckExistenceBlock = (Install-Software -Name "WSL Preview (Win 11+)" -Packages "9P9TQF7MRM4R" -ViaMSStore -NoDialog)
        Invoke-Expression "$CheckExistenceBlock" | Out-Host
        If ($LASTEXITCODE) { Throw "This package is not available for Windows 10, you must be on Windows 11+" } # 0 = False, 1 = True

        Set-OptionalFeatureState -Disabled -OptionalFeatures @("Microsoft-Windows-Subsystem-Linux") # WSL (Old)
    } Catch {
        Write-Status -Types "?", $TweakType -Status "Couldn't install WSL Preview, you must be at least on Windows 11..." -Warning
        Install-WSLTwoAndG
    }

    Write-Status -Types "@", $TweakType -Status "Updating WSL (if possible)..."
    wsl --update | Out-Host
}

function Install-WSLTwoAndG() {
    [CmdletBinding()] param()

    $OSArchList = Get-OSArchitecture

    If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
        # 1607 needs developer mode to be enabled for older Windows 10 versions
        Write-Status -Types "+", $TweakType -Status "Enabling Development mode w/out license and trusted apps (Win 10 1607)"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
    }

    Set-OptionalFeatureState -Enabled -OptionalFeatures @("Microsoft-Windows-Subsystem-Linux") # WSL (VT-d (Intel) or SVM (AMD) need to be enabled on BIOS)

    ForEach ($OSArch in $OSArchList) {
        If ($OSArch -like "x64" -or "arm64") {
            $WSLOutput = Request-FileDownload -FileURI "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_$OSArch.msi" -OutputFile "wsl_update.msi"
            Write-Status -Types "+", $TweakType -Status "Installing WSL Update ($OSArch)..."
            Start-Process -FilePath $WSLOutput -ArgumentList "/passive" -Wait
            Remove-Item -Path $WSLOutput

            wsl --set-default-version 2 | Out-Host

            $WSLgOutput = Get-APIFile -URI "https://api.github.com/repos/microsoft/wslg/releases/latest" -ObjectProperty "assets" -FileNameLike "*$OSArch*.msi" -PropertyValue "browser_download_url" -OutputFile "wsl_graphics_support.msi"
            Write-Status -Types "+", $TweakType -Status "Installing WSL Graphics update (Insider only) ($OSArch)..."
            Start-Process -FilePath $WSLgOutput -ArgumentList "/passive" -Wait
            Remove-Item -Path $WSLgOutput
        } Else {
            Write-Status -Types "?", $TweakType -Status "$OSArch is NOT supported!" -Warning
            Break
        }
    }
}

Install-WSLPreview
