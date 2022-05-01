Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://github.com/ChrisTitusTech/win10script/pull/131/files

function Optimize-WindowsFeaturesList() {
    [CmdletBinding()]
    param (
        [Switch] $Revert,
        [Array]  $EnableStatus = @(
            @{
                Symbol = "-"; Status = "Uninstalling";
                Command = { Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "Enabled" | Disable-WindowsOptionalFeature -Online -NoRestart }
            }
            @{
                Symbol = "+"; Status = "Installing";
                Command = { Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart }
            }
        )
    )
    $TweakType = "Feature"

    If (($Revert)) {
        Write-Status -Symbol "<" -Type $TweakType -Status "Reverting: $Revert." -Warning
        $EnableStatus = @(
            @{
                Symbol = "<"; Status = "Re-Installing";
                Command = { Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart }
            }
            @{
                Symbol = "<"; Status = "Re-Uninstalling";
                Command = { Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "Enabled" | Disable-WindowsOptionalFeature -Online -NoRestart }
            }
        )
    }

    Write-Title -Text "Uninstall features from Windows"

    $DisableFeatures = @(
        "FaxServicesClientPackage"             # Windows Fax and Scan
        "IIS-*"                                # Internet Information Services
        "LegacyComponents"                     # Legacy Components
        "MediaPlayback"                        # Media Features (Windows Media Player)
        "MicrosoftWindowsPowerShellV2"         # PowerShell 2.0
        "MicrosoftWindowsPowershellV2Root"     # PowerShell 2.0
        "Printing-PrintToPDFServices-Features" # Microsoft Print to PDF
        "Printing-XPSServices-Features"        # Microsoft XPS Document Writer
        "WorkFolders-Client"                   # Work Folders Client
    )
    ForEach ($Feature in $DisableFeatures) {
        If (Get-WindowsOptionalFeature -Online -FeatureName $Feature) {
            If (($Revert -eq $true) -and ($Feature -like "IIS-*")) {
                Write-Status -Symbol "?" -Type $TweakType -Status "Skipping $Feature to avoid a security vulnerability ..." -Warning
                Continue
            }
            Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) $Feature ..."
            Invoke-Expression "$($EnableStatus[0].Command)"
        }
        Else {
            Write-Status -Symbol "?" -Type $TweakType -Status "$Feature was not found." -Warning
        }
    }

    Write-Title -Text "Install features for Windows"

    $EnableFeatures = @(
        "NetFx3"                            # NET Framework 3.5
        "NetFx4-AdvSrvs"                    # NET Framework 4
        "NetFx4Extended-ASPNET45"           # NET Framework 4.x + ASPNET 4.x
    )

    ForEach ($Feature in $EnableFeatures) {
        If (Get-WindowsOptionalFeature -Online -FeatureName $Feature) {
            Write-Status -Symbol "+" -Type $TweakType -Status "Installing $Feature ..."
            Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart
        }
        Else {
            Write-Status -Symbol "?" -Type $TweakType -Status "$Feature was not found." -Warning
        }
    }
}

function Main() {
    # List all Optional Features: Get-WindowsOptionalFeature -Online | Select-Object -Property State, FeatureName | Sort-Object State, FeatureName | Out-GridView
    # List all Windows Packages: Get-WindowsPackage -Online | Select-Object -Property ReleaseType, PackageName, PackageState, InstallTime | Sort-Object ReleaseType, PackageState, PackageName | Out-GridView
    # List all Windows Capabilities: Get-WindowsCapability -Online | Select-Object -Property State, Name | Sort-Object State, Name | Out-GridView
    If (!($Revert)) {
        Optimize-WindowsFeaturesList # Disable useless features and Enable features claimed as Optional on Windows, but actually, they are useful
    }
    Else {
        Optimize-WindowsFeaturesList -Revert
    }
}

Main