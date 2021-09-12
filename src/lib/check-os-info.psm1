# function to() Check if a system is 32-bits or 64-bits or Something Else
function CheckOSArchitecture() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        $Architecture = (Get-ComputerInfo -Property OSArchitecture)
    )

    If ($Architecture -like "*32 bits*") {
        Write-Host "32-bits OS detected!"
        $Architecture = "32-bits"
    }
    ElseIf ($Architecture -like "*64 bits*") {
        Write-Host "64-bits OS detected!"
        $Architecture = "64-bits"
    }
    ElseIf ($Architecture -like "*ARM") {
        Write-Host "ARM OS detected!"
        $Architecture = "ARM"
    }
    ElseIf ($Architecture -like "*ARM" -and "*64") {
        Write-Host "ARM64 OS detected!"
        $Architecture = "ARM64"
    }
    Else {
        Write-Host "ARCH_NOT_FOUND ... Couldn't identify the System Architecture. :/"
    }

    Write-Verbose "Architecture = $Architecture."
    return $Architecture
}

# function to() detect the current CPU
function DetectCPU() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        # https://community.spiceworks.com/how_to/170332-how-to-get-cpu-information-in-windows-powershell
        $CPU = (Get-WmiObject -Class Win32_Processor -ComputerName. | Select-Object -Property [a-z]*)
    )

    If ($CPU.Name.contains("AMD")) {
        Write-Host "AMD CPU found!"
    }
    ElseIf ($CPU.Name.contains("Intel")) {
        Write-Host "Intel CPU found!"
    }
    Else {
        Write-Host "CPU_NOT_FOUND (NEW/CONFIDENTIAL?)."
    }

    Write-Host "CPU = $($CPU.Name)."
    return $CPU.Name
}

# function to() detect the current GPU
function DetectGPU() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    # https://community.spiceworks.com/topic/1543645-powershell-get-wmiobject-win32_videocontroller-multiple-graphics-cards
    $ArrComputers = "."

    ForEach ($Computer in $ArrComputers) {
        $Global:GPU = Get-WmiObject -Class Win32_VideoController -ComputerName $Computer
        Write-Verbose "Video Info: $($Global:GPU.description)." 
    }
    
    If ($GPU.description.contains("AMD") -or $GPU.description.contains("Radeon")) {
        Write-Host "AMD GPU found!"
    }
    ElseIf ($GPU.description.contains("Intel")) {
        Write-Host "Intel GPU found!"
    }
    ElseIf ($GPU.description.contains("NVIDIA")) {
        Write-Host "NVIDIA GPU found!"
    }
    Else {
        Write-Host "GPU_NOT_FOUND (NEW/CONFIDENTIAL?)"
    }

    Write-Host "GPU = $($GPU.description)." 
    return $GPU.description
}