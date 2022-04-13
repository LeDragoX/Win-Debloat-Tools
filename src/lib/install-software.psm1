Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Install-Software() {
    [CmdletBinding()]
    param (
        [String]      $Name,
        [Array]       $Packages,
        [ScriptBlock] $InstallBlock = { winget install --silent --source "winget" --id $Package },
        [Parameter(Mandatory = $false)]
        [Switch]      $NoDialog,
        [String]      $PkgMngr = 'Winget',
        [Switch]      $UseChocolatey,
        [Switch]      $UseMSStore,
        [Switch]      $UseWSL
    )

    $DoneTitle = "Information"
    $DoneMessage = "$Name installed successfully!"
    Clear-Host

    If ($UseChocolatey) {
        $UseMSStore, $UseWSL = $false, $false
        $PkgMngr = 'Chocolatey'
        $InstallBlock = { choco install --ignore-dependencies --yes $Package }
        Write-Host "[?] Chocolatey is configured to ignore dependencies (bloat), you may need to install it before using any program." -ForegroundColor Yellow -BackgroundColor Black
    }

    If ($UseMSStore) {
        $UseChocolatey, $UseWSL = $false, $false
        $PkgMngr = 'Winget (MS Store)'
        $InstallBlock = { winget install --source "msstore" --id $Package --accept-package-agreements }
    }

    If ($UseWSL) {
        $UseChocolatey, $UseMSStore = $false, $false
        $PkgMngr = 'WSL'
        $InstallBlock = { wsl --install --distribution $Package }
    }

    Write-Title "Installing $($Name) via $PkgMngr"
    $DoneMessage += "`n`nInstalled:`n"

    ForEach ($Package in $Packages) {
        If ($UseMSStore) {
            $PackageName = (winget search --source 'msstore' --exact $Package)[-1].Replace("$Package Unknown", '').Trim(' ')
            $DoneMessage += " - $PackageName ($Package)`n"
            $Private:Counter = Write-TitleCounter -Text "$Package - $PackageName" -Counter $Counter -MaxLength $Packages.Length
        }
        Else {
            $Private:Counter = Write-TitleCounter -Text "$Package" -Counter $Counter -MaxLength $Packages.Length
            $DoneMessage += " - $Package`n"
        }
        Invoke-Expression "$InstallBlock" | Out-Host
    }

    If (!($NoDialog)) {
        Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
    }
}

<#
Example:
Install-Software -Name "Brave Browser" -Packages "BraveSoftware.BraveBrowser"
Install-Software -Name "Brave Browser" -Packages "BraveSoftware.BraveBrowser" -NoDialog
Install-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -UseChocolatey
Install-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -UseChocolatey -NoDialog
Install-Software -Name "Ubuntu" -Packages "Ubuntu" -UseWSL
Install-Software -Name "Ubuntu" -Packages "Ubuntu" -UseWSL -NoDialog
#>