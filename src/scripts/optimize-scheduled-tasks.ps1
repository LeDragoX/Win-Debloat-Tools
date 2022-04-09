Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://youtu.be/qWESrvP_uU8
# Adapted from: https://github.com/ChrisTitusTech/win10script
# Adapted from: https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f
# Adapted from: https://github.com/Sycnex/Windows10Debloater
# Adapted from: https://github.com/kalaspuffar/windows-debloat

function Optimize-ScheduledTasksList() {
    [CmdletBinding()]
    param (
        [Switch] $Revert,
        [Array]  $EnableStatus = @(
            "[-][TaskScheduler] Disabling",
            "[+][TaskScheduler] Enabling"
        ),
        [Array]  $Commands = @(
            { Get-ScheduledTask -TaskName "$ScheduledTask".Split("\")[-1] | Where-Object State -Like "R*" | Disable-ScheduledTask }, # R* = Ready/Running Tasks
            { Get-ScheduledTask -TaskName "$ScheduledTask".Split("\")[-1] | Where-Object State -Like "Disabled" | Enable-ScheduledTask }
        )
    )

    If (($Revert)) {
        Write-Warning "[<][TaskScheduler] Reverting: $Revert."
        $EnableStatus = @(
            "[<][TaskScheduler] Re-Enabling",
            "[<][TaskScheduler] Re-Disabling"
        )
        $Commands = @(
            { Get-ScheduledTask -TaskName "$ScheduledTask".Split("\")[-1] | Where-Object State -Like "Disabled" | Enable-ScheduledTask },
            { Get-ScheduledTask -TaskName "$ScheduledTask".Split("\")[-1] | Where-Object State -Like "R*" | Disable-ScheduledTask } # R* = Ready/Running Tasks
        )
    }

    Write-Title -Text "Scheduled Tasks tweaks"
    Write-Section -Text "Disabling Scheduled Tasks"

    # Adapted from: https://docs.microsoft.com/pt-br/windows-server/remote/remote-desktop-services/rds-vdi-recommendations#task-scheduler
    $DisableScheduledTasks = @(
        "\Microsoft\Office\OfficeTelemetryAgentLogOn"
        "\Microsoft\Office\OfficeTelemetryAgentFallBack"
        "\Microsoft\Office\Office 15 Subscription Heartbeat"
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
        "\Microsoft\Windows\Application Experience\StartupAppTask"
        "\Microsoft\Windows\Autochk\Proxy"
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"         # Recommended state for VDI use
        "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"       # Recommended state for VDI use
        "\Microsoft\Windows\Customer Experience Improvement Program\Uploader"
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"              # Recommended state for VDI use
        "\Microsoft\Windows\Defrag\ScheduledDefrag"                                       # Recommended state for VDI use
        "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
        "\Microsoft\Windows\Location\Notifications"                                       # Recommended state for VDI use
        "\Microsoft\Windows\Location\WindowsActionDialog"                                 # Recommended state for VDI use
        "\Microsoft\Windows\Maps\MapsToastTask"                                           # Recommended state for VDI use
        "\Microsoft\Windows\Maps\MapsUpdateTask"                                          # Recommended state for VDI use
        "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser"                # Recommended state for VDI use
        "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"                   # Recommended state for VDI use
        "\Microsoft\Windows\Retail Demo\CleanupOfflineContent"                            # Recommended state for VDI use
        "\Microsoft\Windows\Shell\FamilySafetyMonitor"                                    # Recommended state for VDI use
        "\Microsoft\Windows\Shell\FamilySafetyRefreshTask"                                # Recommended state for VDI use
        "\Microsoft\Windows\Shell\FamilySafetyUpload"
        "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary"                          # Recommended state for VDI use
    )

    ForEach ($ScheduledTask in $DisableScheduledTasks) {
        If (Get-ScheduledTaskInfo -TaskName $ScheduledTask -ErrorAction SilentlyContinue) {
            Write-Host "$($EnableStatus[0]) the $ScheduledTask Task ..."
            Invoke-Expression "$($Commands[0])"
        }
        Else {
            Write-Warning "[?][TaskScheduler] $ScheduledTask was not found."
        }
    }

    Write-Section -Text "Enabling Scheduled Tasks"
    $EnableScheduledTasks = @(
        "\Microsoft\Windows\Maintenance\WinSAT"                     # WinSAT detects incorrect system configurations, that causes performance loss, then sends it via telemetry | Reference (PT-BR): https://youtu.be/wN1I0IPgp6U?t=16
        "\Microsoft\Windows\RecoveryEnvironment\VerifyWinRE"        # It's about the Recovery before starting Windows, with Diagnostic tools and Troubleshooting when your PC isn't healthy, need this ON.
        "\Microsoft\Windows\Windows Error Reporting\QueueReporting" # Windows Error Reporting event, needed to improve compatibility with your hardware
    )

    ForEach ($ScheduledTask in $EnableScheduledTasks) {
        If (Get-ScheduledTaskInfo -TaskName $ScheduledTask -ErrorAction SilentlyContinue) {
            Write-Host "[+][TaskScheduler] Enabling the $ScheduledTask Task ..."
            Get-ScheduledTask -TaskName "$ScheduledTask".Split("\")[-1] | Where-Object State -Like "Disabled" | Enable-ScheduledTask
        }
        Else {
            Write-Warning "[?][TaskScheduler] $ScheduledTask was not found."
        }
    }
}

function Main() {
    # List all Scheduled Tasks: Get-ScheduledTask | Select-Object -Property State, TaskPath, TaskName | Sort-Object State, TaskPath, TaskName | Out-GridView
    If (!($Revert)) {
        Optimize-ScheduledTasksList # Disable Scheduled Tasks that causes slowdowns
    }
    Else {
        Optimize-ScheduledTasksList -Revert
    }
}

Main