# Made by LeDragoX
# Adapted from matthewjberger's script:                     https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f
# Adapted from these Baboo videos:                          https://youtu.be/qWESrvP_uU8, https://youtu.be/xz3oXHleKoM
# Adapted from this AdamX's video REG scripts:              https://youtu.be/hQSkPmZRCjc
# Adapted from this ChrisTitus script:                      https://github.com/ChrisTitusTech/win10script
# Adapted from this Sycnex script:                          https://github.com/Sycnex/Windows10Debloater
# Adapted from this kalaspuffar/Daniel Persson script:      https://github.com/kalaspuffar/windows-debloat

Write-Host "Current Script Folder $PSScriptRoot"
Import-Module BitsTransfer # To enable file downloading
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Check-OS-Info.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Count-N-Seconds.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Simple-Message-Box.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Title-Templates.psm1

$CPU = DetectCPU
# Initialize all Path variables used to Registry Tweaks
$Global:PathToActivityHistory =         "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$Global:PathToCloudContent =            "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$Global:PathToContentDeliveryManager =  "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
$Global:PathToDeliveryOptimization =    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization"
$Global:PathToExplorer =                "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
$Global:PathToExplorerAdvanced =        "$PathToExplorer\Advanced"
$Global:PathToGameBar =                 "HKCU:\SOFTWARE\Microsoft\GameBar"
$Global:PathToInputPersonalization =    "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
$Global:PathToLiveTiles =               "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
$Global:PathToMicrosoftEdge =           "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge"
$Global:PathToPsched =                  "HKLM:\SOFTWARE\Policies\Microsoft\Psched"
$Global:PathToSearch =                  "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
$Global:PathToSiufRules =               "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
$Global:PathToWindowsStore =            "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
$Global:PathToWindowsUpdate =           "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU"

function RunDebloatSoftwares {
    
    Title1 -Text "Your drives status:"
    wmic diskdrive get caption,status
    
    # If changing the programs folder move here!!!
    Push-Location "..\lib\Debloat-Softwares"

        Write-Host "+ Running ShutUp10 and applying configs..."
        Push-Location "ShutUp10"
            Start-BitsTransfer -Source "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe" -Destination "OOSU10.exe"
            Start-Process -FilePath ".\OOSU10.exe" -ArgumentList "ooshutup10.cfg", "/quiet" -Wait   # Wait until the process closes
            Remove-Item "*.*" -Exclude "*.cfg" -Force                                               # Leave no traces
        Pop-Location

        Write-Host "+ Running AdwCleaner to do a Quick Virus/Adware Scan..."
        Push-Location "AdwCleaner"
            Start-BitsTransfer -Source "https://downloads.malwarebytes.com/file/adwcleaner" -Destination "adwcleaner.exe"
            Start-Process -FilePath ".\adwcleaner.exe" -ArgumentList "/eula", "/clean", "/noreboot" -Wait
            Remove-Item ".\adwcleaner.exe" -Force
        Pop-Location

    Pop-Location
    
}

function TweaksForScheduledTasks {

    Title1Counter -Text "Scheduled Tasks tweaks" -MaxNum 7
    
    # Took from: https://docs.microsoft.com/pt-br/windows-server/remote/remote-desktop-services/rds-vdi-recommendations#task-scheduler
    $DisableScheduledTasks = @(
        "\Microsoft\Office\OfficeTelemetryAgentLogOn"
        "\Microsoft\Office\OfficeTelemetryAgentFallBack"
        "\Microsoft\Office\Office 15 Subscription Heartbeat"
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
        "\Microsoft\Windows\Application Experience\StartupAppTask"
        "\Microsoft\Windows\Autochk\Proxy"
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"           # Recommended state for VDI use
        "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"         # Recommended state for VDI use
        "\Microsoft\Windows\Customer Experience Improvement Program\Uploader"
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"                # Recommended state for VDI use
        "\Microsoft\Windows\Defrag\ScheduledDefrag"                                         # Recommended state for VDI use
        "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"   
        "\Microsoft\Windows\Location\Notifications"                                         # Recommended state for VDI use
        "\Microsoft\Windows\Location\WindowsActionDialog"                                   # Recommended state for VDI use
        "\Microsoft\Windows\Maintenance\WinSAT"                                             # Recommended state for VDI use
        "\Microsoft\Windows\Maps\MapsToastTask"                                             # Recommended state for VDI use
        "\Microsoft\Windows\Maps\MapsUpdateTask"                                            # Recommended state for VDI use
        "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser"                  # Recommended state for VDI use
        "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"                     # Recommended state for VDI use
        "\Microsoft\Windows\Retail Demo\CleanupOfflineContent"                              # Recommended state for VDI use
        "\Microsoft\Windows\Shell\FamilySafetyMonitor"                                      # Recommended state for VDI use
        "\Microsoft\Windows\Shell\FamilySafetyRefreshTask"                                  # Recommended state for VDI use
        "\Microsoft\Windows\Shell\FamilySafetyUpload"
        "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary"                            # Recommended state for VDI use
        )
        
        foreach ($ScheduledTask in $DisableScheduledTasks) {
            Write-Host "[TaskScheduler] Disabling the $ScheduledTask Task..."
            Disable-ScheduledTask -TaskName $ScheduledTask
        }
        
        $EnableScheduledTasks = @(
            "\Microsoft\Windows\RecoveryEnvironment\VerifyWinRE"            # It's about the Recovery before starting Windows, with Diagnostic tools and Troubleshooting when your PC isn't healthy, need this ON.
            "\Microsoft\Windows\Windows Error Reporting\QueueReporting"     # Windows Error Reporting event, needed most for compatibility updates incoming 
    )

    foreach ($ScheduledTask in $EnableScheduledTasks) {
        Write-Host "[TaskScheduler] Enabling the $ScheduledTask Task..."
        Enable-ScheduledTask -TaskName $ScheduledTask
    }

}

function TweaksForService {

    Title1Counter -Text "Services tweaks"
    Title1 -Text "Re-enabling services at Startup"
    
    $EnableServices = @(
        "BITS"                                      # Background Intelligent Transfer Service
        "DPS"                                       # Diagnostic Policy Service
        "FontCache"                                 # Windows Font Cache Service
        "WMPNetworkSvc"                             # Windows Media Player Network Sharing Service (Miracast / Wi-Fi Direct)
    )
        
    foreach ($Service in $EnableServices) {
        Write-Host "[Services] Starting and re-enabling $Service at Startup..."
        Set-Service -Name $Service -Status Running
        Set-Service -Name $Service -StartupType Automatic
    }
    
    Title1 -Text "Disabling services at Startup"
        
    $DisableServices = @(
        "DiagTrack"                                 # Connected User Experiences and Telemetry
        "diagnosticshub.standardcollector.service"  # Microsoft (R) Diagnostics Hub Standard Collector Service
        "dmwappushservice"                          # Device Management Wireless Application Protocol (WAP)
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
        Set-Service -Name "$Service" -Status Stopped
        Set-Service -Name "$Service" -StartupType Disabled
    }

}

function TweaksForPrivacyAndPerformance {

    Title1Counter -Text "Privacy And Performance Tweaks"
    Title1 -Text "Remove Telemetry & Data Collection"
    Section1 -Text "Personalization Section"
    Caption1 -Text "? & ? & Start & Lockscreen"

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
        
    Section1 -Text "Privacy Section"
    Caption1 -Text "General"
    
    Write-Host "- Let apps use NOT my advertising ID..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
    
    Write-Host "- Let websites provide locally..."
    Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1
    
    Caption1 -Text "Speech"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Type DWord -Value 0
    
    Caption1 -Text "Inking & Typing Personalization"
    
    Set-ItemProperty -Path "$PathToInputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToInputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToInputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
    
    Caption1 -Text "Diagnostics & Feedback"
    
    If (!(Test-Path "$PathToSiufRules")) {
        New-Item -Path "$PathToSiufRules" -Force | Out-Null
    }
    If ((Test-Path "$PathToSiufRules\PeriodInNanoSeconds")){
        Remove-ItemProperty -Path "$PathToSiufRules" -Name "PeriodInNanoSeconds" -Force
    }
    Set-ItemProperty -Path "$PathToSiufRules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtLevel" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey" -Name "EnableEventTranscript" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowDeviceNameInTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

    Caption1 -Text "Activity History"

    Write-Host "- Disabling Activity History..."
    $ActivityHistoryDisableOnZero = @(
        "EnableActivityFeed"
        "PublishUserActivities"
        "UploadUserActivities"
    )
    foreach ($Name in $ActivityHistoryDisableOnZero) {
        Write-Host "[Registry] From Path: [$PathToActivityHistory]"
        Write-Host "[Registry] Setting $Name value: 0"
        Set-ItemProperty -Path "$PathToActivityHistory" -Name "$ActivityHistoryDisableOnZero" -Type DWord -Value 0
    }
    
    Caption1 -Text "Location"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
    
    Caption1 -Text "Notifications"
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" -Name "Value" -Value "Deny"
    
    Caption1 -Text "App Diagnostics"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Value "Deny"
    
    Caption1 -Text "Account Info Access"
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Value "Deny"
    
    Caption1 -Text "Background Apps"
    
    Write-Host "- Disabling Background Apps..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToSearch" -Name "BackgroundAppGlobalToggle" -Type DWord -Value 0
    
    Section1 -Text "Update & Security Section"
    Caption1 -Text "Windows Update"
    
    Write-Host "- Disabling Automatic Download and Installation of Windows Updates..."
    If (!(Test-Path "$PathToWindowsUpdate")) {
        New-Item -Path "$PathToWindowsUpdate" -Force | Out-Null
    }
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
        New-Item -Path "$PathToDeliveryOptimization" -Force | Out-Null
    }
    If (!(Test-Path "$PathToDeliveryOptimization\Config")) {
        New-Item -Path "$PathToDeliveryOptimization\Config" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToDeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1

    Caption1 -Text "Troubleshooting"

    Write-Host "+ Enabling Automatic Recommended Troubleshooting, then notify me..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsMitigation" -Name "UserPreference" -Type DWord -Value 3

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
        New-Item -Path "$PathToCloudContent" -Force | Out-Null
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
        
    Write-Host "- Disabling 'WiFi Sense: HotSpot Sharing'..."
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "value" -Type DWord -Value 0
    Write-Host "- Disabling 'WiFi Sense: Shared HotSpot Auto-Connect'..."
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "value" -Type DWord -Value 0
    
    Section1 -Text "Gaming Section"
    
    Write-Host "- Disabling Game Bar & Game DVR..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
    
    Write-Host "+ Enabling game mode..."
    Set-ItemProperty -Path "$PathToGameBar" -Name "AllowAutoGameMode" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToGameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 1
    
    Section1 -Text "System Section"
    Caption1 -Text "Display"

    Write-Host "+ Enable Hardware Accelerated GPU Scheduling... (Windows 10 20H1+ - Needs Restart)"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Type DWord -Value 2

    Section1 -Text "Explorer Tweaks"

    Write-Host "- Removing 3D Objects from This PC..."
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"

    $ExplorerAdvKeysToZero = @(
        # Show Drives without Media
        "HideDrivesWithNoMedia"
        # Show file extensions in Explorer
        "HideFileExt"
        # Disable File Explorer Ads (OneDrive, New Features etc.)
        "ShowSyncProviderNotifications"
        # Disable MRU lists (jump lists) of XAML apps in Start Menu
        "Start_TrackDocs"
        "Start_TrackProgs"
    )
    $ExplorerAdvKeysToOne = @(
        # Disable Aero-Shake Minimize feature
        "DisallowShaking"
        # Set Windows Explorer to start on This PC instead of Quick Access (1 = This PC, 2 = Quick access)
        "LaunchTo"
        # Show hidden files in Explorer
        "Hidden"
        # Show super hidden system files in Explorer
        #"ShowSuperHidden"
    )
    foreach ($Name in $ExplorerAdvKeysToZero) {
        Write-Host "[Registry] From Path: [$PathToExplorerAdvanced]"
        Write-Host "[Registry] Setting $Name value: 0"
        Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "$Name" -Type DWord -Value 0
    }
    foreach ($Name in $ExplorerAdvKeysToOne) {
        Write-Host "[Registry] From Path: [$PathToExplorerAdvanced]"
        Write-Host "[Registry] Setting $Name value: 1"
        Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "$Name" -Type DWord -Value 1
    }

    Write-Host "+ Showing file transfer details..."
	If (!(Test-Path "$PathToExplorer\OperationStatusManager")) {
		New-Item -Path "$PathToExplorer\OperationStatusManager" -Force | Out-Null
	}
	Set-ItemProperty -Path "$PathToExplorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value 1

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
    
    Section1 -Text "Deleting useless registry keys..."
        
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
        Remove-Item $Key -Recurse -Force # This will not be debugged
    }

    Section1 -Text "Performance Tweaks"
    
    Write-Host "- Disabling Superfetch and APPs Prelaunching..."
    # Superfetch is the SAME as Prefetcher, disable BOTH (0 = Disable Superfetch, 1 = Enable when program is launched, 2 = Enable on Boot, 3 = Enable on everything)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Type DWord -Value 0
    Disable-MMAgent -ApplicationPreLaunch
    
    Write-Host "- Disabling Remote Assistance..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
    
    Write-Host "- Disabling Ndu High RAM Usage..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Type DWord -Value 4

    # https://www.tenforums.com/tutorials/94628-change-split-threshold-svchost-exe-windows-10-a.html
    Write-Host "+ Splitting SVCHost processes to lower RAM usage..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value 4194304

}

function TweaksForSecurity {

    Title1Counter -Text "Security Tweaks"

    Write-Host "+ Ensure your Windows Defender is ENABLED, if you already use another antivirus, nothing will happen."
    Set-MpPreference -DisableRealtimeMonitoring $false -Force

    Write-Host "+ Enabling Microsoft Defender Exploit Guard network protection... (if you already use another antivirus, nothing will happen)"
    Set-MpPreference -EnableNetworkProtection Enabled -Force

    Write-Host "+ Enabling detection for potentially unwanted applications and block them... (if you already use another antivirus, nothing will happen)"
    Set-MpPreference -PUAProtection Enabled -Force

    # Make Windows Defender run in Sandbox Mode (Will run on background MsMpEngCP.exe and MsMpEng.exe)
    # Why? https://www.microsoft.com/security/blog/2018/10/26/windows-defender-antivirus-can-now-run-in-a-sandbox/
    Write-Host "+ Enabling Windows Defender Sandbox mode... (if you already use another antivirus, nothing will happen)"
    setx /M MP_FORCE_USE_SANDBOX 1  # Restart the PC to apply the changes, 0 to Revert

    # https://techcommunity.microsoft.com/t5/storage-at-microsoft/stop-using-smb1/ba-p/425858
    Write-Host "= Disabling SMB 1.0 protocol..."
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

    # Enable strong cryptography for .NET Framework (version 4 and above) - https://stackoverflow.com/questions/36265534/invoke-webrequest-ssl-fails
    Write-Host "+ Enabling .NET strong cryptography..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1

    Write-Host "- Disabling Autoplay..."
    Set-ItemProperty -Path "$PathToExplorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1

    Write-Host "- Disabling Autorun for all Drives..."
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255

    Write-Host "- Disabling Search for App in Store for Unknown Extensions..."
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1

    # https://docs.microsoft.com/pt-br/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings
    Write-Host "+ Raising UAC level..."
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
    }
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 5
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 1

    Write-Host "+ Enabling Meltdown (CVE-2017-5754) compatibility flag..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Force | Out-Null
	}
    if ($CPU.contains("Intel" -or "ARM")) {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -Type DWord -Value 0
    } else {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -Type DWord -Value 1
    }

    Write-Host "+ Enabling 'SmartScreen' for Microsoft Edge..."
    If (!(Test-Path "$PathToMicrosoftEdge\PhishingFilter")) {
        New-Item -Path "$PathToMicrosoftEdge\PhishingFilter" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToMicrosoftEdge\PhishingFilter" -Name "EnabledV9" -Type DWord -Value 1

    Write-Host "+ Enabling 'SmartScreen' for Store Apps..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 1

    # The "OpenPowershellHere.cmd" file actually uses .vbs script, so, i'll make this optional
    # [DIY] Disable Windows Script Host (execution of *.vbs scripts and alike)
    #Write-Host "- Disabling Windows Script Host..."
    #Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Type DWord -Value 0

}

function PersonalTweaks {

    Title1Counter -Text "My Personal Tweaks"

    Push-Location "..\utils"
        Write-Host "+ Enabling Dark theme..."
        regedit /s dark-theme.reg
        Write-Host "- Disabling Cortana..."
        regedit /s disable-cortana.reg
        Write-Host "+ Enabling photo viewer..."
        regedit /s enable-photo-viewer.reg
    Pop-Location

    Section1 -Text "Windows Explorer Tweaks"

    Write-Host "- Hiding Quick Access from Windows Explorer..."
    Set-ItemProperty -Path "$PathToExplorer" -Name "ShowFrequent" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToExplorer" -Name "ShowRecent" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToExplorer" -Name "HubMode" -Type DWord -Value 1

    Section1 -Text "Personalization Section"
    Section1 -Text "TaskBar Tweaks"
    
    Write-Host "- Hiding the search box from taskbar... (0 = Hide completely, 1 = Show icon only, 2 = Show long Search Box)"
    Set-ItemProperty -Path "$PathToSearch" -Name "SearchboxTaskbarMode" -Type DWord -Value 0

    Write-Host "- Hiding the Task View from taskbar... (0 = Hide Task view, 1 = Show Task view)"
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "ShowTaskViewButton" -Type DWord -Value 0

    Write-Host "- Hiding People icon..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced\People" -Name "PeopleBand" -Type DWord -Value 0

    Write-Host "- Disabling Live Tiles..."
    if (!(Test-Path "$PathToLiveTiles")) {
        New-Item -Path "$PathToLiveTiles" -Force | Out-Null
    }
    Set-ItemProperty -Path $PathToLiveTiles -Name "NoTileApplicationNotification" -Type DWord -Value 1

    Write-Host "= Enabling Auto tray icons..."
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
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "DisableThumbnailCache" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "DisableThumbsDBOnNetworkFolders" -Type DWord -Value 1

    Caption1 -Text "Colors"

    Write-Host "- Disabling taskbar transparency."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value 0

    Section1 -Text "System Section"
    Caption1 -Text "Multitasking"

    Write-Host "- Disabling Edge multi tabs showing on Alt + Tab..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 3

    Section1 -Text "Devices Section"
    Caption1 -Text "Bluetooth & other devices"

    Write-Host "+ Enabling driver download over metered connections..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup" -Name "CostedNetworkPolicy" -Type DWord -Value 1
    
    Section1 -Text "Cortana Tweaks"

    Write-Host "- Disabling Bing Search in Start Menu..."
    Set-ItemProperty -Path "$PathToSearch" -Name "BingSearchEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "$PathToSearch" -Name "CortanaConsent" -Type DWord -Value 0

    Write-Host "+ Keep ENABLED Error reporting..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 0

    Write-Host "- Disabling Windows Store apps Automatic Updates..."
    If (!(Test-Path "$PathToWindowsStore")) {
        New-Item -Path "$PathToWindowsStore" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToWindowsStore" -Name "AutoDownload" -Type DWord -Value 2
    
    Write-Host "+ Unlimiting your network bandwitdh for all your system..." # Based on this Chris Titus video: https://youtu.be/7u1miYJmJ_4
    If (!(Test-Path "$PathToPsched")) {
        New-Item -Path "$PathToPsched" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToPsched" -Name "NonBestEffortLimit" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff

    Section1 -Text "Network & Internet Section"
    Caption1 -Text "Proxy"

    # Code from: https://www.reddit.com/r/PowerShell/comments/5iarip/set_proxy_settings_to_automatically_detect/?utm_source=share&utm_medium=web2x&context=3
    Write-Host "- Fixing Edge slowdown by NOT Automatically Detecting Settings..."
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
    $data = (Get-ItemProperty -Path $key -Name DefaultConnectionSettings).DefaultConnectionSettings
    $data[8] = 3
    Set-ItemProperty -Path $key -Name DefaultConnectionSettings -Value $data    

    Write-Host "+ Setting time to UTC..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type DWord -Value 1
    
    Write-Host "+ Setting up the DNS from Google..."
    Set-DNSClientServerAddress -interfaceIndex 12 -ServerAddresses ("8.8.8.8","8.8.4.4") # Ethernet
    Set-DNSClientServerAddress -InterfaceAlias "Ethernet*" -ServerAddresses ("8.8.8.8","8.8.4.4")
    Set-DNSClientServerAddress -InterfaceAlias "Wi-Fi*" -ServerAddresses ("8.8.8.8","8.8.4.4")
    
    Write-Host "+ Bringing back F8 alternative Boot Modes..."
    bcdedit /set `{current`} bootmenupolicy Legacy

    Write-Host "+ Fixing Xbox Game Bar FPS Counter... (LIMITED BY LANGUAGE)"
    net localgroup "Performance Log Users" "$env:USERNAME" /add         # ENG
    net localgroup "Usuários de log de desempenho" "$env:USERNAME" /add # PT-BR

    Write-Host "= Enabling Memory Compression..."
    Enable-MMAgent -MemoryCompression

    Section1 -Text "Power Plan Tweaks"

    Write-Host "+ Setting Power Plan to High Performance..."
    Try {
        powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    }
    Catch {
        Write-Host "An Error Occurred:"
        Write-Host "Reason: $_"
        Write-Host "Where: "$_.ScriptStackTrace
        powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    }

    # Found on the registry: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\User\Default\PowerSchemes
    Write-Host "+ Enabling (Not setting) the Ultimate Performance Power Plan..."
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61

    Write-Host "= Fix Hibernate not working..."
    powercfg -h on
    powercfg -h -type full

    Write-Host "+ Setting the Monitor Timeout to 10 min (AC = Alternating Current, DC = Direct Current)"
    powercfg -Change Monitor-Timeout-AC 10
    powercfg -Change Monitor-Timeout-DC 10

    Write-Host "+ Setting the Disk Timeout to 10 min"
    powercfg -Change Disk-Timeout-AC 10
    powercfg -Change Disk-Timeout-DC 10

    Write-Host "+ Setting the Standby Timeout to 10 min"
    powercfg -Change Standby-Timeout-AC 10
    powercfg -Change Standby-Timeout-DC 10

    Write-Host "+ Setting the Hibernate Timeout to 10 min"
    powercfg -Change Hibernate-Timeout-AC 10
    powercfg -Change Hibernate-Timeout-DC 10

}

function RemoveBloatwareApps {

    Title1Counter -Text "Remove Bloatware Apps"

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

        # <==========[ DIY ]==========> (Remove the # to Unninstall)

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
        Get-AppxPackage -Name $Bloat| Remove-AppxPackage    # App
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online  # Payload
    }

}

function EnableFeatures {

    Title1Counter -Text "Install additional features for Windows"
    
    # Dism /online /Get-Features #/Format:Table # To find all features
    # Get-WindowsOptionalFeature -Online
    
    $FeatureName = @(
        "Microsoft-Hyper-V-All"                 # Hyper-V - VT-d (Intel) / SVM (AMD) needed on BIOS
        "NetFx3"                                # NET Framework 3.5
        "NetFx4-AdvSrvs"                        # NET Framework 4
        "NetFx4Extended-ASPNET45"               # NET Framework 4.x
        "DirectPlay"                            # Direct Play
        # WSL 2 Support Semi-Install
        "Microsoft-Windows-Subsystem-Linux"     # WSL
        "VirtualMachinePlatform"                # VM Platform
    )
    
    foreach ($Feature in $FeatureName) {
        $FeatureDetails = $(Get-WindowsOptionalFeature -Online -FeatureName $Feature)
        
        Write-Host "Checking if $Feature was already installed..."
        Write-Host "$Feature Status:" $FeatureDetails.State
        if ($FeatureDetails.State -like "Enabled") {
            Write-Host "$Feature already installed! Skipping..."
        }
        elseif ($FeatureDetails.State -like "Disabled") {
            Write-Host "Installing $Feature..."
            Dism -Online -Enable-Feature -All -NoRestart -FeatureName:$Feature
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

RunDebloatSoftwares             # [AUTOMATED] ShutUp10 with personal configs and AdwCleaner for Virus Scanning.
TweaksForScheduledTasks         # Disable Scheduled Tasks that causes slowdowns
TweaksForService                # Enable essential Services and Disable bloating Services
TweaksForPrivacyAndPerformance  # Disable Registries that causes slowdowns and privacy invasion
TweaksForSecurity               # Improve the Windows Security
PersonalTweaks                  # The icing on the cake, last and useful optimizations
RemoveBloatwareApps             # Remove the main Bloat from Pre-installed Apps
EnableFeatures                  # Enable features claimed as Optional on Windows, but actually, they are useful