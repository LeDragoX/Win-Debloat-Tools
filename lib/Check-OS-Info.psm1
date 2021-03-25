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
        Write-Host "ARCH_NOT_FOUND (ARM?) ... Couldn't identify the System Architecture. :/"
    }

    Write-Host "Architecture = $Architecture"
    return $Architecture
}

# Function to detect the current CPU
function DetectCPU() {
    # https://community.spiceworks.com/how_to/170332-how-to-get-cpu-information-in-windows-powershell
    $Global:CPU = Get-WmiObject -Class Win32_Processor -ComputerName. | Select-Object -Property [a-z]*

    if ($CPU.Name.contains("AMD") -or $CPU.Name.contains("Radeon")) {
		Write-Host "AMD CPU found!"
	} elseif ($CPU.Name.contains("Intel")) {
        Write-Host "Intel CPU found!"
	} else {
        Write-Host "CPU_NOT_FOUND (NEW/CONFIDENTIAL?)"
    }

    Write-Host "CPU =" $CPU.Name
    return $CPU.Name
}


# Function to detect the current GPU
function DetectGPU() {
	# https://community.spiceworks.com/topic/1543645-powershell-get-wmiobject-win32_videocontroller-multiple-graphics-cards
	$ArrComputers = "."

	foreach ($Computer in $ArrComputers) {
		$Global:GPU = Get-WmiObject -Class Win32_VideoController -ComputerName $Computer
		Write-Host "Video Info:" $Global:GPU.description
    }
    
    if ($GPU.description.contains("AMD") -or $GPU.description.contains("Radeon")) {
		Write-Host "AMD GPU found!"
	} elseif ($GPU.description.contains("Intel")) {
        Write-Host "Intel GPU found!"
	} elseif ($GPU.description.contains("NVIDIA")) {
        Write-Host "NVIDIA GPU found!"
    } else {
        Write-Host "GPU_NOT_FOUND (NEW/CONFIDENTIAL?)"
    }

    Write-Host "GPU =" $GPU.description
    return $GPU.description
}