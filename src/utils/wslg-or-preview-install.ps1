Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"download-web-file.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"get-hardware-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"install-software.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Install-WSLPreview() {
    [CmdletBinding()] param()

    $TweakType = "WSL"

    Try {
        Write-Status -Symbol "?" -Type $TweakType "Installing WSL Preview from MS Store for Windows 11+ ..." -Warning
        Write-Host "[?] Press 'Y' and ENTER to continue if stuck (Winget bug) ..." -ForegroundColor Magenta -BackgroundColor Black
        $CheckExistenceBlock = { Install-Software -Name "WSL Preview (Win 11+)" -Packages "9P9TQF7MRM4R" -ViaMSStore -NoDialog }
        $err = $null
        $err = (Invoke-Expression "$CheckExistenceBlock") | Out-Host
        If (($LASTEXITCODE)) { throw $err } # 0 = False, 1 = True

        Write-Status -Symbol "-" -Type $TweakType -Status "Uninstalling WSL from Optional Features ..."
        Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" | Where-Object State -Like "Enabled" | Disable-WindowsOptionalFeature -Online -NoRestart
    }
    Catch {
        Write-Status -Symbol "?" -Type $TweakType -Status "Couldn't install WSL Preview, you must be at least on Windows 11 ..." -Warning
        Install-WSLTwoAndG
    }

    Write-Status -Symbol "@" -Type $TweakType -Status "Updating WSL (if possible) ..."
    wsl --update
}

function Install-WSLTwoAndG() {
    [CmdletBinding()] param()

    $OSArchList = Get-OSArchitecture

    If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
        # 1607 needs developer mode to be enabled for older Windows 10 versions
        Write-Status -Symbol "+" -Type $TweakType -Status "Enabling Development mode w/out license and trusted apps (Win 10 1607)"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
    }

    Write-Status -Symbol "+" -Type $TweakType -Status "Installing Microsoft-Windows-Subsystem-Linux..."
    Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart # WSL (VT-d (Intel) or SVM (AMD) need to be enabled on BIOS)
    Write-Status -Symbol "+" -Type $TweakType -Status "Installing VirtualMachinePlatform..."
    Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart # VM Platform
    Write-Status -Symbol "+" -Type $TweakType -Status "Installing HypervisorPlatform..."
    Get-WindowsOptionalFeature -Online -FeatureName "HypervisorPlatform" | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart # Hypervisor Platform from Windows

    ForEach ($OSArch in $OSArchList) {
        If ($OSArch -like "x64" -or "arm64") {
            $WSLOutput = Request-FileDownload -FileURI "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_$OSArch.msi" -OutputFile "wsl_update.msi"
            Write-Status -Symbol "+" -Type $TweakType -Status "Installing WSL Update ($OSArch)..."
            Start-Process -FilePath $WSLOutput -ArgumentList "/passive" -Wait
            Remove-Item -Path $WSLOutput

            wsl --set-default-version 2 | Out-Host

            $WSLgOutput = Get-APIFile -URI "https://api.github.com/repos/microsoft/wslg/releases/latest" -APIObjectContainer "assets" -FileNameLike "*$OSArch*.msi" -APIProperty "browser_download_url" -OutputFile "wsl_graphics_support.msi"
            Write-Status -Symbol "+" -Type $TweakType -Status "Installing WSL Graphics update (Insider only) ($OSArch)..."
            Start-Process -FilePath $WSLgOutput -ArgumentList "/passive" -Wait
            Remove-Item -Path $WSLgOutput
        }
        Else {
            Write-Status -Symbol "?" -Type $TweakType -Status "$OSArch is NOT supported!" -Warning
            Break
        }
    }
}

function Main {
    Install-WSLPreview
}

Main