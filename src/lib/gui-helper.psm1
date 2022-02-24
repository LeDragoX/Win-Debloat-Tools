function Set-GUILayout() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    Write-Host "[@] Loading GUI Layout..."
    # Loading System Libs
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()  # Rounded Buttons :3

    # <== FONTS ==>

    $Global:Fonts = @(
        "Arial"                 # 0
        "Bahnschrift"           # 1
        "Calibri"               # 2
        "Cambria"               # 3
        "Cambria Math"          # 4
        "Candara"               # 5
        "Comic Sans MS"         # 6
        "Consolas"              # 7
        "Constantia"            # 8
        "Corbel"                # 9
        "Courier New"           # 10
        "Ebrima"                # 11
        "Franklin Gothic"       # 12
        "Gabriola"              # 13
        "Gadugi"                # 14
        "Georgia"               # 15
        "HoloLens MDL2 Assets"  # 16
        "Impact"                # 17
        "Ink Free"              # 18
        "Javanese Text"         # 19
        "Leelawadee UI"         # 20
        "Lucida Console"        # 21
        "Lucida Sans Unicode"   # 22
        "Malgun Gothic"         # 23
        "Microsoft Himalaya"    # 24
        "Microsoft JhengHei"    # 25
        "Microsoft JhengHei UI" # 26
        "Microsoft New Tai Lue" # 27
        "Microsoft PhagsPa"     # 28
        "Microsoft Sans Serif"  # 29
        "Microsoft Tai Le"      # 30
        "Microsoft YaHei"       # 31
        "Microsoft YaHei UI"    # 32
        "Microsoft Yi Baiti"    # 33
        "MingLiU_HKSCS-ExtB"    # 34
        "MingLiU-ExtB"          # 35
        "Mongolian Baiti"       # 36
        "MS Gothic"             # 37
        "MS PGothic"            # 38
        "MS UI Gothic"          # 39
        "MV Boli"               # 40
        "Myanmar Text"          # 41
        "Nirmala UI"            # 42
        "NSimSun"               # 43
        "Palatino Linotype"     # 44
        "PMingLiU-ExtB"         # 45
        "Segoe Fluent Icons"    # 46
        "Segoe MDL2 Assets"     # 47
        "Segoe Print"           # 48
        "Segoe Script"          # 49
        "Segoe UI"              # 50
        "Segoe UI Emoji"        # 51
        "Segoe UI Historic"     # 52
        "Segoe UI Symbol"       # 53
        "Segoe UI Variable"     # 54
        "SimSun"                # 55
        "SimSun-ExtB"           # 56
        "Sitka Text"            # 57
        "Sylfaen"               # 58
        "Symbol"                # 59
        "Tahoma"                # 60
        "Times New Roman"       # 61
        "Trebuchet MS"          # 62
        "Verdana"               # 63
        "Webdings"              # 64
        "Wingdings"             # 65
        "Yu Gothic"             # 66
        "Yu Gothic UI"          # 67
        "Unispace"              # 68
        # Installable           # ##
        "Courier"               # 69
        "Fixedsys"              # 70
        "JetBrains Mono"        # 71
        "JetBrains Mono NL"     # 72
        "Modern"                # 73
        "MS Sans Serif"         # 74
        "MS Serif"              # 75
        "Roman"                 # 76
        "Script"                # 77
        "Small Fonts"           # 78
        "System"                # 79
        "Terminal"              # 80
    )  

    # <== Used Font ==>

    $Global:FontName = $Fonts[62]

    # <== SIZES LAYOUT ==>

    # To Forms
    $Global:MaxWidth = 1366 * 0.85 # ~ 1162
    $Global:MaxHeight = 768 * 0.85 # ~ 653
    # To Panels
    $Global:CurrentPanelIndex = -1
    $NumOfPanels = 4
    [Int]$PanelWidth = ($MaxWidth / $NumOfPanels)
    # To Labels
    $LabelWidth = $PanelWidth
    $TitleLabelHeight = 35
    $CaptionLabelHeight = 20
    # To Buttons
    $ButtonWidth = $PanelWidth * 0.91
    $ButtonHeight = 30
    $Global:DistanceBetweenButtons = 5
    # To Fonts
    $Global:FontSize1 = 12
    $Global:FontSize2 = 14
    $Global:FontSize3 = 16
    $Global:FontSize4 = 20

    # <== LOCATIONS LAYOUT ==>

    [Int]$Global:TitleLabelX = $PanelWidth * 0
    [Int]$Global:TitleLabelY = $MaxHeight * 0.01
    [Int]$Global:CaptionLabelX = $PanelWidth * 0.25
    [Int]$Global:ButtonX = $PanelWidth * 0.01
    [Int]$Global:FirstButtonY = $TitleLabelY + $TitleLabelHeight + 30 # 70

    # <== COLOR PALETTE ==>

    $Global:Green = "#1fff00"
    $Global:LightBlue = "#00ffff"
    $Global:LightGray = "#eeeeee"
    $Global:WinDark = "#252525"
    $Global:WarningColor = "#eed202"

    # <== GUI ELEMENT LAYOUT ==>

    $Global:TextAlign = "MiddleCenter"

    # Panel Layout

    $Global:PWidth = $PanelWidth
    $Global:PHeight = $MaxHeight

    # Title Label Layout - Unique per Panel

    $Global:TLWidth = $LabelWidth
    $Global:TLHeight = $TitleLabelHeight

    # Caption Label Layout

    $Global:CLWidth = $LabelWidth - ($LabelWidth - $ButtonWidth)
    $Global:CLHeight = $CaptionLabelHeight

    # Big Button Layout - Unique per Panel

    $Global:BBWidth = $ButtonWidth
    $Global:BBHeight = ($ButtonHeight * 2) + $DistanceBetweenButtons

    # Small Button Layout

    $Global:SBWidth = $ButtonWidth
    $Global:SBHeight = $ButtonHeight

}

function Create-Panel() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [Int] $Width,
        [Int] $Height,
        [Int] $LocationX,
        [Int] $LocationY,
        [Bool] $HasVerticalScroll = $false
    )

    Write-Verbose "Panel$($Global:CurrentPanelIndex+1): W$Width, H$Height, X$LocationX, Y$LocationY"
    $Panel = New-Object System.Windows.Forms.Panel
    $Panel.Width = $Width
    $Panel.Height = $Height
    $Panel.Location = New-Object System.Drawing.Point($LocationX, $LocationY)

    if ($HasVerticalScroll) {
        $Panel.HorizontalScroll.Enabled = $false
        $Panel.HorizontalScroll.Visible = $false
        $Panel.AutoScroll = $true
    }

    return $Panel
}

function Create-Label() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [String] $Text,
        [Int] $Width,
        [Int] $Height,
        [Int] $LocationX,
        [Int] $LocationY,
        [String] $Font = $Global:FontName,
        [Int] $FontSize,
        [String] $FontStyle = "Regular",
        [String] $ForeColor = $Global:Green,
        [String] $TextAlign = $Global:TextAlign
    )

    Write-Verbose "Label '$Text': W$Width, H$Height, X$LocationX, Y$LocationY, F $Font, FSize $FontSize, FStyle $FontStyle, FC $ForeColor, TA $TextAlign"
    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = $Text
    $Label.Width = $Width
    $Label.Height = $Height
    $Label.Location = New-Object System.Drawing.Point($LocationX, $LocationY)
    $Label.Font = New-Object System.Drawing.Font($Font, $FontSize, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::$FontStyle))
    $Label.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($ForeColor)
    $Label.TextAlign = $TextAlign

    return $Label
}

function Create-Button() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [String] $Text,
        [Int] $Width,
        [Int] $Height,
        [Int] $LocationX,
        [Int] $LocationY,
        [String] $Font = $Global:FontName,
        [Int] $FontSize,
        [String] $FontStyle = "Regular",
        [String] $ForeColor = $Global:LightGray,
        [String] $TextAlign = $Global:TextAlign
    )

    Write-Verbose "Button '$Text': W$Width, H$Height, X$LocationX, Y$LocationY, F $Font, FSize $FontSize, FStyle $FontStyle, FC $ForeColor, TA $TextAlign"
    $Button = New-Object System.Windows.Forms.Button
    $Button.Text = $Text
    $Button.Width = $Width
    $Button.Height = $Height
    $Button.Location = New-Object System.Drawing.Point($LocationX, $LocationY)
    $Button.Font = New-Object System.Drawing.Font($Font, $FontSize, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::$FontStyle))
    $Button.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($ForeColor)
    $Button.TextAlign = $TextAlign

    return $Button
}