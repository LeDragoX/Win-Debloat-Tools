Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

function Set-OptionalFeatureState() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [ValidateSet('Disabled', 'Enabled')]
        [String] $State,
        [Parameter(Position = 1, Mandatory)]
        [String[]] $OptionalFeatures,
        [String[]] $Filter
    )

    Begin {
        $Script:SecurityFilterOnEnable = @("IIS-*")
        $Script:TweakType = "OptionalFeature"
    }

    Process {
        ForEach ($OptionalFeature in $OptionalFeatures) {
            If (!(Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature)) {
                Write-Status -Types "?", $TweakType -Status "The `"$OptionalFeature`" optional feature was not found." -Warning
                Continue
            }

            If (($OptionalFeature -in $SecurityFilterOnEnable) -and ($State -eq 'Enabled')) {
                Write-Status -Types "?", $TweakType -Status "Skipping $OptionalFeature ($((Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature).DisplayName)) to avoid a security vulnerability..." -Warning
                Continue
            }

            If ($OptionalFeature -in $Filter) {
                Write-Status -Types "?", $TweakType -Status "The $OptionalFeature ($((Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature).DisplayName)) will be skipped as set on Filter..." -Warning
                Continue
            }

            If ($State -eq 'Disabled') {
                Write-Status -Types "-", $TweakType -Status "Uninstalling the $OptionalFeature ($((Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature).DisplayName)) optional feature..."
                Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature | Where-Object State -Like "Enabled" | Disable-WindowsOptionalFeature -Online -NoRestart -Remove
            } ElseIf ($State -eq 'Enabled') {
                Write-Status -Types "+", $TweakType -Status "Installing the $OptionalFeature ($((Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature).DisplayName)) optional feature..."
                Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart
            }
        }
    }
}

<#
Set-OptionalFeatureState -State Disabled -OptionalFeatures @("OptionalFeature1", "OptionalFeature2", "OptionalFeature3")
Set-OptionalFeatureState -State Disabled -OptionalFeatures @("OptionalFeature1", "OptionalFeature2", "OptionalFeature3") -Filter @("OptionalFeature3")
Set-OptionalFeatureState -State Disabled -OptionalFeatures @("OptionalFeature1", "OptionalFeature2", "OptionalFeature3") -Filter @("OptionalFeature3") -CustomMessage { "Uninstalling $OptionalFeature feature!"}

Set-OptionalFeatureState -State Enabled -OptionalFeatures @("OptionalFeature1", "OptionalFeature2", "OptionalFeature3")
Set-OptionalFeatureState -State Enabled -OptionalFeatures @("OptionalFeature1", "OptionalFeature2", "OptionalFeature3") -Filter @("OptionalFeature3")
Set-OptionalFeatureState -State Enabled -OptionalFeatures @("OptionalFeature1", "OptionalFeature2", "OptionalFeature3") -Filter @("OptionalFeature3") -CustomMessage { "Installing $OptionalFeature feature!"}
#>
