Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Enable-WSearchService() {
    Write-Status -Types "*", "Service" -Status "Enabling Search Indexing (Recommended for SSDs)..."
    Get-Service -Name "WSearch" -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic
    Start-Service "WSearch"
}

Enable-WSearchService