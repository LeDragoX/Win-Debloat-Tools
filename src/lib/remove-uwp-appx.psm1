Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Remove-UWPAppx() {
    [CmdletBinding()]
    param (
        [Array] $AppxPackages
    )
    $TweakType = "UWP"

    ForEach ($AppxPackage in $AppxPackages) {
        If ((Get-AppxPackage -AllUsers -Name $AppxPackage) -or (Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $AppxPackage)) {
            Write-Status -Types "-", $TweakType -Status "Trying to remove $AppxPackage from ALL users..."
            Get-AppxPackage -AllUsers -Name $AppxPackage | Remove-AppxPackage # App
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $AppxPackage | Remove-AppxProvisionedPackage -Online -AllUsers # Payload
        } Else {
            Write-Status -Types "?", $TweakType -Status "$AppxPackage was already removed or not found..." -Warning
        }
    }
}

<#
Example:
Remove-UWPAppx -AppxPackages "AppX1"
Remove-UWPAppx -AppxPackages @("AppX1", "AppX2", "AppX3")
#>
