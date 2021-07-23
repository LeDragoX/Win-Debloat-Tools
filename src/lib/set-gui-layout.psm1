function SetGuiLayout() {

  [CmdletBinding()] #<<-- This turns a regular function into an advanced function
  param ()

  # Loading System Libs
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing

  # <=== SIZES LAYOUT ===>

  # To Forms
  $Global:MaxWidth = 854
  $Global:MaxHeight = 480
  # To Panels
  $Global:CurrentPanelIndex = -2
  $Global:NumOfPanels = 3
  [int]$Global:PanelWidth = ($MaxWidth / $NumOfPanels) # 284
  # To Labels
  $Global:LabelWidth = 25
  $Global:LabelHeight = 10
  # To Buttons
  $Global:ButtonWidth = 150
  $Global:ButtonHeight = 30
  $Global:BigButtonHeight = 70
  # To Fonts
  $Global:DocumentTitle2 = 16
  $Global:DocumentTitle3 = 14
  $Global:DocumentTitle4 = 12

  # <=== FONTS ===>
    
  $Global:Fonts = @(
    "Arial", # 0
    "Bahnschrift", # 1
    "Calibri", # 2
    "Cambria", # 3
    "Cambria Math", # 4
    "Candara", # 5
    "Comic Sans MS", # 6
    "Consolas", # 7
    "Constantia", # 8
    "Corbel", # 9
    "Courier New", # 10
    "Ebrima", # 11
    "Franklin Gothic", # 12
    "Gabriola", # 13
    "Gadugi", # 14
    "Georgia", # 15
    "HoloLens MDL2 Assets", # 16
    "Impact", # 17
    "Ink Free", # 18
    "Javanese Text", # 19
    "Leelawadee UI", # 20
    "Lucida Console", # 21
    "Lucida Sans Unicode", # 22
    "Malgun Gothic", # 23
    "Microsoft Himalaya", # 24
    "Microsoft JhengHei", # 25
    "Microsoft JhengHei UI", # 26
    "Microsoft New Tai Lue", # 27
    "Microsoft PhagsPa", # 28
    "Microsoft Sans Serif", # 29
    "Microsoft Tai Le", # 30
    "Microsoft YaHei", # 31
    "Microsoft YaHei UI", # 32
    "Microsoft Yi Baiti", # 33
    "MingLiU_HKSCS-ExtB", # 34
    "MingLiU-ExtB", # 35
    "Mongolian Baiti", # 36
    "MS Gothic", # 37
    "MS PGothic", # 38
    "MS UI Gothic", # 39
    "MV Boli", # 40
    "Myanmar Text", # 41
    "Nirmala UI", # 42
    "NSimSun", # 43
    "Palatino Linotype", # 44
    "PMingLiU-ExtB", # 45
    "Segoe Fluent Icons", # 46
    "Segoe MDL2 Assets", # 47
    "Segoe Print", # 48
    "Segoe Script", # 49
    "Segoe UI", # 50
    "Segoe UI Emoji", # 51
    "Segoe UI Historic", # 52
    "Segoe UI Symbol", # 53
    "Segoe UI Variable", # 54
    "SimSun", # 55
    "SimSun-ExtB", # 56
    "Sitka Text", # 57
    "Sylfaen", # 58
    "Symbol", # 59
    "Tahoma", # 60
    "Times New Roman", # 61
    "Trebuchet MS", # 62
    "Verdana", # 63
    "Webdings", # 64
    "Wingdings", # 65
    "Yu Gothic", # 66
    "Yu Gothic UI", # 67
    "Unispace", # 68
    # Installable # ##
    "Courier", # 69
    "Fixedsys", # 70
    "JetBrains Mono", # 71
    "JetBrains Mono NL", # 72
    "Modern", # 73
    "MS Sans Serif", # 74
    "MS Serif", # 75
    "Roman", # 76
    "Script", # 77
    "Small Fonts", # 78
    "System", # 79
    "Terminal" # 80
  )

  # <=== LOCATIONS LAYOUT ===>

  [int]$Global:TitleLabelX = $PanelWidth * 0.15
  [int]$Global:TitleLabelY = $MaxHeight * 0.01
  [int]$Global:CaptionLabelX = $PanelWidth * 0.25
  [int]$Global:ButtonX = $PanelWidth * 0.15

  # <=== COLOR PALETTE ===>

  $Global:Green = "#1fff00"
  $Global:LightBlue = "#00ffff"
  $Global:LightGray = "#eeeeee"
  $Global:WinDark = "#252525"

  # <=== GUI ELEMENT LAYOUT ===>

  # Panel Layout

  $Global:CurrentPanelIndex++ # -1
  $Global:PWidth = $PanelWidth
  $Global:PHeight = $MaxHeight

  # Title Label Layout

  $Global:TLAutoSize = $true
  $Global:TLWidth = $LabelWidth
  $Global:TLHeight = $LabelHeight
  $Global:TLLocation = New-Object System.Drawing.Point($TitleLabelX, $TitleLabelY)
  $Global:TLFont = New-Object System.Drawing.Font($Fonts[62], $DocumentTitle2, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
  $Global:TLForeColor = [System.Drawing.ColorTranslator]::FromHtml("$Green")

  # Caption Label Layout

  $Global:CLAutoSize = $true
  $Global:CLWidth = $LabelWidth
  $Global:CLHeight = $LabelHeight
  $Global:CLFont = New-Object System.Drawing.Font($Fonts[62], $DocumentTitle3)
  $Global:CLForeColor = [System.Drawing.ColorTranslator]::FromHtml("$Green")

  # Big Button Layout

  $Global:BBWidth = $ButtonWidth
  $Global:BBHeight = $BigButtonHeight
  $Global:BBLocation = New-Object System.Drawing.Point($ButtonX, 40)
  $Global:BBFont = New-Object System.Drawing.Font($Fonts[62], $DocumentTitle4, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
  $Global:BBForeColor = [System.Drawing.ColorTranslator]::FromHtml("$LightBlue")

  # Small Button Layout

  $Global:SBWidth = $ButtonWidth
  $Global:SBHeight = $ButtonHeight
  $Global:SBFont = New-Object System.Drawing.Font($Fonts[62], $DocumentTitle4)
  $Global:SBForeColor = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
                    
}

