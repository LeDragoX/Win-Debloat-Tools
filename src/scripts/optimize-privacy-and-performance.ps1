Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"file-runner.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://youtu.be/qWESrvP_uU8
# Adapted from: https://youtu.be/hQSkPmZRCjc
# Adapted from: https://github.com/ChrisTitusTech/win10script
# Adapted from: https://github.com/Sycnex/Windows10Debloater
# Adapted from: ://github.com/kalaspuffar/windows-debloat

function Optimize-PrivacyAndPerformance() {
    # Initialize all Path variables used to Registry Tweaks
    $PathToLMActivityHistory = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    $PathToLMAutoLogger = "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger"
    $PathToLMDeliveryOptimizationCfg = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
    $PathToLMPoliciesAdvertisingInfo = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"
    $PathToLMPoliciesCloudContent = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $PathToLMPoliciesPsched = "HKLM:\SOFTWARE\Policies\Microsoft\Psched"
    $PathToLMPoliciesSQMClient = "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows"
    $PathToLMPoliciesTelemetry = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $PathToLMPoliciesTelemetry2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    $PathToLMPoliciesToWifi = "HKLM:\Software\Microsoft\PolicyManager\default\WiFi"
    $PathToLMPoliciesWindowsStore = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
    $PathToLMPoliciesWindowsUpdate = "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $PathToLMPrefetchParams = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
    $PathToLMWindowsTroubleshoot = "HKLM:\SOFTWARE\Microsoft\WindowsMitigation"
    $PathToCUContentDeliveryManager = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    $PathToCUDeviceAccessGlobal = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global"
    $PathToCUGameBar = "HKCU:\SOFTWARE\Microsoft\GameBar"
    $PathToCUInputPersonalization = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
    $PathToCUInputTIPC = "HKCU:\SOFTWARE\Microsoft\Input\TIPC"
    $PathToCUOnlineSpeech = "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"
    $PathToCUPoliciesCloudContent = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $PathToCUSearch = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    $PathToCUSiufRules = "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"

    Write-Title -Text "Privacy And Performance Tweaks"
    Write-Section -Text "Personalization"
    Write-Caption -Text "Start & Lockscreen"
    Write-Host "$($EnableStatus[0]) Show me the windows welcome experience after updates..."
    Write-Host "$($EnableStatus[0]) 'Get fun facts and tips, etc. on lock screen'..."

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

    Write-Warning "[?][Priv&Perf] From Path: [$PathToCUContentDeliveryManager]."
    ForEach ($Name in $ContentDeliveryManagerDisableOnZero) {
        Write-Host "$($EnableStatus[0]) $($Name): $Zero."
        Set-ItemProperty -Path "$PathToCUContentDeliveryManager" -Name "$Name" -Type DWord -Value $Zero
    }

    Write-Host "[-][Priv&Perf] Disabling 'Suggested Content in the Settings App'..."
    If (Test-Path "$PathToCUContentDeliveryManager\Subscriptions") {
        Remove-Item -Path "$PathToCUContentDeliveryManager\Subscriptions" -Recurse
    }

    Write-Host "$($EnableStatus[0]) 'Show Suggestions' in Start..."
    If (Test-Path "$PathToCUContentDeliveryManager\SuggestedApps") {
        Remove-Item -Path "$PathToCUContentDeliveryManager\SuggestedApps" -Recurse
    }

    Write-Section -Text "Privacy -> Windows Permissions"
    Write-Caption -Text "General"
    Write-Host "$($EnableStatus[0]) Let apps use my advertising ID..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value $Zero
    If (!(Test-Path "$PathToLMPoliciesAdvertisingInfo")) {
        New-Item -Path "$PathToLMPoliciesAdvertisingInfo" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMPoliciesAdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value $One

    Write-Host "$($EnableStatus[0]) 'Let websites provide locally relevant content by accessing my language list'..."
    Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value $One

    Write-Caption -Text "Speech"
    Write-Host "$($EnableStatus[0]) Online Speech Recognition..."
    If (!(Test-Path "$PathToCUOnlineSpeech")) {
        New-Item -Path "$PathToCUOnlineSpeech" -Force | Out-Null
    }
    # [@] (0 = Decline, 1 = Accept)
    Set-ItemProperty -Path "$PathToCUOnlineSpeech" -Name "HasAccepted" -Type DWord -Value $Zero

    Write-Caption -Text "Inking & Typing Personalization"
    Set-ItemProperty -Path "$PathToCUInputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToCUInputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value $One
    Set-ItemProperty -Path "$PathToCUInputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value $One
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value $Zero

    Write-Caption -Text "Diagnostics & Feedback"
    Write-Host "$($EnableStatus[0]) telemetry..."
    # [@] (0 = Security (Enterprise only), 1 = Basic Telemetry, 2 = Enhanced Telemetry, 3 = Full Telemetry)
    Set-ItemProperty -Path "$PathToLMPoliciesTelemetry" -Name "AllowTelemetry" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToLMPoliciesTelemetry2" -Name "AllowTelemetry" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToLMPoliciesTelemetry" -Name "AllowDeviceNameInTelemetry" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) send inking and typing data to Microsoft..."
    If (!(Test-Path "$PathToCUInputTIPC")) {
        New-Item -Path "$PathToCUInputTIPC" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToCUInputTIPC" -Name "Enabled" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) Tailored Experiences..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) View diagnostic data..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey" -Name "EnableEventTranscript" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) feedback frequency..."
    If (!(Test-Path "$PathToCUSiufRules")) {
        New-Item -Path "$PathToCUSiufRules" -Force | Out-Null
    }
    If ((Test-Path "$PathToCUSiufRules\PeriodInNanoSeconds")) {
        Remove-ItemProperty -Path "$PathToCUSiufRules" -Name "PeriodInNanoSeconds"
    }
    Set-ItemProperty -Path "$PathToCUSiufRules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value $Zero

    Write-Caption -Text "Activity History"
    Write-Host "$($EnableStatus[0]) Activity History..."
    $ActivityHistoryDisableOnZero = @(
        "EnableActivityFeed"
        "PublishUserActivities"
        "UploadUserActivities"
    )

    Write-Warning "[?][Priv&Perf] From Path: [$PathToLMActivityHistory]."
    ForEach ($Name in $ActivityHistoryDisableOnZero) {
        Write-Host "$($EnableStatus[0]) $($Name): $Zero."
        Set-ItemProperty -Path "$PathToLMActivityHistory" -Name "$ActivityHistoryDisableOnZero" -Type DWord -Value $Zero
    }

    Write-Section -Text "Privacy -> Apps Permissions"
    Write-Caption -Text "Location"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value $Zero
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "EnableStatus" -Type DWord -Value $Zero

    Write-Caption -Text "Notifications"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" -Name "Value" -Value "Deny"

    Write-Caption -Text "App Diagnostics"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Name "Value" -Value "Deny"

    Write-Caption -Text "Account Info Access"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Value "Deny"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Name "Value" -Value "Deny"

    Write-Caption -Text "Other Devices"
    Write-Host "[-][Priv&Perf] Denying device access..."
    If (!(Test-Path "$PathToCUDeviceAccessGlobal\LooselyCoupled")) {
        New-Item -Path "$PathToCUDeviceAccessGlobal\LooselyCoupled" -Force | Out-Null
    }
    # Disable sharing information with unpaired devices
    Set-ItemProperty -Path "$PathToCUDeviceAccessGlobal\LooselyCoupled" -Name "Value" -Value "Deny"
    ForEach ($key in (Get-ChildItem "$PathToCUDeviceAccessGlobal")) {
        If ($key.PSChildName -EQ "LooselyCoupled") {
            continue
        }
        Write-Host "$($EnableStatus[1]) Setting $($key.PSChildName) value to 'Deny'..."
        Set-ItemProperty -Path ("$PathToCUDeviceAccessGlobal\" + $key.PSChildName) -Name "Value" -Value "Deny"
    }

    Write-Caption -Text "Background Apps"
    Write-Host "$($EnableStatus[0]) Background Apps..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value $One
    Set-ItemProperty -Path "$PathToCUSearch" -Name "BackgroundAppGlobalToggle" -Type DWord -Value $Zero

    Write-Section -Text "Update & Security"
    Write-Caption -Text "Windows Update"
    Write-Host "[-][Priv&Perf] Disabling Automatic Download and Installation of Windows Updates..."
    If (!(Test-Path "$PathToLMPoliciesWindowsUpdate")) {
        New-Item -Path "$PathToLMPoliciesWindowsUpdate" -Force | Out-Null
    }
    # [@] (2 = Notify before download, 3 = Automatically download and notify of installation)
    # [@] (4 = Automatically download and schedule installation, 5 = Automatic Updates is required and users can configure it)
    Set-ItemProperty -Path "$PathToLMPoliciesWindowsUpdate" -Name "AUOptions" -Type DWord -Value 2

    Write-Host "$($EnableStatus[1]) Automatic Updates..."
    # [@] (0 = Enable Automatic Updates, 1 = Disable Automatic Updates)
    Set-ItemProperty -Path "$PathToLMPoliciesWindowsUpdate" -Name "NoAutoUpdate" -Type DWord -Value $Zero

    Write-Host "[+][Priv&Perf] Setting Scheduled Day to Every day..."
    # [@] (0 = Every day, 1~7 = The days of the week from Sunday (1) to Saturday (7) (Only valid if AUOptions = 4))
    Set-ItemProperty -Path "$PathToLMPoliciesWindowsUpdate" -Name "ScheduledInstallDay" -Type DWord -Value 0

    Write-Host "[-][Priv&Perf] Setting Scheduled time to 03h00m..."
    # [@] (0-23 = The time of day in 24-hour format)
    Set-ItemProperty -Path "$PathToLMPoliciesWindowsUpdate" -Name "ScheduledInstallTime" -Type DWord -Value 3

    Write-Host "$($EnableStatus[1]) Change Windows Updates to 'Notify to schedule restart'..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "UxOption" -Type DWord -Value $One

    Write-Host "$($EnableStatus[1]) Restricting Windows Update P2P downloads for Local Network only..."
    If (!(Test-Path "$PathToLMDeliveryOptimizationCfg")) {
        New-Item -Path "$PathToLMDeliveryOptimizationCfg" -Force | Out-Null
    }
    # [@] (0 = Off, 1 = Local Network only, 2 = Local Network private peering only)
    # [@] (3 = Local Network and Internet,  99 = Simply Download mode, 100 = Bypass mode)
    Set-ItemProperty -Path "$PathToLMDeliveryOptimizationCfg" -Name "DODownloadMode" -Type DWord -Value $One

    Write-Caption -Text "Troubleshooting"
    Write-Host "[+][Priv&Perf] Enabling Automatic Recommended Troubleshooting, then notify me..."
    If (!(Test-Path "$PathToLMWindowsTroubleshoot")) {
        New-Item -Path "$PathToLMWindowsTroubleshoot" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMWindowsTroubleshoot" -Name "UserPreference" -Type DWord -Value 3

    Write-Host "$($EnableStatus[0]) Windows Spotlight Features..."
    Write-Host "$($EnableStatus[0]) Third Party Suggestions..."
    Write-Host "$($EnableStatus[0]) More Telemetry Features..."

    $CloudContentDisableOnOne = @(
        "DisableWindowsSpotlightFeatures"
        "DisableWindowsSpotlightOnActionCenter"
        "DisableWindowsSpotlightOnSettings"
        "DisableWindowsSpotlightWindowsWelcomeExperience"
        "DisableTailoredExperiencesWithDiagnosticData"      # Tailored Experiences
        "DisableThirdPartySuggestions"
    )

    Write-Warning "[?][Priv&Perf] From Path: [$PathToCUPoliciesCloudContent]."
    ForEach ($Name in $CloudContentDisableOnOne) {
        Write-Host "$($EnableStatus[0]) $($Name): $One."
        Set-ItemProperty -Path "$PathToCUPoliciesCloudContent" -Name "$Name" -Type DWord -Value $One
    }
    If (!(Test-Path "$PathToCUPoliciesCloudContent")) {
        New-Item -Path "$PathToCUPoliciesCloudContent" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToCUPoliciesCloudContent" -Name "ConfigureWindowsSpotlight" -Type DWord -Value 2
    Set-ItemProperty -Path "$PathToCUPoliciesCloudContent" -Name "IncludeEnterpriseSpotlight" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) Apps Suggestions..."
    If (!(Test-Path "$PathToLMPoliciesCloudContent")) {
        New-Item -Path "$PathToLMPoliciesCloudContent" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMPoliciesCloudContent" -Name "DisableThirdPartySuggestions" -Type DWord -Value $One
    Set-ItemProperty -Path "$PathToLMPoliciesCloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value $One

    # Reference: https://forums.guru3d.com/threads/windows-10-registry-tweak-for-disabling-drivers-auto-update-controversy.418033/
    Write-Host "$($EnableStatus[0]) automatic driver updates..."
    # [@] (0 = Yes, do this automatically, 1 = No, let me choose what to do, Always install the best, 2 = [...] Install driver software from Windows Update, 3 = [...] Never install driver software from Windows Update
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value $One
    # [@] (0 = Enhanced icons enabled, 1 = Enhanced icons disabled)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" -Name "SearchOrderConfig" -Type DWord -Value $One

    If (!(Test-Path "$PathToLMPoliciesSQMClient")) {
        New-Item -Path "$PathToLMPoliciesSQMClient" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMPoliciesSQMClient" -Name "CEIPEnable" -Type DWord -Value $Zero
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Type DWord -Value $Zero
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableUAR" -Type DWord -Value $One

    # Details: https://docs.microsoft.com/pt-br/windows-server/remote/remote-desktop-services/rds-vdi-recommendations-2004#windows-system-startup-event-traces-autologgers
    Write-Host "$($EnableStatus[0]) some startup event traces (AutoLoggers)..."
    If (!(Test-Path "$PathToLMAutoLogger\AutoLogger-Diagtrack-Listener")) {
        New-Item -Path "$PathToLMAutoLogger\AutoLogger-Diagtrack-Listener" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMAutoLogger\AutoLogger-Diagtrack-Listener" -Name "Start" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToLMAutoLogger\SQMLogger" -Name "Start" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) 'WiFi Sense: HotSpot Sharing'..."
    If (!(Test-Path "$PathToLMPoliciesToWifi\AllowWiFiHotSpotReporting")) {
        New-Item -Path "$PathToLMPoliciesToWifi\AllowWiFiHotSpotReporting" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMPoliciesToWifi\AllowWiFiHotSpotReporting" -Name "value" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) 'WiFi Sense: Shared HotSpot Auto-Connect'..."
    If (!(Test-Path "$PathToLMPoliciesToWifi\AllowAutoConnectToWiFiSenseHotspots")) {
        New-Item -Path "$PathToLMPoliciesToWifi\AllowAutoConnectToWiFiSenseHotspots" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMPoliciesToWifi\AllowAutoConnectToWiFiSenseHotspots" -Name "value" -Type DWord -Value $Zero

    Write-Section -Text "Gaming"
    Write-Host "$($EnableStatus[0]) Game Bar & Game DVR..."
    $Scripts = @("disable-game-bar-dvr.reg")
    If ($Revert) {
        $Scripts = @("enable-game-bar-dvr.reg")
    }
    Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle "" -DoneMessage "" -NoDialog

    Write-Host "[=][Priv&Perf] Enabling game mode..."
    Set-ItemProperty -Path "$PathToCUGameBar" -Name "AllowAutoGameMode" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToCUGameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 1

    Write-Section -Text "System"
    Write-Caption -Text "Display"
    Write-Host "[+][Priv&Perf] Enable Hardware Accelerated GPU Scheduling... (Windows 10 20H1+ - Needs Restart)"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Type DWord -Value 2

    # Show Task Manager details - Applicable to 1607 and later - Although this functionality exist even in earlier versions, the Task Manager's behavior is different there and is not compatible with this tweak
    Write-Host "$($EnableStatus[1]) Showing task manager details..."
    $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
    Do {
        Start-Sleep -Milliseconds 100
        $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
    } Until ($preferences)
    Stop-Process $taskmgr
    $preferences.Preferences[28] = 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences

    Write-Caption "Deleting useless registry keys..."
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

    ForEach ($Key in $KeysToDelete) {
        If ((Test-Path $Key)) {
            Write-Host "[Priv&Perf] Removing Key: [$Key]."
            Remove-Item $Key -Recurse
        }
    }

    Write-Title -Text "Performance Tweaks"
    Write-Host "$($EnableStatus[0]) SysMain/Superfetch..."
    # As SysMain was already disabled on the Services, just need to remove it's key
    # [@] (0 = Disable SysMain, 1 = Enable when program is launched, 2 = Enable on Boot, 3 = Enable on everything)
    Set-ItemProperty -Path "$PathToLMPrefetchParams" -Name "EnableSuperfetch" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) Remote Assistance..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value $Zero

    Write-Host "[-][Priv&Perf] Disabling Ndu High RAM Usage..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Type DWord -Value 4

    # Details: https://www.tenforums.com/tutorials/94628-change-split-threshold-svchost-exe-windows-10-a.html
    # Will reduce Processes number considerably on > 4GB of RAM systems
    Write-Host "[+][Priv&Perf] Setting SVCHost to match RAM size..."
    $RamInKB = (Get-WmiObject -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1KB
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $RamInKB

    Write-Host "[+][Priv&Perf] Unlimiting your network bandwidth for all your system..." # Based on this Chris Titus video: https://youtu.be/7u1miYJmJ_4
    If (!(Test-Path "$PathToLMPoliciesPsched")) {
        New-Item -Path "$PathToLMPoliciesPsched" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMPoliciesPsched" -Name "NonBestEffortLimit" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff

    Write-Host "[=][Priv&Perf] Enabling Windows Store apps Automatic Updates..."
    If (!(Test-Path "$PathToLMPoliciesWindowsStore")) {
        New-Item -Path "$PathToLMPoliciesWindowsStore" -Force | Out-Null
    }
    If ((Get-Item "$PathToLMPoliciesWindowsStore").GetValueNames() -like "AutoDownload") {
        Remove-ItemProperty -Path "$PathToLMPoliciesWindowsStore" -Name "AutoDownload" # [@] (2 = Disable, 4 = Enable)
    }

    Write-Section -Text "Power Plan Tweaks"
    Write-Host "[+][Priv&Perf] Setting Power Plan to High Performance..."
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

    # Found on the registry: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\User\Default\PowerSchemes
    Write-Host "[+][Priv&Perf] Enabling (Not setting) the Ultimate Performance Power Plan..."
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61

    Write-Section -Text "Network & Internet"
    Write-Caption -Text "Proxy"
    Write-Host "[-][Priv&Perf] Fixing Edge slowdown by NOT Automatically Detecting Settings..."
    # Code from: https://www.reddit.com/r/PowerShell/comments/5iarip/set_proxy_settings_to_automatically_detect/?utm_source=share&utm_medium=web2x&context=3
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections'
    $data = (Get-ItemProperty -Path $key -Name DefaultConnectionSettings).DefaultConnectionSettings
    $data[8] = 3
    Set-ItemProperty -Path $key -Name DefaultConnectionSettings -Value $data
}

function Main() {
    $Zero = 0
    $One = 1
    $EnableStatus = @(
        "[-][Priv&Perf] Disabling",
        "[+][Priv&Perf] Enabling"
    )

    If (($Revert)) {
        Write-Warning "[<][Priv&Perf] Reverting: $Revert."
        $Zero = 1
        $One = 0
        $EnableStatus = @(
            "[<][Priv&Perf] Re-Enabling",
            "[<][Priv&Perf] Re-Disabling"
        )
    }

    Optimize-PrivacyAndPerformance # Disable Registries that causes slowdowns and privacy invasion
}

Main