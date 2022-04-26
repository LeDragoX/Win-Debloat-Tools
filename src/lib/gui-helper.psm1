Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Set-GUILayout() {
    [CmdletBinding()] param ()

    Write-Mandatory "Loading GUI Layout..."
    # Loading System Libs
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()  # Rounded Buttons :3

    # <===== FONTS =====>

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

    # <===== Used Font =====>

    $Global:FontName = $Fonts[62]

    # <===== SIZES LAYOUT =====>

    # To Forms
    $Global:FormWidth = 1366 * 0.85 # ~ 1162
    $Global:FormHeight = 768 * 0.85 # ~ 653
    # To Panels
    $Global:CurrentPanelIndex = -1
    $NumOfPanels = 4
    [Int] $Global:PanelWidth = ($FormWidth / $NumOfPanels)
    # To Labels
    $Global:LabelWidth = $PanelWidth
    $Global:TitleLabelHeight = 35
    $Global:CaptionLabelHeight = 20
    # To Buttons
    $Global:ButtonWidth = $PanelWidth * 0.91
    $Global:ButtonHeight = 30
    $Global:DistanceBetweenButtons = 5
    # To Fonts
    $Global:FontSize1 = 12
    $Global:FontSize2 = 14
    $Global:FontSize3 = 16
    $Global:FontSize4 = 20

    # <===== LOCATIONS LAYOUT =====>

    [Int] $Global:TitleLabelX = $PanelWidth * 0
    [Int] $Global:TitleLabelY = $FormHeight * 0.01
    [Int] $Global:CaptionLabelX = $PanelWidth * 0.25
    [Int] $Global:ButtonX = $PanelWidth * 0.01
    [Int] $Global:FirstButtonY = $TitleLabelY + $TitleLabelHeight + 30 # 70

    # <===== COLOR PALETTE =====>

    $Global:Gray = "#2C2C2C"
    $Global:Green = "#1FFF00"
    $Global:LightGray = "#EEEEEE"
    $Global:Purple = "#996DFF"
    $Global:WinBlue = "#08ABF7"
    $Global:WinDark = "#252525"
    $Global:WarningColor = "#EED202"

    # <===== GUI ELEMENT LAYOUT =====>

    $Global:TextAlign = "MiddleCenter"

    # Panel Layout -> $PanelWidth & $FormHeight
    # Title Label Layout - (Unique per Panel) -> $LabelWidth & $TitleLabelHeight
    # Caption Label Layout
    $Global:CaptionLabelWidth = $LabelWidth - ($LabelWidth - $ButtonWidth) # & $CaptionLabelHeight
    # Big Button Layout (Unique per Panel) -> $ButtonWidth &
    $Global:BBHeight = ($ButtonHeight * 2) + $DistanceBetweenButtons
    # Small Button Layout -> $ButtonWidth & $ButtonHeight
}

function New-Form {
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.Form])]
    param (
        [Int]    $Width,
        [Int]    $Height,
        [String] $Text,
        [String] $BackColor,
        [Bool]   $Minimize = $false,
        [Bool]   $Maximize = $false,
        [String] $FormBorderStyle = 'FixedSingle',
        [String] $StartPosition = 'CenterScreen',
        [Bool]   $TopMost = $false
    )

    Write-Verbose "Form '$Text': W$Width, H$Height, BC $BackColor, Min $Minimize, Max $Maximize, FBS $FormBorderStyle, SP $StartPosition, TM $TopMost"
    $Form = New-Object System.Windows.Forms.Form
    $Form.Size = New-Object System.Drawing.Size($Width, $Height)
    $Form.Text = $Text
    $Form.BackColor = [System.Drawing.ColorTranslator]::FromHtml($BackColor)
    $Form.MinimizeBox = $Minimize            # Hide the Minimize Button
    $Form.MaximizeBox = $Maximize            # Hide the Maximize Button
    $Form.FormBorderStyle = $FormBorderStyle # Not adjustable
    $Form.StartPosition = $StartPosition     # Appears on the center
    $Form.TopMost = $TopMost

    return $Form
}

function New-FormIcon {
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.Form])]
    param (
        [System.Windows.Forms.Form] $Form,
        [String]                    $ImageLocation
    )

    # Adapted from: https://stackoverflow.com/a/53377253
    Write-Verbose "FormIcon: IL $ImageLocation"
    $IconBase64 = [Convert]::ToBase64String((Get-Content $ImageLocation -Encoding Byte))
    $IconBytes = [Convert]::FromBase64String($IconBase64)
    $Stream = New-Object IO.MemoryStream($IconBytes, 0, $IconBytes.Length)
    $Stream.Write($IconBytes, 0, $IconBytes.Length);
    $Form.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $Stream).GetHIcon())
    $Stream.Dispose()

    return $Form
}

function New-Panel() {
    [CmdletBinding()]
    param (
        [Int] $Width,
        [Int] $Height,
        [Int] $LocationX,
        [Int] $LocationY,
        [Switch] $HasVerticalScroll
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

function New-Label() {
    [CmdletBinding()]
    param (
        [String] $Text,
        [Int]    $Width,
        [Int]    $Height,
        [Int]    $LocationX,
        [Int]    $LocationY,
        [String] $Font = $Global:FontName,
        [Int]    $FontSize,
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

function New-Button() {
    [CmdletBinding()]
    param (
        [String] $Text,
        [Int]    $Width,
        [Int]    $Height,
        [Int]    $LocationX,
        [Int]    $LocationY,
        [String] $Font = $Global:FontName,
        [Int]    $FontSize,
        [String] $FontStyle = "Regular",
        [String] $ForeColor = $Global:LightGray,
        [String] $BackColor = $Global:Gray,
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
    $Button.BackColor = [System.Drawing.ColorTranslator]::FromHtml($BackColor)
    $Button.TextAlign = $TextAlign

    return $Button
}

function New-PictureBox {
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.PictureBox])]
    param (
        [String] $ImageLocation,
        [Int]    $Width,
        [Int]    $Height,
        [Int]    $LocationX,
        [Int]    $LocationY,
        [String] $SizeMode = 'Zoom' # Autosize, CenterImage, Normal, StretchImage, Zoom
    )

    Write-Verbose "PictureBox: IL $ImageLocation, W$Width, H$Height, X$LocationX, Y$LocationY, SM $SizeMode"
    $PictureBox = New-Object System.Windows.Forms.PictureBox
    $PictureBox.imageLocation = $ImageLocation
    $PictureBox.Width = $Width
    $PictureBox.Height = $Height
    $PictureBox.Location = New-Object System.Drawing.Point($LocationX, $LocationY)
    $PictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::$SizeMode

    return $PictureBox
}