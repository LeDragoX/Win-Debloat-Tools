Import-Module -DisableNameChecking $PSScriptRoot\..\"title-templates.psm1"

function Remove-ItemVerified() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String] $Path,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Include,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Exclude,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Switch] $Recurse,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Switch] $Force
    )

    Begin {
        $Script:TweakType = "Exp/Reg"
    }

    Process {
        If (Test-Path "$Path") {
            Write-Status -Types "-", $TweakType -Status "Removing: '$Path'"
            If ($Recurse -and $Force) {
                Remove-Item -Path "$Path" -Include $Include -Exclude $Exclude -Recurse -Force
                Continue
            }

            If ($Recurse) {
                Remove-Item -Path "$Path" -Include $Include -Exclude $Exclude -Recurse
            } ElseIf ($Force) {
                Remove-Item -Path "$Path" -Include $Include -Exclude $Exclude -Force
            } Else {
                Remove-Item -Path "$Path" -Include $Include -Exclude $Exclude
            }
        } Else {
            Write-Status -Types "?", $TweakType -Status "The path $Path does not exist" -Warning
        }
    }

    End {
    }
}
