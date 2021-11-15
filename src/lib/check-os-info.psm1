function Check-OSArchitecture() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        $Architecture = (Get-ComputerInfo -Property OSArchitecture)
    )

    If ($Architecture -like "*64 bits*") {
        $Architecture = "x64"
    }
    ElseIf ($Architecture -like "*32 bits*") {
        $Architecture = "x86"
    }
    ElseIf ($Architecture -like "*ARM" -and "*64") {
        $Architecture = "arm64"
    }
    ElseIf ($Architecture -like "*ARM") {
        $Architecture = "arm"
    }
    Else {
        Write-Warning "[?] Couldn't identify the System Architecture '$Architecture'. :/"
        $Architecture = $null
    }

    Write-Warning "$Architecture OS detected!"
    return $Architecture
}

function Check-CPU() {

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

function Check-GPU() {

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