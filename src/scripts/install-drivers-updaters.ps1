Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"get-os-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Install-DriverUpdater() {
    # Check for CPU drivers
    If ($CPU.contains("AMD")) {
        Write-Section -Text "Installing AMD $CPU chipset drivers updaters!"
        Write-Host "Search for $CPU chipset driver on the AMD website." -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "This will only download an updater if AMD makes one." -ForegroundColor Yellow -BackgroundColor Black
    }
    ElseIf ($CPU.contains("Intel")) {
        Write-Section -Text "Installing Intel $CPU chipset drivers updaters!"
        Install-Software -Name "Intel® Driver & Support Assistant (Intel® DSA)" -Packages "Intel.IntelDriverAndSupportAssistant" -NoDialog # Intel® Driver & Support Assistant (Intel® DSA)
    }

    # Check for GPU drivers then
    If ($GPU.contains("AMD") -or $GPU.contains("Radeon")) {
        Write-Title -Text "AMD $GPU GPU, you will have to install Manually!"
        Write-Host "Search for $GPU Graphics driver on the AMD website." -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "This will only download an updater if AMD makes one." -ForegroundColor Yellow -BackgroundColor Black
    }

    If ($GPU.contains("Intel")) {
        Write-Section -Text "Intel $GPU Graphics driver updater already included!"
        Install-Software -Name "Intel® Driver & Support Assistant (Intel® DSA)" -Packages "Intel.IntelDriverAndSupportAssistant" -NoDialog # Intel® Driver & Support Assistant (Intel® DSA)
    }

    If ($GPU.contains("NVIDIA")) {
        Write-Section -Text "NVIDIA $GPU Graphics driver updater!"
        Install-Software -Name "NVIDIA GeForce Experience" -Packages "Nvidia.GeForceExperience" -NoDialog # NVIDIA GeForce Experience
    }
}

function Main() {
    $CPU = Get-CPU -NameOnly # Detects the current CPU
    $GPU = Get-GPU           # Detects the current GPU
    $Ask = "Do you want to install CPU/GPU drivers?`nAll the following Driver Updaters will be installed (if found):`n`n- $CPU`n- $GPU"

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