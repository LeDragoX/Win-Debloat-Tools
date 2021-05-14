Function CountNseconds {
    param (
        $Time = 3,
        $Msg = 'Exiting in'
    )
    $Time..0 | ForEach-Object {Start-Sleep -Seconds 1 ; "$Msg $_ seconds..."}
}

# Demo: CountNseconds -Time 5 -Msg "This is closing in"