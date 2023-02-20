Import-Module -DisableNameChecking $PSScriptRoot\..\"title-templates.psm1"

function Set-CapabilityState() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Array] $Capabilities,
        [Parameter(Mandatory = $true)]
        [ValidateSet('Disabled', 'Enabled')]
        [String] $State
    )

    Begin {
        $Script:TweakType = "Capability"
    }

    Process {
        ForEach ($Capability in $Capabilities) {
            If (!(Get-WindowsCapability -Online -Name $Capability).Name) {
                Write-Status -Types "?", $TweakType -Status "The $Capability capability was not found." -Warning
                Continue
            }

            If ($State -eq 'Disabled') {
                Write-Status -Types "-", $TweakType -Status "Uninstalling the $((Get-WindowsCapability -Online -Name $Capability).Name) capability..."
                Get-WindowsCapability -Online | Where-Object Name -Like "$Capability" | Remove-WindowsCapability -Online
            } ElseIf ($State -eq 'Enabled') {
                Write-Status -Types "+", $TweakType -Status "Installing the $((Get-WindowsCapability -Online -Name $Capability).Name) capability..."
                Get-WindowsCapability -Online | Where-Object Name -Like "$Capability" | Add-WindowsCapability -Online
            }
        }
    }
}
