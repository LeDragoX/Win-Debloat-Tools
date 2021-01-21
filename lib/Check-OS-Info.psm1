# Function to Check if a system is 32-bits or 64-bits or Something Else
function CheckOSArchitecture {
	$Global:Architecture = wmic os get osarchitecture
	if ($Architecture -like "*32 bits*") {
        Write-Host "32-bits OS detected!"
        $Architecture = "32-bits"
	} elseif ($Architecture -like "*64 bits*") {
        Write-Host "64-bits OS detected!"
        $Architecture = "64-bits"
    } else {
        Write-Host "Couldn't identify the System Architecture. :/"
        $Architecture = "ARCH_NOT_FOUND (ARM?)"
        break
    }

    # Note that $Architecture is not Global
    Write-Host "Architecture = $Architecture"
    return $Architecture
}

# Function to detect the current GPU
function DetectVideoCard() {
	$Global:GPU
	# https://community.spiceworks.com/topic/1543645-powershell-get-wmiobject-win32_videocontroller-multiple-graphics-cards
	$ArrComputers = "."

	foreach ($Computer in $ArrComputers) {
		$ComputerVideo = Get-WmiObject Win32_VideoController -ComputerName $Computer
		Write-Host "Video Info: " $ComputerVideo.description
		$Global:GPU = $ComputerVideo.description
    }
    
    if ($GPU.contains("AMD") -or $GPU.contains("Radeon")) {
		Write-Host "AMD GPU found!"
        $GPU = "AMD"
	} elseif ($GPU.contains("Intel")) {
        Write-Host "Intel GPU found!"
        $GPU = "Intel"
	} elseif ($GPU.contains("NVIDIA")) {
        Write-Host "NVIDIA GPU found!"
        $GPU = "NVIDIA"
    } else {
        Write-Host "GPU_NOT_FOUND (NEW/CONFIDENTIAL?)"
        $GPU = "GPU_NOT_FOUND (NEW/CONFIDENTIAL?)"
    }

    # Note that $GPU is not Global
    Write-Host "GPU = $GPU"
    return $GPU
}