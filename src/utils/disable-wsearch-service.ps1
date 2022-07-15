Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Disable-WSearchService() {
    Write-Status -Types "-", "Service" -Status "Disabling Search Indexing (Recommended for HDDs)..."
    Get-Service -Name "WSearch" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    Stop-Service "WSearch" -Force -NoWait
}

Disable-WSearchService