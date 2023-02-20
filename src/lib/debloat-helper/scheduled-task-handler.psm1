Import-Module -DisableNameChecking $PSScriptRoot\..\"title-templates.psm1"

function Set-ScheduledTaskState() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Disabled', 'Enabled')]
        [String] $State,
        [Parameter(Mandatory = $true)]
        [Array] $ScheduledTasks,
        [Parameter(Mandatory = $false)]
        [Array] $Filter
    )

    Begin {
        $Script:TweakType = "TaskScheduler"
    }

    Process {
        ForEach ($ScheduledTask in $ScheduledTasks) {
            If (!(Get-ScheduledTaskInfo -TaskName $ScheduledTask -ErrorAction SilentlyContinue)) {
                Write-Status -Types "?", $TweakType -Status "The $ScheduledTask task was not found." -Warning
                Continue
            }

            If ($ScheduledTask -in $Filter) {
                Write-Status -Types "?", $TweakType -Status "The $ScheduledTask ($((Get-ScheduledTask $ScheduledTask).TaskName)) will be skipped as set on Filter..." -Warning
                Continue
            }

            If ($State -eq 'Disabled') {
                Write-Status -Types "-", $TweakType -Status "Disabling the $ScheduledTask task..."
                Get-ScheduledTask -TaskName (Split-Path -Path $ScheduledTask -Leaf) | Where-Object State -Like "R*" | Disable-ScheduledTask # R* = Ready/Running
            } ElseIf ($State -eq 'Enabled') {
                Write-Status -Types "+", $TweakType -Status "Enabling the $ScheduledTask task..."
                Get-ScheduledTask -TaskName (Split-Path -Path $ScheduledTask -Leaf) | Where-Object State -Like "Disabled" | Enable-ScheduledTask
            }
        }
    }
}

<#
Set-ScheduledTaskState -State Disabled -ScheduledTasks @("ScheduledTask1", "ScheduledTask2", "ScheduledTask3")
Set-ScheduledTaskState -State Disabled -ScheduledTasks @("ScheduledTask1", "ScheduledTask2", "ScheduledTask3") -Filter @("ScheduledTask3")

Set-ScheduledTaskState -State Enabled -ScheduledTasks @("ScheduledTask1", "ScheduledTask2", "ScheduledTask3")
Set-ScheduledTaskState -State Enabled -ScheduledTasks @("ScheduledTask1", "ScheduledTask2", "ScheduledTask3") -Filter @("ScheduledTask3")
#>
