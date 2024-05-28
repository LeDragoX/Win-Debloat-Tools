Import-Module -DisableNameChecking "$PSScriptRoot\Ui-Helper.psm1"

function Get-CurrentResolution() {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param ()

    Add-Type -AssemblyName System.Windows.Forms

    # Get the primary screen's working area, which takes DPI scaling into account
    $PrimaryScreen = [System.Windows.Forms.Screen]::PrimaryScreen
    $WorkingArea = $PrimaryScreen.WorkingArea

    $ScreenWidth = $WorkingArea.Width
    $ScreenHeight = $WorkingArea.Height

    Write-Verbose "Primary Monitor: Width: $ScreenWidth, Height: $ScreenHeight (DPI Scaled)"

    return $ScreenWidth, $ScreenHeight
}
