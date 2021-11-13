Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"check-os-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Install-Drivers() {

    # Install CPU drivers first
    If ($CPU.contains("AMD")) {

        Write-Section -Text "Installing AMD $CPU chipset drivers!"
        If ($CPU.contains("Ryzen")) {
            Write-Section -Text "You have a Ryzen CPU, installing Chipset driver for Ryzen processors!"
            Write-Caption -Text "Installing: amd-ryzen-chipset"
            choco install -y "amd-ryzen-chipset" | Out-Host # AMD Ryzen Chipset Drivers
        }

    }
    ElseIf ($CPU.contains("Intel")) {

        Write-Section -Text "Installing Intel $CPU chipset drivers!"

        Write-Caption -Text "Installing: intel-dsa"
        winget install --silent --id "Intel.IntelDriverAndSupportAssistant" | Out-Host # Intel® Driver & Support Assistant (Intel® DSA)

    }

    # Install GPU drivers then
    If ($GPU.contains("AMD") -or $GPU.contains("Radeon")) {
        Write-Title -Text "AMD $GPU GPU, you will have to install Manually!"
        Write-Warning "Search for $GPU Graphics driver on the AMD website."
    }

    If ($GPU.contains("Intel")) {
        Write-Section -Text "Intel $GPU Graphics driver!"
        Write-Caption -Text "Installing: intel-graphics-driver"
        choco install -y "chocolatey-fastanswers.extension" "dependency-windows10" "intel-graphics-driver" | Out-Host # Dependencies + Intel Graphics Driver (latest)
    }

    If ($GPU.contains("NVIDIA")) {

        Write-Section -Text "NVIDIA $GPU Graphics driver!"
        Write-Caption -Text "Installing: Nvidia.GeForceExperience"
        winget install --silent --id "Nvidia.GeForceExperience" | Out-Host # GeForce Experience (latest)

        Write-Caption -Text "Configuring 'geforce-game-ready-driver' for DCH..."
        choco feature enable -n=useRememberedArgumentsForUpgrades | Out-Host
        Write-Caption -Text "Installing: geforce-game-ready-driver"
        choco install -y "geforce-game-ready-driver" --package-parameters="'/dch'" | Out-Host # GeForce Game Ready Driver (latest)

    }
}

function Main() {

    $CPU = Check-CPU # Detects the current CPU
    $GPU = Check-GPU # Detects the current GPU
    Install-Drivers   # Install CPU & GPU Drivers (If applicable)

}

Main