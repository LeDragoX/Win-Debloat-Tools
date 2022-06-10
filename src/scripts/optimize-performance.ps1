Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"open-file.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://youtu.be/hQSkPmZRCjc
# Adapted from: https://github.com/ChrisTitusTech/win10script
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
        Write-Status -Types "<", $TweakType -Status "Reverting the tweaks is set to '$Revert'." -Warning
        $Zero = 1
        $One = 0
        $EnableStatus = @(
            @{ Symbol = "<"; Status = "Re-Enabling"; }
            @{ Symbol = "<"; Status = "Re-Disabling"; }
        )
    }

    $ExistingPowerPlans = $((powercfg -L)[3..(powercfg -L).Count])
    # Found on the registry: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\User\Default\PowerSchemes
    $BuiltInPowerPlans = @{
        "Power Saver"            = "a1841308-3541-4fab-bc81-f71556f20b4a"
        "Balanced (recommended)" = "381b4222-f694-41f0-9685-ff5bb260df2e"
        "High Performance"       = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        "Ultimate Performance"   = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    }
    $UniquePowerPlans = $BuiltInPowerPlans.Clone()
    # Initialize all Path variables used to Registry Tweaks
    $PathToLMPoliciesPsched = "HKLM:\SOFTWARE\Policies\Microsoft\Psched"
    $PathToLMPoliciesWindowsStore = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    $PathToLMPrefetchParams = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
    $PathToCUGameBar = "HKCU:\SOFTWARE\Microsoft\GameBar"

    Write-Title -Text "Performance Tweaks"

    Write-Section -Text "Gaming"
    Write-Status -Types $EnableStatus[0].Symbol, $TweakType -Status "$($EnableStatus[0].Status) Game Bar & Game DVR..."
    $Scripts = @("disable-game-bar-dvr.reg")
    If ($Revert) {
        $Scripts = @("enable-game-bar-dvr.reg")
    }
    Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -NoDialog

    Write-Status -Types "=", $TweakType -Status "Enabling game mode..."
    Set-ItemProperty -Path "$PathToCUGameBar" -Name "AllowAutoGameMode" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToCUGameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 1

    Write-Section -Text "System"
    Write-Caption -Text "Display"
    Write-Status -Types "+", $TweakType -Status "Enable Hardware Accelerated GPU Scheduling... (Windows 10 20H1+ - Needs Restart)"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Type DWord -Value 2

    Write-Status -Types $EnableStatus[0].Symbol, $TweakType -Status "$($EnableStatus[0].Status) SysMain/Superfetch..."
    # As SysMain was already disabled on the Services, just need to remove it's key
    # [@] (0 = Disable SysMain, 1 = Enable when program is launched, 2 = Enable on Boot, 3 = Enable on everything)
    Set-ItemProperty -Path "$PathToLMPrefetchParams" -Name "EnableSuperfetch" -Type DWord -Value $Zero

    Write-Status -Types $EnableStatus[0].Symbol, $TweakType -Status "$($EnableStatus[0].Status) Remote Assistance..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value $Zero

    Write-Status -Types "-", $TweakType -Status "Disabling Ndu High RAM Usage..."
    # [@] (2 = Enable Ndu, 4 = Disable Ndu)
    Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Type DWord -Value 4

    # Details: https://www.tenforums.com/tutorials/94628-change-split-threshold-svchost-exe-windows-10-a.html
    # Will reduce Processes number considerably on > 4GB of RAM systems
    Write-Status -Types "+", $TweakType -Status "Setting SVCHost to match RAM size..."
    $RamInKB = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1KB
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $RamInKB

    Write-Status -Types "+", $TweakType -Status "Unlimiting your network bandwidth for all your system..." # Based on this Chris Titus video: https://youtu.be/7u1miYJmJ_4
    If (!(Test-Path "$PathToLMPoliciesPsched")) {
        New-Item -Path "$PathToLMPoliciesPsched" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMPoliciesPsched" -Name "NonBestEffortLimit" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff

    Write-Status -Types "=", $TweakType -Status "Enabling Windows Store apps Automatic Updates..."
    If (!(Test-Path "$PathToLMPoliciesWindowsStore")) {
        New-Item -Path "$PathToLMPoliciesWindowsStore" -Force | Out-Null
    }
    If ((Get-Item "$PathToLMPoliciesWindowsStore").GetValueNames() -like "AutoDownload") {
        Remove-ItemProperty -Path "$PathToLMPoliciesWindowsStore" -Name "AutoDownload" # [@] (2 = Disable, 4 = Enable)
    }

    Write-Section -Text "Power Plan Tweaks"

    Write-Status -Types "@", $TweakType -Status "Cleaning up duplicated Power plans..."
    ForEach ($PowerCfgString in $ExistingPowerPlans) {
        $PowerPlanGUID = $PowerCfgString.Split(':')[1].Split('(')[0].Trim()
        $PowerPlanName = $PowerCfgString.Split('(')[-1].Replace(')', '').Trim()

        If (($PowerPlanGUID -in $BuiltInPowerPlans.Values)) {
            Write-Status -Types "@", $TweakType -Status "The '$PowerPlanName' power plan` is built-in, skipping $PowerPlanGUID ..." -Warning
            Continue
        }

        Try {
            If (($PowerPlanName -notin $UniquePowerPlans.Keys) -and ($PowerPlanGUID -notin $UniquePowerPlans.Values)) {
                $UniquePowerPlans.Add($PowerPlanName, $PowerPlanGUID)
            } Else {
                Write-Status -Types "-", $TweakType -Status "Duplicated '$PowerPlanName' power plan found, deleting $PowerPlanGUID ..."
                powercfg -Delete $PowerPlanGUID
            }
        } Catch {
            Write-Status -Types "-", $TweakType -Status "Duplicated '$PowerPlanName' power plan found, deleting $PowerPlanGUID ..."
            powercfg -Delete $PowerPlanGUID
        }
    }

    Write-Status -Types "+", $TweakType -Status "Setting Power Plan to High Performance..."
    powercfg -SetActive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

    Write-Status -Types "+", $TweakType -Status "Creating the Ultimate Performance hidden Power Plan..."
    powercfg -DuplicateScheme e9a42b02-d5df-448d-aa00-03f14749eb61

    Write-Status -Types "+", $TweakType -Status "Setting Hibernate size to reduced..."
    powercfg -Hibernate -type Reduced

    Write-Status -Types "+", $TweakType -Status "Enabling Hibernate (Boots faster on Laptops/PCs with HDD and generate '$env:SystemDrive\hiberfil.sys' file)..."
    powercfg -Hibernate on

    Write-Section -Text "Network & Internet"
    Write-Caption -Text "Proxy"
    Write-Status -Types "-", $TweakType -Status "Fixing Edge slowdown by NOT Automatically Detecting Settings..."
    # Code from: https://www.reddit.com/r/PowerShell/comments/5iarip/set_proxy_settings_to_automatically_detect/?utm_source=share&utm_medium=web2x&context=3
    $Key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
    $Data = (Get-ItemProperty -Path $Key -Name DefaultConnectionSettings).DefaultConnectionSettings
    $Data[8] = 3
    Set-ItemProperty -Path $Key -Name DefaultConnectionSettings -Value $Data

}

function Main() {
    If (!$Revert) {
        Optimize-Performance # Change from stock configurations that slowdowns the system to improve performance
    } Else {
        Optimize-Performance -Revert
    }
}

Main
