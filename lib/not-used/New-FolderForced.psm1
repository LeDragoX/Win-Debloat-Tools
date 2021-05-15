<#
.SYNOPSIS
If the target registry key is already present, all values within that key are purged.

.DESCRIPTION
While `mkdir -force` works fine when dealing with regular folders, it behaves strange when using it at registry level.
If the target registry key is already present, all values within that key are purged.

.PARAMETER Path
Full path of the storage or registry folder

.EXAMPLE
New-FolderForced -Path "HKCU:\Printers\Defaults"

.EXAMPLE
New-FolderForced "HKCU:\Printers\Defaults"

.EXAMPLE
"HKCU:\Printers\Defaults" | New-FolderForced

.NOTES
Replacement for `force-mkdir` to uphold PowerShell conventions.
Thanks to raydric, this function should be used instead of `mkdir -force`.
#>
function New-FolderForced {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
		[Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
        $Path
    )

    process {
        if (-not (Test-Path $Path)) {
            Write-Verbose "-- Creating full path to:  $Path"
            New-Item -Path $Path -ItemType Directory -Force
        }
    }
}