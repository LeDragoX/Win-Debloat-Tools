Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"

function Show-DebloatInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
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
    $RAMAvailable = [Int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1KB)
    $RamInMB = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1MB

    $Title = "System Debloat Info"
    $Message = @"
Disabled Scheduled Tasks: $DisabledScheduledTasks / $TotalScheduledTasks ($((($DisabledScheduledTasks / $TotalScheduledTasks) * 100).ToString("#.##"))%)
Disabled Services: $DisabledServices / $TotalServices ($((($DisabledServices / $TotalServices) * 100).ToString("#.##"))%)
Manual Services: $ManualServices / $TotalServices ($((($ManualServices / $TotalServices) * 100).ToString("#.##"))%)
Disabled Windows Features: $DisabledWinFeatures / $TotalWinFeatures ($((($DisabledWinFeatures / $TotalWinFeatures) * 100).ToString("#.##"))%)
Disabled Windows Capabilities: $DisabledWinCapabilities / $TotalWinCapabilities ($((($DisabledWinCapabilities / $TotalWinCapabilities) * 100).ToString("#.##"))%)
-----------------------------------------------------------------
Total of UWP Apps: $TotalAppx
Total of UWP Provisioned Apps: $TotalProvisionedAppx
Total of Windows Packages: $TotalWinPackages
-----------------------------------------------------------------
Number of Processes: $NumberOfProcesses
RAM Available: $RAMAvailable/$RamInMB MB ($((($RAMAvailable / $RamInMB) * 100).ToString("#.##"))%)
"@ # Here-String

    If ($PostMessage) {
        $Message += "`n-----------------------------------------------------------------`n$PostMessage"
    }

    Write-Host "`n$Message`n" -ForegroundColor Cyan

    If (!($Silent)) {
        Show-Message -Title "$Title" -Message "$Message"
    }
}

<#
Example:
Show-DebloatInfo
Show-DebloatInfo -PostMessage "PostMessage"
Show-DebloatInfo -PostMessage "PostMessage" -Silent
#>