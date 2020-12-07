function CountNseconds {
    param (
        $Time = 3,
        $Msg = 'Closing in'
    )
    $Time..0 | ForEach-Object {Start-Sleep -Seconds 1 ; "$Msg $_ seconds..."}
}