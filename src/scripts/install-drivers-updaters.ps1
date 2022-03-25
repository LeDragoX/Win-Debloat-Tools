Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"get-os-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-message-box.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Install-DriverUpdater() {

    $CPU = Get-CPU  # Detects the current CPU
    $GPU = Get-GPU  # Detects the current GPU
    $Ask = "Do you want to install CPU/GPU drivers?`nAll the following Driver Updaters will be installed (if found):`n- $CPU driver updater`n- $GPU driver updater"
  
    switch (Show-Question -Title "Warning" -Message $Ask) {
        'Yes' {
            # Check for CPU drivers
            If ($CPU.contains("AMD")) {
                Write-Section -Text "Installing AMD $CPU chipset drivers updaters!"
                Write-Warning "Search for $CPU chipset driver on the AMD website."
                Write-Warning "This will only download an updater if AMD makes one."
            }
            ElseIf ($CPU.contains("Intel")) {
                Write-Section -Text "Installing Intel $CPU chipset drivers updaters!"
                Write-Caption -Text "Installing: intel-dsa"
                winget install --silent --source "winget" --id "Intel.IntelDriverAndSupportAssistant" | Out-Host # Intel® Driver & Support Assistant (Intel® DSA)
            }

            # Check for GPU drivers then
            If ($GPU.contains("AMD") -or $GPU.contains("Radeon")) {
                Write-Title -Text "AMD $GPU GPU, you will have to install Manually!"
                Write-Warning "Search for $GPU Graphics driver on the AMD website."
                Write-Warning "This will only download an updater if AMD makes one."
            }

            If ($GPU.contains("Intel")) {
                Write-Section -Text "Intel $GPU Graphics driver updater already included!"
                Write-Caption -Text "Installing: intel-dsa"
                winget install --silent --source "winget" --id "Intel.IntelDriverAndSupportAssistant" | Out-Host # Intel® Driver & Support Assistant (Intel® DSA)
            }

            If ($GPU.contains("NVIDIA")) {
                Write-Section -Text "NVIDIA $GPU Graphics driver updater!"
                Write-Caption -Text "Installing: Nvidia.GeForceExperience"
                winget install --silent --source "winget" --id "Nvidia.GeForceExperience" | Out-Host # GeForce Experience (latest)
            }
        }
        'No' {
            Write-Host "You choose No. (No = Cancel)"
        }
        'Cancel' {
            # With Yes, No and Cancel, the user can press Esc to exit
            Write-Host "You choose Cancel. (Cancel = No)"
        }
    }
}

function Main() {

    Install-DriverUpdater # Install CPU & GPU Drivers (If applicable)

}

Main