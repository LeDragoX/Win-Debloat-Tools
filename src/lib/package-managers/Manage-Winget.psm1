Import-Module -DisableNameChecking "$PSScriptRoot\Install-PackageManager.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\Manage-DailyUpgradeJob.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\Get-HardwareInfo.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\Get-TempScriptFolder.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\Request-FileDownload.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\ui\Show-MessageDialog.psm1"

# Adapted from: https://github.com/ChrisTitusTech/win10script/blob/master/win10debloat.ps1
# Adapted from: https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/utils/install-basic-software.ps1

$Script:DoneTitle = "Information"
$Script:DoneMessage = "Process Completed!"

function Install-Winget() {
    [CmdletBinding()]
    param (
        [Switch] $Force
    )

    Begin {
        $WingetParams = @{
            Name                = "Winget"
            CheckExistenceBlock = { winget --version }
            InstallCommandBlock =
            {
                New-Item -Path "$(Get-TempScriptFolder)\downloads\" -Name "winget-install" -ItemType Directory -Force | Out-Null
                Push-Location -Path "$(Get-TempScriptFolder)\downloads\winget-install\"
                Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
                Install-Script -Name winget-install -Force
                winget-install.ps1
                Pop-Location
                Remove-Item -Path "$(Get-TempScriptFolder)\downloads\winget-install\"
            }
        }

        $WingetParams2 = @{
            Name                = "Winget (Method 2)"
            CheckExistenceBlock = { winget --version }
            InstallCommandBlock =
            {
                $WingetDepOutput = Install-WingetDependency
                $WingetOutput = Get-APIFile -URI "https://api.github.com/repos/microsoft/winget-cli/releases/latest" -ObjectProperty "assets" -FileNameLike "*.msixbundle" -PropertyValue "browser_download_url" -OutputFile "Microsoft.DesktopAppInstaller.msixbundle"
                $AppName = Split-Path -Path $WingetOutput -Leaf

                Try {
                    # Method from: https://github.com/microsoft/winget-cli/blob/master/doc/troubleshooting/README.md#machine-wide-provisioning
                    If ($WingetDepOutput) {
                        Write-Status -Types "@" -Status "Trying to install the App (w/ dependency): $AppName" -Warning
                        $InstallPackageCommand = { Add-AppxProvisionedPackage -Online -PackagePath $WingetOutput -SkipLicense -DependencyPackagePath $WingetDepOutput | Out-Null }
                        Invoke-Expression "$InstallPackageCommand"
                    }

                    Write-Status -Types "@" -Status "Trying to install the App (no dependency): $AppName" -Warning
                    $InstallPackageCommand = { Add-AppxProvisionedPackage -Online -PackagePath $WingetOutput -SkipLicense | Out-Null }
                    Invoke-Expression "$InstallPackageCommand"
                } Catch {
                    Write-Status -Types "@" -Status "Couldn't install '$AppName' automatically, trying to install the App manually..." -Warning
                    Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1" -Wait # GUI App installer can't install itself
                }

                Remove-Item -Path $WingetOutput
                Remove-Item -Path $WingetDepOutput
            }
        }
    }

    Process {
        If ($Force) {
            # Install Winget on Windows (Method 1)
            Install-PackageManager -PackageManagerFullName $WingetParams.Name -CheckExistenceBlock $WingetParams.CheckExistenceBlock -InstallCommandBlock $WingetParams.InstallCommandBlock -Force
            # Install Winget on Windows (Method 2)
        } Else {
            # Install Winget on Windows (Method 1)
            Install-PackageManager -PackageManagerFullName $WingetParams.Name -CheckExistenceBlock $WingetParams.CheckExistenceBlock -InstallCommandBlock $WingetParams.InstallCommandBlock
            # Install Winget on Windows (Method 2)
        }

        Install-PackageManager -PackageManagerFullName $WingetParams2.Name -CheckExistenceBlock $WingetParams2.CheckExistenceBlock -InstallCommandBlock $WingetParams2.InstallCommandBlock

        If (!$Force) {
            Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
        }
    }
}

function Install-WingetDependency() {
    # Dependency for Winget: https://docs.microsoft.com/en-us/troubleshoot/developer/visualstudio/cpp/libraries/c-runtime-packages-desktop-bridge#how-to-install-and-update-desktop-framework-packages
    $OSArchList = Get-OSArchitecture

    ForEach ($OSArch in $OSArchList) {
        If ($OSArch -like "x64" -or "x86" -or "arm64" -or "arm") {
            $WingetDepOutput = Request-FileDownload -FileURI "https://aka.ms/Microsoft.VCLibs.$OSArch.14.00.Desktop.appx" -OutputFile "Microsoft.VCLibs.14.00.Desktop.appx"
            $AppName = Split-Path -Path $WingetDepOutput -Leaf

            Try {
                Write-Status -Types "@" -Status "Trying to install the App: $AppName" -Warning
                $InstallPackageCommand = { Add-AppxPackage -Path $WingetDepOutput }
                Invoke-Expression "$InstallPackageCommand"
                If ($LASTEXITCODE) { Throw "Couldn't install automatically" }
            } Catch {
                Write-Status -Types "@" -Status "Couldn't install '$AppName' automatically, trying to install the App manually..." -Warning
                Start-Process -FilePath $WingetDepOutput
                $AppInstallerId = (Get-Process AppInstaller).Id
                Wait-Process -Id $AppInstallerId
            }

            Return $WingetDepOutput
        } Else {
            Write-Status -Types "?" -Status "$OSArch is not supported!" -Warning
        }
    }

    Return $false
}

function Register-WingetDailyUpgrade() {
    Begin {
        $WingetJobParams = @{
            Name              = "Winget"
            Time              = "12:00"
            UpdateScriptBlock =
            {
                Remove-Item -Path "$env:TEMP\Win-Debloat-Tools\logs\*" -Include "WingetDailyUpgrade_*.log"
                Start-Transcript -Path "$env:TEMP\Win-Debloat-Tools\logs\WingetDailyUpgrade_$(Get-Date -Format "yyyy-MM-dd_HH-mm-ss").log"
                Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force # Only needed to run Winget
                winget source update --disable-interactivity | Out-Host
                winget upgrade --all --silent | Out-Host
                Stop-Transcript
            }
        }
    }

    Process {
        Register-DailyUpgradeJob -PackageManagerFullName $WingetJobParams.Name -Time $WingetJobParams.Time -UpdateScriptBlock $WingetJobParams.UpdateScriptBlock
        Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
    }
}

function Unregister-WingetDailyUpgrade() {
    Begin {
        $JobName = "Winget Daily Upgrade"
    }

    Process {
        Unregister-DailyUpgradeJob -Name $JobName
        Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
    }
}
