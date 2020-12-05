# Made by LeDragoX (Inspired on Baboo video) and matthewjberger https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f
Write-Output "Original Folder $PSScriptRoot"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\simple-message-box.psm1

wmic diskdrive get caption,status

Write-Output "*** Disabling some services ***"

cmd.exe /c sc start BITS
cmd.exe /c sc stop DiagTrack
cmd.exe /c sc start DPS
cmd.exe /c sc stop diagnosticshub.standardcollector.service
cmd.exe /c sc stop dmwappushservice
cmd.exe /c sc stop SysMain
cmd.exe /c sc stop WMPNetworkSvc
cmd.exe /c sc start WSearch

Write-Output "*** Disabling services at Startup ***"

Get-Service -Name BITS | Set-Service -StartupType Automatic # - BITS: Transfer files in the background using idle network bandwidth. If the service is disabled, any application that depends on BITS, such as Windows Update or MSN Explorer, will not be able to download programs and other information automatically.
Get-Service -Name DiagTrack | Set-Service -StartupType Disabled
Get-Service -Name DPS | Set-Service -StartupType Automatic # - DPS: This service detects problems and diagnoses the PC (Important)
Get-Service -Name diagnosticshub.standardcollector.service | Set-Service -StartupType Disabled
Get-Service -Name dmwappushservice | Set-Service -StartupType Disabled
# cmd.exe /c sc config RemoteRegistry start= disabled
Get-Service -Name SysMain | Set-Service -StartupType Disabled
# cmd.exe /c sc config TrkWks start= disabled
Get-Service -Name WMPNetworkSvc | Set-Service -StartupType Disabled
Get-Service -Name WSearch | Set-Service -StartupType Automatic # - Search local files on the Task Search bar

Write-Output "*** Scheduled Tasks tweaks ***" 

schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentLogOn" /Disable
schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentFallBack" /Disable
schtasks /Change /TN "Microsoft\Office\Office 15 Subscription Heartbeat" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\StartupAppTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Autochk\Proxy" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Uploader" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable
schtasks /Change /TN "Microsoft\Windows\Defrag\ScheduledDefrag" /Disable
schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyUpload" /Disable

# schtasks /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Disable
# schtasks /Change /TN "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /Disable
# schtasks /Change /TN "Microsoft\Windows\DiskFootprint\Diagnostics" /Disable # *** Not sure if should be disabled, maybe related to S.M.A.R.T.
# schtasks /Change /TN "Microsoft\Windows\FileHistory\File History (maintenance mode)" /Disable
# schtasks /Change /TN "Microsoft\Windows\Maintenance\WinSAT" /Disable
# schtasks /Change /TN "Microsoft\Windows\NetTrace\GatherNetworkInfo" /Disable
# schtasks /Change /TN "Microsoft\Windows\PI\Sqm-Tasks" /Disable
# schtasks /Change /TN "Microsoft\Windows\SettingSync\BackgroundUploadTask" /Disable # The stubborn task can be Disabled using a simple bit change. I use a REG file for that (attached to this post).
# schtasks /Change /TN "Microsoft\Windows\Time Synchronization\ForceSynchronizeTime" /Disable
# schtasks /Change /TN "Microsoft\Windows\Time Synchronization\SynchronizeTime" /Disable
# schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable
# schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\Automatic App Update" /Disable
Write-Output ""

# *** Remove Telemetry & Data Collection ***
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableUAR" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" -Name "Start" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" -Name "Start" -Type DWord -Value 0

# Only remove if extremily necessary (Memory Compression)
# disable-MMAgent -mc

Write-Output "*** Disabling Superfetch ***"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name EnableSuperfetch -Type DWord -Value 0

Write-Output "*** Disabling Remote Assistance ***"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0

Write-Output "*** Repairing RAM high usage ***"
Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Type DWord -Value 4

Write-Output "*** Disabling Cortana ***"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCloudSearch" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1

Write-Output "*** Disabling Background Apps ***"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1

# Settings -> Privacy -> General -> Let apps use my advertising ID...
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
# - SmartScreen Filter for Store Apps: Disable
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 0
# - Let websites provide locally...
Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1

# WiFi Sense: HotSpot Sharing: Disable
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "value" -Type DWord -Value 0
# WiFi Sense: Shared HotSpot Auto-Connect: Disable
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "value" -Type DWord -Value 0

# Change Windows Updates to "Notify to schedule restart"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "UxOption" -Type DWord -Value 1

# Disable P2P Update downloads outside of local network
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 0

# *** Hide the search box from taskbar. You can still search by pressing the Win key and start typing what you're looking for ***
# 0 = hide completely, 1 = show only icon, 2 = show long search box
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1

# *** Disable MRU lists (jump lists) of XAML apps in Start Menu ***
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type DWord -Value 0

# *** Set Windows Explorer to start on This PC instead of Quick Access ***
# 1 = This PC, 2 = Quick access
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1

# *** Show hidden files in Explorer ***
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1

# *** Show file extensions in Explorer ***
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0

# *** Show super hidden system files in Explorer ***
# Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Type DWord -Value 1

Write-Output "" "*** Misc. Tweaks ***" ""

Write-Output "" "Bring back F8 for alternative Boot Modes"
bcdedit /set {default} bootmenupolicy legacy 

Push-Location "$env:SystemRoot\System32"
    Write-Output "" "Fix Windows Search Bar"
    .\Regsvr32.exe /s msimtf.dll | .\Regsvr32.exe /s msctf.dll | Start-Process -Verb RunAs .\ctfmon.exe
Pop-Location

Push-Location ..\utils
    Write-Output "" "Dark theme"
    regedit /s dark-theme.reg
    Write-Output "" "Enabling photo viewer"
    regedit /s enable-photo-viewer.reg
    Write-Output "" "Lowering the RAM usage"
    regedit /s lower-ram-usage.reg
Pop-Location

# If changing the programs folder move here!!!
Push-Location "..\Windows Debloater Programs"

    # Write-Output "[OPTIONAL] Windows searches go to the default Web Browser"
    # Write-Output "[OPTIONAL] "EdgeDeflector_install.exe" /S"

    Push-Location "Winaero Tweaker"
        Start-Process WinaeroTweaker.exe
    Pop-Location

ShowMessage -Title "Winaero Tweaker" -Message "1 - If showed click [I AGREE]
2 - Click on the guide Tools >
3 - Go on Import/Export Tweaks >
4 - Import tweaks from a file >
5 - hit Next > Browse... > Select 'Winaero_Tweaker_exported_configs.ini' >
6 - Next > Finish (DON'T SPAM)
7 - Close it"

    # ShutUp10 is portable now
    Push-Location "ShutUp10"
        Start-Process OOSU10.exe ooshutup10.cfg /quiet # quiet may be better?
    Pop-Location
Pop-Location

Write-Output "Solving DNS problems..."
ipconfig /release
ipconfig /renew
ipconfig /flushdns
Write-Output "DNS flushed!"

Start-Process wsreset