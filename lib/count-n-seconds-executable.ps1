function CountNseconds {
    param (
        $Time = 3
    )
    $Time..0 | ForEach-Object {Start-Sleep -Seconds $_ ; "Closing in $_ seconds..."}
}

CountNseconds