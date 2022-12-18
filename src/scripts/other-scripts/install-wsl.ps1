Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"download-web-file.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"get-hardware-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"manage-software.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"set-windows-feature-state.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"title-templates.psm1"

function Install-WSL() {
    [CmdletBinding()] param()
    $TweakType = "WSL"

    Write-Status -Types "+", $TweakType -Status "Enabling Install updates to other Microsoft products (auto-update WSL and other products)..."
    # [@] (0 = Do not install updates to other Microsoft products , 1 = Install updates to other Microsoft products)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AllowMUUpdateService" -Type DWord -Value 1

    If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
        # 1607 needs developer mode to be enabled for older Windows 10 versions
        Write-Status -Types "+", $TweakType -Status "Enabling Development mode w/out license and trusted apps (Win 10 1607)"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
    }

    Set-OptionalFeatureState -Enabled -OptionalFeatures @("VirtualMachinePlatform", "HypervisorPlatform") # VM Platform / Hypervisor Platform from Windows

    Try {
        Write-Status -Types "?", $TweakType "Installing WSL from MS Store..." -Warning
        $CheckExistenceBlock = (Install-Software -Name "WSL" -Packages "9P9TQF7MRM4R" -ViaMSStore -NoDialog)
        Invoke-Expression "$CheckExistenceBlock" | Out-Host
        If ($LASTEXITCODE) { Throw "Couldn't install WSL" } # 0 = False, 1 = True

        Set-OptionalFeatureState -Disabled -OptionalFeatures @("Microsoft-Windows-Subsystem-Linux") # WSL (Old)
    } Catch {
        Write-Status -Types "?", $TweakType -Status "Couldn't install WSL..." -Warning
    }

    Write-Status -Types "@", $TweakType -Status "Updating WSL (if possible)..."
    Install-WSLTwo
    wsl --update | Out-Host
}

function Install-WSLTwo() {
    [CmdletBinding()] param()
    $OSArchList = Get-OSArchitecture

    Set-OptionalFeatureState -Enabled -OptionalFeatures @("Microsoft-Windows-Subsystem-Linux") # WSL (VT-d (Intel) or SVM (AMD) need to be enabled on BIOS)

    ForEach ($OSArch in $OSArchList) {
        If ($OSArch -like "x64" -or "arm64") {
            $WSLOutput = Request-FileDownload -FileURI "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_$OSArch.msi" -OutputFile "wsl_update.msi"
            Write-Status -Types "+", $TweakType -Status "Installing WSL Update ($OSArch)..."
            Start-Process -FilePath $WSLOutput -ArgumentList "/passive" -Wait
            Remove-Item -Path $WSLOutput

            wsl --set-default-version 2 | Out-Host
        } Else {
            Write-Status -Types "?", $TweakType -Status "$OSArch is NOT supported!" -Warning
            Break
        }
    }
}

Install-WSL
