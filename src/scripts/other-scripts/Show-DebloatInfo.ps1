Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\ui\Show-MessageDialog.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\ui\Ui-Helper.psm1" # Load UI libs

function Show-DebloatInfo() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [String] $PostMessage,
        [Switch] $Silent
    )

    $TotalScheduledTasks = (Get-ScheduledTask).Count # Slow
    $DisabledScheduledTasks = (Get-ScheduledTask | Where-Object State -Like "Disabled").Count # Slow
    $TotalServices = (Get-Service).Count
    $DisabledServices = (Get-Service | Where-Object StartType -Like "Disabled").Count
    $ManualServices = (Get-Service | Where-Object StartType -Like "Manual").Count
    $TotalWinFeatures = (Get-CimInstance Win32_OptionalFeature).Count
    $DisabledWinFeatures = (Get-WindowsOptionalFeature -Online | Where-Object State -Like "Disabled*").Count # Very Slow (Accurate)
    $TotalWinCapabilities = (Get-WindowsCapability -Online).Count
    $DisabledWinCapabilities = (Get-WindowsCapability -Online | Where-Object State -Like "NotPresent").Count # Slow
    $TotalAppx = (Get-AppxPackage).Count
    $TotalProvisionedAppx = (Get-AppxProvisionedPackage -Online).Count
    $TotalWinPackages = (Get-WindowsPackage -Online).Count # Slow
    $NumberOfProcesses = (Get-Process).Count
    $RAMAvailableInGB = ((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB) # Accurate
    $TotalRAMInGB = ((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB) # Accurate (Not equal installed memory)
    $RAMUsedInGB = ($TotalRAMInGB - $RAMAvailableInGB)
    $SystemDrive = (Get-PSDrive -Name $env:SystemDrive[0])
    $AvailableStorage = $SystemDrive.Free / 1GB
    $UsedStorage = $SystemDrive.Used / 1GB
    $TotalStorage = $AvailableStorage + $UsedStorage

    $Title = "System Debloat Info"
    $Message = @"
Disabled Scheduled Tasks: $DisabledScheduledTasks/$TotalScheduledTasks ($((($DisabledScheduledTasks / $TotalScheduledTasks) * 100).ToString("#.#"))%)
Disabled Services: $DisabledServices/$TotalServices ($((($DisabledServices / $TotalServices) * 100).ToString("#.#"))%)
Manual Services: $ManualServices/$TotalServices ($((($ManualServices / $TotalServices) * 100).ToString("#.#"))%)
Disabled Windows Features: $DisabledWinFeatures/$TotalWinFeatures ($((($DisabledWinFeatures / $TotalWinFeatures) * 100).ToString("#.#"))%)
Disabled Windows Capabilities: $DisabledWinCapabilities/$TotalWinCapabilities ($((($DisabledWinCapabilities / $TotalWinCapabilities) * 100).ToString("#.#"))%)
-----------------------------------------------------------------
Total of UWP Apps: $TotalAppx
Total of UWP Provisioned Apps: $TotalProvisionedAppx
Total of Windows Packages: $TotalWinPackages
-----------------------------------------------------------------
Number of Processes: $NumberOfProcesses
RAM Used: $($RAMUsedInGB.ToString("#.#"))/$($TotalRAMInGB.ToString("#.#")) GB ($((($RAMUsedInGB / $TotalRAMInGB) * 100).ToString("#.#"))%)
Storage Used ($env:SystemDrive): $($UsedStorage.ToString("#.#"))/$($TotalStorage.ToString("#.#")) GB ($((($UsedStorage / $TotalStorage) * 100).ToString("#.#"))%)
"@ # Here-String

    If ($PostMessage) {
        $Message += "`n-----------------------------------------------------------------`n$PostMessage"
    }

    Write-Host "`n$Message`n" -ForegroundColor Cyan

    If (!($Silent)) {
        Show-MessageDialog -Title "$Title" -Message "$Message"
    }
}

Show-DebloatInfo

<#
Example:
Show-DebloatInfo
Show-DebloatInfo -PostMessage "PostMessage"
Show-DebloatInfo -PostMessage "PostMessage" -Silent
#>
