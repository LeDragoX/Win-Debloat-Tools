Import-Module -DisableNameChecking $PSScriptRoot\..\"title-templates.psm1"

function Set-CapabilityState() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Disabled', 'Enabled')]
        [String] $State,
        [Parameter(Mandatory = $true)]
        [Array] $Capabilities
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
                Write-Status -Types "-", $TweakType -Status "Uninstalling the $Capability ($((Get-WindowsCapability -Online -Name $Capability).DisplayName)) capability..."
                Get-WindowsCapability -Online -Name "$Capability" | Where-Object State -eq "Installed" | Remove-WindowsCapability -Online
            } ElseIf ($State -eq 'Enabled') {
                Write-Status -Types "+", $TweakType -Status "Installing the $Capability ($((Get-WindowsCapability -Online -Name $Capability).DisplayName)) capability..."
                Get-WindowsCapability -Online -Name "$Capability" | Where-Object State -eq "NotPresent" | Add-WindowsCapability -Online
            }
        }
    }
}

<#
Set-CapabilityState -State Disabled -Capabilities "Capability*"
Set-CapabilityState -State Disabled -Capabilities @("Capability1", "Capability2")
Set-CapabilityState -State Enabled -Capabilities @("Capability1", "Capability*")
#>
