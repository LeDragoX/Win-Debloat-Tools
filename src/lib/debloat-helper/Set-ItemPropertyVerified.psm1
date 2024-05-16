Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

function Set-ItemPropertyVerified() {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Path,
        [Parameter(Position = 1, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String]   $Name,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateSet('Binary', 'DWord', 'ExpandString', 'MultiString', 'None', 'QWord', 'String', 'Unknown')]
        [String]   $Type,
        [Parameter(Position = 2, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        $Value <# Will have dynamic typing #>
    )

    Begin {
        $ScriptBlock = "Set-ItemProperty"
        $Script:TweakType = "Registry"
    }

    Process {
        ForEach ($PathParam in $Path) {
            If (!(Test-Path "$PathParam")) {
                Write-Status -Types "?", $TweakType -Status "Creating new path in `"$PathParam`"..." -Warning
                New-Item -Path "$PathParam" -Force | Out-Null
            }
        }

        If ($null -ne $Path) {
            $ScriptBlock += " -Path "
            ForEach ($PathParam in $Path) {
                $ScriptBlock += "`"$PathParam`", "
            }
            $ScriptBlock = $ScriptBlock.TrimEnd(", ")
        }

        If ($null -ne $Name) {
            $ScriptBlock += " -Name "
            $ScriptBlock += "`"$Name`""
        }

        If (($null -ne $Type) -and ($Type -notlike '')) {
            $ScriptBlock += " -Type "
            $ScriptBlock += "$Type"
        }

        If ($null -ne $Value) {
            $ScriptBlock += " -Value "

            If ($Type -like 'Binary') {
                $ScriptBlock += "([byte[]]($($Value -join ", ")))"
            } Else {
                $ScriptBlock += "$Value"
            }
        }

        Write-Verbose "> $ScriptBlock"
        Invoke-Expression "$ScriptBlock"
    }
}
