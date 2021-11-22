function Main() {
  Write-Host "[-] Disabling Search Indexing (Recommended for HDDs)..."
  Get-Service -Name "WSearch" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
  Stop-Service "WSearch" -Force -NoWait
}

Main