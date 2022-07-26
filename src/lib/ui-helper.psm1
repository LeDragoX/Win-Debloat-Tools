Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://stackoverflow.com/a/35965782
# Adapted from: https://www.osdeploy.com/modules/pshot/technical/resolution-scale-and-dpi
# Adapted from: https://stackoverflow.com/a/53377253
# Adapted from: https://stackoverflow.com/a/68296985

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles() # Rounded Buttons :3 (Win 11)

function Get-CurrentResolution {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param ()

    # Adapted from: https://www.reddit.com/r/PowerShell/comments/67no9x/comment/dgrry3b/?utm_source=share&utm_medium=web2x&context=3
    $NumberOfScreens = (Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams | Where-Object { $_.Active -like "True" }).Active.Count
    $ScreenWidth = $null
    $ScreenHeight = $null

    Write-Verbose "Num. of Monitors: $NumberOfScreens"

    If ($NumberOfScreens -eq 1) {
        # Accepts Scaling/DPI
        [System.Windows.Forms.SystemInformation]::VirtualScreen | ForEach-Object {
            Write-Verbose "W: $($_.Width) | H: $($_.Height)"

            If (!$ScreenWidth -or !$ScreenHeight) {
                $ScreenWidth = $_.Width
                $ScreenHeight = $_.Height
            }

            If (($_.Width) -and ($_.Width -le $ScreenWidth)) {
                $ScreenWidth = $_.Width
                $ScreenHeight = $_.Height
            }
        }
    } Else {
        # Doesn't accepts Scaling/DPI (rollback method)
        Get-CimInstance -Class "Win32_VideoController" | ForEach-Object {
            Write-Verbose "W: $($_.CurrentHorizontalResolution) | H: $($_.CurrentVerticalResolution)"

            If (!$ScreenWidth -or !$ScreenHeight) {
                $ScreenWidth = $_.CurrentHorizontalResolution
                $ScreenHeight = $_.CurrentVerticalResolution
            }

            If (($_.CurrentHorizontalResolution) -and ($_.CurrentHorizontalResolution -le $ScreenWidth)) {
                $ScreenWidth = $_.CurrentHorizontalResolution
                $ScreenHeight = $_.CurrentVerticalResolution
            }
        }
    }

    Write-Verbose "Width: $ScreenWidth, Height: $ScreenHeight"
    return $ScreenWidth, $ScreenHeight
}

function Set-UIFont() {
    [CmdletBinding()] param ()

    $Script:Fonts = @(
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

    $Script:MainFont = $Fonts[62]
}

function New-Form() {
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.Form])]
    param (
        [Int]    $Width,
        [Int]    $Height,
        [String] $Text,
        [String] $BackColor = "#252525", # Windows Dark
        [Bool]   $Minimize = $true,
        [Bool]   $Maximize = $true,
        [String] $FormBorderStyle = 'FixedSingle', # FixedSingle, Fixed3D, FixedDialog, Sizable, FixedToolWindow, SizableToolWindow
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

function New-FormIcon() {
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.Form])]
    param (
        [System.Windows.Forms.Form] $Form,
        [String]                    $ImageLocation
    )

    Write-Verbose "FormIcon: IL $ImageLocation"
    $IconBase64 = [Convert]::ToBase64String((Get-Content $ImageLocation -Encoding Byte))
    $IconBytes = [Convert]::FromBase64String($IconBase64)
    $Stream = New-Object IO.MemoryStream($IconBytes, 0, $IconBytes.Length)
    $Stream.Write($IconBytes, 0, $IconBytes.Length);
    $Form.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $Stream).GetHIcon())
    $Stream.Dispose()

    return $Form
}

function New-TabControl() {
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.TabControl])]
    param (
        [Int]    $Width,
        [Int]    $Height,
        [Int]    $LocationX,
        [Int]    $LocationY,
        [String] $ForeColor = "#FFFFFF", # White
        [String] $BackColor = "#252525" # Windows Dark
    )

    $FormTabControl = New-object System.Windows.Forms.TabControl
    $FormTabControl.Size = "$Width,$Height"
    $FormTabControl.Location = "$LocationX,$LocationY"
    $FormTabControl.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($ForeColor)
    $FormTabControl.BackColor = [System.Drawing.ColorTranslator]::FromHtml($BackColor)

    return $FormTabControl
}

function New-TabPage() {
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.Form])]
    param (
        [String] $Name,
        [String] $Text,
        [String] $ForeColor = "#FFFFFF", # White
        [String] $BackColor = "#252525" # Windows Dark
    )

    $FormTabPage = New-object System.Windows.Forms.TabPage
    $FormTabPage.DataBindings.DefaultDataSourceUpdateMode = 0
    $FormTabPage.UseVisualStyleBackColor = $True
    $FormTabPage.Name = $Name
    $FormTabPage.Text = $Text
    $FormTabPage.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($ForeColor)
    $FormTabPage.BackColor = [System.Drawing.ColorTranslator]::FromHtml($BackColor)
    $FormTabPage.AutoScroll = $True

    return $FormTabPage
}


function New-Panel() {
    [CmdletBinding()]
    param (
        [Int]           $Width,
        [Int]           $Height,
        [System.Object] $ElementBefore,
        [Int]           $MarginTop = 0,
        [Int]           $LocationX,
        [Int]           $LocationY,
        [Switch]        $HasScroll
    )

    Write-Verbose "Panel: W$Width, H$Height, X$LocationX, Y$LocationY VScroll $HasScroll"
    $Panel = New-Object System.Windows.Forms.Panel
    $Panel.Width = $Width
    $Panel.Height = $Height

    If (!$ElementBefore) {
        $Panel.Location = New-Object System.Drawing.Point($LocationX, ($LocationY + $MarginTop))
    } Else {
        $Panel.Location = New-Object System.Drawing.Point($LocationX, ($ElementBefore.Location.Y + $ElementBefore.Height + $MarginTop))
    }

    if ($HasScroll) {
        $Panel.AutoScroll = $true
    }

    return $Panel
}

function New-Label() {
    [CmdletBinding()]
    param (
        [String]        $Text,
        [Int]           $Width,
        [Int]           $Height,
        [System.Object] $ElementBefore,
        [Int]           $MarginTop = 0,
        [Int]           $LocationX,
        [Int]           $LocationY,
        [String]        $Font = $MainFont,
        [Int]           $FontSize = 14,
        [String]        $FontStyle = "Regular",
        [String]        $ForeColor = "#55EE00", # Green
        [String]        $TextAlign = "MiddleCenter"
    )

    Write-Verbose "Label '$Text': W$Width, H$Height, X$LocationX, Y$LocationY, F $Font, FSize $FontSize, FStyle $FontStyle, FC $ForeColor, TA $TextAlign"
    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = $Text
    $Label.Width = $Width
    $Label.Height = $Height
    $Label.Font = New-Object System.Drawing.Font($Font, $FontSize, [System.Drawing.FontStyle]::$FontStyle)
    $Label.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($ForeColor)
    $Label.TextAlign = $TextAlign

    If (!$ElementBefore) {
        $Label.Location = New-Object System.Drawing.Point($LocationX, ($LocationY + $MarginTop))
    } Else {
        $Label.Location = New-Object System.Drawing.Point($LocationX, ($ElementBefore.Location.Y + $ElementBefore.Height + $MarginTop))
    }

    return $Label
}

function New-Button() {
    [CmdletBinding()]
    param (
        [String]        $Text,
        [Int]           $Width,
        [Int]           $Height,
        [System.Object] $ElementBefore,
        [Int]           $MarginTop = 5,
        [Int]           $LocationX,
        [Int]           $LocationY,
        [String]        $Font = $MainFont,
        [Int]           $FontSize = 12,
        [String]        $FontStyle = "Regular",
        [String]        $ForeColor = "#FFFFFF", # White
        [String]        $BackColor = "#2C2C2C", # Dark Gray
        [String]        $TextAlign = "MiddleCenter",
        [String]        $FlatStyle = "Flat", # Flat, Popup, Standard, System
        [String]        $BorderSize = 1
    )

    Write-Verbose "Button '$Text': W$Width, H$Height, X$LocationX, Y$LocationY, F $Font, FSize $FontSize, FStyle $FontStyle, FC $ForeColor, TA $TextAlign"
    $Button = New-Object System.Windows.Forms.Button
    $Button.Text = $Text
    $Button.Width = $Width
    $Button.Height = $Height
    $Button.Font = New-Object System.Drawing.Font($Font, $FontSize, [System.Drawing.FontStyle]::$FontStyle)
    $Button.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($ForeColor)
    $Button.BackColor = [System.Drawing.ColorTranslator]::FromHtml($BackColor)
    $Button.TextAlign = $TextAlign
    $Button.FlatStyle = [System.Windows.Forms.FlatStyle]::$FlatStyle
    $Button.FlatAppearance.BorderSize = $BorderSize

    If (!$ElementBefore) {
        $Button.Location = New-Object System.Drawing.Point($LocationX, ($LocationY + $MarginTop))
    } Else {
        $Button.Location = New-Object System.Drawing.Point($LocationX, ($ElementBefore.Location.Y + $ElementBefore.Height + $MarginTop))
    }

    return $Button
}

function New-CheckBox() {
    [CmdletBinding()]
    param (
        [String]        $Text,
        [Int]           $Width,
        [Int]           $Height,
        [System.Object] $ElementBefore,
        [Int]           $MarginTop = 5,
        [Int]           $LocationX,
        [Int]           $LocationY,
        [String]        $Font = $MainFont,
        [Int]           $FontSize = 12,
        [String]        $FontStyle = "Italic",
        [String]        $ForeColor = "#FFFFFF", # White
        [String]        $BackColor = "#2C2C2C", # Dark Gray
        [String]        $TextAlign = "MiddleLeft"
    )

    Write-Verbose "CheckBox '$Text': W$Width, H$Height, X$LocationX, Y$LocationY, F $Font, FSize $FontSize, FStyle $FontStyle, FC $ForeColor, BC $BackColor, TA $TextAlign"
    $CheckBox = New-Object System.Windows.Forms.CheckBox
    $CheckBox.Text = $Text
    $CheckBox.Width = $Width
    $CheckBox.Height = $Height
    $CheckBox.Font = New-Object System.Drawing.Font($Font, $FontSize, [System.Drawing.FontStyle]::$FontStyle)
    $CheckBox.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($ForeColor)
    $CheckBox.BackColor = [System.Drawing.ColorTranslator]::FromHtml($BackColor)
    $CheckBox.TextAlign = $TextAlign
    $CheckBox.FlatStyle = [System.Windows.Forms.FlatStyle]::Standard
    $CheckBox.FlatAppearance.BorderSize = 1

    If (!$ElementBefore) {
        $CheckBox.Location = New-Object System.Drawing.Point($LocationX, ($LocationY + $MarginTop))
    } Else {
        $CheckBox.Location = New-Object System.Drawing.Point($LocationX, ($ElementBefore.Location.Y + $ElementBefore.Height + $MarginTop))
    }

    return $CheckBox
}

function New-PictureBox() {
    [CmdletBinding()]
    [OutputType([System.Windows.Forms.PictureBox])]
    param (
        [String]        $ImageLocation,
        [Int]           $Width,
        [Int]           $Height,
        [System.Object] $ElementBefore,
        [Int]           $MarginTop = 0,
        [Int]           $LocationX,
        [Int]           $LocationY,
        [String]        $SizeMode = 'Zoom' # Autosize, CenterImage, Normal, StretchImage, Zoom
    )

    Write-Verbose "PictureBox: IL $ImageLocation, W$Width, H$Height, X$LocationX, Y$LocationY, SM $SizeMode"
    $PictureBox = New-Object System.Windows.Forms.PictureBox
    $PictureBox.ImageLocation = $ImageLocation
    $PictureBox.Width = $Width
    $PictureBox.Height = $Height
    $PictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::$SizeMode

    If (!$ElementBefore) {
        $PictureBox.Location = New-Object System.Drawing.Point($LocationX, ($LocationY + $MarginTop))
    } Else {
        $PictureBox.Location = New-Object System.Drawing.Point($LocationX, ($ElementBefore.Location.Y + $ElementBefore.Height + $MarginTop))
    }

    return $PictureBox
}