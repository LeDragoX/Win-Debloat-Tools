Import-Module -DisableNameChecking "$PSScriptRoot\Ui-Helper.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

function New-LayoutPage() {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        # To Panels
        [Parameter(Position = 0)]
        [ValidateSet(1, 2, 3, 4, 5)]
        [Int]    $NumOfPanels = 1,
        [Parameter(Position = 1)]
        [Int]    $PanelHeight = 480,
        [Parameter(Position = 2)]
        [Double] $PanelElementMarginWidth = 0.025,
        [Int]    $DistanceBetweenElements = 5
    )

    Begin {
        $ScreenWidth, $ScreenHeight = Get-CurrentResolution # Get the Screen Size
        $ScreenProportion = $ScreenWidth / $ScreenHeight # 16:9 ~1.777...

        # To Scroll
        $VerticalScrollWidth = 17 # CONSTANT

        # To Forms
        If ($ScreenProportion -lt 1.5) {
            $FormWidth = ($ScreenWidth * 0.99) + $VerticalScrollWidth # Small Resolution Width + Scroll Width
            $FormHeight = $ScreenHeight * 0.85
        } ElseIf ($ScreenProportion -lt 2.0) {
            $FormWidth = ($ScreenWidth * 0.85) + $VerticalScrollWidth # Scaled Resolution Width + Scroll Width
            $FormHeight = $ScreenHeight * 0.85
        } ElseIf ($ScreenProportion -ge 2.0) {
            $FormWidth = ($ScreenWidth * 0.65) + $VerticalScrollWidth # Scaled Resolution Width + Scroll Width
            $FormHeight = $ScreenHeight * 0.85
        }

        # To Panels
        $PanelWidth = ($FormWidth / $NumOfPanels) - (2 * ($VerticalScrollWidth / $NumOfPanels)) # - Scroll Width per Panel
        $TotalWidth = $PanelWidth * $NumOfPanels
        $PanelElementWidth = $PanelWidth - ($PanelWidth * (2 * $PanelElementMarginWidth))
        $PanelElementX = $PanelWidth * $PanelElementMarginWidth
        # To Labels
        $TitleLabelHeight = 45
        $CaptionLabelHeight = 50
        $TitleLabelY = 0
        # To Buttons
        $ButtonHeight = 30
        # To CheckBox
        $CheckBoxHeight = 40
        # To Fonts
        $Heading = @{ 0 = 32; 1 = 20; 2 = 16; 3 = 13; 4 = 12; 5 = 11; 6 = 10 }
    }

    Process {
        $LayoutParams = @{
            FormWidth               = $FormWidth
            FormHeight              = $FormHeight
            TotalWidth              = $TotalWidth
            PanelWidth              = $PanelWidth
            PanelHeight             = $PanelHeight
            PanelElementWidth       = $PanelElementWidth
            PanelElementX           = $PanelElementX
            TitleLabelHeight        = $TitleLabelHeight
            CheckBoxHeight          = $CheckBoxHeight
            ButtonHeight            = $ButtonHeight
            TitleLabelY             = $TitleLabelY
            CaptionLabelHeight      = $CaptionLabelHeight
            DistanceBetweenElements = $DistanceBetweenElements
            Heading                 = $Heading
        }
    }

    End {
        return $LayoutParams
    }
}
