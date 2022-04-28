Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"file-runner.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://github.com/ChrisTitusTech/win10script
# Adapted from: https://github.com/Sycnex/Windows10Debloater
# Adapted from: https://github.com/kalaspuffar/windows-debloat

function Register-PersonalTweaksList() {
    [CmdletBinding()]
    param (
        [Switch] $Revert,
        [Int]    $Zero = 0,
        [Int]    $One = 1,
        [Array]  $EnableStatus = @(
            @{ Symbol = "-"; Status = "Disabling"; }
            @{ Symbol = "+"; Status = "Enabling"; }
        )
    )
    $TweakType = "Personal"

    If ($Revert) {
        Write-Status -Symbol "<" -Type $TweakType -Status "Reverting: $Revert."
        $Zero = 1
        $One = 0
        $EnableStatus = @(
            @{ Symbol = "<"; Status = "Re-Enabling"; }
            @{ Symbol = "<"; Status = "Re-Disabling"; }
        )
    }

    # Initialize all Path variables used to Registry Tweaks
    $PathToCUAccessibility = "HKCU:\Control Panel\Accessibility"
    $PathToCUPoliciesEdge = "HKCU:\SOFTWARE\Policies\Microsoft\Edge"
    $PathToCUExplorer = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
    $PathToCUExplorerAdvanced = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $PathToCUPoliciesExplorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $PathToCUPoliciesLiveTiles = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
    $PathToCUNewsAndInterest = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds"
    $PathToCUSearch = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"

    Write-Title -Text "My Personal Tweaks"
    $Scripts = @("use-dark-theme.reg", "disable-cortana.reg", "enable-photo-viewer.reg", "disable-clipboard-history.reg")
    If ($Revert) {
        $Scripts = @("use-light-theme.reg", "enable-cortana.reg", "disable-photo-viewer.reg", "enable-clipboard-history.reg")
    }
    Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle "" -DoneMessage "" -NoDialog

    # Show Task Manager details - Applicable to 1607 and later - Although this functionality exist even in earlier versions, the Task Manager's behavior is different there and is not compatible with this tweak
    Write-Status -Symbol "+" -Type $TweakType -Status "Showing task manager details..."
    $taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
    Do {
        Start-Sleep -Milliseconds 100
        $preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
    } Until ($preferences)
    Stop-Process $taskmgr
    $preferences.Preferences[28] = 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences

    Write-Section -Text "Windows Explorer Tweaks"
    Write-Status -Symbol $EnableStatus[1].Symbol -Type $TweakType -Status "$($EnableStatus[1].Status) Quick Access from Windows Explorer..."
    Set-ItemProperty -Path "$PathToCUExplorer" -Name "ShowFrequent" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToCUExplorer" -Name "ShowRecent" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToCUExplorer" -Name "HubMode" -Type DWord -Value $One

    Write-Status -Symbol "-" -Type $TweakType -Status "Removing 3D Objects from This PC..."
    If (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}") {
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse
    }
    If (Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}") {
        Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse
    }

    Write-Status -Symbol "-" -Type $TweakType -Status "Removing 'Edit with Paint 3D' from the Context Menu..."
    $Paint3DFileTypes = @(".3mf", ".bmp", ".fbx", ".gif", ".jfif", ".jpe", ".jpeg", ".jpg", ".png", ".tif", ".tiff")
    ForEach ($FileType in $Paint3DFileTypes) {
        If (Test-Path "Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\$FileType\Shell\3D Edit") {
            Write-Status -Symbol "-" -Type $TweakType -Status "Removing Paint 3D from file type: $FileType"
            Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\$FileType\Shell\3D Edit" -Recurse
        }
    }

    Write-Status -Symbol $EnableStatus[1].Symbol -Type $TweakType -Status "$($EnableStatus[1].Status) Show Drives without Media..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "HideDrivesWithNoMedia" -Type DWord -Value $Zero

    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) File Explorer Ads (OneDrive, New Features etc.)..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value $Zero

    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) MRU lists (jump lists) of XAML apps in Start Menu..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "Start_TrackDocs" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "Start_TrackProgs" -Type DWord -Value $Zero

    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) Aero-Shake Minimize feature..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "DisallowShaking" -Type DWord -Value $One

    Write-Status -Symbol "+" -Type $TweakType -Status "Setting Windows Explorer to start on This PC instead of Quick Access..."
    # [@] (1 = This PC, 2 = Quick access) # DO NOT REVERT, BREAKS EXPLORER.EXE
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "LaunchTo" -Type DWord -Value 1

    Write-Status -Symbol $EnableStatus[1].Symbol -Type $TweakType -Status "$($EnableStatus[1].Status) Show hidden files in Explorer..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "Hidden" -Type DWord -Value $One

    Write-Status -Symbol $EnableStatus[1].Symbol -Type $TweakType -Status "$($EnableStatus[1].Status) Showing file transfer details..."
    If (!(Test-Path "$PathToCUExplorer\OperationStatusManager")) {
        New-Item -Path "$PathToCUExplorer\OperationStatusManager" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToCUExplorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value $One

    Write-Status -Symbol "-" -Type $TweakType -Status "Disabling '- Shortcut' name after creating a shortcut..."
    Set-ItemProperty -Path "$PathToCUExplorer" -Name "link" -Value ([byte[]](0x00, 0x00, 0x00, 0x00))

    Write-Section -Text "Personalization"
    Write-Section -Text "Task Bar Tweaks"
    Write-Caption -Text "Task Bar - Windows 10 Compatible"
    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) the 'Search Box' from taskbar..."
    # [@] (0 = Hide completely, 1 = Show icon only, 2 = Show long Search Box)
    Set-ItemProperty -Path "$PathToCUSearch" -Name "SearchboxTaskbarMode" -Type DWord -Value $Zero

    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) the 'Task View' icon from taskbar..."
    # [@] (0 = Hide Task view, 1 = Show Task view)
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "ShowTaskViewButton" -Type DWord -Value $Zero

    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) Open on Hover from 'News and Interest' from taskbar..."
    If (!(Test-Path "$PathToCUNewsAndInterest")) {
        New-Item -Path "$PathToCUNewsAndInterest" -Force | Out-Null
    }
    # [@] (0 = Disable, 1 = Enable)
    Set-ItemProperty -Path "$PathToCUNewsAndInterest" -Name "ShellFeedsTaskbarOpenOnHover" -Type DWord -Value $Zero

    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) 'News and Interest' from taskbar..."
    # [@] (0 = Enable, 1 = Enable Icon only, 2 = Disable)
    Set-ItemProperty -Path "$PathToCUNewsAndInterest" -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 2

    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) 'People' icon from taskbar..."
    If (!(Test-Path "$PathToCUExplorerAdvanced\People")) {
        New-Item -Path "$PathToCUExplorerAdvanced\People" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced\People" -Name "PeopleBand" -Type DWord -Value $Zero

    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) Live Tiles..."
    If (!(Test-Path "$PathToCUPoliciesLiveTiles")) {
        New-Item -Path "$PathToCUPoliciesLiveTiles" -Force | Out-Null
    }
    Set-ItemProperty -Path $PathToCUPoliciesLiveTiles -Name "NoTileApplicationNotification" -Type DWord -Value $One

    Write-Status -Symbol "=" -Type $TweakType -Status "Enabling Auto tray icons..."
    Set-ItemProperty -Path "$PathToCUExplorer" -Name "EnableAutoTray" -Type DWord -Value 1

    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) 'Meet now' icon on taskbar..."
    If (!(Test-Path "$PathToCUPoliciesExplorer")) {
        New-Item -Path "$PathToCUPoliciesExplorer" -Force | Out-Null
    }
    # [@] (0 = Show Meet Now, 1 = Hide Meet Now)
    Set-ItemProperty -Path "$PathToCUPoliciesExplorer" -Name "HideSCAMeetNow" -Type DWord -Value $One

    Write-Caption -Text "Task Bar - Windows 11 Compatible"
    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) 'Widgets' icon from taskbar..."
    # [@] (0 = Hide Widgets, 1 = Show Widgets)
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "TaskbarDa" -Type DWord -Value $Zero

    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) 'Chat' icon from taskbar..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "TaskbarMn" -Type DWord -Value $Zero

    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) creation of Thumbs.db thumbnail cache files..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "DisableThumbnailCache" -Type DWord -Value $One
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "DisableThumbsDBOnNetworkFolders" -Type DWord -Value $One

    Write-Caption -Text "Colors"
    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) taskbar transparency..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value $Zero

    Write-Section -Text "System"
    Write-Caption -Text "Multitasking"
    Write-Status -Symbol "-" -Type $TweakType -Status "Disabling Edge multi tabs showing on Alt + Tab..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 3

    Write-Section -Text "Devices"
    Write-Caption -Text "Bluetooth & other devices"
    Write-Status -Symbol $EnableStatus[1].Symbol -Type $TweakType -Status "$($EnableStatus[1].Status) driver download over metered connections..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup" -Name "CostedNetworkPolicy" -Type DWord -Value $One

    Write-Section -Text "Cortana Tweaks"
    Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) Bing Search in Start Menu..."
    Set-ItemProperty -Path "$PathToCUSearch" -Name "BingSearchEnabled" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToCUSearch" -Name "CortanaConsent" -Type DWord -Value $Zero

    Write-Section -Text "Ease of Access"
    Write-Caption -Text "Keyboard"
    Write-Status -Symbol "-" -Type $TweakType -Status "Disabling Sticky Keys..."
    Set-ItemProperty -Path "$PathToCUAccessibility\StickyKeys" -Name "Flags" -Value "506"
    Set-ItemProperty -Path "$PathToCUAccessibility\Keyboard Response" -Name "Flags" -Value "122"
    Set-ItemProperty -Path "$PathToCUAccessibility\ToggleKeys" -Name "Flags" -Value "58"

    Write-Section -Text "Microsoft Edge Policies"
    Write-Caption -Text "Privacy, search and services / Address bar and search"
    Write-Status -Symbol "=" -Type $TweakType -Status "Show me search and site suggestions using my typed characters..."
    Remove-ItemProperty -Path "$PathToCUPoliciesEdge" -Name "SearchSuggestEnabled" -Force -ErrorAction SilentlyContinue

    Write-Status -Symbol "=" -Type $TweakType -Status "Show me history and favorite suggestions and other data using my typed characters..."
    Remove-ItemProperty -Path "$PathToCUPoliciesEdge" -Name "LocalProvidersEnabled" -Force -ErrorAction SilentlyContinue

    Write-Status -Symbol $EnableStatus[1].Symbol -Type $TweakType -Status "$($EnableStatus[1].Status) Error reporting..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value $Zero

    # Adapted from: https://techcommunity.microsoft.com/t5/networking-blog/windows-insiders-gain-new-dns-over-https-controls/ba-p/2494644
    Write-Status -Symbol "+" -Type $TweakType -Status "Setting up the DNS over HTTPS for Google and Cloudflare (ipv4 and ipv6)..."
    Set-DnsClientDohServerAddress -ServerAddress ("8.8.8.8", "8.8.4.4", "2001:4860:4860::8888", "2001:4860:4860::8844") -AutoUpgrade $true -AllowFallbackToUdp $true
    Set-DnsClientDohServerAddress -ServerAddress ("1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001") -AutoUpgrade $true -AllowFallbackToUdp $true

    Write-Status -Symbol "+" -Type $TweakType -Status "Setting up the DNS from Google (ipv4 and ipv6)..."
    #Get-DnsClientServerAddress # To look up the current config.           # Cloudflare, Google,         Cloudflare,              Google
    Set-DNSClientServerAddress -InterfaceAlias "Ethernet*" -ServerAddresses ("1.1.1.1", "8.8.8.8", "2606:4700:4700::1111", "2001:4860:4860::8888")
    Set-DNSClientServerAddress -InterfaceAlias    "Wi-Fi*" -ServerAddresses ("1.1.1.1", "8.8.8.8", "2606:4700:4700::1111", "2001:4860:4860::8888")

    Write-Status -Symbol "+" -Type $TweakType -Status "Bringing back F8 alternative Boot Modes..."
    bcdedit /set `{current`} bootmenupolicy Legacy

    Write-Section -Text "Power Plan Tweaks"
    $TimeoutScreenBattery = 5
    $TimeoutScreenPluggedIn = 10

    $TimeoutStandByBattery = 15
    $TimeoutStandByPluggedIn = 30

    $TimeoutDiskBattery = 15
    $TimeoutDiskPluggedIn = 30

    $TimeoutHibernateBattery = 15
    $TimeoutHibernatePluggedIn = 30

    Write-Status -Symbol "+" -Type $TweakType -Status "Setting Hibernate size to reduced..."
    powercfg -hibernate -type reduced

    Write-Status -Symbol "+" -Type $TweakType -Status "Enabling Hibernate (Boots faster on Laptops/PCs with HDD and generate $env:SystemDrive\hiberfil.sys file)..."
    powercfg -hibernate on

    Write-Status -Symbol "+" -Type $TweakType -Status "Setting the Monitor Timeout to AC: $TimeoutScreenPluggedIn and DC: $TimeoutScreenBattery..."
    powercfg -Change Monitor-Timeout-AC $TimeoutScreenPluggedIn
    powercfg -Change Monitor-Timeout-DC $TimeoutScreenBattery

    Write-Status -Symbol "+" -Type $TweakType -Status "Setting the Standby Timeout to AC: $TimeoutStandByPluggedIn and DC: $TimeoutStandByBattery..."
    powercfg -Change Standby-Timeout-AC $TimeoutStandByPluggedIn
    powercfg -Change Standby-Timeout-DC $TimeoutStandByBattery

    Write-Status -Symbol "+" -Type $TweakType -Status "Setting the Disk Timeout to AC: $TimeoutDiskPluggedIn and DC: $TimeoutDiskBattery..."
    powercfg -Change Disk-Timeout-AC $TimeoutDiskPluggedIn
    powercfg -Change Disk-Timeout-DC $TimeoutDiskBattery

    Write-Status -Symbol "+" -Type $TweakType -Status "Setting the Hibernate Timeout to AC: $TimeoutHibernatePluggedIn and DC: $TimeoutHibernateBattery..."
    powercfg -Change Hibernate-Timeout-AC $TimeoutHibernatePluggedIn
    powercfg -Change Hibernate-Timeout-DC $TimeoutHibernateBattery
}

function Main() {
    If (!($Revert)) {
        Register-PersonalTweaksList # Personal UI, Network, Energy and Accessibility Optimizations
    }
    Else {
        Register-PersonalTweaksList -Revert
    }
}

Main