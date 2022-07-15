Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"manage-software.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"title-templates.psm1"

function Get-HEVCSupport() {
    Write-Status -Types "+" -Status "Adding support to HEVC/H.265 video codec (MUST HAVE)..."
    Install-Software -Name "HEVC Video Extensions from Device Manufacturer" -Packages "9N4WGH0Z6VHQ" -ViaMSStore -NoDialog # Gives error
}

Get-HEVCSupport