Import-Module -DisableNameChecking "$PSScriptRoot\Get-TempScriptFolder.psm1"

function Start-Logging() {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position = 0)]
        [String] $Path = "$(Get-TempScriptFolder)\logs",
        [Parameter(Position = 1, Mandatory)]
        [String] $File
    )

    Begin {
        $File = "$File.log"
    }

    Process {
        Write-Host -NoNewline "[@] " -ForegroundColor Blue
        Start-Transcript -Path "$Path\$File" -Append
        Write-Host
    }
}

function Stop-Logging() {
    Write-Host -NoNewline "[@] " -ForegroundColor Blue
    Stop-Transcript
    Write-Host
}

<#
Example:
Start-Logging -File (Split-Path -Path $PSCommandPath -Leaf).Split(".")[0]
Start-Logging -Path "$env:TEMP\Win-Debloat-Tools\logs" -File "WingetDailyUpgrade" # Automatically uses .log format
Stop-Logging # Only after logging has started
#>
