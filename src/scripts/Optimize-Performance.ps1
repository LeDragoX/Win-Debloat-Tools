Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Open-File.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Get-HardwareInfo.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Unregister-DuplicatedPowerPlan.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\utils\Individual-Tweaks.psm1"

# Adapted from: https://youtu.be/hQSkPmZRCjc
# Adapted from: https://github.com/ChrisTitusTech/win10script
# Adapted from: https://github.com/ChrisTitusTech/winutil
# Adapted from: https://github.com/Sycnex/Windows10Debloater

function Optimize-Performance() {
    [CmdletBinding()]
    param(
        [Switch] $Revert,
        [Int]    $Zero = 0,
        [Int]    $One = 1,
        [Array]  $EnableStatus = @(
            @{ Symbol = "-"; Status = "Disabling"; }
            @{ Symbol = "+"; Status = "Enabling"; }
        )
    )
    $TweakType = "Performance"

    If (($Revert)) {
        Write-Status -Types "*", $TweakType -Status "Reverting the tweaks is set to '$Revert'." -Warning
        $Zero = 1
        $One = 0
        $EnableStatus = @(
            @{ Symbol = "*"; Status = "Restoring"; }
            @{ Symbol = "*"; Status = "Re-Disabling"; }
        )
    }

    $PCSystemType = Get-PCSystemType
    # Initialize all Path variables used to Registry Tweaks
    $PathToLMMultimediaSystemProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    $PathToLMMultimediaSystemProfileOnGameTasks = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    $PathToLMPoliciesEdge = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    $PathToLMPoliciesPsched = "HKLM:\SOFTWARE\Policies\Microsoft\Psched"
    $PathToLMPoliciesWindowsStore = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    $PathToUsersControlPanelDesktop = "Registry::HKEY_USERS\.DEFAULT\Control Panel\Desktop"
    $PathToCUControlPanelDesktop = "HKCU:\Control Panel\Desktop"
    $PathToCUGameBar = "HKCU:\SOFTWARE\Microsoft\GameBar"

    Write-Title "Performance Tweaks"

    Write-Section "System"
    Write-Caption "Display"
    Write-Status -Types "+", $TweakType, "20H1" -Status "Enable Hardware Accelerated GPU Scheduling... (Windows 10+ - Needs Restart)"
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Type DWord -Value 2

    Write-Status -Types $EnableStatus[0].Symbol, $TweakType -Status "$($EnableStatus[0].Status) Remote Assistance..."
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value $Zero

    Write-Status -Types "-", $TweakType -Status "Disabling Ndu High RAM Usage..."
    # [@] (2 = Enable Ndu, 4 = Disable Ndu)
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Type DWord -Value 4

    # Details: https://www.tenforums.com/tutorials/94628-change-split-threshold-svchost-exe-windows-10-a.html
    # Will reduce Processes number considerably on > 4GB of RAM systems
    Write-Status -Types "+", $TweakType -Status "Setting SVCHost to match installed RAM size..."
    $RamInKB = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1KB
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $RamInKB

    Write-Status -Types "*", $TweakType -Status "Enabling Windows Store apps Automatic Updates..."
    If (!(Test-Path "$PathToLMPoliciesWindowsStore")) {
        New-Item -Path "$PathToLMPoliciesWindowsStore" -Force | Out-Null
    }
    Remove-ItemPropertyVerified -Path "$PathToLMPoliciesWindowsStore" -Name "AutoDownload" # [@] (2 = Disable, 4 = Enable)

    Write-Section "Microsoft Edge Tweaks"
    Write-Caption "System and Performance"
    Write-Status -Types $EnableStatus[0].Symbol, $TweakType -Status "$($EnableStatus[0].Status) Edge Startup boost..."
    Set-ItemPropertyVerified -Path "$PathToLMPoliciesEdge" -Name "StartupBoostEnabled" -Type DWord -Value $Zero

    Write-Status -Types $EnableStatus[0].Symbol, $TweakType -Status "$($EnableStatus[0].Status) run extensions and apps when Edge is closed..."
    Set-ItemPropertyVerified -Path "$PathToLMPoliciesEdge" -Name "BackgroundModeEnabled" -Type DWord -Value $Zero

    Write-Section "Power Plan Tweaks"

    If ($PCSystemType -eq 1) {
        Write-Status -Types "+", $TweakType -Status "Desktop ($PCSystemType): Setting Power Plan to High Performance..."
        powercfg -SetActive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    } ElseIf ($PCSystemType -eq 2) {
        Write-Status -Types "@", $TweakType -Status "Laptop ($PCSystemType): Keeping current power plan..." -Warning
    } Else {
        Write-Status -Types "@", $TweakType -Status "Unknown ($PCSystemType): Keeping current power plan..." -Warning
    }

    Write-Status -Types "+", $TweakType -Status "Creating the Ultimate Performance hidden Power Plan..."
    powercfg -DuplicateScheme e9a42b02-d5df-448d-aa00-03f14749eb61
    Write-Host
    Unregister-DuplicatedPowerPlan
    Enable-Hibernate -Type 'Full'

    Write-Section "Network & Internet"
    Write-Status -Types "+", $TweakType -Status "Unlimiting your network bandwidth for all your system..." # Based on this Chris Titus video: https://youtu.be/7u1miYJmJ_4
    Set-ItemPropertyVerified -Path "$PathToLMPoliciesPsched" -Name "NonBestEffortLimit" -Type DWord -Value 0
    Set-ItemPropertyVerified -Path "$PathToLMMultimediaSystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff

    Write-Section "System & Apps Timeout behaviors"
    Write-Status -Types "+", $TweakType -Status "Reducing Time to services app timeout to 2s to ALL users..."
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "WaitToKillServiceTimeout" -Type DWord -Value 2000 # Default: 20000 / 5000
    Write-Status -Types "*", $TweakType -Status "Don't clear page file at shutdown (takes more time) to ALL users..."
    Set-ItemPropertyVerified -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Type DWord -Value 0 # Default: 0

    Write-Status -Types "+", $TweakType -Status "Reducing mouse hover time events to 250ms..."
    Set-ItemPropertyVerified -Path "HKCU:\Control Panel\Mouse" -Name "MouseHoverTime" -Type String -Value "250" # Default: "400" (ms)

    # Details: https://windowsreport.com/how-to-speed-up-windows-11-animations/ and https://www.tenforums.com/tutorials/97842-change-hungapptimeout-value-windows-10-a.html
    ForEach ($DesktopRegistryPath in @($PathToUsersControlPanelDesktop, $PathToCUControlPanelDesktop)) {
        <# $DesktopRegistryPath is the path related to all users and current user configuration #>
        If ($DesktopRegistryPath -eq $PathToUsersControlPanelDesktop) {
            Write-Caption "TO ALL USERS"
        } ElseIf ($DesktopRegistryPath -eq $PathToCUControlPanelDesktop) {
            Write-Caption "TO CURRENT USER"
        }

        Write-Status -Types "+", $TweakType -Status "Don't prompt user to end tasks on shutdown..."
        Set-ItemPropertyVerified -Path "$DesktopRegistryPath" -Name "AutoEndTasks" -Type DWord -Value 1 # Default: Removed or 0

        Write-Status -Types "*", $TweakType -Status "Returning 'Hung App Timeout' to default..."
        Remove-ItemPropertyVerified -Path "$DesktopRegistryPath" -Name "HungAppTimeout"

        Write-Status -Types "+", $TweakType -Status "Reducing mouse and keyboard hooks timeout to 1s..."
        Set-ItemPropertyVerified -Path "$DesktopRegistryPath" -Name "LowLevelHooksTimeout" -Type DWord -Value 1000 # Default: Removed or 5000
        Write-Status -Types "+", $TweakType -Status "Reducing animation speed delay to 1ms on Windows 11..."
        Set-ItemPropertyVerified -Path "$DesktopRegistryPath" -Name "MenuShowDelay" -Type DWord -Value 1 # Default: 400
        Write-Status -Types "+", $TweakType -Status "Reducing Time to kill apps timeout to 5s..."
        Set-ItemPropertyVerified -Path "$DesktopRegistryPath" -Name "WaitToKillAppTimeout" -Type DWord -Value 5000 # Default: 20000
    }

    Write-Section "Gaming Responsiveness Tweaks"

    If (!$Revert) {
        Disable-XboxGameBarDVRandMode
    } Else {
        Enable-XboxGameBarDVRandMode
    }

    Write-Status -Types "*", $TweakType -Status "Enabling game mode..."
    Set-ItemPropertyVerified -Path "$PathToCUGameBar" -Name "AllowAutoGameMode" -Type DWord -Value 1
    Set-ItemPropertyVerified -Path "$PathToCUGameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 1

    # Details: https://www.reddit.com/r/killerinstinct/comments/4fcdhy/an_excellent_guide_to_optimizing_your_windows_10/
    Write-Status -Types "+", $TweakType -Status "Reserving 100% of CPU to Multimedia/Gaming tasks..."
    Set-ItemPropertyVerified -Path "$PathToLMMultimediaSystemProfile" -Name "SystemResponsiveness" -Type DWord -Value 0 # Default: 20
    Write-Status -Types "+", $TweakType -Status "Dedicate more CPU/GPU usage to Gaming tasks..."
    Set-ItemPropertyVerified -Path "$PathToLMMultimediaSystemProfileOnGameTasks" -Name "GPU Priority" -Type DWord -Value 8 # Default: 8
    Set-ItemPropertyVerified -Path "$PathToLMMultimediaSystemProfileOnGameTasks" -Name "Priority" -Type DWord -Value 6 # Default: 2
    Set-ItemPropertyVerified -Path "$PathToLMMultimediaSystemProfileOnGameTasks" -Name "Scheduling Category" -Type String -Value "High" # Default: "Medium"

    # Details: https://winbuzzer.com/2020/08/18/how-to-enable-or-disable-windows-10-reserved-storage-xcxwbt/
    Write-Section "Storage Tweaks"
    Write-Status -Types "-", $TweakType -Status "Disabling Reserved Storage (Windows 10 1903+)..."
    DISM /Online /Set-ReservedStorageState /State:Disabled | Out-Host
}

If (!$Revert) {
    Optimize-Performance # Change from stock configurations that slowdowns the system to improve performance
} Else {
    Optimize-Performance -Revert
}

