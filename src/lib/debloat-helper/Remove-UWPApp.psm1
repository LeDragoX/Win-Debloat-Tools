Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

function Remove-UWPApp() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [String[]] $AppxPackages
    )

    Begin {
        $Script:TweakType = "App"
    }

    Process {
        ForEach ($AppxPackage in $AppxPackages) {
            If (!((Get-AppxPackage -AllUsers -Name "$AppxPackage") -or (Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "$AppxPackage"))) {
                Write-Status -Types "?", $TweakType -Status "`"$AppxPackage`" was already removed or not found..." -Warning
                Continue
            }

            Write-Status -Types "-", $TweakType -Status "Trying to remove $AppxPackage from ALL users..."
            Get-AppxPackage -AllUsers -Name "$AppxPackage" | Remove-AppxPackage -AllUsers
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "$AppxPackage" | Remove-AppxProvisionedPackage -Online -AllUsers
        }
    }
}

<#
Example:
Remove-UWPApp -AppxPackages "AppX1"
Remove-UWPApp -AppxPackages @("AppX1", "AppX2", "AppX3")
#>
