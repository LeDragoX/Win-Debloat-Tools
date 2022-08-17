Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"manage-software.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"new-shortcut.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"remove-uwp-appx.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"set-windows-feature-state.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

$DesktopPath = [Environment]::GetFolderPath("Desktop");
$PathToLMPoliciesActivityHistory = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$PathToLMPoliciesCortana = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
$PathToCUOnlineSpeech = "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"
$PathToCUThemes = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"

function Disable-ActivityHistory() {
    Write-Status -Types "-", "Privacy" -Status "Disabling Activity History..."
    Set-ItemProperty -Path $PathToLMPoliciesActivityHistory -Name "EnableActivityFeed" -Type DWord -Value 0
    Set-ItemProperty -Path $PathToLMPoliciesActivityHistory -Name "PublishUserActivities" -Type DWord -Value 0
    Set-ItemProperty -Path $PathToLMPoliciesActivityHistory -Name "UploadUserActivities" -Type DWord -Value 0
}

function Enable-ActivityHistory() {
    Write-Status -Types "*", "Privacy" -Status "Enabling Activity History..."
    Remove-ItemProperty -Path $PathToLMPoliciesActivityHistory -Name "EnableActivityFeed"
    Remove-ItemProperty -Path $PathToLMPoliciesActivityHistory -Name "PublishUserActivities"
    Remove-ItemProperty -Path $PathToLMPoliciesActivityHistory -Name "UploadUserActivities"
}

function Disable-BackgroundAppsToogle() {
    Write-Status -Types "-", "Misc" -Status "Disabling Background Apps..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BackgroundAppGlobalToggle" -Type DWord -Value 0
}

function Enable-BackgroundAppsToogle() {
    Write-Status -Types "*", "Misc" -Status "Enabling Background Apps..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BackgroundAppGlobalToggle" -Type DWord -Value 1
}

function Disable-ClipboardHistory() {
    Write-Status -Types "-", "Privacy" -Status "Disabling Clipboard History..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowClipboardHistory" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Type DWord -Value 0
}

function Enable-ClipboardHistory() {
    Write-Status -Types "*", "Privacy" -Status "Enabling Clipboard History..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "AllowClipboardHistory" -Type DWord -Value 1
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Type DWord -Value 1
}

function Disable-Cortana() {
    Write-Status -Types "-", "Privacy" -Status "Disabling Cortana..."
    Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "AllowCortana" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "AllowCloudSearch" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "DisableWebSearch" -Type DWord -Value 1
}

function Enable-Cortana() {
    Write-Status -Types "*", "Privacy" -Status "Enabling Cortana..."
    Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "AllowCortana" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "AllowCloudSearch" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "ConnectedSearchUseWeb" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToLMPoliciesCortana" -Name "DisableWebSearch" -Type DWord -Value 0
}

function Disable-DarkTheme() {
    Write-Status -Types "*", "Personal" -Status "Disabling Dark Theme..."
    Set-ItemProperty -Path "$PathToCUThemes" -Name "AppsUseLightTheme" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToCUThemes" -Name "SystemUsesLightTheme" -Type DWord -Value 1
}

function Enable-DarkTheme() {
    Write-Status -Types "+", "Personal" -Status "Enabling Dark Theme..."
    Set-ItemProperty -Path "$PathToCUThemes" -Name "AppsUseLightTheme" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToCUThemes" -Name "SystemUsesLightTheme" -Type DWord -Value 0
}

function Disable-EncryptedDNS() {
    # I'm still not sure how to disable DNS over HTTPS, so this'll need to wait
    # Adapted from: https://stackoverflow.com/questions/64465089/powershell-cmdlet-to-remove-a-statically-configured-dns-addresses-from-a-network
    Write-Status -Types "*" -Status "Resetting DNS server configs..."
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet*" -ResetServerAddresses
    Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi*" -ResetServerAddresses
}

function Enable-EncryptedDNS() {
    # Adapted from: https://techcommunity.microsoft.com/t5/networking-blog/windows-insiders-gain-new-dns-over-https-controls/ba-p/2494644
    Write-Status -Types "+" -Status "Setting up the DNS over HTTPS for Google and Cloudflare (ipv4 and ipv6)..."
    Set-DnsClientDohServerAddress -ServerAddress ("8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844") -AutoUpgrade $true -AllowFallbackToUdp $true
    Set-DnsClientDohServerAddress -ServerAddress ("1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001") -AutoUpgrade $true -AllowFallbackToUdp $true

    Write-Status -Types "+" -Status "Setting up the DNS from Cloudflare and Google (ipv4 and ipv6)..."
    #Get-DnsClientServerAddress # To look up the current config.           # Cloudflare, Google,         Cloudflare,              Google
    Set-DNSClientServerAddress -InterfaceAlias "Ethernet*" -ServerAddresses ("1.1.1.1", "8.8.8.8", "2606:4700:4700::1111", "2001:4860:4860::8888")
    Set-DNSClientServerAddress -InterfaceAlias    "Wi-Fi*" -ServerAddresses ("1.1.1.1", "8.8.8.8", "2606:4700:4700::1111", "2001:4860:4860::8888")
}

function Disable-FastShutdownShortcut() {
    Write-Status -Types "*" -Status "Removing the shortcut to shutdown the computer on the Desktop..." -Warning
    Remove-Item -Path "$DesktopPath\Fast Shutdown.lnk"
}

function Enable-FastShutdownShortcut() {
    $SourcePath = "$env:SystemRoot\System32\shutdown.exe"
    $ShortcutPath = "$DesktopPath\Fast Shutdown.lnk"
    $Description = "Turns off the computer without any prompt"
    $IconLocation = "$env:SystemRoot\System32\shell32.dll, 27"
    $Arguments = "-s -f -t 0"
    $Hotkey = "CTRL+ALT+F12"

    Write-Status -Types "+" -Status "Creating a shortcut to shutdown the computer on the Desktop..."
    New-Shortcut -SourcePath $SourcePath -ShortcutPath $ShortcutPath -Description $Description -IconLocation $IconLocation -Arguments $Arguments -Hotkey $Hotkey
}

function Disable-GodMode() {
    Write-Status -Types "*" -Status "Disabling God Mode hidden folder..." -Warning
    Write-Host @"
###############################################################################
#       _______  _______  ______     __   __  _______  ______   _______       #
#      |       ||       ||      |   |  |_|  ||       ||      | |       |      #
#      |    ___||   _   ||  _    |  |       ||   _   ||  _    ||    ___|      #
#      |   | __ |  | |  || | |   |  |       ||  | |  || | |   ||   |___       #
#      |   ||  ||  |_|  || |_|   |  |       ||  |_|  || |_|   ||    ___|      #
#      |   |_| ||       ||       |  | ||_|| ||       ||       ||   |___       #
#      |_______||_______||______|   |_|   |_||_______||______| |_______|      #
#                                                                             #
#         God Mode has been disabled, link removed from your Desktop          #
#                                                                             #
###############################################################################
"@ -ForegroundColor Cyan

    $DesktopPath = [Environment]::GetFolderPath("Desktop");
    Remove-Item -Path "$DesktopPath\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
}

function Enable-GodMode() {
    Write-Status -Types "+" -Status "Enabling God Mode hidden folder on Desktop..."
    Write-Host @"
###############################################################################
#       _______  _______  ______     __   __  _______  ______   _______       #
#      |       ||       ||      |   |  |_|  ||       ||      | |       |      #
#      |    ___||   _   ||  _    |  |       ||   _   ||  _    ||    ___|      #
#      |   | __ |  | |  || | |   |  |       ||  | |  || | |   ||   |___       #
#      |   ||  ||  |_|  || |_|   |  |       ||  |_|  || |_|   ||    ___|      #
#      |   |_| ||       ||       |  | ||_|| ||       ||       ||   |___       #
#      |_______||_______||______|   |_|   |_||_______||______| |_______|      #
#                                                                             #
#      God Mode has been enabled, check out the new link on your Desktop      #
#                                                                             #
###############################################################################
"@ -ForegroundColor Blue

    $DesktopPath = [Environment]::GetFolderPath("Desktop");
    New-Item -Path "$DesktopPath\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}" -ItemType Directory -Force
}

function Disable-OldVolumeControl() {
    Write-Status -Types "*", "Misc" -Status "Disabling Old Volume Control..."
    Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\MTCUVC" -Name "EnableMtcUvc"
}

function Enable-OldVolumeControl() {
    Write-Status -Types "+", "Misc" -Status "Enabling Old Volume Control..."
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\MTCUVC" -Name "EnableMtcUvc" -Type DWord -Value 0
}

function Disable-OnlineSpeechRecognition() {
    Write-Status -Types "-", "Privacy" -Status "Disabling Online Speech Recognition..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Name "AllowInputPersonalization" -Type DWord -Value 0

    If (!(Test-Path "$PathToCUOnlineSpeech")) {
        New-Item -Path "$PathToCUOnlineSpeech" -Force | Out-Null
    }
    # [@] (0 = Decline, 1 = Accept)
    Set-ItemProperty -Path "$PathToCUOnlineSpeech" -Name "HasAccepted" -Type DWord -Value 0
}

function Enable-OnlineSpeechRecognition() {
    Write-Status -Types "+", "Privacy" -Status "Enabling Online Speech Recognition..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Name "AllowInputPersonalization"

    If (!(Test-Path "$PathToCUOnlineSpeech")) {
        New-Item -Path "$PathToCUOnlineSpeech" -Force | Out-Null
    }
    # [@] (0 = Decline, 1 = Accept)
    Set-ItemProperty -Path "$PathToCUOnlineSpeech" -Name "HasAccepted" -Type DWord -Value 1
}

function Disable-PrintToPDFServicesToogle() {
    Set-OptionalFeatureState -Disabled -OptionalFeatures @("Printing-PrintToPDFServices-Features")
}

function Enable-PrintToPDFServicesToogle() {
    Set-OptionalFeatureState -Enabled -OptionalFeatures @("Printing-PrintToPDFServices-Features")
}

function Disable-PrintingXPSServicesToogle() {
    Set-OptionalFeatureState -Disabled -OptionalFeatures @("Printing-XPSServices-Features")
}

function Enable-PrintingXPSServicesToogle() {
    Set-OptionalFeatureState -Enabled -OptionalFeatures @("Printing-XPSServices-Features")
}

function Disable-SearchAppForUnknownExt() {
    Write-Status -Types "-", "Misc" -Status "Disabling Search for App in Store for Unknown Extensions..."
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1
}

function Enable-SearchAppForUnknownExt() {
    Write-Status -Types "*", "Misc" -Status "Enabling Search for App in Store for Unknown Extensions..."
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
    }
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith"
}

function Disable-Telemetry() {
    Write-Status -Types "-", "Privacy" -Status "Disabling Telemetry..."
    # [@] (0 = Security (Enterprise only), 1 = Basic Telemetry, 2 = Enhanced Telemetry, 3 = Full Telemetry)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowDeviceNameInTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
}

function Enable-Telemetry() {
    Write-Status -Types "*", "Privacy" -Status "Enabling Telemetry..."
    # [@] (0 = Security (Enterprise only), 1 = Basic Telemetry, 2 = Enhanced Telemetry, 3 = Full Telemetry)
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry"
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowDeviceNameInTelemetry"
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry"
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry"
}

function Disable-WindowsMediaPlayer() {
    Set-OptionalFeatureState -Disabled -OptionalFeatures @("MediaPlayback")
}

function Enable-WindowsMediaPlayer() {
    Set-OptionalFeatureState -Enabled -OptionalFeatures @("MediaPlayback")
}

function Disable-WSearchService() {
    Write-Status -Types "-", "Service" -Status "Disabling Search Indexing (Recommended for HDDs)..."
    Get-Service -Name "WSearch" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    Stop-Service "WSearch" -Force -NoWait
}

function Enable-WSearchService() {
    Write-Status -Types "*", "Service" -Status "Enabling Search Indexing (Recommended for SSDs)..."
    Get-Service -Name "WSearch" -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic
    Start-Service "WSearch"
}

function Disable-XboxGameBarDVR() {
    $PathToLMPoliciesGameDVR = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"

    Write-Status -Types "-", "Performance" -Status "Disabling Xbox Game Bar DVR..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
    If (!(Test-Path "$PathToLMPoliciesGameDVR")) {
        New-Item -Path "$PathToLMPoliciesGameDVR" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMPoliciesGameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
}

function Enable-XboxGameBarDVR() {
    $PathToLMPoliciesGameDVR = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"

    Write-Status -Types "*", "Performance" -Status "Enabling Xbox Game Bar DVR..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value"
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled"
    Remove-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled"
    If (!(Test-Path "$PathToLMPoliciesGameDVR")) {
        New-Item -Path "$PathToLMPoliciesGameDVR" -Force | Out-Null
    }
    Remove-ItemProperty -Path "$PathToLMPoliciesGameDVR" -Name "AllowGameDVR"
}
