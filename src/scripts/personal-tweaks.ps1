Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from this ChrisTitus script:                 https://github.com/ChrisTitusTech/win10script
# Adapted from this Sycnex script:                     https://github.com/Sycnex/Windows10Debloater
# Adapted from this kalaspuffar/Daniel Persson script: https://github.com/kalaspuffar/windows-debloat

function PersonalTweaks() {

    Title1 -Text "My Personal Tweaks"

    Push-Location -Path "$PSScriptRoot\..\utils\"
    Write-Host "[+][Personal] Enabling Dark theme..."
    regedit /s dark-theme.reg
    Write-Host "$($EnableStatus[0]) Cortana..."
    regedit /s disable-cortana.reg
    Write-Host "[+][Personal] Enabling photo viewer..."
    regedit /s enable-photo-viewer.reg
    Pop-Location

    Section1 -Text "Windows Explorer Tweaks"

    Write-Host "[-][Personal] Hiding Quick Access from Windows Explorer..."
    Set-ItemProperty -Path "$PathToExplorer" -Name "ShowFrequent" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToExplorer" -Name "ShowRecent" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToExplorer" -Name "HubMode" -Type DWord -Value $One

    Write-Host "[-][Priv&Perf] Removing 3D Objects from This PC..."
    If (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}") {
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse
    }
    If (Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}") {
        Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse
    }

    Write-Host "$($EnableStatus[1]) Show Drives without Media..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "HideDrivesWithNoMedia" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) File Explorer Ads (OneDrive, New Features etc.)..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) MRU lists (jump lists) of XAML apps in Start Menu..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "Start_TrackDocs" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "Start_TrackProgs" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) Aero-Shake Minimize feature..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "DisallowShaking" -Type DWord -Value $One

    Write-Host "[@] (1 = This PC, 2 = Quick access)"
    Write-Host "$($EnableStatus[1]) Set Windows Explorer to start on This PC instead of Quick Access..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "LaunchTo" -Type DWord -Value $One

    Write-Host "$($EnableStatus[1]) Show hidden files in Explorer..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "Hidden" -Type DWord -Value $One

    Write-Host "$($EnableStatus[1]) Showing file transfer details..."
    If (!(Test-Path "$PathToExplorer\OperationStatusManager")) {
        New-Item -Path "$PathToExplorer\OperationStatusManager" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToExplorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value $One

    Section1 -Text "Personalization"
    Section1 -Text "Task Bar Tweaks"
    
    Caption1 -Text "Task Bar - Windows 10 Compatible"
    
    Write-Host "[@] (0 = Hide completely, 1 = Show icon only, 2 = Show long Search Box)"
    Write-Host "[-][Personal] Hiding the search box from taskbar..."
    Set-ItemProperty -Path "$PathToSearch" -Name "SearchboxTaskbarMode" -Type DWord -Value $Zero

    Write-Host "[@] (0 = Hide Task view, 1 = Show Task view)"
    Write-Host "[-][Personal] Hiding the Task View from taskbar..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "ShowTaskViewButton" -Type DWord -Value $Zero

    Write-Host "[@] (0 = Disable, 1 = Enable)"
    Write-Host "$($EnableStatus[0]) Open on Hover from News and Interest from taskbar..."
    Set-ItemProperty -Path "$PathToNewsAndInterest" -Name "ShellFeedsTaskbarOpenOnHover" -Type DWord -Value $Zero

    Write-Host "[@] (0 = Enable, 1 = Enable Icon only, 2 = Disable)"
    Write-Host "$($EnableStatus[0]) News and Interest from taskbar..."
    Set-ItemProperty -Path "$PathToNewsAndInterest" -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 2

    Write-Host "[-][Personal] Hiding People icon..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced\People" -Name "PeopleBand" -Type DWord -Value $Zero

    Write-Host "$($EnableStatus[0]) Live Tiles..."
    If (!(Test-Path "$PathToLiveTiles")) {
        New-Item -Path "$PathToLiveTiles" -Force | Out-Null
    }
    Set-ItemProperty -Path $PathToLiveTiles -Name "NoTileApplicationNotification" -Type DWord -Value $One

    Write-Host "[=][Personal] Enabling Auto tray icons..."
    Set-ItemProperty -Path "$PathToExplorer" -Name "EnableAutoTray" -Type DWord -Value 1

    Caption1 -Text "Task Bar - Windows 11 Only"

    Write-Host "[@] (0 = Hide Widgets, 1 = Show Widgets)"
    Write-Host "[-][Personal] Hiding Widgets from taskbar..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "TaskbarDa" -Type DWord -Value $Zero

    # Disable creation of Thumbs.db thumbnail cache files
    Write-Host "$($EnableStatus[0]) creation of Thumbs.db..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "DisableThumbnailCache" -Type DWord -Value $One
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "DisableThumbsDBOnNetworkFolders" -Type DWord -Value $One

    Caption1 -Text "Colors"

    Write-Host "$($EnableStatus[0]) taskbar transparency..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value $Zero

    Section1 -Text "System"
    Caption1 -Text "Multitasking"

    Write-Host "$($EnableStatus[0]) Edge multi tabs showing on Alt + Tab..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 3

    Section1 -Text "Devices"
    Caption1 -Text "Bluetooth & other devices"

    Write-Host "$($EnableStatus[1]) driver download over metered connections..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup" -Name "CostedNetworkPolicy" -Type DWord -Value $One
    
    Section1 -Text "Cortana Tweaks"

    Write-Host "$($EnableStatus[0]) Bing Search in Start Menu..."
    Set-ItemProperty -Path "$PathToSearch" -Name "BingSearchEnabled" -Type DWord -Value $Zero
    Set-ItemProperty -Path "$PathToSearch" -Name "CortanaConsent" -Type DWord -Value $Zero

    Section1 -Text "Ease of Access"
    Caption1 -Text "Keyboard"

    Write-Output "[-][Personal] Disabling Sticky Keys..."
    Set-ItemProperty -Path "$PathToAccessibility\StickyKeys" -Name "Flags" -Value "506"
    Set-ItemProperty -Path "$PathToAccessibility\Keyboard Response" -Name "Flags" -Value "122"
    Set-ItemProperty -Path "$PathToAccessibility\ToggleKeys" -Name "Flags" -Value "58"

    Section1 -Text "Microsoft Edge Policies"
    Caption1 -Text "Privacy, search and services / Address bar and search"

    Write-Host "[=][Personal] Show me search and site suggestions using my typed characters..."
    Remove-ItemProperty -Path "$PathToEdgeUserPol" -Name "SearchSuggestEnabled" -Force -ErrorAction SilentlyContinue
    Write-Host "[=][Personal] Show me history and favorite suggestions and other data using my typed characters..."
    Remove-ItemProperty -Path "$PathToEdgeUserPol" -Name "LocalProvidersEnabled" -Force -ErrorAction SilentlyContinue

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

    Write-Host "[+][Personal] Fixing Xbox Game Bar FPS Counter... (LIMITED BY LANGUAGE)"
    net localgroup "Performance Log Users" "$env:USERNAME" /add         # ENG
    net localgroup "Usuários de log de desempenho" "$env:USERNAME" /add # PT-BR

    Section1 -Text "Power Plan Tweaks"
    $Timeout = 10

    Write-Host "[=][Personal] Setting Hibernate size to full..."
    powercfg -hibernate -type full
    Write-Host "[-][Personal] Disabling Hibernate..."
    powercfg -hibernate off

    Write-Host "[+][Personal] Setting the Monitor Timeout to $Timeout min (AC = Alternating Current, DC = Direct Current)"
    powercfg -Change Monitor-Timeout-AC $Timeout
    powercfg -Change Monitor-Timeout-DC $Timeout

    Write-Host "[+][Personal] Setting the Disk Timeout to $Timeout min"
    powercfg -Change Disk-Timeout-AC $Timeout
    powercfg -Change Disk-Timeout-DC $Timeout

    Write-Host "[+][Personal] Setting the Standby Timeout to $Timeout min"
    powercfg -Change Standby-Timeout-AC $Timeout
    powercfg -Change Standby-Timeout-DC $Timeout

    Write-Host "[+][Personal] Setting the Hibernate Timeout to $Timeout min"
    powercfg -Change Hibernate-Timeout-AC $Timeout
    powercfg -Change Hibernate-Timeout-DC $Timeout

}

function Main() {

    # Initialize all Path variables used to Registry Tweaks
    $Global:PathToAccessibility = "HKCU:\Control Panel\Accessibility"
    $Global:PathToEdgeUserPol = "HKCU:\SOFTWARE\Policies\Microsoft\Edge"
    $Global:PathToExplorer = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
    $Global:PathToExplorerAdvanced = "$PathToExplorer\Advanced"
    $Global:PathToLiveTiles = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
    $Global:PathToNewsAndInterest = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds"
    $Global:PathToSearch = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"

    $Zero = 0
    $One = 1
    $EnableStatus = @(
        "[-][Personal] Disabling",
        "[+][Personal] Enabling"
    )

    if (($Revert)) {
        Write-Host "[<][Personal] Reverting: $Revert"

        $Zero = 1
        $One = 0
        $EnableStatus = @(
            "[<][Personal] Re-Enabling",
            "[<][Personal] Re-Disabling"
        )
      
    }
    
    PersonalTweaks  # Personal UI, Network, Energy and Accessibility Optimizations

}

Main