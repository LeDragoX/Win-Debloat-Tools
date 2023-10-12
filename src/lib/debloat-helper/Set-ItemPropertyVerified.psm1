Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

function Set-ItemPropertyVerified() {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Path,
        [Parameter(Position = 1, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]   $Name,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateSet('Binary', 'DWord', 'ExpandString', 'MultiString', 'None', 'Qword', 'String', 'Unknown')]
        [String]   $Type,
        [Parameter(Position = 2, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $Value <# Will have dynamic typing #>
    )

    Begin {
        $Script:TweakType = "Registry"
    }

    Process {
        If (!(Test-Path "$Path")) {
            Write-Status -Types "?", $TweakType -Status "Creating new path in '$Path'..." -Warning
            New-Item -Path "$Path" -Force | Out-Null
        }

        If ($Type) {
            Set-ItemProperty -Path "$Path" -Name "$Name" -Type $Type -Value $Value
        } Else {
            Set-ItemProperty -Path "$Path" -Name "$Name" -Value $Value
        }
    }
}
