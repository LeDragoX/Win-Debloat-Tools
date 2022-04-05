Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"get-os-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Install-DriverUpdater() {
    $CPU = Get-CPU -NameOnly # Detects the current CPU
    $GPU = Get-GPU           # Detects the current GPU

    # Check for CPU drivers
    If ($CPU.contains("AMD")) {
        Write-Section -Text "Installing AMD $CPU chipset drivers updaters!"
        Write-Warning "Search for $CPU chipset driver on the AMD website."
        Write-Warning "This will only download an updater if AMD makes one."
    }
    ElseIf ($CPU.contains("Intel")) {
        Write-Section -Text "Installing Intel $CPU chipset drivers updaters!"
        Install-Software -Name "Intel® Driver & Support Assistant (Intel® DSA)" -Packages "Intel.IntelDriverAndSupportAssistant" # Intel® Driver & Support Assistant (Intel® DSA)
    }

    # Check for GPU drivers then
    If ($GPU.contains("AMD") -or $GPU.contains("Radeon")) {
        Write-Title -Text "AMD $GPU GPU, you will have to install Manually!"
        Write-Warning "Search for $GPU Graphics driver on the AMD website."
        Write-Warning "This will only download an updater if AMD makes one."
    }

    If ($GPU.contains("Intel")) {
        Write-Section -Text "Intel $GPU Graphics driver updater already included!"
        Install-Software -Name "Intel® Driver & Support Assistant (Intel® DSA)" -Packages "Intel.IntelDriverAndSupportAssistant" # Intel® Driver & Support Assistant (Intel® DSA)
    }

    If ($GPU.contains("NVIDIA")) {
        Write-Section -Text "NVIDIA $GPU Graphics driver updater!"
        Install-Software -Name "NVIDIA GeForce Experience" -Packages "Nvidia.GeForceExperience" # NVIDIA GeForce Experience
    }
}

function Main() {
    $Ask = "Do you want to install CPU/GPU drivers?`nAll the following Driver Updaters will be installed (if found):`n- $CPU driver updater`n- $GPU driver updater"

    switch (Show-Question -Title "Warning" -Message $Ask) {
        'Yes' {
            Install-DriverUpdater # Install CPU & GPU Drivers (If applicable)
        }
        'No' {
            Write-Host "Aborting..."
        }
        'Cancel' {
            Write-Host "Aborting..." # With Yes, No and Cancel, the user can press Esc to exit
        }
    }
}

Main