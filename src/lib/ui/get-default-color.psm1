function Get-DefaultColor() {
    $Colors = @{
        Cyan          = "#25F7D8"
        DarkGray      = "#2C2C2C"
        Green         = "#55EE00"
        LightGreen    = "#9CFF75"
        WarningYellow = "#EED202"
        White         = "#FEFEFE"
    }

    $BrandColors = @{
        AMD    = @{ Ryzen = "#E4700D" }
        Intel  = "#0071C5"
        NVIDIA = "#76B900"
        Win    = @{ Blue = "#08ABF7"; Dark = "#252525" }
    }

    return $Colors, $BrandColors
}
