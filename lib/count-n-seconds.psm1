function CountNseconds {
    param (
        $Time = 3,
        $Msg = 'Exiting in'
    )
    $Time..0 | ForEach-Object {Start-Sleep -Seconds 1 ; "$Msg $_ seconds..."}
}