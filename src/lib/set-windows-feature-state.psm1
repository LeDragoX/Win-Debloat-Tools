Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Find-OptionalFeature() {
    [CmdletBinding()]
    [OutputType([Bool])]
    param (
        [Parameter(Mandatory = $true)]
        [String] $OptionalFeature
    )

    If (Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature) {
        return $true
    } Else {
        Write-Status -Types "?", $TweakType -Status "The $OptionalFeature optional feature was not found." -Warning
        return $false
    }
}

function Set-OptionalFeatureState() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Switch] $Disabled,
        [Parameter(Mandatory = $false)]
        [Switch] $Enabled,
        [Parameter(Mandatory = $true)]
        [Array] $OptionalFeatures,
        [Parameter(Mandatory = $false)]
        [Array] $Filter,
        [Parameter(Mandatory = $false)]
        [ScriptBlock] $CustomMessage
    )

    $Script:SecurityFilterOnEnable = @("IIS-*")
    $Script:TweakType = "OptionalFeature"

    ForEach ($OptionalFeature in $OptionalFeatures) {
        If (Find-OptionalFeature $OptionalFeature) {
            If (($OptionalFeature -in $SecurityFilterOnEnable) -and ($Enabled)) {
                Write-Status -Types "?", $TweakType -Status "Skipping $OptionalFeature ($((Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature).DisplayName)) to avoid a security vulnerability..." -Warning
                Continue
            }

            If ($OptionalFeature -in $Filter) {
                Write-Status -Types "?", $TweakType -Status "The $OptionalFeature ($((Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature).DisplayName)) will be skipped as set on Filter..." -Warning
                Continue
            }

            If (!$CustomMessage) {
                If ($Disabled) {
                    Write-Status -Types "-", $TweakType -Status "Uninstalling the $OptionalFeature ($((Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature).DisplayName)) optional feature..."
                } ElseIf ($Enabled) {
                    Write-Status -Types "+", $TweakType -Status "Installing the $OptionalFeature ($((Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature).DisplayName)) optional feature..."
                } Else {
                    Write-Status -Types "?", $TweakType -Status "No parameter received (valid params: -Disabled or -Enabled)" -Warning
                }
            } Else {
                Write-Status -Types "@", $TweakType -Status $(Invoke-Expression "$CustomMessage")
            }

            If ($Disabled) {
                Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature | Where-Object State -Like "Enabled" | Disable-WindowsOptionalFeature -Online -NoRestart
            } ElseIf ($Enabled) {
                Get-WindowsOptionalFeature -Online -FeatureName $OptionalFeature | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart
            }
        }
    }
}

<#
Set-OptionalFeatureState -Disabled -OptionalFeatures @("OptionalFeature1", "OptionalFeature2", "OptionalFeature3")
Set-OptionalFeatureState -Disabled -OptionalFeatures @("OptionalFeature1", "OptionalFeature2", "OptionalFeature3") -Filter @("OptionalFeature3")
Set-OptionalFeatureState -Disabled -OptionalFeatures @("OptionalFeature1", "OptionalFeature2", "OptionalFeature3") -Filter @("OptionalFeature3") -CustomMessage { "Uninstalling $OptionalFeature feature!"}

Set-OptionalFeatureState -Enabled -OptionalFeatures @("OptionalFeature1", "OptionalFeature2", "OptionalFeature3")
Set-OptionalFeatureState -Enabled -OptionalFeatures @("OptionalFeature1", "OptionalFeature2", "OptionalFeature3") -Filter @("OptionalFeature3")
Set-OptionalFeatureState -Enabled -OptionalFeatures @("OptionalFeature1", "OptionalFeature2", "OptionalFeature3") -Filter @("OptionalFeature3") -CustomMessage { "Installing $OptionalFeature feature!"}
#>
