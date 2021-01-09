# Made by LeDragoX (Inspired on Baboo video) and matthewjberger https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f
Write-Host "Original Folder $PSScriptRoot"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\New-FolderForced.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\simple-message-box.psm1

$Message = "1 - If showed click [I AGREE]
2 - Click on the guide Tools >
3 - Go on Import/Export Tweaks >
4 - Import tweaks from a file >
5 - hit Next > Browse... > Select 'Winaero_Tweaker_exported_configs.ini' >
6 - Next > Finish (DON'T SPAM)
7 - Close it then OK"

wmic diskdrive get caption,status

# If changing the programs folder move here!!!
Push-Location "..\Windows Debloater Programs"

    # Write-Host "[OPTIONAL] Windows searches go to the default Web Browser"
    # Write-Host "[OPTIONAL] "EdgeDeflector_install.exe" /S"

    Push-Location "Winaero Tweaker"
        Start-Process WinaeroTweaker.exe
    Pop-Location

    ShowMessage -Title "DON'T CLOSE YET" -Message $Message
    Write-Host "Running ShutUp10 and applying configs..."
    Push-Location "ShutUp10"
    .\OOSU10.exe "ooshutup10.cfg" /quiet # quiet may be better?
    Pop-Location
Pop-Location

Write-Host "<==================== Re-enabling some services ====================>"

Set-Service -Name BITS -Status Running
Set-Service -Name DPS -Status Running
Set-Service -Name WSearch -Status Running

Write-Host "<==================== Re-enabling services at Startup ====================>"

Set-Service -Name BITS -StartupType Automatic       # - BITS: Transfer files in the background using idle network bandwidth. If the service is disabled, any application that depends on BITS, such as Windows Update or MSN Explorer, will not be able to download programs and other information automatically.
Set-Service -Name DPS -StartupType Automatic        # - DPS: This service detects problems and diagnoses the PC (Important)
Set-Service -Name WSearch -StartupType Automatic    # - Search local files on the Task Search bar

Write-Host "<==================== Disabling some services ====================>"

Set-Service -Name DiagTrack -Status Stopped
Set-Service -Name diagnosticshub.standardcollector.service -Status Stopped
Set-Service -Name dmwappushservice -Status Stopped
Set-Service -Name SysMain -Status Stopped
Set-Service -Name WMPNetworkSvc -Status Stopped

Write-Host "<==================== Disabling services at Startup ====================>"

Set-Service -Name DiagTrack -StartupType Disabled
Set-Service -Name diagnosticshub.standardcollector.service -StartupType Disabled
Set-Service -Name dmwappushservice -StartupType Disabled
Set-Service -Name RemoteRegistry -StartupType Disabled
Set-Service -Name SysMain -StartupType Disabled
Set-Service -Name TrkWks -StartupType Disabled
Set-Service -Name WMPNetworkSvc -StartupType Disabled

Write-Host "<==================== Scheduled Tasks tweaks ====================>"

Disable-ScheduledTask -TaskName "Microsoft\Office\OfficeTelemetryAgentLogOn"
Disable-ScheduledTask -TaskName "Microsoft\Office\OfficeTelemetryAgentFallBack"
Disable-ScheduledTask -TaskName "Microsoft\Office\Office 15 Subscription Heartbeat"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\StartupAppTask"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Uploader"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Defrag\ScheduledDefrag"
Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
Disable-ScheduledTask -TaskName "Microsoft\Windows\Shell\FamilySafetyUpload"

# Disable-ScheduledTask -TaskName "Microsoft\Windows\AppID\SmartScreenSpecific"
# Disable-ScheduledTask -TaskName "Microsoft\Windows\CloudExperienceHost\CreateObjectTask"
# Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskFootprint\Diagnostics" # *** Not sure if should be disabled, maybe related to S.M.A.R.T.
# Disable-ScheduledTask -TaskName "Microsoft\Windows\FileHistory\File History (maintenance mode)"
# Disable-ScheduledTask -TaskName "Microsoft\Windows\Maintenance\WinSAT"
# Disable-ScheduledTask -TaskName "Microsoft\Windows\NetTrace\GatherNetworkInfo"
# Disable-ScheduledTask -TaskName "Microsoft\Windows\PI\Sqm-Tasks"
# Disable-ScheduledTask -TaskName "Microsoft\Windows\SettingSync\BackgroundUploadTask" # The stubborn task can be Disabled using a simple bit change. I use a REG file for that (attached to this post).
# Disable-ScheduledTask -TaskName "Microsoft\Windows\Time Synchronization\ForceSynchronizeTime"
# Disable-ScheduledTask -TaskName "Microsoft\Windows\Time Synchronization\SynchronizeTime"
# Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting"
# Disable-ScheduledTask -TaskName "Microsoft\Windows\WindowsUpdate\Automatic App Update"

Write-Host "<====================          Registry Tweaks           ====================>"
Write-Host "<==================== Remove Telemetry & Data Collection ====================>"

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableUAR" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" -Name "Start" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" -Name "Start" -Type DWord -Value 0

Write-Host "Settings -> Privacy -> General -> Let apps use my advertising ID..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0

Write-Host "- SmartScreen Filter for Store Apps: Disable"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 0

Write-Host "- Let websites provide locally..."
Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1

Write-Host "WiFi Sense: HotSpot Sharing: Disable"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "value" -Type DWord -Value 0
Write-Host "WiFi Sense: Shared HotSpot Auto-Connect: Disable"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "value" -Type DWord -Value 0

Write-Host "Change Windows Updates to 'Notify to schedule restart'"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "UxOption" -Type DWord -Value 1
Write-Host "Disable P2P Update downloads outside of local network"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 0

Write-Host "*** Hide the search box from taskbar. You can still search by pressing the Win key and start typing what you're looking for ***"
Write-Host "0 = hide completely, 1 = show only icon, 2 = show long search box"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0

Write-Host "*** Disable MRU lists (jump lists) of XAML apps in Start Menu ***"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type DWord -Value 0

Write-Host "*** Set Windows Explorer to start on This PC instead of Quick Access ***"
Write-Host "1 = This PC, 2 = Quick access"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1

Write-Host "*** Show hidden files in Explorer ***"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1

Write-Host "*** Show file extensions in Explorer ***"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0

# Write-Host "*** Show super hidden system files in Explorer ***"
# Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Type DWord -Value 1

Write-Host "<==================== My Tweaks ====================>"

Write-Host "Hide the Task View from taskbar."
Write-Host "0 = Hide Task view, 1 = Show Task view"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0

Write-Host "Disabling Superfetch..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name EnableSuperfetch -Type DWord -Value 0

Write-Host "Disabling Remote Assistance..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0

Write-Host "Repairing RAM high usage..."
Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Type DWord -Value 4

Write-Host "Disabling Cortana..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCloudSearch" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1

Write-Host "Disabling Background Apps..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1

Write-Host "Unlimit your network bandwitdh for all your system" # Based on this Chris video: https://youtu.be/7u1miYJmJ_4
New-FolderForced -Path "HKLM:\SOFTWARE\Policies\Microsoft\Psched"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Psched" -Name "NonBestEffortLimit" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff

Write-Host "Set the DNS from Google"
Set-DNSClientServerAddress -interfaceIndex 12 -ServerAddresses ("8.8.8.8","8.8.4.4") # Ethernet
Set-DNSClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("8.8.8.8","8.8.4.4")
Set-DNSClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("8.8.8.8","8.8.4.4")


# Write-Host "Only remove if extremily necessary (Memory Compression)"
# disable-MMAgent -mc

Write-Host "Bring back F8 for alternative Boot Modes"
bcdedit /set {default} bootmenupolicy legacy
bcdedit /set `{current`} bootmenupolicy Legacy

Push-Location "$env:SystemRoot\System32"
    Write-Host "Fix Windows Search Bar"
    .\Regsvr32.exe /s msimtf.dll | .\Regsvr32.exe /s msctf.dll | Start-Process -Verb RunAs .\ctfmon.exe
Pop-Location

Push-Location ..\utils
    Write-Host "Dark theme"
    regedit /s dark-theme.reg
    Write-Host "Enabling photo viewer"
    regedit /s enable-photo-viewer.reg
    Write-Host "Lowering the RAM usage"
    regedit /s lower-ram-usage.reg
Pop-Location