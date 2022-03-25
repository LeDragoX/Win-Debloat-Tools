function Get-OSArchitecture() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        $Architecture = (Get-ComputerInfo -Property OSArchitecture)
    )

    If ($Architecture -like "*64 bits*") {
        $Architecture = @("x64")
    }
    ElseIf ($Architecture -like "*32 bits*") {
        $Architecture = @("x86")
    }
    ElseIf ($Architecture -like "*ARM" -and "*64") {
        $Architecture = @("arm64")
    }
    ElseIf ($Architecture -like "*ARM") {
        $Architecture = @("arm")
    }
    Else {
        Write-Warning "[?] Couldn't identify the System Architecture '$Architecture'. :/"
        $Architecture = $null
    }

    Write-Warning "$Architecture OS detected!"
    return $Architecture
}

function Get-CPU() {

    # Adapted from: https://community.spiceworks.com/how_to/170332-how-to-get-cpu-information-in-windows-powershell
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        $CPU = (Get-WmiObject -Class Win32_Processor -ComputerName. | Select-Object -Property [a-z]*)
    )

    $CPUName = $CPU.Name.Trim(" ")
    If ($CPUName.contains("AMD")) {
        Write-Host "AMD CPU found!"
    }
    ElseIf ($CPUName.contains("Intel")) {
        Write-Host "Intel CPU found!"
    }
    ElseIf ($CPUName.contains("ARM")) {
        Write-Host "ARM CPU found!"
    }
    Else {
        Write-Host "CPU_NOT_FOUND (NEW/CONFIDENTIAL?)."
    }

    Write-Host "CPU = $($CPUName)."
    return ($CPUName)
}

function Get-GPU() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    # Adapted from: https://community.spiceworks.com/topic/1543645-powershell-get-wmiobject-win32_videocontroller-multiple-graphics-cards
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

    Write-Host "GPU = $($GPU.description.Trim(" "))."
    return $GPU.description.Trim(" ")
}

function Get-OSDriveType() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    # Adapted from: https://stackoverflow.com/a/62087930
    $SystemDriveType = Get-PhysicalDisk | ForEach-Object {
        $PhysicalDisk = $_
        $PhysicalDisk | Get-Disk | Get-Partition |
        Where-Object DriveLetter -EQ "$($env:SystemDrive[0])" | Select-Object DriveLetter, @{n = 'MediaType'; e = { $PhysicalDisk.MediaType }
        }
    }

    $IsSSD? = $SystemDriveType.MediaType -eq "SSD"
    return $IsSSD?
}