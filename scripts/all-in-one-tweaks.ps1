# Made by LeDragoX
# Inspired on matthewjberger's script https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f
# Inspired on this Baboo video https://youtu.be/qWESrvP_uU8
# Inspired on this AdamX video https://youtu.be/hQSkPmZRCjc

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

    Push-Location "Winaero Tweaker"
        Start-Process WinaeroTweaker.exe
    Pop-Location

    ShowMessage -Title "DON'T CLOSE YET" -Message $Message
    Write-Host "Running ShutUp10 and applying configs..."
    Push-Location "ShutUp10"
    .\OOSU10.exe "ooshutup10.cfg" /quiet # quiet may be better?
    Pop-Location
Pop-Location

Write-Host "<==================== 1/3 - [Services tweaks] ====================>"
Write-Host "<==================== Re-enabling services at Startup ====================>"

$EnableServices = @(
    "BITS"                  # Background Intelligent Transfer Service
    "DPS"                   # Diagnostic Policy Service
    "WSearch"               # Windows Search
)

foreach ($service in $EnableServices) {
    Write-Host "Re-enabling $service at Startup..."
    Set-Service -Name $service -StartupType Automatic
}

Write-Host "<==================== Disabling services at Startup ====================>"

$DisableServices = @(
    "DiagTrack"                                 # Connected User Experiences and Telemetry
    "diagnosticshub.standardcollector.service"  # Microsoft (R) Diagnostics Hub Standard Collector Service
    "dmwappushservice"                          # Device Management Wireless Application Protocol (WAP)
    "FontCache"                                 # Windows Font Cache Service
    "GraphicsPerfSvc"                           # Graphics performance monitor service
    "lfsvc"                                     # Geolocation Service
    "MapsBroker"                                # Downloaded Maps Manager
    "ndu"                                       # Windows Network Data Usage Monitoring Driver
    "RemoteAccess"                              # Routing and Remote Access
    "RemoteRegistry"                            # Remote Registry
    "SysMain"                                   # SysMain / Superfetch
    "TrkWks"                                    # Distributed Link Tracking Client
    "WbioSrvc"                                  # Windows Biometric Service (required for Fingerprint reader / facial detection)
    "WMPNetworkSvc"                             # Windows Media Player Network Sharing Service

    # If you dont use Xbox Live and Games [DIY]

    # "XblAuthManager"                          # Xbox Live Auth Manager
    # "XblGameSave"                             # Xbox Live Game Save Service
    # "XboxNetApiSvc"                           # Xbox Live Networking Service
)

foreach ($service in $DisableServices) {
    Write-Host "Disabling $service now and at Startup..."
    Set-Service -Name $service -Status Stopped
    Set-Service -Name $service -StartupType Disabled
}

Write-Host "<==================== 2/3 - [Scheduled Tasks tweaks] ====================>"

$DisableScheduledTasks = @(
    "Microsoft\Office\OfficeTelemetryAgentLogOn"
    "Microsoft\Office\OfficeTelemetryAgentFallBack"
    "Microsoft\Office\Office 15 Subscription Heartbeat"
    "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "Microsoft\Windows\Application Experience\ProgramDataUpdater"
    "Microsoft\Windows\Application Experience\StartupAppTask"
    "Microsoft\Windows\Autochk\Proxy"
    "Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
    "Microsoft\Windows\Customer Experience Improvement Program\Uploader"
    "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    "Microsoft\Windows\Defrag\ScheduledDefrag"
    "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    "Microsoft\Windows\Shell\FamilySafetyUpload"
    # "Microsoft\Windows\AppID\SmartScreenSpecific"
    # "Microsoft\Windows\CloudExperienceHost\CreateObjectTask"
    # "Microsoft\Windows\DiskFootprint\Diagnostics" # *** Not sure if should be disabled, maybe related to S.M.A.R.T.
    # "Microsoft\Windows\FileHistory\File History (maintenance mode)"
    # "Microsoft\Windows\Maintenance\WinSAT"
    # "Microsoft\Windows\NetTrace\GatherNetworkInfo"
    # "Microsoft\Windows\PI\Sqm-Tasks"
    # "Microsoft\Windows\SettingSync\BackgroundUploadTask" # The stubborn task can be Disabled using a simple bit change. I use a REG file for that (attached to this post).
    # "Microsoft\Windows\Time Synchronization\ForceSynchronizeTime"
    # "Microsoft\Windows\Time Synchronization\SynchronizeTime"
    # "Microsoft\Windows\Windows Error Reporting\QueueReporting"
    # "Microsoft\Windows\WindowsUpdate\Automatic App Update"
)

foreach ($ScheduledTask in $DisableScheduledTasks) {
    Write-Host "Disabling the $ScheduledTask Task..."
    Disable-ScheduledTask -TaskName $ScheduledTask
}

Write-Host "<==================== 3/3 - [Registry Tweaks] ====================>"
Write-Host "<==================== Remove Telemetry & Data Collection ====================>"

Write-Host "<==========[Personalization Section]==========>"

Write-Host "-> Colors"

Write-Host "Disable taskbar transparency."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value 0

Write-Host "-> ? & ? & Start & Lockscreen"
Write-Host "Disable Show me suggested content in the settings app."
Write-Host "Disable Show me the windows welcome experience after updates."
Write-Host "Disable Show suggestions in start."
Write-Host "Disable Get fun facts and tips, etc. on lock screen."

$ContentDeliveryManagerBlock = @(
    "SubscribedContent-310093Enabled"
    "SubscribedContent-314559Enabled"
    "SubscribedContent-314563Enabled"
    "SubscribedContent-338387Enabled"
    "SubscribedContent-338388Enabled"
    "SubscribedContent-338389Enabled"
    "SubscribedContent-338393Enabled"
    "SubscribedContent-353698Enabled"
    "RotatingLockScreenOverlayEnabled"
    "RotatingLockScreenEnabled"
    # Disable Auto installation of unnecessary bloatware
    "ContentDeliveryAllowed"
    "OemPreInstalledAppsEnabled"
    "PreInstalledAppsEnabled"
    "PreInstalledAppsEverEnabled"
    "SilentInstalledAppsEnabled"
    "SoftLandingEnabled"
    "SubscribedContentEnabled"
    "FeatureManagementEnabled"
    "SystemPaneSuggestionsEnabled"
    "RemediationRequired"
)

foreach ($RegName in $ContentDeliveryManagerBlock) {
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name $RegName -Type DWord -Value 0
}

Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions" -Recurse
Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps" -Recurse

Write-Host "<==========[Gaming Section]==========>"

Write-Host "Disable Game Bar & Game DVR..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0

Write-Host "Enable game mode..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\GameBar" -Name "AllowAutoGameMode" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 1

Write-Host "Enable Hardware Accelerated GPU Scheduling... (Windows 10 2004 + NVIDIA 10 Series Above + AMD 5000 and Above)"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Type DWord -Value 2

Write-Host "<==========[Privacy Section]==========>"

Write-Host "-> General"

Write-Host "Settings -> Privacy -> General -> Let apps use my advertising ID..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0

Write-Host "- Let websites provide locally..."
Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1

Write-Host "-> Speech"

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Type DWord -Value 0

Write-Host "-> Inking & Typing Personalization"

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0

Write-Host "-> Diagnostics & Feedback"

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtLevel" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowDeviceNameInTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey" -Name "EnableEventTranscript" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0

Write-Host "-> Location"

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"

Write-Host "-> Notifications"

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" -Name "Value" -Value "Deny"

Write-Host "-> App Diagnostics"

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Value "Deny" # Or Allow

Write-Host "-> Account Info Access"

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Value "Deny"

Write-Host "-> Background Apps"

Write-Host "Disabling Background Apps..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BackgroundAppGlobalToggle" -Type DWord -Value 0

Write-Host "Disable File Explorer Ads (OneDrive, New Features etc.)"

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0

Write-Host "Disable Windows Spotlight Features"
Write-Host "Disable Third Party Suggestions"
Write-Host "Disable More Telemetry Features"

Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "ConfigureWindowsSpotlight" -Type DWord -Value 2
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "IncludeEnterpriseSpotlight" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightFeatures" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightWindowsWelcomeExperience" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightOnActionCenter" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightOnSettings" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableThirdPartySuggestions" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1

Write-Host "Disable Third Party Suggestions"
Write-Host "Disable app suggestions on start"

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableThirdPartySuggestions" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableUAR" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" -Name "Start" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" -Name "Start" -Type DWord -Value 0

Write-Host "- SmartScreen Filter for Store Apps: Disable"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 0

Write-Host "WiFi Sense: HotSpot Sharing: Disable"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "value" -Type DWord -Value 0
Write-Host "WiFi Sense: Shared HotSpot Auto-Connect: Disable"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "value" -Type DWord -Value 0

Write-Host "Change Windows Updates to 'Notify to schedule restart'"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "UxOption" -Type DWord -Value 1
Write-Host "Disable P2P Update downloads outside of local network"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 0

Write-Host "*** Hide the search box from taskbar. You can still search by pressing the Win key and start typing what you're looking for ***"
# "0 = hide completely, 1 = show only icon, 2 = show long search box"
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

Write-Host "Repairing high RAM usage..."
Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Type DWord -Value 4

Write-Host "Disabling Cortana..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCloudSearch" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1

Write-Host "Unlimit your network bandwitdh for all your system" # Based on this Chris Titus video: https://youtu.be/7u1miYJmJ_4
New-FolderForced -Path "HKLM:\SOFTWARE\Policies\Microsoft\Psched"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Psched" -Name "NonBestEffortLimit" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff

Write-Host "Set the DNS from Google"
Set-DNSClientServerAddress -interfaceIndex 12 -ServerAddresses ("8.8.8.8","8.8.4.4") # Ethernet
Set-DNSClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("8.8.8.8","8.8.4.4")
Set-DNSClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("8.8.8.8","8.8.4.4")

Write-Host "Bring back F8 for alternative Boot Modes"
bcdedit /set {default} bootmenupolicy legacy
bcdedit /set `{current`} bootmenupolicy Legacy

Push-Location ..\utils
    Write-Host "Dark theme"
    regedit /s dark-theme.reg
    Write-Host "Enabling photo viewer"
    regedit /s enable-photo-viewer.reg
    Write-Host "Lowering the RAM usage"
    regedit /s lower-ram-usage.reg
Pop-Location