function Start-Logging {
    [CmdletBinding()]
    param (
        [String] $LOGPATH = $env:TEMP,
        [String] $File
    )
    $Date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $File = "$File`_$Date.log"

    Write-Host -NoNewline "[@] " -ForegroundColor White
    Start-Transcript -Path "$LOGPATH\$File"
    Write-Host
}

function Stop-Logging {
    Write-Host -NoNewline "[@] " -ForegroundColor White
    Stop-Transcript
    Write-Host
}