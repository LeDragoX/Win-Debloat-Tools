function CountXseconds {
    #param (OptionalParameters)
    1..3 | ForEach-Object {Start-Sleep -Seconds $_ ; "$_ seconds"}
}

CountXseconds