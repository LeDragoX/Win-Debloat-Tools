Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-CapabilityState.psm1"

function Remove-CapabilitiesList() {
    [CmdletBinding()]
    param (
        [Switch] $Revert
    )

    $DisableCapabilities = [System.Collections.ArrayList] @(
        "App.StepsRecorder*"                # Steps Recorder
        "Browser.InternetExplorer*"         # Internet Explorer (Also has on Optional Features)
        "MathRecognizer*"                   # Math Recognizer
        "Microsoft.Windows.PowerShell.ISE*" # PowerShell ISE
        "Microsoft.Windows.WordPad*"        # WordPad
        "Print.Fax.Scan*"                   # Fax features
        "Print.Management.Console*"         # printmanagement.msc
    )

    If (Get-AppxPackage -AllUsers -Name "MicrosoftCorporationII.QuickAssist") {
        $DisableCapabilities.Add("App.Support.QuickAssist*")
    }

    $DisableCapabilities.Sort()

    Write-Title "Windows Capabilities Tweaks"
    Write-Section "Uninstall Windows Capabilities from Windows"

    If ($Revert) {
        Write-Status -Types "*", "Capability" -Status "Reverting the tweaks is set to '$Revert'." -Warning
        Set-CapabilityState -State Enabled -Capabilities $DisableCapabilities
    } Else {
        Set-CapabilityState -State Disabled -Capabilities $DisableCapabilities
    }
}

# List all Windows Capabilities:
#Get-WindowsCapability -Online | Select-Object -Property State, Name, Online, RestartNeeded, LogPath, LogLevel | Sort-Object State, Name | Format-Table

If (!$Revert) {
    Remove-CapabilitiesList # Disable useless capabilities which came with Windows, but are legacy now and almost nobody cares
} Else {
    Remove-CapabilitiesList -Revert
}
