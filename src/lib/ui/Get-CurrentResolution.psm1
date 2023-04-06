Import-Module -DisableNameChecking "$PSScriptRoot\Ui-Helper.psm1"

function Get-CurrentResolution() {
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
