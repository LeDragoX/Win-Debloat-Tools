# Made by LeDragoX
# Adapted from matthewjberger's script:                     https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f
# Adapted from this Baboo video:                            https://youtu.be/qWESrvP_uU8
# Adapted from this AdamX video's REG scripts:              https://youtu.be/hQSkPmZRCjc
# Adapted from this ChrisTitus script:                      https://github.com/ChrisTitusTech/win10script
# Adapted from this Sycnex script:                          https://github.com/Sycnex/Windows10Debloater
# Adapted from this kalaspuffar/Daniel Persson script:      https://github.com/kalaspuffar/windows-debloat

Write-Host "Current Script Folder $PSScriptRoot"
Import-Module BitsTransfer # To enable file downloading
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Count-N-Seconds.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\New-FolderForced.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Simple-Message-Box.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Title-Templates.psm1

# Initialize all Path variables used to Registry Tweaks
$Global:PathToActivityHistory =         "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$Global:PathToCloudContent =            "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$Global:PathToCortana =                 "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
$Global:PathToContentDeliveryManager =  "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
$Global:PathToDeliveryOptimization =    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization"
$Global:PathToExplorer =                "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
$Global:PathToExplorerAdvanced =        "$PathToExplorer\Advanced"
$Global:PathToGameBar =                 "HKCU:\SOFTWARE\Microsoft\GameBar"
$Global:PathToInputPersonalization =    "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
$Global:PathToLiveTiles =               "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
$Global:PathToPsched =                  "HKLM:\SOFTWARE\Policies\Microsoft\Psched"
$Global:PathToSearch =                  "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
$Global:PathToSiufRules =               "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
$Global:PathToWindowsStore =            "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
$Global:PathToWindowsUpdate =           "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU"

function RunDebloatSoftwares {

    $Message = "[This is a DIY step]
    1 - If showed click [I AGREE]
    2 - Click on the guide Tools >
    3 - Go on Import/Export Tweaks >
    4 - Import tweaks from a file >
    5 - hit Next > Browse... > Select 'My_Winaero_Profile.ini' >
    6 - Next > Finish (DON'T SPAM)
    7 - Close it then OK"
    
    BeautyTitleTemplate -Text "Your drives status:"
    wmic diskdrive get caption,status
    
    # If changing the programs folder move here!!!
    Push-Location "..\lib\Debloat-Softwares"
    
    Write-Host "+ [DIY] Running WinAero Tweaker..."
        Expand-Archive '.\Winaero Tweaker.zip'
        Push-Location "Winaero Tweaker"
            Remove-Item ".\Winaero.url" -Force -Recurse # Web page Shortcut
            Start-Process -FilePath ".\WinaeroTweaker.exe" # Could not download it (Tried Start-BitsTransfer and WebClient, but nothing)
        Pop-Location
    
        CountNseconds -Time 2 -Msg "Waiting" # Count 2 seconds then show the Message
        ShowMessage -Title "DON'T CLOSE YET" -Message $Message
        Taskkill /F /IM "WinaeroTweaker.exe"
        Taskkill /F /IM "WinaeroTweakerHelper.exe"
        Remove-Item ".\Winaero Tweaker\" -Exclude "*.ini" -Force -Recurse
    
        Write-Host "+ Running ShutUp10 and applying configs..."
        Push-Location "ShutUp10"
            Start-BitsTransfer -Source "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -Destination "OOSU10.exe"
            Start-Process -FilePath ".\OOSU10.exe" -ArgumentList "ooshutup10.cfg", "/quiet" -Wait   # quiet may be better? # Wait until the process closes
            Remove-Item "*.*" -Exclude "*.cfg" -Force                                               # Leave no traces
        Pop-Location
    Pop-Location
    
    Push-Location "..\utils"
        Write-Host "+ Enabling Dark theme..."
        regedit /s dark-theme.reg
        Write-Host "+ Enabling photo viewer..."
        regedit /s enable-photo-viewer.reg
        Write-Host "+ Lowering the RAM usage..."
        regedit /s lower-ram-usage.reg
    Pop-Location

}

function TweaksForScheduledTasks {

    TitleWithContinuousCounter -Text "Scheduled Tasks tweaks" -MaxNum 7
    
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

function TweaksForService {

    TitleWithContinuousCounter -Text "Services tweaks"
    BeautyTitleTemplate -Text "Re-enabling services at Startup"
    
    $EnableServices = @(
        "BITS"                                      # Background Intelligent Transfer Service
        "DPS"                                       # Diagnostic Policy Service
        "WMPNetworkSvc"                             # Windows Media Player Network Sharing Service (Miracast / Wi-Fi Direct)
    )
        
    foreach ($Service in $EnableServices) {
        Write-Host "[Services] Starting and re-enabling $Service at Startup..."
        Set-Service -Name $Service -Status Running
        Set-Service -Name $Service -StartupType Automatic
    }
    
    BeautyTitleTemplate -Text "Disabling services at Startup"
        
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
        "SysMain"                                   # SysMain / Superfetch (100% Disk)
        "TrkWks"                                    # Distributed Link Tracking Client
        "WbioSrvc"                                  # Windows Biometric Service (required for Fingerprint reader / facial detection)
        "WSearch"                                   # Windows Search (100% Disk)

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

function TweaksForRegistry {

    TitleWithContinuousCounter -Text "Registry Tweaks"
    BeautyTitleTemplate -Text "Remove Telemetry & Data Collection"

    BeautySectionTemplate -Text "Personalization Section"
        
    CaptionTemplate -Text "? & ? & Start & Lockscreen"
    Write-Host "- Disabling Show me the windows welcome experience after updates..."
    Write-Host "- Disabling 'Get fun facts and tips, etc. on lock screen'..."
    
    $ContentDeliveryManagerDisableOnZero = @(
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
    foreach ($Name in $ContentDeliveryManagerDisableOnZero) {
        Write-Host "[Registry] From Path: [$PathToContentDeliveryManager]"
        Write-Host "[Registry] Setting $Name value: 0"
        Set-ItemProperty -Path "$PathToContentDeliveryManager" -Name "$Name" -Type DWord -Value 0
    }

    Write-Host "- Disabling 'Suggested Content in the Settings App'..."
    If (Test-Path "$PathToContentDeliveryManager\Subscriptions") {
        Remove-Item -Path "$PathToContentDeliveryManager\Subscriptions" -Recurse
    }
    
    Write-Host "- Disabling 'Show Suggestions' in Start..."
    If (Test-Path "$PathToContentDeliveryManager\SuggestedApps") {
        Remove-Item -Path "$PathToContentDeliveryManager\SuggestedApps" -Recurse
    }
    
    BeautySectionTemplate -Text "Gaming Section"
    
    Write-Host "- Disabling Game Bar & Game DVR..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
    
    Write-Host "+ Enabling game mode..."
    Set-ItemProperty -Path "$PathToGameBar" -Name "AllowAutoGameMode" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToGameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 1
    
    Write-Host "+ Enable Hardware Accelerated GPU Scheduling... (Windows 10 2004 + NVIDIA 10 Series Above + AMD 5000 and Above)"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Type DWord -Value 2
    
    BeautySectionTemplate -Text "Privacy Section"
    
    CaptionTemplate -Text "General"
    
    Write-Host "+ Settings --> Privacy --> General --> Let apps use my advertising ID..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
    
    Write-Host "+ Let websites provide locally..."
    Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1
    
    CaptionTemplate -Text "Speech"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Type DWord -Value 0
    
    CaptionTemplate -Text "Inking & Typing Personalization"
    
    Set-ItemProperty -Path "$PathToInputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToInputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToInputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
    
    CaptionTemplate -Text "Diagnostics & Feedback"
    
    If (!(Test-Path "$PathToSiufRules")) {
        New-FolderForced -Path "$PathToSiufRules"
    }
    If ((Test-Path "$PathToSiufRules\PeriodInNanoSeconds")){
        Remove-ItemProperty -Path "$PathToSiufRules" -Name "PeriodInNanoSeconds"
    }
    Set-ItemProperty -Path "$PathToSiufRules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtLevel" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey" -Name "EnableEventTranscript" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowDeviceNameInTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

    CaptionTemplate -Text "Activity History"

    Write-Host "- Disabling Activity History..."
    $ActivityHistoryDisableOnZero = @(
        "EnableActivityFeed"
        "PublishUserActivities"
        "UploadUserActivities"
    )
    foreach ($Name in $ActivityHistoryDisableOnZero) {
        Write-Host "[Registry] From Path: [$PathToActivityHistory]"
        Write-Host "[Registry] Setting $Name value: 1"
        Set-ItemProperty -Path "$PathToActivityHistory" -Name "$ActivityHistoryDisableOnZero" -Type DWord -Value 0
    }
    
    CaptionTemplate -Text "Location"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
    
    CaptionTemplate -Text "Notifications"
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" -Name "Value" -Value "Deny"
    
    CaptionTemplate -Text "App Diagnostics"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Value "Deny"
    
    CaptionTemplate -Text "Account Info Access"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Value "Deny"
    
    CaptionTemplate -Text "Background Apps"
    
    Write-Host "- Disabling Background Apps..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToSearch" -Name "BackgroundAppGlobalToggle" -Type DWord -Value 0
    
    BeautySectionTemplate -Text "Update & Security Section"
    
    CaptionTemplate -Text "Windows Update"
    
    Write-Host "- Disabling Automatic Download and Installation of Windows Updates..."
    New-FolderForced -Path "$PathToWindowsUpdate"
    Set-ItemProperty -Path "$PathToWindowsUpdate" -Name "AUOptions" -Type DWord -Value 2
    Set-ItemProperty -Path "$PathToWindowsUpdate" -Name "NoAutoUpdate" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToWindowsUpdate" -Name "ScheduledInstallDay" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToWindowsUpdate" -Name "ScheduledInstallTime" -Type DWord -Value 3

    Write-Host "+ Assuring automatic driver update is ENABLED..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Type DWord -Value 1
    
    Write-Host "+ Change Windows Updates to 'Notify to schedule restart'..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "UxOption" -Type DWord -Value 1
    
    Write-Host "+ Restricting Windows Update P2P downloads for Local Network only..."
    Write-Host "(0 = Off, 1 = Local Network only, 2 = Local Network private peering only      )"
    Write-Host "(3 = Local Network and Internet,  99 = Simply Download mode, 100 = Bypass mode)"
    If (!(Test-Path "$PathToDeliveryOptimization")) {
        New-FolderForced -Path "$PathToDeliveryOptimization"
    }
    If (!(Test-Path "$PathToDeliveryOptimization\Config")) {
        New-FolderForced -Path "$PathToDeliveryOptimization\Config"
    }
    Set-ItemProperty -Path "$PathToDeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1

    Write-Host "- Disabling Windows Spotlight Features..."
    Write-Host "- Disabling Third Party Suggestions..."
    Write-Host "- Disabling More Telemetry Features..."
    
    $CloudContentDisableOnOne = @(
        "DisableWindowsSpotlightFeatures"
        "DisableWindowsSpotlightOnActionCenter"
        "DisableWindowsSpotlightOnSettings"
        "DisableWindowsSpotlightWindowsWelcomeExperience"
        "DisableTailoredExperiencesWithDiagnosticData"
        "DisableThirdPartySuggestions"
    )
    foreach ($Name in $CloudContentDisableOnOne) {
        Write-Host "[Registry] From Path: [$PathToCloudContent]"
        Write-Host "[Registry] Setting $Name value: 1"
        Set-ItemProperty -Path "$PathToCloudContent" -Name "$Name" -Type DWord -Value 1
    }
    If (!(Test-Path "$PathToCloudContent")) {
        New-FolderForced -Path "$PathToCloudContent"
    }
    Set-ItemProperty -Path "$PathToCloudContent" -Name "ConfigureWindowsSpotlight" -Type DWord -Value 2
    Set-ItemProperty -Path "$PathToCloudContent" -Name "IncludeEnterpriseSpotlight" -Type DWord -Value 0
    
    Write-Host "- Disabling Apps Suggestions..."
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableThirdPartySuggestions" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableUAR" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" -Name "Start" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" -Name "Start" -Type DWord -Value 0
    
    Write-Host "- Disabling 'SmartScreen Filter' for Store Apps..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 0
    
    Write-Host "- Disabling 'WiFi Sense: HotSpot Sharing'..."
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "value" -Type DWord -Value 0
    Write-Host "- Disabling 'WiFi Sense: Shared HotSpot Auto-Connect'..."
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "value" -Type DWord -Value 0
    
    BeautySectionTemplate -Text "Explorer Tweaks"

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
        Write-Host "[Registry] From Path: [$PathToExplorerAdvanced]"
        Write-Host "[Registry] Setting $Name value: 0"
        Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "$Name" -Type DWord -Value 0
    }
    foreach ($Name in $ExplorerKeysToOne) {
        Write-Host "[Registry] From Path: [$PathToExplorerAdvanced]"
        Write-Host "[Registry] Setting $Name value: 1"
        Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "$Name" -Type DWord -Value 1
    }

    BeautySectionTemplate -Text "These are the registry keys that it will delete."
        
    $KeysToDelete = @(
        # Remove Background Tasks
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

        # Windows File
        "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"

        # Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"

        # Scheduled Tasks to delete
        "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
            
        # Windows Protocol Keys
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
                
        # Windows Share Target
        "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    )
    foreach ($Key in $KeysToDelete) {
        if (!(Test-Path $Key)) { # Only remove if the Path exists
            continue
        }
        Write-Host "[Registry] Removing [$Key]..."
        Remove-Item $Key -Recurse # This will not be debugged
    }

}

function TweaksForSecurity {

    TitleWithContinuousCounter -Text "Security Tweaks"

    Write-Host "+ Ensure your Windows Defender is ENABLED, if you already use another antivirus, this will make nothing."
    Set-MpPreference -DisableRealtimeMonitoring $false -Force

    Write-Host "= Disabling SMB 1.0 protocol... (https://techcommunity.microsoft.com/t5/storage-at-microsoft/stop-using-smb1/ba-p/425858)"
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

    # Enable strong cryptography for .NET Framework (version 4 and above)
    Write-Host "+ Enabling .NET strong cryptography... (https://stackoverflow.com/questions/36265534/invoke-webrequest-ssl-fails)"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1

    Write-Host "- Disabling Autoplay..."
    Set-ItemProperty -Path "$PathToExplorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1

    Write-Host "- Disabling Autorun for all Drives..."
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255

    Write-Host "- Disabling Search for App in Store for Unknown Extensions..."
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1

    # Make Windows Defender run in Sandbox Mode (Will run on background MsMpEngCP.exe and MsMpEng.exe)
    # Why? https://www.microsoft.com/security/blog/2018/10/26/windows-defender-antivirus-can-now-run-in-a-sandbox/
    Write-Host "+ Enabling Windows Defender Sandbox mode... (if you already use another antivirus, this will make nothing)"
    setx /M MP_FORCE_USE_SANDBOX 1  # Restart the PC to apply the changes, 0 to Revert

    # The "utils\Shutdown-Shortcut-To-Desktop.bat" file actually uses .vbs script, so, i'll make this optional
    # [DIY] Disable Windows Script Host (execution of *.vbs scripts and alike)
    #Write-Host "- Disabling Windows Script Host..."
    #Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Type DWord -Value 0

}

function PersonalTweaks {

    TitleWithContinuousCounter -Text "My Personal Tweaks"

    BeautySectionTemplate -Text "Personalization Section"
    BeautySectionTemplate -Text "TaskBar Tweaks"
    
    Write-Host "- Hiding the search box from taskbar... (0 = Hide completely, 1 = Show icon only, 2 = Show long Search Box)"
    Set-ItemProperty -Path "$PathToSearch" -Name "SearchboxTaskbarMode" -Type DWord -Value 0

    Write-Host "- Hiding the Task View from taskbar... (0 = Hide Task view, 1 = Show Task view)"
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "ShowTaskViewButton" -Type DWord -Value 0

    Write-Host "- Hiding People icon..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced\People" -Name "PeopleBand" -Type DWord -Value 0

    Write-Host "- Disabling Live Tiles..."
    if (!(Test-Path "$PathToLiveTiles")) {
        New-FolderForced -Path "$PathToLiveTiles"
    }
    Set-ItemProperty -Path $PathToLiveTiles -Name "NoTileApplicationNotification" -Type DWord -Value 1

    Write-Host "= [Default] Enabling Auto tray icons..."
    Set-ItemProperty -Path "$PathToExplorer" -Name "EnableAutoTray" -Type DWord -Value 1

    Write-Host "+ Showing This PC shortcut on desktop..."
    If (!(Test-Path "$PathToExplorer\HideDesktopIcons\ClassicStartMenu")) {
        New-Item -Path "$PathToExplorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToExplorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
    If (!(Test-Path "$PathToExplorer\HideDesktopIcons\NewStartPanel")) {
        New-Item -Path "$PathToExplorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToExplorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0

    # Disable creation of Thumbs.db thumbnail cache files
    Write-Host "- Disabling creation of Thumbs.db..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbnailCache" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbsDBOnNetworkFolders" -Type DWord -Value 1

    CaptionTemplate -Text "Colors"

    Write-Host "- Disabling taskbar transparency."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value 0

    BeautySectionTemplate -Text "System Section"

    CaptionTemplate -Text "Multitasking"

    Write-Host "- Disabling Edge multi tabs showing on Alt + Tab..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 3

    BeautySectionTemplate -Text "Devices Section"

    CaptionTemplate -Text "Bluetooth & other devices"

    Write-Host "+ Enabling driver download over metered connections..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup" -Name "CostedNetworkPolicy" -Type DWord -Value 1
    
    BeautySectionTemplate -Text "Performance Tweaks"
    
    Write-Host "- Disabling Superfetch..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name EnableSuperfetch -Type DWord -Value 0
    
    Write-Host "- Disabling Remote Assistance..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
    
    Write-Host "- Disabling Ndu High RAM Usage..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Type DWord -Value 4

    BeautySectionTemplate -Text "Cortana Tweaks"

    Write-Host "- Disabling Bing Search in Start Menu..."
    Set-ItemProperty -Path "$PathToSearch" -Name "BingSearchEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "$PathToSearch" -Name "CortanaConsent" -Type DWord -Value 0
    
    BeautySectionTemplate -Text "Disabling Cortana"

    $CortanaDisableOnZero = @(
        "AllowCortana"
        "AllowCloudSearch"
        "ConnectedSearchUseWeb"
    )
    foreach ($Name in $CortanaDisableOnZero) {
        Write-Host "[Registry] From Path: [$PathToCortana]"
        Write-Host "[Registry] Setting $Name value: 0"
        Set-ItemProperty -Path "$PathToCortana" -Name "$Name" -Type DWord -Value 0
    }
    Set-ItemProperty -Path "$PathToCortana" -Name "DisableWebSearch" -Type DWord -Value 1

    # Show Task Manager details - Applicable to 1607 and later - Although this functionality exist even in earlier versions, the Task Manager's behavior is different there and is not compatible with this tweak
    Write-Host "+ Showing task manager details..."
    $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
    Do {
        Start-Sleep -Milliseconds 100
        $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
    } Until ($preferences)
    Stop-Process $taskmgr
    $preferences.Preferences[28] = 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences

    Write-Host "+ Keep ENABLED Error reporting..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 0
    Enable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting"

    Write-Host "- Disabling Windows Store apps Automatic Updates..."
    If (!(Test-Path "$PathToWindowsStore")) {
        New-FolderForced -Path "$PathToWindowsStore"
    }
    Set-ItemProperty -Path "$PathToWindowsStore" -Name "AutoDownload" -Type DWord -Value 2
    
    Write-Host "+ Unlimiting your network bandwitdh for all your system..." # Based on this Chris Titus video: https://youtu.be/7u1miYJmJ_4
    If (!(Test-Path "$PathToPsched")) {
        New-FolderForced -Path "$PathToPsched"
    }
    Set-ItemProperty -Path "$PathToPsched" -Name "NonBestEffortLimit" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff

    Write-Host "+ Setting time to UTC..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type DWord -Value 1
    
    Write-Host "+ Setting up the DNS from Google..."
    Set-DNSClientServerAddress -interfaceIndex 12 -ServerAddresses ("8.8.8.8","8.8.4.4") # Ethernet
    Set-DNSClientServerAddress -InterfaceAlias "Ethernet*" -ServerAddresses ("8.8.8.8","8.8.4.4")
    Set-DNSClientServerAddress -InterfaceAlias "Wi-Fi*" -ServerAddresses ("8.8.8.8","8.8.4.4")
    
    Write-Host "+ Bringing back F8 alternative Boot Modes..."
    bcdedit /set `{current`} bootmenupolicy Legacy

}

function RemoveBloatwareApps {

    TitleWithContinuousCounter -Text "Remove Bloatware Apps"

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

        # <==========[ DIY ]==========> (Remove the # to Debloat)

        # [DIY] Default apps i'll keep

        #"Microsoft.FreshPaint"
        #"Microsoft.GamingServices"
        #"Microsoft.MicrosoftEdge"
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
        # Apps which cannot be removed using Remove-AppxPackage from Xbox
        #"Microsoft.XboxGameCallableUI"
        #"Microsoft.XboxIdentityProvider"
        
        # [DIY] Common Streaming services
        
        #"*Netflix*"
        #"*SpotifyMusic*"

        #"Microsoft.WindowsStore"                   # can't be re-installed

        # Apps which cannot be removed using Remove-AppxPackage
        #"Microsoft.BioEnrollment"
        #"Microsoft.Windows.Cortana"
        #"Microsoft.WindowsFeedback"
        #"Windows.ContactSupport"
    )

    foreach ($Bloat in $Apps) {
        Write-Host "Trying to remove $Bloat ..."
        Get-AppxPackage -Name $Bloat| Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online
    }

}

function EnableFeatures {

    TitleWithContinuousCounter -Text "Install additional features for Windows"
    
    # Dism /online /Get-Features #/Format:Table # To find all features
    # Get-WindowsOptionalFeature -Online
    
    $FeatureName = @(
        "NetFx3"
        "NetFx4-AdvSrvs"
        "NetFx4Extended-ASPNET45"
        "IIS-ASPNET"
        "IIS-ASPNET45"
        "DirectPlay"
        # WSL 2 Support Semi-Install
        "Microsoft-Windows-Subsystem-Linux"
        "VirtualMachinePlatform"
    )
    
    foreach ($Feature in $FeatureName) {
        $FeatureDetails = $(Get-WindowsOptionalFeature -Online -FeatureName $Feature)
        
        Write-Host "Checking if $Feature was already installed..."
        Write-Host "$Feature Status:" $FeatureDetails.State
        if ($FeatureDetails.State -like ("Enabled")) {
            Write-Host "$Feature already installed! Skipping..."
        }
        elseif ($FeatureDetails.State -like "Disabled") {
            Write-Host "Installing $Feature..."
            Dism /Online /Enable-Feature /All /NoRestart /FeatureName:$Feature
        }
        Write-Host ""
    }

    # This is for WSL 2
    If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
        # 1607 needs developer mode to be enabled
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
    }

    wsl --set-default-version 2

}

RunDebloatSoftwares         # Run WinAeroTweaker and ShutUp10 with personal configs.
TweaksForScheduledTasks     # Disable Scheduled Tasks that causes slowdowns
TweaksForService            # Enable essential Services and Disable bloating Services
TweaksForRegistry           # Disable Registries that causes slowdowns
TweaksForSecurity           # Improve a little the Windows Security
PersonalTweaks              # The icing on the cake, last and useful optimizations
RemoveBloatwareApps         # Remove the main Bloat from Pre-installed Apps
EnableFeatures              # Enable features claimed as Optional on Windows, but actually, they are useful