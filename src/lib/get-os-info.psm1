function Get-CPU() {
    [CmdletBinding()] param ()

    $CPUName = (Get-ItemProperty "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0").ProcessorNameString.Trim(" ")
    $CPUCoresAndThreads = "($((Get-WmiObject -class Win32_processor).NumberOfCores)C/$env:NUMBER_OF_PROCESSORS`rT)"

    return "$CPUName $CPUCoresAndThreads"
}

function Get-GPU() {
    [CmdletBinding()] param ()

    # Adapted from: https://community.spiceworks.com/topic/1543645-powershell-get-wmiobject-win32_videocontroller-multiple-graphics-cards
    $ArrComputers = "."

    ForEach ($Computer in $ArrComputers) {
        $GPU = Get-WmiObject -Class Win32_VideoController -ComputerName $Computer
        Write-Verbose "Video Info: $($GPU.description)."
    }

    return $GPU.description.Trim(" ")
}

function Get-OSArchitecture() {
    [CmdletBinding()]
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

function Get-OSDriveType() {
    [CmdletBinding()] param ()

    # Adapted from: https://stackoverflow.com/a/62087930
    $SystemDriveType = Get-PhysicalDisk | ForEach-Object {
        $PhysicalDisk = $_
        $PhysicalDisk | Get-Disk | Get-Partition |
        Where-Object DriveLetter -EQ "$($env:SystemDrive[0])" | Select-Object DriveLetter, @{n = 'MediaType'; e = { $PhysicalDisk.MediaType }
        }
    }

    $OSDriveType = $SystemDriveType.MediaType
    return "$OSDriveType"
}

function Get-SystemSpec() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [String] $Separator = '|'
    )

    Write-Host "[@] Loading system specs..."
    # Adapted From: https://www.delftstack.com/howto/powershell/find-windows-version-in-powershell/#using-the-wmi-class-with-get-wmiobject-cmdlet-in-powershell-to-get-the-windows-version
    $WinVer = (Get-WmiObject -class Win32_OperatingSystem).Caption -replace 'Microsoft ', ''
    $DisplayVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
    $OldBuildNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
    $DisplayedVersionResult = '(' + @{ $true = $DisplayVersion; $false = $OldBuildNumber }[$null -ne $DisplayVersion] + ')'

    return $(Get-OSDriveType), $Separator, $WinVer, $DisplayedVersionResult, $Separator, $Env:PROCESSOR_ARCHITECTURE, $Separator, $(Get-CPU)
}