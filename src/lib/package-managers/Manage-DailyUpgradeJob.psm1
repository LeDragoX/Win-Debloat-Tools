Import-Module PSScheduledJob
Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

# Adapted from: https://blogs.technet.microsoft.com/heyscriptingguy/2013/11/23/using-scheduled-tasks-and-scheduled-jobs-in-powershell/

function Register-DailyUpgradeJob() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [String]	  $PackageManagerFullName,
        [String]      $Time,
        [ScriptBlock] $UpdateScriptBlock
    )

    Begin {
        $JobName = "$PackageManagerFullName Daily Upgrade"
        $ScheduledJob = @{
            Name               = $JobName
            ScriptBlock        = $UpdateScriptBlock
            Trigger            = New-JobTrigger -Daily -At $Time
            ScheduledJobOption = New-ScheduledJobOption -RunElevated -MultipleInstancePolicy StopExisting -RequireNetwork
        }
        $ScheduledJobsPath = "\Microsoft\Windows\PowerShell\ScheduledJobs\"
    }

    Process {
        Write-Status -Types "@", $PackageManagerFullName -Status "Creating a daily task to automatically upgrade $PackageManagerFullName packages at $Time."

        If ((Get-ScheduledTask -TaskPath $ScheduledJobsPath -TaskName $JobName -ErrorAction SilentlyContinue) -or (Get-ScheduledJob -Name $JobName -ErrorAction SilentlyContinue)) {
            Write-Status -Types "@", $PackageManagerFullName -Status "The ScheduledJob '$JobName' already exists!" -Warning
            Write-Status -Types "@", $PackageManagerFullName -Status "Re-Creating with the command:"
            Write-Host " { $("$UpdateScriptBlock".Trim(' ')) }`n" -ForegroundColor Cyan
            Stop-ScheduledTask -TaskPath $ScheduledJobsPath -TaskName $JobName
            Unregister-ScheduledJob -Name $JobName
            Register-ScheduledJob @ScheduledJob | Out-Null
        } Else {
            Write-Status -Types "@", $PackageManagerFullName -Status "Creating Scheduled Job with the command:"
            Write-Host " { $("$UpdateScriptBlock".Trim(' ')) }`n" -ForegroundColor Cyan
            Register-ScheduledJob @ScheduledJob | Out-Null
        }
    }
}

function Unregister-DailyUpgradeJob() {
    [CmdletBinding()]
    param (
        [Alias('ScheduledJobName')]
        [Parameter(Position = 0, Mandatory)]
        [String] $Name
    )

    Begin {
        $ScheduledJobsPath = "\Microsoft\Windows\PowerShell\ScheduledJobs\"
    }

    Process {
        Write-Status -Types "@", "Scripted Job" -Status "Removing the Scheduled Job $Name."

        If ((Get-ScheduledTask -TaskPath $ScheduledJobsPath -TaskName $Name -ErrorAction SilentlyContinue) -or (Get-ScheduledJob -Name $Name -ErrorAction SilentlyContinue)) {
            Write-Status -Types "@", "Scripted Job" -Status "ScheduledJob: $Name FOUND!"
            Stop-ScheduledTask -TaskPath $ScheduledJobsPath -TaskName $Name
            Unregister-ScheduledJob -Name $Name
        } Else {
            Write-Status -Types "@", "Scripted Job" -Status "Scheduled Job $Name was not found." -Warning
        }
    }
}
