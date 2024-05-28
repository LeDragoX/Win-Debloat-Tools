Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

function Remove-ItemPropertyVerified() {
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Path,
        [Parameter(Position = 1, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Name,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Include,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Exclude,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Switch]   $Force
    )

    Begin {
        $ScriptBlock = "Remove-ItemProperty"
        $Script:TweakType = "Exp/Reg"
    }

    Process {
        ForEach ($DirectoryPath in $Path) {
            If (Test-Path "$DirectoryPath") {
                If ((Get-Item -Path "$DirectoryPath").Property -ccontains $Name) {
                    Write-Status -Types "-", $TweakType -Status "Removing: `"$DirectoryPath>$Name`""

                    If ($null -ne $DirectoryPath) {
                        $ScriptBlock += " -Path "
                        $ScriptBlock += "`"$DirectoryPath`", "
                        $ScriptBlock = $ScriptBlock.TrimEnd(", ")
                    }

                    If ($null -ne $Name) {
                        $ScriptBlock += " -Name "
                        ForEach ($NameParam in $Name) {
                            $ScriptBlock += "`"$NameParam`", "
                        }
                        $ScriptBlock = $ScriptBlock.TrimEnd(", ")
                    }

                    If ($null -ne $Include) {
                        $ScriptBlock += " -Include "
                        ForEach ($IncludeParam in $Include) {
                            $ScriptBlock += "`"$IncludeParam`", "
                        }
                        $ScriptBlock = $ScriptBlock.TrimEnd(", ")
                    }

                    If ($null -ne $Exclude) {
                        $ScriptBlock += " -Exclude "
                        ForEach ($ExcludeParam in $Exclude) {
                            $ScriptBlock += "`"$ExcludeParam`", "
                        }
                        $ScriptBlock = $ScriptBlock.TrimEnd(", ")
                    }

                    If ($null -ne $Force) {
                        $ScriptBlock += " -Force"
                    }

                    Write-Verbose "> $ScriptBlock"
                    Invoke-Expression "$ScriptBlock"
                    $ScriptBlock = "Remove-ItemProperty"
                } Else {
                    Write-Status -Types "?", $TweakType -Status "The property `"$DirectoryPath>$Name`" does not exist." -Warning

                }
            } Else {
                Write-Status -Types "?", $TweakType -Status "The path(s) `"$DirectoryPath`" to the property `"$Name`" couldn't be found." -Warning
            }
        }
    }
}
