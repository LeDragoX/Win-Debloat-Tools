Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://github.com/ChrisTitusTech/win10script/pull/131/files

function OptimizeOptionalFeatures() {

    Title1 -Text "Uninstall features from Windows"

    # Dism /online /Get-Features #/Format:Table # To find all features
    # Get-WindowsOptionalFeature -Online

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

            Write-Host "$($EnableStatus[0]) $Feature..."
            Invoke-Expression "$($Commands[0])"

        }
        Else {

            Write-Warning "[?][Features] $Feature was not found."

        }
    }

    Title1 -Text "Install features for Windows"

    $EnableFeatures = @(
        "Microsoft-Hyper-V-All"             # Hyper-V (VT-d (Intel) or SVM (AMD) need to be enabled on BIOS)
        "NetFx3"                            # NET Framework 3.5
        "NetFx4-AdvSrvs"                    # NET Framework 4
        "NetFx4Extended-ASPNET45"           # NET Framework 4.x + ASPNET 4.x
        # WSL 2 Support Semi-Install
        "HypervisorPlatform"                # Hypervisor Platform from Windows
        "Microsoft-Windows-Subsystem-Linux" # WSL
        "VirtualMachinePlatform"            # VM Platform
    )
    
    ForEach ($Feature in $EnableFeatures) {

        If (Get-WindowsOptionalFeature -Online -FeatureName $Feature) {

            Write-Host "[+][Features] Installing $Feature..."
            Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "Disabled*" | Enable-WindowsOptionalFeature -Online -NoRestart

        }
        Else {

            Write-Warning "[?][Features] $Feature was not found."

        }
    }
}

function Main() {

    $EnableStatus = @(
        "[-][Features] Uninstalling",
        "[+][Features] Installing"
    )
    $FeatureState = @(
        "Enabled",
        "Disabled*"
    )
    $Commands = @(
        { Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "$($FeatureState[0])" | Disable-WindowsOptionalFeature -Online -NoRestart },
        { Get-WindowsOptionalFeature -Online -FeatureName $Feature | Where-Object State -Like "$($FeatureState[1])" | Enable-WindowsOptionalFeature -Online -NoRestart }
    )

    if (($Revert)) {
        Write-Warning "[<][Features] Reverting: $Revert."

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

    OptimizeOptionalFeatures  # Disable useless features and Enable features claimed as Optional on Windows, but actually, they are useful

}

Main