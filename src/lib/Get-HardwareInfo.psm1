Import-Module -DisableNameChecking "$PSScriptRoot\Title-Templates.psm1"

function Get-CPU() {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Switch] $NameOnly,
        [String] $Separator = '|'
    )

    $CPUName = ""

    ForEach ($Item in (Get-ItemProperty "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0").ProcessorNameString.Trim(" ").Split(" ")) {
        If (($Item -ne " ") -or ($null -ne $Item)) {
            $CPUName = $CPUName.Trim(" ") + " " + $Item.Trim(" ")
        }
    }

    If ($NameOnly) {
        return "$CPUName"
    }

    $CPUCoresAndThreads = "($((Get-CimInstance -class Win32_processor).NumberOfCores)C/$env:NUMBER_OF_PROCESSORS`T)"

    return "$Env:PROCESSOR_ARCHITECTURE $Separator $CPUName $CPUCoresAndThreads"
}

function Get-GPU() {
    [CmdletBinding()]
    [OutputType([String])]

    $GPU = (Get-CimInstance -Class Win32_VideoController).Name
    Write-Verbose "Video Info: $GPU"

    return "$GPU"
}

function Get-RAM() {
    [CmdletBinding()]
    [OutputType([String])]

    $RamInGB = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
    $RAMSpeed = (Get-CimInstance -ClassName Win32_PhysicalMemory).Speed[0]

    return "$RamInGB`GB ($RAMSpeed`MHz)"
}

function Get-OSArchitecture() {
    [CmdletBinding()]
    param (
        $Architecture = (Get-ComputerInfo -Property OSArchitecture)
    )

    If ($Architecture -like "*64*bit*") {
        $Architecture = @("x64")
    } ElseIf ($Architecture -like "*32*bit*") {
        $Architecture = @("x86")
    } ElseIf (($Architecture -like "*ARM") -and ($Architecture -like "*64")) {
        $Architecture = @("arm64")
    } ElseIf ($Architecture -like "*ARM") {
        $Architecture = @("arm")
    } Else {
        Write-Host "[?] Couldn't identify the System Architecture '$Architecture'. :/" -ForegroundColor Yellow -BackgroundColor Black
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
        Where-Object DriveLetter -EQ "$($env:SystemDrive[0])" | Select-Object DriveLetter, @{ n = 'MediaType'; e = { $PhysicalDisk.MediaType } }
    }

    $OSDriveType = $SystemDriveType.MediaType
    return "$OSDriveType"
}

function Get-DriveSpace() {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [String] $DriveLetter = $env:SystemDrive[0]
    )

    $SystemDrive = (Get-PSDrive -Name $DriveLetter)
    $AvailableStorage = $SystemDrive.Free / 1GB
    $UsedStorage = $SystemDrive.Used / 1GB
    $TotalStorage = $AvailableStorage + $UsedStorage

    return "$DriveLetter`: $($AvailableStorage.ToString("#.#"))/$($TotalStorage.ToString("#.#")) GB ($((($AvailableStorage / $TotalStorage) * 100).ToString("#.#"))%)"
}

function Get-PCSystemType() {
    [CmdletBinding()]

    $PCSystemType = Get-CimInstance -Class Win32_ComputerSystem | Select-Object -ExpandProperty PCSystemType

    If ($PCSystemType -eq 1) {
        Write-Status -Types "@", "Info" -Status "Your PC is a Desktop ($PCSystemType)" -Warning
    } ElseIf ($PCSystemType -eq 2) {
        Write-Status -Types "@", "Info" -Status "Your PC is a Laptop ($PCSystemType)" -Warning
    } Else {
        Write-Status -Types "?", "Info" -Status "Your PC system type is Unknown ($PCSystemType)" -Warning
    }

    return $PCSystemType
}

function Get-SystemSpec() {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [String] $Separator = '|'
    )

    Write-Status -Types "@", "Info" -Status "Loading system specs..."
    # Adapted From: https://www.delftstack.com/howto/powershell/find-windows-version-in-powershell/#using-the-wmi-class-with-get-wmiobject-cmdlet-in-powershell-to-get-the-windows-version
    $WinVer = (Get-CimInstance -class Win32_OperatingSystem).Caption -replace 'Microsoft ', ''
    $DisplayVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
    $OldBuildNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
    $DisplayedVersionResult = '(' + @{ $true = $DisplayVersion; $false = $OldBuildNumber }[$null -ne $DisplayVersion] + ')'

    return $(Get-OSDriveType), $Separator, $WinVer, $DisplayedVersionResult, $Separator, $(Get-RAM), $Separator, $(Get-CPU -Separator $Separator), $Separator, $(Get-GPU)
}
