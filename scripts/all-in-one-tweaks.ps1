# Made by LeDragoX
# Adapted from matthewjberger's script https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f
# Adapted from this Baboo video https://youtu.be/qWESrvP_uU8
# Adapted from this AdamX video https://youtu.be/hQSkPmZRCjc

Write-Host "Original Folder $PSScriptRoot"
Import-Module BitsTransfer # To enable file downloading
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\count-n-seconds.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\New-FolderForced.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\simple-message-box.psm1

function RunDebloatSoftwares {

    $Message = "1 - If showed click [I AGREE]
    2 - Click on the guide Tools >
    3 - Go on Import/Export Tweaks >
    4 - Import tweaks from a file >
    5 - hit Next > Browse... > Select 'Winaero_Tweaker_exported_configs.ini' >
    6 - Next > Finish (DON'T SPAM)
    7 - Close it then OK"
    
    Write-Host "Your drives status:"
    Write-Host "" # New line
    wmic diskdrive get caption,status
    
    # If changing the programs folder move here!!!
    Push-Location "..\lib\Debloat-Softwares"
    
        Push-Location "Winaero Tweaker"
            Start-Process WinaeroTweaker.exe # Could not download it (Tried Start-BitsTransfer and WebClient, but nothing)
        Pop-Location
    
        CountNseconds -Time 2 -Msg "Waiting" # Count 2 seconds then show the Message
        ShowMessage -Title "DON'T CLOSE YET" -Message $Message
    
        Write-Host "Running ShutUp10 and applying configs..."
        Push-Location "ShutUp10"
        Start-BitsTransfer -Source "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -Destination "OOSU10.exe"
        Start-Process -FilePath ".\OOSU10.exe" -ArgumentList "ooshutup10.cfg", "/quiet" -Wait   # quiet may be better? # Wait until the process closes
        Remove-Item "*.*" -Exclude "*.cfg" -Force                                               # Leave no traces
        Pop-Location
    Pop-Location
    
    Push-Location "..\utils"
        Write-Host "Enabling Dark theme..."
        regedit /s dark-theme.reg
        Write-Host "Enabling photo viewer..."
        regedit /s enable-photo-viewer.reg
        Write-Host "Lowering the RAM usage..."
        regedit /s lower-ram-usage.reg
    Pop-Location

}

function RunTweaksForScheduledTasks {

    Write-Host "" # New line
    Write-Host "<==================== 1/4 - [Scheduled Tasks tweaks] ====================>"
    
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
        Write-Host "[TaskScheduler] Disabling the $ScheduledTask Task..."
        Disable-ScheduledTask -TaskName $ScheduledTask
    }

}

function RunTweaksForService {

    Write-Host "" # New line
    Write-Host "<====================     2/4 - [Services tweaks]     ====================>"
    Write-Host "<==================== Re-enabling services at Startup ====================>"
    
    $EnableServices = @(
        "BITS"                                      # Background Intelligent Transfer Service
        "DPS"                                       # Diagnostic Policy Service
        "WSearch"                                   # Windows Search
    )
        
    foreach ($Service in $EnableServices) {
        Write-Host "[Services] Starting and re-enabling $Service at Startup..."
        Set-Service -Name $Service -Status Running
        Set-Service -Name $Service -StartupType Automatic
    }
    
    Write-Host "" # New line
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
        "PcaSvc"                                    # Program Compatibility Assistant (PCA)
        "RemoteAccess"                              # Routing and Remote Access
        "RemoteRegistry"                            # Remote Registry
        "SysMain"                                   # SysMain / Superfetch
        "TrkWks"                                    # Distributed Link Tracking Client
        "WbioSrvc"                                  # Windows Biometric Service (required for Fingerprint reader / facial detection)
        "WMPNetworkSvc"                             # Windows Media Player Network Sharing Service
    
        # <==========[DIY]==========> (Remove the # to Disable)
    
        #"NetTcpPortSharing"                        # Net.Tcp Port Sharing Service
        #"SharedAccess"                             # Internet Connection Sharing (ICS)
        #"stisvc"                                   # Windows Image Acquisition (WIA)
        #"WlanSvc"                                  # WLAN AutoConfig
        #"Wecsvc"                                   # Windows Event Collector
        #"WerSvc"                                   # Windows Error Reporting Service
        #"wscsvc"                                   # Windows Security Center Service
        #"WdiServiceHost"                           # Diagnostic Service Host
        #"WdiSystemHost"                            # Diagnostic System Host
    
        # [DIY] If you don't use Bluetooth devices
    
        #"BTAGService"                              # Bluetooth Audio Gateway Service
        #"bthserv"                                  # Bluetooth Support Service
    
        # [DIY] If you don't use a Printer
    
        #"Spooler"                                  # Print Spooler
        #"PrintNotify"                              # Printer Extensions and Notifications
    
        # [DIY] If you don't use Xbox Live and Games
    
        #"XblAuthManager"                           # Xbox Live Auth Manager
        #"XblGameSave"                              # Xbox Live Game Save Service
        #"XboxGipSvc"                               # Xbox Accessory Management Service
        #"XboxNetApiSvc"                            # Xbox Live Networking Service
    
        # Services which cannot be disabled
        #"WdNisSvc"
    )
    
    foreach ($Service in $DisableServices) {
        Write-Host "[Services] Stopping and Disabling $Service at Startup..."
        Set-Service -Name $Service -Status Stopped
        Set-Service -Name $Service -StartupType Disabled
    }

}

function RunTweaksForRegistry {

    Write-Host "" # New line
    Write-Host "<==================== 3/4 - [Registry Tweaks] ====================>"
    Write-Host "<==================== Remove Telemetry & Data Collection ====================>"
    
    Write-Host "" # New line
    Write-Host "<==========[System Section]==========>"

    Write-Host "-> Multitasking"

    Write-Host "Disable Edge multi tabs showing on Alt + Tab..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 3

    Write-Host "" # New line
    Write-Host "<==========[Devices Section]==========>"

    Write-Host "-> Bluetooth & other devices"

    Write-Host "Enable driver download over metered connections..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup" -Name "CostedNetworkPolicy" -Type DWord -Value 1

    Write-Host "" # New line
    Write-Host "<==========[Personalization Section]==========>"
    
    Write-Host "-> Colors"
    
    Write-Host "-> ? & ? & Start & Lockscreen"
    Write-Host "Disable Show me the windows welcome experience after updates."
    Write-Host "Disable Get fun facts and tips, etc. on lock screen."
    
    $Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    $ContentDeliveryManagerKeysToZero = @(
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
        # Prevents Apps from re-installing
        "ContentDeliveryAllowed"
        "FeatureManagementEnabled"
        "OemPreInstalledAppsEnabled"
        "PreInstalledAppsEnabled"
        "PreInstalledAppsEverEnabled"
        "RemediationRequired"
        "SilentInstalledAppsEnabled"
        "SoftLandingEnabled"
        "SubscribedContentEnabled"
        "SystemPaneSuggestionsEnabled"
    )
            
    foreach ($Name in $ContentDeliveryManagerKeysToZero) {
        Write-Host "[Registry] From Path: [$Path]"
        Write-Host "[Registry] Setting $Name value: 0"
        Set-ItemProperty -Path $Path -Name $Name -Type DWord -Value 0
    }

    Write-Host "Disable Show me suggested content in the settings app."
    If (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions") {
        Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions" -Recurse
    }
    
    Write-Host "Disable Show suggestions in start."
    If (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps") {
        Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps" -Recurse
    }
    
    Write-Host "" # New line
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
    
    Write-Host "" # New line
    Write-Host "<==========[Privacy Section]==========>"
    
    Write-Host "-> General"
    
    Write-Host "Settings -> Privacy -> General -> Let apps use my advertising ID..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
    
    Write-Host "- Let websites provide locally..."
    Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1
    
    Write-Host "-> Speech"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Type DWord -Value 0
    
    Write-Host "-> Inking & Typing Personalization"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
    
    Write-Host "-> Diagnostics & Feedback"
    
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
        New-FolderForced -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtLevel" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey" -Name "EnableEventTranscript" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowDeviceNameInTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    
    Write-Host "-> Location"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"
    
    Write-Host "-> Notifications"
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" -Name "Value" -Value "Deny"
    
    Write-Host "-> App Diagnostics"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Value "Allow" # Or Deny (Just testing to unbreak WU)
    
    Write-Host "-> Account Info Access"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Value "Deny"
    
    Write-Host "-> Background Apps"
    
    Write-Host "Disabling Background Apps..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BackgroundAppGlobalToggle" -Type DWord -Value 0
    
    Write-Host "" # New line
    Write-Host "<==========[Update & Security Section]==========>"
    
    Write-Host "-> Windows Update"
    
    Write-Host "Assure automatic driver update is ENABLED"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Type DWord -Value 1
    
    Write-Host "- Change Windows Updates to 'Notify to schedule restart'"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "UxOption" -Type DWord -Value 1
    
    Write-Host "- Disable P2P Update downloads outside of local network | 0=off, 1=On but local network only, 2=On, local network private peering only, 3=On local network and Internet,99=simply download mode, 100=bypass mode"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
    
    If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
        New-FolderForced -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    }

    Write-Host "Disable Windows Spotlight Features"
    Write-Host "Disable Third Party Suggestions"
    Write-Host "Disable More Telemetry Features"

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "ConfigureWindowsSpotlight" -Type DWord -Value 2
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "IncludeEnterpriseSpotlight" -Type DWord -Value 0
    
    $Path = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $CloudContentRegsToOne = @(
        "DisableWindowsSpotlightFeatures"
        "DisableWindowsSpotlightOnActionCenter"
        "DisableWindowsSpotlightOnSettings"
        "DisableWindowsSpotlightWindowsWelcomeExperience"
        "DisableTailoredExperiencesWithDiagnosticData"
        "DisableThirdPartySuggestions"
    )
    
    foreach ($Name in $CloudContentRegsToOne) {
        Write-Host "[Registry] From Path: [$Path]"
        Write-Host "[Registry] Setting $Name value: 1"
        Set-ItemProperty -Path $Path -Name $Name -Type DWord -Value 1
    }
    
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
    
    Write-Host "- WiFi Sense: HotSpot Sharing: Disable"
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "value" -Type DWord -Value 0
    Write-Host "- WiFi Sense: Shared HotSpot Auto-Connect: Disable"
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "value" -Type DWord -Value 0
    
    Write-Host "" # New line
    Write-Host "<==========[Explorer Tweaks]==========>"

    $Path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $ExplorerKeysToZero = @(
        # *** Show file extensions in Explorer ***
        "HideFileExt"
        # Disable File Explorer Ads (OneDrive, New Features etc.)
        "ShowSyncProviderNotifications"
        # *** Disable MRU lists (jump lists) of XAML apps in Start Menu ***
        "Start_TrackDocs"
        "Start_TrackProgs"
    )
    $ExplorerKeysToOne = @(
        # *** Set Windows Explorer to start on This PC instead of Quick Access *** 1 = This PC, 2 = Quick access
        "LaunchTo"
        # *** Show hidden files in Explorer ***
        "Hidden"
        # *** Show super hidden system files in Explorer ***
        #"ShowSuperHidden"
    )
    
    foreach ($Name in $ExplorerKeysToZero) {
        Write-Host "[Registry] From Path: [$Path]"
        Write-Host "[Registry] Setting $Name value: 0"
        Set-ItemProperty -Path $Path -Name $Name -Type DWord -Value 0
    }
    
    foreach ($Name in $ExplorerKeysToOne) {
        Write-Host "[Registry] From Path: [$Path]"
        Write-Host "[Registry] Setting $Name value: 1"
        Set-ItemProperty -Path $Path -Name $Name -Type DWord -Value 1
    }

}

function RunPersonalTweaks {

    Write-Host "" # New line
    Write-Host "<==================== My Personal Tweaks ====================>"

    Write-Host "" # New line
    Write-Host "<==========[Personalization Section]==========>"
    Write-Host "<==========[TaskBar Tweaks]==========>"
    
    Write-Host "*** Hide the search box from taskbar ***"
    # 0 = Hide completely, 1 = Show icon only, 2 = Show long Search Box
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0

    # Hide the Task View from taskbar. 0 = Hide Task view, 1 = Show Task view
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0

    Write-Host "Hiding People icon..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0

    Write-Host "Disable taskbar transparency."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value 0
    
    Write-Host "Disabling Superfetch..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name EnableSuperfetch -Type DWord -Value 0
    
    Write-Host "Disabling Remote Assistance..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
    
    Write-Host "Repairing high RAM usage..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Type DWord -Value 4
    
    Write-Host "" # New line
    Write-Host "<==========[Disabling Cortana]==========>"

    $Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    $CortanaDisableToZero = @(
        "AllowCortana"
        "AllowCloudSearch"
        "ConnectedSearchUseWeb"
    )

    foreach ($Name in $CortanaDisableToZero) {
        Write-Host "[Registry] From Path: [$Path]"
        Write-Host "[Registry] Setting $Name value: 0"
        Set-ItemProperty -Path $Path -Name $Name -Type DWord -Value 0
    }
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1

    Write-Host "Disable Windows Store apps Automatic Updates"
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore")) {
        New-FolderForced -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "AutoDownload" 2
    
    Write-Host "Unlimiting your network bandwitdh for all your system..." # Based on this Chris Titus video: https://youtu.be/7u1miYJmJ_4
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Psched")) {
        New-FolderForced -Path "HKLM:\SOFTWARE\Policies\Microsoft\Psched"
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Psched" -Name "NonBestEffortLimit" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff

    Write-Host "Setting time to UTC..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type DWord -Value 1
    
    Write-Host "Setting up the DNS from Google..."
    Set-DNSClientServerAddress -interfaceIndex 12 -ServerAddresses ("8.8.8.8","8.8.4.4") # Ethernet
    Set-DNSClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("8.8.8.8","8.8.4.4")
    Set-DNSClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("8.8.8.8","8.8.4.4")
    
    Write-Host "Bring back F8 for alternative Boot Modes"
    bcdedit /set {default} bootmenupolicy legacy
    bcdedit /set `{current`} bootmenupolicy Legacy

}

function RemoveBloatwareApps {

    Write-Host "" # New line
    Write-Host "<==================== 4/4 - [Remove Bloatware Apps] ====================>"

    $Apps = @(
        # [Alphabetic order] Default Windows 10 apps
        "Microsoft.3DBuilder"
        "Microsoft.Appconnector"
        "Microsoft.BingFinance"
        "Microsoft.BingFoodAndDrink"
        "Microsoft.BingHealthAndFitness"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingTranslator"
        "Microsoft.BingTravel"
        "Microsoft.BingWeather"
        "Microsoft.CommsPhone"
        "Microsoft.ConnectivityStore"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftPowerBIForWindows"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MinecraftUWP"
        "Microsoft.MixedReality.Portal"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.Office.OneNote"
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.ScreenSketch"
        "Microsoft.SkypeApp"                        # Who still uses Skype? Use Discord
        "Microsoft.Wallet"
        "Microsoft.WindowsAlarms"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsPhone"
        "Microsoft.WindowsReadingList"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.YourPhone"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        
        # 3rd party Apps
        "*ACGMediaPlayer*"
        "*ActiproSoftwareLLC*"
        "*AdobePhotoshopExpress*"
        "*Asphalt8Airborne*"
        "*AutodeskSketchBook*"
        "*BubbleWitch3Saga*"
        "*CaesarsSlotsFreeCasino*"
        "*CandyCrush*"
        "*COOKINGFEVER*"
        "*CyberLinkMediaSuiteEssentials*"
        "*DisneyMagicKingdoms*"
        "*Dolby*"
        "*DrawboardPDF*"
        "*Duolingo-LearnLanguagesforFree*"
        "*EclipseManager*"
        "*Facebook*"
        "*FarmVille2CountryEscape*"
        "*FitbitCoach*"
        "*Flipboard*"
        "*HiddenCity*"
        "*Hulu*"
        "*iHeartRadio*"
        "*Keeper*"
        "*LinkedInforWindows*"
        "*MarchofEmpires*"
        "*NYTCrossword*"
        "*OneCalendar*"
        "*PandoraMediaInc*"
        "*PhototasticCollage*"
        "*PicsArt-PhotoStudio*"
        "*Plex*"  
        "*PolarrPhotoEditorAcademicEdition*"
        "*RoyalRevolt*"
        "*Shazam*"
        "*SlingTV*"
        "*Speed Test*"
        "*Sway*"
        "*TuneInRadio*"
        "*Twitter*"
        "*Viber*"
        "*WinZipUniversal*"
        "*Wunderlist*"
        "*XING*"
        
        # Apps which other apps depend on
        "Microsoft.Advertising.Xaml"

        # <==========[DIY]==========> (Remove the # to Debloat)

        # [DIY] Default apps i'll keep

        #"Microsoft.FreshPaint"
        #"Microsoft.GamingServices"
        #"Microsoft.MicrosoftStickyNotes"           # Productivity
        #"Microsoft.MSPaint"                        # Where every artist truly start as a kid
        #"Microsoft.WindowsCalculator"              # A basic need
        #"Microsoft.WindowsCamera"                  # People may use it
        #"Microsoft.Windows.Photos"                 # Reproduce GIFs
        
        # [DIY] Xbox Apps and Dependencies
        
        #"Microsoft.Xbox.TCUI"
        #"Microsoft.XboxApp"
        #"Microsoft.XboxGameOverlay"
        #"Microsoft.XboxGamingOverlay"
        #"Microsoft.XboxSpeechToTextOverlay"
        
        # [DIY] Common Streaming services
        
        #"*Netflix*"
        #"*SpotifyMusic*"

        #"Microsoft.WindowsStore"                   # can't be re-installed

        # Apps which cannot be removed using Remove-AppxPackage
        #"Microsoft.BioEnrollment"
        #"Microsoft.MicrosoftEdge"
        #"Microsoft.Windows.Cortana"
        #"Microsoft.WindowsFeedback"
        #"Microsoft.XboxGameCallableUI"
        #"Microsoft.XboxIdentityProvider"
        #"Windows.ContactSupport"
    )

    foreach ($Bloat in $Apps) {
        Write-Output "Trying to remove $Bloat ..."
        Get-AppxPackage -Name $Bloat| Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online
    }

}

RunDebloatSoftwares         # Run WinAeroTweaker and ShutUp10 with personal configs.
RunTweaksForScheduledTasks  # Disable Scheduled Tasks that causes slowdowns
RunTweaksForService         # Enable essential Services and Disable bloating Services
#RunTweaksForRegistry        # Disable Registries that causes slowdowns
RunPersonalTweaks           # The icing on the cake, last and useful optimizations
RemoveBloatwareApps         # Remove the main Bloat from Pre-installed Apps