﻿Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

function Remove-ItemVerified() {
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Path,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Include,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [String[]] $Exclude,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Switch]   $Recurse,
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Switch]   $Force
    )

    Begin {
        $ScriptBlock = "Remove-Item"
        $Script:TweakType = "Exp/Reg"
    }

    Process {
        If (Test-Path "$Path") {
            Write-Status -Types "-", $TweakType -Status "Removing: '$Path'"

            If ($null -ne $Path) {
                $ScriptBlock += " -Path "
                ForEach ($PathParam in $Path) {
                    $ScriptBlock += "`"$PathParam`", "
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

            If ($null -ne $Recurse) {
                $ScriptBlock += " -Recurse"
            }

            If ($null -ne $Force) {
                $ScriptBlock += " -Force"
            }

            Write-Verbose "> $ScriptBlock"
            Invoke-Expression "$ScriptBlock"
        } Else {
            Write-Status -Types "?", $TweakType -Status "The path `"$Path`" does not exist." -Warning
        }
    }
}
