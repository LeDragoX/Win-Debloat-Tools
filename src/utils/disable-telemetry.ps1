function DisableTelemetry() {

  Write-Host "[@] (0 = Security (Enterprise only), 1 = Basic Telemetry, 2 = Enhanced Telemetry, 3 = Full Telemetry)"
  Write-Host "[-] Disabling Full Telemetry..."
  Set-ItemProperty -Path "$PathToTelemetry" -Name "AllowTelemetry" -Type DWord -Value 0
  Set-ItemProperty -Path "$PathToTelemetry2" -Name "AllowTelemetry" -Type DWord -Value 0
  Set-ItemProperty -Path "$PathToTelemetry" -Name "AllowDeviceNameInTelemetry" -Type DWord -Value 0

}

function Main() {
  
  $Global:PathToTelemetry = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
  $Global:PathToTelemetry2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"

  DisableTelemetry

}

Main