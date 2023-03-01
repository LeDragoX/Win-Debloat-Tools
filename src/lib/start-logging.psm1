function Start-Logging {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position = 0)]
        [String] $Path = "$env:TEMP\Win-DT-Logs",
        [Parameter(Position = 1, Mandatory)]
        [String] $File
    )

    Begin {
        $Date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $File = "$File`_$Date.log"
    }

    Process {
        Write-Host -NoNewline "[@] " -ForegroundColor Blue
        Start-Transcript -Path "$Path\$File"
        Write-Host
    }
}

function Stop-Logging {
    Write-Host -NoNewline "[@] " -ForegroundColor Blue
    Stop-Transcript
    Write-Host
}

<#
Example:
Start-Logging -File (Split-Path -Path $PSCommandPath -Leaf).Split(".")[0]
Start-Logging -Path "$env:TEMP\Win-DT-Logs" -File "WingetDailyUpgrade" # Automatically uses .log format
Stop-Logging # Only after logging has started
#>
