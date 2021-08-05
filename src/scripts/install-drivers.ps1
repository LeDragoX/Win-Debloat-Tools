Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"check-os-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function InstallDrivers() {

  # Install CPU drivers first
  If ($CPU.contains("AMD")) {
      
    Section1 -Text "Installing AMD chipset drivers!"
    If ($CPU.contains("Ryzen")) {
      Section1 -Text "You have a Ryzen CPU, installing Chipset driver for Ryzen processors!"
      Caption1 -Text "Installing: amd-ryzen-chipset"
      choco install -y "amd-ryzen-chipset" | Out-Host # AMD Ryzen Chipset Drivers
    }

  }
  ElseIf ($CPU.contains("Intel")) {
  
    Section1 -Text "Installing Intel chipset drivers!"
            
    Caption1 -Text "Installing: intel-dsa"
    winget install --silent "Intel.IntelDriverAndSupportAssistant" | Out-Host # Intel® Driver & Support Assistant (Intel® DSA)
  
  }
      
  # Install GPU drivers then
  If ($GPU.contains("AMD") -or $GPU.contains("Radeon")) {
    Title1 -Text "AMD GPU, you will have to install Manually!"
    Write-Host "Search for $GPU drivers."
  }
      
  If ($GPU.contains("Intel")) {
    Section1 -Text "Installing Intel Graphics driver!"
    Caption1 -Text "Installing: intel-graphics-driver"
    choco install -y "chocolatey-fastanswers.extension" # Dependency
    choco install -y "dependency-windows10"             # Dependency
    choco install -y "intel-graphics-driver" | Out-Host # Intel Graphics Driver (latest)
  }
  
  If ($GPU.contains("NVIDIA")) {
  
    Section1 -Text "Installing NVIDIA Graphics driver!"
    Caption1 -Text "Installing: Nvidia.GeForceExperience"
    winget install --silent "Nvidia.GeForceExperience" | Out-Host # GeForce Experience (latest)
  
    Caption1 -Text "Configuring 'geforce-game-ready-driver' for DCH..."
    choco feature enable -n=useRememberedArgumentsForUpgrades | Out-Host
    Caption1 -Text "Installing: geforce-game-ready-driver"
    choco install -y "geforce-game-ready-driver" --package-parameters="'/dch'" | Out-Host # GeForce Game Ready Driver (latest)
  
  }    
  
}

function Main() {

  $CPU = DetectCPU  # Detects the current CPU
  $GPU = DetectGPU  # Detects the current GPU
  InstallDrivers    # Install CPU & GPU Drivers (If applicable)

}

Main