Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Install-Software() {
    [CmdletBinding()]
    param (
        [String]      $Name,
        [Array]       $Packages,
        [ScriptBlock] $InstallBlock = { winget install --silent --source "winget" --id $Package },
        [Parameter(Mandatory = $false)]
        [Switch]      $NoDialog
    )

    $DoneTitle = "Information"
    $DoneMessage = "$Name installed successfully!"

    Clear-Host
    Write-Title "Installing: $($Name)"

    ForEach ($Package in $Packages) {
        $Private:Counter = Write-TitleCounter -Text "Installing: $Package" -Counter $Counter -MaxLength $Packages.Length
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
Install-Software -Name "Multiple Packages" -Packages @("Package1", "Package2", "Package3", ...) -InstallBlock { choco install -y $Package }
#>