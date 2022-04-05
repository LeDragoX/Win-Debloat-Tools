function Get-CPU() {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Switch] $NameOnly,
        [Parameter(Mandatory = $false)]
        [String] $Separator = '|'
    )

    $CPUName = (Get-ItemProperty "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0").ProcessorNameString.Trim(" ")

    If ($NameOnly) {
        return "$CPUName"
    }

    $CPUCoresAndThreads = "($((Get-WmiObject -class Win32_processor).NumberOfCores)C/$env:NUMBER_OF_PROCESSORS`rT)"

    return "$Env:PROCESSOR_ARCHITECTURE $Separator $CPUName $CPUCoresAndThreads"
}

function Get-GPU() {
    [CmdletBinding()]
    [OutputType([String])]

    # Adapted from: https://community.spiceworks.com/topic/1543645-powershell-get-wmiobject-win32_videocontroller-multiple-graphics-cards
    $ArrComputers = "."

    ForEach ($Computer in $ArrComputers) {
        $GPU = Get-WmiObject -Class Win32_VideoController -ComputerName $Computer
        Write-Verbose "Video Info: $($GPU.description)."
    }

    return $GPU.description.Trim(" ")
}

function Get-RAM() {
    [CmdletBinding()]
    [OutputType([String])]

    $RamInGB = (Get-WmiObject -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
    $RAMSpeed = (Get-WmiObject -ClassName Win32_PhysicalMemory).Speed[0]

    return "$RamInGB`rGB ($RAMSpeed`rMHz)"
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
    ElseIf (($Architecture -like "*ARM") -and ($Architecture -like "*64")) {
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
    [CmdletBinding()]
    [OutputType([String])]

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
    [OutputType([System.Object[]])]
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

    return $(Get-OSDriveType), $Separator, $WinVer, $DisplayedVersionResult, $Separator, $(Get-RAM), $Separator, $(Get-CPU -Separator $Separator)
}