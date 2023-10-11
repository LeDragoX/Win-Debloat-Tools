Import-Module -DisableNameChecking "$PSScriptRoot\Manage-Chocolatey.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\Manage-Winget.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\Open-File.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\ui\Show-MessageDialog.psm1"

function Install-Software() {
    [CmdletBinding()]
    [OutputType([ScriptBlock])]
    param (
        [Parameter(Position = 0, Mandatory)]
        [String]      $Name,
        [Parameter(Position = 1, Mandatory)]
        [String[]]    $Packages,
        [Parameter(Position = 2)]
        [ValidateSet('Winget', 'MsStore', 'Chocolatey', 'WSL')]
        [String]      $PackageProvider = 'Winget',
        [Parameter(Position = 3)]
        [ScriptBlock] $InstallBlock = { winget install --exact $Package --accept-source-agreements --accept-package-agreements --silent },
        [Switch]      $NoDialog
    )

    [ScriptBlock] $CheckVersionCommand
    [String]      $Script:DoneTitle = "Information"
    [String]      $Script:DoneMessage = "$Name installed successfully!"

    If ($PackageProvider -in @('Winget', 'MsStore')) {
        $CheckVersionCommand = { winget --version }
    }

    If ($PackageProvider -eq 'Chocolatey') {
        $CheckVersionCommand = { choco --version }
        $InstallBlock = { choco install --ignore-dependencies --yes $Package }
        Write-Status -Types "?" -Status "Chocolatey is configured to ignore dependencies (bloat), you may need to install it before using any program." -Warning
    }

    If ($PackageProvider -eq 'WSL') {
        $CheckVersionCommand = { wsl --version }
        $InstallBlock = { wsl --install --distribution $Package }
    }

    Try {
        $Err = (Invoke-Expression "$CheckVersionCommand")
        If (($LASTEXITCODE)) { throw $Err } # 0 = False, 1 = True
        Write-Status -Types "?", $PackageProvider -Status "$PackageProvider is already installed." -Warning
    } Catch {
        If ($PackageProvider -in @('Winget', 'MsStore')) {
            Install-Winget -Force
        }
        If ($PackageProvider -in @('Chocolatey')) {
            Install-Chocolatey -Force
        }
        If ($PackageProvider -in @('WSL')) {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("Install-WSL.ps1") -NoDialog
        }
    }

    Write-Title "Installing $($Name) via $PackageProvider"
    $DoneMessage += "`n`nInstalled via $PackageProvider`:`n"

    ForEach ($Package in $Packages) {
        If ($PackageProvider -eq 'MsStore') {
            Write-Status -Types "?" -Status "Reminder: Press 'Y' and ENTER to continue if stuck (1st time only) ..." -Warning
            $PackageName = (winget search --source 'msstore' --exact $Package)[-1].Replace("$Package Unknown", '').Trim(' ')
            $Private:Counter = Write-TitleCounter "$Package - $PackageName" -Counter $Counter -MaxLength $Packages.Length
        } Else {
            $Private:Counter = Write-TitleCounter "$Package" -Counter $Counter -MaxLength $Packages.Length
        }

        Try {
            Invoke-Expression "$InstallBlock" | Out-Host
            If (($LASTEXITCODE)) { throw "Couldn't install package." } # 0 = False, 1 = True

            If ($PackageProvider -eq 'MsStore') {
                $DoneMessage += "+ $PackageName ($Package)`n"
            } Else {
                $DoneMessage += "+ $Package`n"
            }
        } Catch {
            Write-Status -Types "!" -Status "Failed to install package via $PackageProvider" -Warning

            If ($PackageProvider -eq 'MsStore') {
                Start-Process "ms-windows-store://pdp/?ProductId=$Package"
                $DoneMessage += "! $PackageName ($Package)`n"
            } Else {
                $DoneMessage += "! $Package`n"
            }
        }
    }

    Write-Host "$DoneMessage" -ForegroundColor Cyan

    If (!($NoDialog)) {
        Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
    }

    return $DoneMessage
}

function Uninstall-Software() {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Position = 0, Mandatory)]
        [String]      $Name,
        [Parameter(Position = 1, Mandatory)]
        [String[]]    $Packages,
        [Parameter(Position = 2)]
        [ValidateSet('Winget', 'MsStore', 'Chocolatey', 'WSL')]
        [String]      $PackageProvider = 'Winget',
        [Parameter(Position = 3)]
        [ScriptBlock] $UninstallBlock = { winget uninstall --exact $Package --accept-source-agreements --purge --silent },
        [Switch]      $NoDialog
    )

    $DoneTitle = "Information"
    $DoneMessage = "$Name uninstalled successfully!"

    If ($PackageProvider -eq 'Chocolatey') {
        $UninstallBlock = { choco uninstall --remove-dependencies --yes $Package }
        Write-Status -Types "?" -Status "Chocolatey is configured to remove dependencies (bloat), you may need to install it before using any program." -Warning
    }

    If ($PackageProvider -eq 'WSL') {
        $UninstallBlock = { wsl --unregister $Package }
    }

    Write-Title "Uninstalling $($Name) via $PackageProvider"
    $DoneMessage += "`n`nUninstalled via $PackageProvider`:`n"

    ForEach ($Package in $Packages) {
        If ($PackageProvider -eq 'MsStore') {
            $PackageName = (winget search --source 'msstore' --exact $Package)[-1].Replace("$Package Unknown", '').Trim(' ')
            $Private:Counter = Write-TitleCounter "$Package - $PackageName" -Counter $Counter -MaxLength $Packages.Length
        } Else {
            $Private:Counter = Write-TitleCounter "$Package" -Counter $Counter -MaxLength $Packages.Length
        }

        Try {
            Invoke-Expression "$UninstallBlock" | Out-Host
            If (($LASTEXITCODE)) { throw "Couldn't uninstall package." } # 0 = False, 1 = True

            If ($PackageProvider -eq 'MsStore') {
                $DoneMessage += "- $PackageName ($Package)`n"
            } Else {
                $DoneMessage += "- $Package`n"
            }
        } Catch {
            Write-Status -Types "!" -Status "Failed to uninstall package via $PackageProvider" -Warning

            If ($PackageProvider -eq 'MsStore') {
                $DoneMessage += "! $PackageName ($Package)`n"
            } Else {
                $DoneMessage += "! $Package`n"
            }
        }
    }

    Write-Host "$DoneMessage" -ForegroundColor Cyan

    If (!($NoDialog)) {
        Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
    }

    return $DoneMessage
}

<#
Example:
Install-Software -Name "Brave Browser" -Packages "BraveSoftware.BraveBrowser"
Install-Software -Name "Brave Browser" -Packages "BraveSoftware.BraveBrowser" -NoDialog
Install-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -PackageProvider 'Chocolatey'
Install-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -PackageProvider 'Chocolatey' -NoDialog
Install-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -PackageProvider 'MsStore'
Install-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -PackageProvider 'MsStore' -NoDialog
Install-Software -Name "Ubuntu" -Packages "Ubuntu" -PackageProvider 'WSL'
Install-Software -Name "Ubuntu" -Packages "Ubuntu" -PackageProvider 'WSL' -NoDialog

Uninstall-Software -Name "Brave Browser" -Packages "BraveSoftware.BraveBrowser"
Uninstall-Software -Name "Brave Browser" -Packages "BraveSoftware.BraveBrowser" -NoDialog
Uninstall-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -PackageProvider 'Chocolatey'
Uninstall-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -PackageProvider 'Chocolatey' -NoDialog
Uninstall-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -PackageProvider 'MsStore'
Uninstall-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -PackageProvider 'MsStore' -NoDialog
Uninstall-Software -Name "Ubuntu" -Packages "Ubuntu" -PackageProvider 'WSL'
Uninstall-Software -Name "Ubuntu" -Packages "Ubuntu" -PackageProvider 'WSL' -NoDialog
#>
