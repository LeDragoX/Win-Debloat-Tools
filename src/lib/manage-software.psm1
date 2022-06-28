Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Install-Software() {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [String]      $Name,
        [Array]       $Packages,
        [ScriptBlock] $InstallBlock = { winget install --silent --source "winget" --id $Package },
        [Parameter(Mandatory = $false)]
        [Switch]      $NoDialog,
        [String]      $PkgMngr = 'Winget',
        [Switch]      $ViaChocolatey,
        [Switch]      $ViaMSStore,
        [Switch]      $ViaWSL
    )

    $DoneTitle = "Information"
    $DoneMessage = "$Name installed successfully!"

    If ($ViaChocolatey) {
        $ViaMSStore, $ViaWSL = $false, $false
        $PkgMngr = 'Chocolatey'
        $InstallBlock = { choco install --ignore-dependencies --yes $Package }
        Write-Status -Types "?" -Status "Chocolatey is configured to ignore dependencies (bloat), you may need to install it before using any program." -Warning
    }

    If ($ViaMSStore) {
        $ViaChocolatey, $ViaWSL = $false, $false
        $PkgMngr = 'Winget (MS Store)'
        $InstallBlock = { winget install --source "msstore" --id $Package --accept-package-agreements }
    }

    If ($ViaWSL) {
        $ViaChocolatey, $ViaMSStore = $false, $false
        $PkgMngr = 'WSL'
        $InstallBlock = { wsl --install --distribution $Package }
    }

    Write-Title "Installing $($Name) via $PkgMngr"
    $DoneMessage += "`n`nInstalled via $PkgMngr`:`n"

    ForEach ($Package in $Packages) {
        If ($ViaMSStore) {
            Write-Status -Types "?" -Status "Reminder: Press 'Y' and ENTER to continue if stuck (1st time only) ..." -Warning
            $PackageName = (winget search --source 'msstore' --exact $Package)[-1].Replace("$Package Unknown", '').Trim(' ')
            $Private:Counter = Write-TitleCounter -Text "$Package - $PackageName" -Counter $Counter -MaxLength $Packages.Length
        } Else {
            $Private:Counter = Write-TitleCounter -Text "$Package" -Counter $Counter -MaxLength $Packages.Length
        }

        Try {
            Invoke-Expression "$InstallBlock" | Out-Host
            If (($LASTEXITCODE)) { throw $Err } # 0 = False, 1 = True

            If ($ViaMSStore) {
                $DoneMessage += " + $PackageName ($Package)`n"
            } Else {
                $DoneMessage += " + $Package`n"
            }
        } Catch {
            Write-Status -Types "!" -Status "Failed to install package via $PkgMngr" -Warning

            If ($ViaMSStore) {
                Start-Process "ms-windows-store://pdp/?ProductId=$Package"
                $DoneMessage += "[!] $PackageName ($Package)`n"
            } Else {
                $DoneMessage += "[!] $Package`n"
            }
        }
    }

    Write-Host "$DoneMessage" -ForegroundColor Cyan

    If (!($NoDialog)) {
        Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
    }

    return $DoneMessage
}

function Uninstall-Software() {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [String]      $Name,
        [Array]       $Packages,
        [ScriptBlock] $UninstallBlock = { winget uninstall --source "winget" --id $Package },
        [Parameter(Mandatory = $false)]
        [Switch]      $NoDialog,
        [String]      $PkgMngr = 'Winget',
        [Switch]      $ViaChocolatey,
        [Switch]      $ViaMSStore,
        [Switch]      $ViaWSL
    )

    $DoneTitle = "Information"
    $DoneMessage = "$Name uninstalled successfully!"

    If ($ViaChocolatey) {
        $ViaMSStore, $ViaWSL = $false, $false
        $PkgMngr = 'Chocolatey'
        $UninstallBlock = { choco uninstall --remove-dependencies --yes $Package }
        Write-Status -Types "?" -Status "Chocolatey is configured to remove dependencies (bloat), you may need to install it before using any program." -Warning
    }

    If ($ViaMSStore) {
        $ViaChocolatey, $ViaWSL = $false, $false
        $PkgMngr = 'Winget (MS Store)'
        $UninstallBlock = { winget uninstall --source "msstore" --id $Package }
    }

    If ($ViaWSL) {
        $ViaChocolatey, $ViaMSStore = $false, $false
        $PkgMngr = 'WSL'
        $UninstallBlock = { wsl --unregister $Package }
    }

    Write-Title "Uninstalling $($Name) via $PkgMngr"
    $DoneMessage += "`n`nUninstalled via $PkgMngr`:`n"

    ForEach ($Package in $Packages) {
        If ($ViaMSStore) {
            $PackageName = (winget search --source 'msstore' --exact $Package)[-1].Replace("$Package Unknown", '').Trim(' ')
            $Private:Counter = Write-TitleCounter -Text "$Package - $PackageName" -Counter $Counter -MaxLength $Packages.Length
        } Else {
            $Private:Counter = Write-TitleCounter -Text "$Package" -Counter $Counter -MaxLength $Packages.Length
        }

        Try {
            Invoke-Expression "$UninstallBlock" | Out-Host
            If (($LASTEXITCODE)) { throw $Err } # 0 = False, 1 = True

            If ($ViaMSStore) {
                $DoneMessage += " - $PackageName ($Package)`n"
            } Else {
                $DoneMessage += " - $Package`n"
            }
        } Catch {
            Write-Status -Types "!" -Status "Failed to uninstall package via $PkgMngr" -Warning

            If ($ViaMSStore) {
                $DoneMessage += "[!] $PackageName ($Package)`n"
            } Else {
                $DoneMessage += "[!] $Package`n"
            }
        }
    }

    Write-Host "$DoneMessage" -ForegroundColor Cyan

    If (!($NoDialog)) {
        Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
    }

    return $DoneMessage
}

<#
Example:
Install-Software -Name "Brave Browser" -Packages "BraveSoftware.BraveBrowser"
Install-Software -Name "Brave Browser" -Packages "BraveSoftware.BraveBrowser" -NoDialog
Install-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -ViaChocolatey
Install-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -ViaChocolatey -NoDialog
Install-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -ViaMSStore
Install-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -ViaMSStore -NoDialog
Install-Software -Name "Ubuntu" -Packages "Ubuntu" -ViaWSL
Install-Software -Name "Ubuntu" -Packages "Ubuntu" -ViaWSL -NoDialog

Uninstall-Software -Name "Brave Browser" -Packages "BraveSoftware.BraveBrowser"
Uninstall-Software -Name "Brave Browser" -Packages "BraveSoftware.BraveBrowser" -NoDialog
Uninstall-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -ViaChocolatey
Uninstall-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -ViaChocolatey -NoDialog
Uninstall-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -ViaMSStore
Uninstall-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -ViaMSStore -NoDialog
Uninstall-Software -Name "Ubuntu" -Packages "Ubuntu" -ViaWSL
Uninstall-Software -Name "Ubuntu" -Packages "Ubuntu" -ViaWSL -NoDialog
#>
