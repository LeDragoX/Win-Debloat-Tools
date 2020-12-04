# Made by LeDragoX (Inspired on Baboo video) and matthewjberger https://gist.githubusercontent.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f/raw/b23fa065febed8a2d7c2f030fba6da381f640997/Remove-Windows10-Bloat.bat
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
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v PreventDeviceMetadataFromNetwork /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v DontOfferThroughWUAU /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /v "Start" /t REG_DWORD /d 0 /f

# Only remove if extremily necessary (Memory Compression)
# disable-MMAgent -mc

Write-Output "*** Disabling Superfetch ***"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f

Write-Output "*** Disabling Remote Assistance ***"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp /t REG_DWORD /d 0 /f

Write-Output "*** Repairing RAM high usage ***"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Ndu" /v Start /t REG_DWORD /d 4 /f

Write-Output "*** Disabling Cortana ***"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCloudSearch /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v ConnectedSearchUseWeb /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v DisableWebSearch /t REG_DWORD /d 1 /f

Write-Output "*** Disabling Background Apps ***"
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications /v GlobalUserDisabled /t REG_DWORD /d 1 /f

# Settings -> Privacy -> General -> Let apps use my advertising ID...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
# - SmartScreen Filter for Store Apps: Disable
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v EnableWebContentEvaluation /t REG_DWORD /d 0 /f
# - Let websites provide locally...
reg add "HKCU\Control Panel\International\User Profile" /v HttpAcceptLanguageOptOut /t REG_DWORD /d 1 /f

# WiFi Sense: HotSpot Sharing: Disable
reg add "HKLM\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" /v value /t REG_DWORD /d 0 /f
# WiFi Sense: Shared HotSpot Auto-Connect: Disable
reg add "HKLM\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /v value /t REG_DWORD /d 0 /f

# Change Windows Updates to "Notify to schedule restart"
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v UxOption /t REG_DWORD /d 1 /f

# Disable P2P Update downloads outside of local network
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v DODownloadMode /t REG_DWORD /d 0 /f

# *** Hide the search box from taskbar. You can still search by pressing the Win key and start typing what you're looking for ***
# 0 = hide completely, 1 = show only icon, 2 = show long search box
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 1 /f

# *** Disable MRU lists (jump lists) of XAML apps in Start Menu ***
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d 0 /f

# *** Set Windows Explorer to start on This PC instead of Quick Access ***
# 1 = This PC, 2 = Quick access
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 1 /f

# *** Show hidden files in Explorer ***
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d 1 /f

# *** Show file extensions in Explorer ***
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t  REG_DWORD /d 0 /f

# *** Show super hidden system files in Explorer ***
# reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSuperHidden" /t REG_DWORD /d 1 /f

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
Pop-Location

# If changing the programs folder move here!!!
Push-Location "..\Windows Debloater Programs"

    Write-Output "[OPTIONAL] Windows searches go to the default Web Browser"
    Write-Output "[OPTIONAL] "EdgeDeflector_install.exe" /S"

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
        Start-Process OOSU10.exe ooshutup10.cfg #/quiet
    Pop-Location
Pop-Location

Write-Output "Solving DNS problems..."
ipconfig /release
ipconfig /renew
ipconfig /flushdns
Write-Output "DNS flushed!"

Start-Process wsreset