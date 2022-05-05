Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Remove-UWPAppsList() {
    [CmdletBinding()]
    param (
        [Array] $Apps
    )
    $TweakType = "UWP"

    ForEach ($Bloat in $Apps) {
        If ((Get-AppxPackage -AllUsers -Name $Bloat) -or (Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat)) {
            Write-Status -Symbol "-" -Type $TweakType -Status "Trying to remove $Bloat from ALL users ..."
            Get-AppxPackage -AllUsers -Name $Bloat | Remove-AppxPackage # App
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online -AllUsers # Payload
        }
        Else {
            Write-Status -Symbol "?" -Type $TweakType -Status "$Bloat was already removed or not found ..." -Warning
        }
    }
}

<#
Example:
Remove-UWPAppsList -Apps "AppX1"
Remove-UWPAppsList -Apps @("AppX1", "AppX2", "AppX3")
#>