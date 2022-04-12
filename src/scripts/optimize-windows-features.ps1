Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://github.com/ChrisTitusTech/win10script/pull/131/files

function Optimize-WindowsFeaturesList() {
    [CmdletBinding()]
    param (
        [Switch] $Revert,
        [Array]  $EnableStatus = @(
            "[-][Features] Uninstalling",
            "[+][Features] Installing"
        ),
        [Array]  $FeatureState = @(
            "Enabled",
            "Disabled*"
        ),
        [Array]  $Commands = @(
            { Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "$($FeatureState[0])" | Disable-WindowsOptionalFeature -Online -NoRestart },
            { Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "$($FeatureState[1])" | Enable-WindowsOptionalFeature -Online -NoRestart }
        )
    )

    If (($Revert)) {
        Write-Host "[<][Features] Reverting: $Revert." -ForegroundColor Yellow -BackgroundColor Black
        $EnableStatus = @(
            "[<][Features] Re-Installing",
            "[<][Features] Re-Uninstalling"
        )
        $FeatureState = @(
            "Disabled*",
            "Enabled"
        )
        $Commands = @(
            { Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "$($FeatureState[0])" | Enable-WindowsOptionalFeature -Online -NoRestart },
            { Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "$($FeatureState[1])" | Disable-WindowsOptionalFeature -Online -NoRestart }
        )
    }

    Write-Title -Text "Uninstall features from Windows"

    $DisableFeatures = @(
        "FaxServicesClientPackage"             # Windows Fax and Scan
        "IIS-*"                                # Internet Information Services
        "LegacyComponents"                     # Legacy Components
        #"MediaPlayback"                       # Media Features (Windows Media Player)
        "MicrosoftWindowsPowerShellV2"         # PowerShell 2.0
        "MicrosoftWindowsPowershellV2Root"     # PowerShell 2.0
        "Printing-PrintToPDFServices-Features" # Microsoft Print to PDF
        "Printing-XPSServices-Features"        # Microsoft XPS Document Writer
        "WorkFolders-Client"                   # Work Folders Client
    )
    ForEach ($Feature in $DisableFeatures) {
        If (Get-WindowsOptionalFeature -Online -FeatureName $Feature) {
            If (($Revert -eq $true) -and ($Feature -like "IIS-*")) {
                Write-Host "[?][Features] Skipping $Feature to avoid a security vulnerability ..." -ForegroundColor Yellow -BackgroundColor Black
                Continue
            }
            Write-Host "$($EnableStatus[0]) $Feature ..."
            Invoke-Expression "$($Commands[0])"
        }
        Else {
            Write-Host "[?][Features] $Feature was not found." -ForegroundColor Yellow -BackgroundColor Black
        }
    }

    Write-Title -Text "Install features for Windows"

    $EnableFeatures = @(
        "NetFx3"                            # NET Framework 3.5
        "NetFx4-AdvSrvs"                    # NET Framework 4
        "NetFx4Extended-ASPNET45"           # NET Framework 4.x + ASPNET 4.x
        # WSL 2 Support Semi-Install
        "HypervisorPlatform"                # Hypervisor Platform from Windows
        "Microsoft-Windows-Subsystem-Linux" # WSL (VT-d (Intel) or SVM (AMD) need to be enabled on BIOS)
        "VirtualMachinePlatform"            # VM Platform
    )

    ForEach ($Feature in $EnableFeatures) {
        If (Get-WindowsOptionalFeature -Online -FeatureName $Feature) {
            Write-Host "[+][Features] Installing $Feature ..."
            Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart
        }
        Else {
            Write-Host "[?][Features] $Feature was not found." -ForegroundColor Yellow -BackgroundColor Black
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