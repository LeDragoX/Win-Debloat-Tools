Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://github.com/ChrisTitusTech/win10script/pull/131/files

function OptimizeOptionalFeatures() {

    Title1 -Text "Install additional features for Windows"
    
    # Dism /online /Get-Features #/Format:Table # To find all features
    # Get-WindowsOptionalFeature -Online

    $DisableFeatures = @(
        "FaxServicesClientPackage"             # Windows Fax and Scan
        "LegacyComponents"                     # Legacy Components
        "MediaPlayback"                        # Media Features
        "MicrosoftWindowsPowerShellV2"         # PowerShell 2.0
        "MicrosoftWindowsPowershellV2Root"     # PowerShell 2.0
        "Printing-PrintToPDFServices-Features" # Microsoft Print to PDF
        "Printing-XPSServices-Features"        # Microsoft XPS Document Writer
        "WorkFolders-Client"                   # Work Folders Client
    )

    ForEach ($Feature in $DisableFeatures) {

        $FeatureDetails = $(Get-WindowsOptionalFeature -Online -FeatureName $Feature)
        
        Write-Host "[?][Feature] $Feature Status:" $FeatureDetails.State

        If ($FeatureDetails.State -like "Enabled") {

            Write-Host "[-][Feature] Uninstalling $Feature..."
            Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName $Feature

        }
    }
    
    $EnableFeatures = @(
        "Microsoft-Hyper-V-All"             # Hyper-V (VT-d (Intel) / SVM (AMD) needed on BIOS)
        "NetFx3"                            # NET Framework 3.5
        "NetFx4-AdvSrvs"                    # NET Framework 4
        "NetFx4Extended-ASPNET45"           # NET Framework 4.x + ASPNET 4.x
        # WSL 2 Support Semi-Install
        "HypervisorPlatform"                # Hypervisor Platform from Windows
        "Microsoft-Windows-Subsystem-Linux" # WSL
        "VirtualMachinePlatform"            # VM Platform
    )
    
    ForEach ($Feature in $EnableFeatures) {
        $FeatureDetails = $(Get-WindowsOptionalFeature -Online -FeatureName $Feature)
        
        Write-Host "[?][Feature] Checking if $Feature was already installed..."
        Write-Host "[?][Feature] $Feature Status:" $FeatureDetails.State

        If ($FeatureDetails.State -like "Disabled*") {

            Write-Host "[+][Feature] Installing $Feature..."
            Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName $Feature

        }
    }

    # This is for WSL 2
    If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
        # 1607 needs developer mode to be enabled
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
    }
    wsl --set-default-version 2
    wsl --list --online

}

function Main() {

    OptimizeOptionalFeatures  # Disable useless features and Enable features claimed as Optional on Windows, but actually, they are useful

}

Main