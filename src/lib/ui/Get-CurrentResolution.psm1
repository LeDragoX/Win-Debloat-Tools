Import-Module -DisableNameChecking "$PSScriptRoot\Ui-Helper.psm1"

function Get-CurrentResolution() {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param ()

    Add-Type -AssemblyName System.Windows.Forms

    # Get the primary screen's working area, which takes DPI scaling into account
    $primaryScreen = [System.Windows.Forms.Screen]::PrimaryScreen
    $bounds = $primaryScreen.Bounds
    $workingArea = $primaryScreen.WorkingArea

    $ScreenWidth = $workingArea.Width
    $ScreenHeight = $workingArea.Height

    Write-Verbose "Primary Monitor: Width: $ScreenWidth, Height: $ScreenHeight (DPI Scaled)"

    return $ScreenWidth, $ScreenHeight
}
