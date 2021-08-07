function EnableTelemetry() {

  Write-Host "[@] (0 = Security (Enterprise only), 1 = Basic Telemetry, 2 = Enhanced Telemetry, 3 = Full Telemetry)"
  Write-Host "[+] Enabling Full Telemetry..."
  Set-ItemProperty -Path "$PathToTelemetry" -Name "AllowTelemetry" -Type DWord -Value 3
  Set-ItemProperty -Path "$PathToTelemetry2" -Name "AllowTelemetry" -Type DWord -Value 3
  Set-ItemProperty -Path "$PathToTelemetry" -Name "AllowDeviceNameInTelemetry" -Type DWord -Value 1

}

function Main() {

  $Global:PathToTelemetry = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
  $Global:PathToTelemetry2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"

  EnableTelemetry
  
}

Main