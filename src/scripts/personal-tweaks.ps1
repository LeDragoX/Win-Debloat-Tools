Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from this ChrisTitus script:                 https://github.com/ChrisTitusTech/win10script
# Adapted from this Sycnex script:                     https://github.com/Sycnex/Windows10Debloater
# Adapted from this kalaspuffar/Daniel Persson script: https://github.com/kalaspuffar/windows-debloat

function Register-PersonalTweaksList() {

    # Initialize all Path variables used to Registry Tweaks
    $Global:PathToCUAccessibility = "HKCU:\Control Panel\Accessibility"
    $Global:PathToCUPoliciesEdge = "HKCU:\SOFTWARE\Policies\Microsoft\Edge"
    $Global:PathToCUExplorer = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
    $Global:PathToCUExplorerAdvanced = "$PathToCUExplorer\Advanced"
    $Global:PathToCUPoliciesExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $Global:PathToCUPoliciesLiveTiles = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
    $Global:PathToCUNewsAndInterest = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds"
    $Global:PathToCUSearch = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"

    Write-Title -Text "My Personal Tweaks"

    Push-Location -Path "$PSScriptRoot\..\utils\"

    Write-Host "[+][Personal] Enabling Dark theme..."
    regedit /s use-dark-theme.reg
    Write-Host "[-][Personal] Disabling Cortana..."
    regedit /s disable-cortana.reg
    Write-Host "[+][Personal] Enabling photo viewer..."
    regedit /s enable-photo-viewer.reg
    Write-Host "[-][Personal] Disabling clipboard history..."
    regedit /s disable-clipboard-history.reg

    Pop-Location

    Write-Section -Text "Windows Explorer Tweaks"

    Write-Host "[-][Personal] Hiding Quick Access from Windows Explorer..."
    Set-ItemProperty -Path "$PathToCUExplorer" -Name "ShowFrequent" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToCUExplorer" -Name "ShowRecent" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToCUExplorer" -Name "HubMode" -Type DWord -Value $One

    Write-Host "[-][Priv&Perf] Removing 3D Objects from This PC..."
    If (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}") {
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse
    }
    If (Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}") {
        Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse
    }

    Write-Host "$($EnableStatus[1]) Show Drives without Media..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "HideDrivesWithNoMedia" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) File Explorer Ads (OneDrive, New Features etc.)..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) MRU lists (jump lists) of XAML apps in Start Menu..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "Start_TrackDocs" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "Start_TrackProgs" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) Aero-Shake Minimize feature..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "DisallowShaking" -Type DWord -Value $One

    # [@] (1 = This PC, 2 = Quick access) # DO NOT REVERT (BREAKS EXPLORER.EXE)
    Write-Host "$[+][Personal] Setting Windows Explorer to start on This PC instead of Quick Access..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "LaunchTo" -Type DWord -Value 1

    Write-Host "$($EnableStatus[1]) Show hidden files in Explorer..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "Hidden" -Type DWord -Value $One

    Write-Host "$($EnableStatus[1]) Showing file transfer details..."
    If (!(Test-Path "$PathToCUExplorer\OperationStatusManager")) {
        New-Item -Path "$PathToCUExplorer\OperationStatusManager" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToCUExplorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value $One

    Write-Section -Text "Personalization"
    Write-Section -Text "Task Bar Tweaks"

    Write-Caption -Text "Task Bar - Windows 10 Compatible"

    # [@] (0 = Hide completely, 1 = Show icon only, 2 = Show long Search Box)
    Write-Host "[-][Personal] Hiding the search box from taskbar..."
    Set-ItemProperty -Path "$PathToCUSearch" -Name "SearchboxTaskbarMode" -Type DWord -Value $Zero

    # [@] (0 = Hide Task view, 1 = Show Task view)
    Write-Host "[-][Personal] Hiding the Task View from taskbar..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "ShowTaskViewButton" -Type DWord -Value $Zero

    # [@] (0 = Disable, 1 = Enable)
    Write-Host "$($EnableStatus[0]) Open on Hover from News and Interest from taskbar..."
    If (!(Test-Path "$PathToCUNewsAndInterest")) {
        New-Item -Path "$PathToCUNewsAndInterest" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToCUNewsAndInterest" -Name "ShellFeedsTaskbarOpenOnHover" -Type DWord -Value $Zero

    # [@] (0 = Enable, 1 = Enable Icon only, 2 = Disable)
    Write-Host "$($EnableStatus[0]) News and Interest from taskbar..."
    Set-ItemProperty -Path "$PathToCUNewsAndInterest" -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 2

    Write-Host "[-][Personal] Hiding People icon..."
    If (!(Test-Path "$PathToCUExplorerAdvanced\People")) {
        New-Item -Path "$PathToCUExplorerAdvanced\People" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced\People" -Name "PeopleBand" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) Live Tiles..."
    If (!(Test-Path "$PathToCUPoliciesLiveTiles")) {
        New-Item -Path "$PathToCUPoliciesLiveTiles" -Force | Out-Null
    }
    Set-ItemProperty -Path $PathToCUPoliciesLiveTiles -Name "NoTileApplicationNotification" -Type DWord -Value $One

    Write-Host "[=][Personal] Enabling Auto tray icons..."
    Set-ItemProperty -Path "$PathToCUExplorer" -Name "EnableAutoTray" -Type DWord -Value 1

    Write-Host "$($EnableStatus[0]) 'Meet now' button on taskbar..."
    If (!(Test-Path "$PathToCUPoliciesExplorer")) {
        New-Item -Path "$PathToCUPoliciesExplorer" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToCUPoliciesExplorer" -Name "HideSCAMeetNow" -Type DWord -Value $One

    Write-Caption -Text "Task Bar - Windows 11 Only"

    # [@] (0 = Hide Widgets, 1 = Show Widgets)
    Write-Host "[-][Personal] Hiding Widgets from taskbar..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "TaskbarDa" -Type DWord -Value $Zero

    # Disable creation of Thumbs.db thumbnail cache files
    Write-Host "$($EnableStatus[0]) creation of Thumbs.db..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "DisableThumbnailCache" -Type DWord -Value $One
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "DisableThumbsDBOnNetworkFolders" -Type DWord -Value $One

    Write-Caption -Text "Colors"

    Write-Host "$($EnableStatus[0]) taskbar transparency..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value $Zero

    Write-Section -Text "System"
    Write-Caption -Text "Multitasking"

    Write-Host "[-][Personal] Disabling Edge multi tabs showing on Alt + Tab..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 3

    Write-Section -Text "Devices"
    Write-Caption -Text "Bluetooth & other devices"

    Write-Host "$($EnableStatus[1]) driver download over metered connections..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup" -Name "CostedNetworkPolicy" -Type DWord -Value $One

    Write-Section -Text "Cortana Tweaks"

    Write-Host "$($EnableStatus[0]) Bing Search in Start Menu..."
    Set-ItemProperty -Path "$PathToCUSearch" -Name "BingSearchEnabled" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToCUSearch" -Name "CortanaConsent" -Type DWord -Value $Zero

    Write-Section -Text "Ease of Access"
    Write-Caption -Text "Keyboard"

    Write-Output "[-][Personal] Disabling Sticky Keys..."
    Set-ItemProperty -Path "$PathToCUAccessibility\StickyKeys" -Name "Flags" -Value "506"
    Set-ItemProperty -Path "$PathToCUAccessibility\Keyboard Response" -Name "Flags" -Value "122"
    Set-ItemProperty -Path "$PathToCUAccessibility\ToggleKeys" -Name "Flags" -Value "58"

    Write-Section -Text "Microsoft Edge Policies"
    Write-Caption -Text "Privacy, search and services / Address bar and search"

    Write-Host "[=][Personal] Show me search and site suggestions using my typed characters..."
    Remove-ItemProperty -Path "$PathToCUPoliciesEdge" -Name "SearchSuggestEnabled" -Force -ErrorAction SilentlyContinue
    Write-Host "[=][Personal] Show me history and favorite suggestions and other data using my typed characters..."
    Remove-ItemProperty -Path "$PathToCUPoliciesEdge" -Name "LocalProvidersEnabled" -Force -ErrorAction SilentlyContinue

    Write-Host "$($EnableStatus[1]) Error reporting..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value $Zero

    # Adapted from: https://techcommunity.microsoft.com/t5/networking-blog/windows-insiders-gain-new-dns-over-https-controls/ba-p/2494644
    Write-Host "[+][Personal] Setting up the DNS over HTTPS for Google and Cloudflare (ipv4 and ipv6)..."
    Set-DnsClientDohServerAddress -ServerAddress ("8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844") -AutoUpgrade $true -AllowFallbackToUdp $true
    Set-DnsClientDohServerAddress -ServerAddress ("1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001") -AutoUpgrade $true -AllowFallbackToUdp $true
    Write-Host "[+][Personal] Setting up the DNS from Google (ipv4 and ipv6)..."
    #Get-DnsClientServerAddress # To look up the current config.           # Cloudflare, Google,         Cloudflare,              Google
    Set-DNSClientServerAddress -InterfaceAlias "Ethernet*" -ServerAddresses ("1.1.1.1", "8.8.8.8", "2606:4700:4700::1111", "2001:4860:4860::8888")
    Set-DNSClientServerAddress -InterfaceAlias    "Wi-Fi*" -ServerAddresses ("1.1.1.1", "8.8.8.8", "2606:4700:4700::1111", "2001:4860:4860::8888")

    Write-Host "[+][Personal] Bringing back F8 alternative Boot Modes..."
    bcdedit /set `{current`} bootmenupolicy Legacy

    Write-Host "[+][Personal] Fixing Xbox Game Bar FPS Counter (LIMITED BY LANGUAGE)..."
    net localgroup "Performance Log Users" "$env:USERNAME" /add         # ENG
    net localgroup "Usuários de log de desempenho" "$env:USERNAME" /add # PT-BR

    Write-Section -Text "Power Plan Tweaks"
    $TimeoutScreenBattery = 5
    $TimeoutScreenPluggedIn = 10

    $TimeoutStandByBattery = 15
    $TimeoutStandByPluggedIn = 30

    $TimeoutDiskBattery = 15
    $TimeoutDiskPluggedIn = 30

    $TimeoutHibernateBattery = 15
    $TimeoutHibernatePluggedIn = 30

    Write-Host "[=][Personal] Setting Hibernate size to full..."
    powercfg -hibernate -type full
    Write-Host "[-][Personal] Disabling Hibernate..."
    powercfg -hibernate off

    Write-Host "[+][Personal] Setting the Monitor Timeout to AC: $TimeoutScreenPluggedIn and DC: $TimeoutScreenBattery..."
    powercfg -Change Monitor-Timeout-AC $TimeoutScreenPluggedIn
    powercfg -Change Monitor-Timeout-DC $TimeoutScreenBattery

    Write-Host "[+][Personal] Setting the Standby Timeout to AC: $TimeoutStandByPluggedIn and DC: $TimeoutStandByBattery..."
    powercfg -Change Standby-Timeout-AC $TimeoutStandByPluggedIn
    powercfg -Change Standby-Timeout-DC $TimeoutStandByBattery

    Write-Host "[+][Personal] Setting the Disk Timeout to AC: $TimeoutDiskPluggedIn and DC: $TimeoutDiskBattery..."
    powercfg -Change Disk-Timeout-AC $TimeoutDiskPluggedIn
    powercfg -Change Disk-Timeout-DC $TimeoutDiskBattery

    Write-Host "[+][Personal] Setting the Hibernate Timeout to AC: $TimeoutHibernatePluggedIn and DC: $TimeoutHibernateBattery..."
    powercfg -Change Hibernate-Timeout-AC $TimeoutHibernatePluggedIn
    powercfg -Change Hibernate-Timeout-DC $TimeoutHibernateBattery

}

function Main() {

    $Zero = 0
    $One = 1
    $EnableStatus = @(
        "[-][Personal] Disabling",
        "[+][Personal] Enabling"
    )

    if (($Revert)) {
        Write-Host "[<][Personal] Reverting: $Revert."

        $Zero = 1
        $One = 0
        $EnableStatus = @(
            "[<][Personal] Re-Enabling",
            "[<][Personal] Re-Disabling"
        )

    }

    Register-PersonalTweaksList # Personal UI, Network, Energy and Accessibility Optimizations

}

Main