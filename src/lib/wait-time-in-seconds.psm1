function Wait-TimeInSecond() {
    [CmdletBinding()]
    param (
        [Int]    $Time = 3,
        [String] $Msg = "Exiting in"
    )

    $Time..0 | ForEach-Object { Start-Sleep -Seconds 1 ; "$Msg $_ seconds..." }
}

<#
Example:
Wait-TimeInSecond -Time 5 -Msg "This is closing in"
#>