Function CountNseconds {
    
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [Int]       $Time = 3,
        [String]    $Msg = "Exiting in"
    )

    $Time..0 | ForEach-Object { Start-Sleep -Seconds 1 ; "$Msg $_ seconds..." }
}

# Demo: CountNseconds -Time 5 -Msg "This is closing in"