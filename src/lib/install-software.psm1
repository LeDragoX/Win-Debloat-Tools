function Install-Software() {
    [CmdletBinding()]
    param (
        [String]      $Name,
        [Array]       $PackageName,
        [ScriptBlock] $InstallBlock = { winget install --silent --source "winget" --id $Package },
        [Parameter(Mandatory = $false)]
        [Switch]        $NoDialog
    )

    $DoneTitle = "Done"
    $DoneMessage = "$Name installed successfully!"

    Write-Host "==> Installing: $($Name)" -ForegroundColor Cyan
    # Avoiding a softlock only on the script that occurs if the APP is already installed on Microsoft Store (Blame Spotify)
    If ((Get-AppxPackage).Name -ilike "*$($Name)*") {
        Write-Host "==> $PackageName is already installed on MS Store!`nSkipping..." -ForegroundColor Cyan
    }
    Else {
        ForEach ($Package in $PackageName) {
            #Invoke-Expression "$InstallBlock" | Out-Host
        }
    }

    If (!($NoDialog)) {
        Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
    }
}

<#
Example:
Install-Software -Name "Brave Browser" -PackageName "BraveSoftware.BraveBrowser"
Install-Software -Name "Multiple Packages" -PackageName @("Package1", "Package2", "Package3", ...) -InstallBlock { choco install -y $Package }
#>