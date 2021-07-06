# Adapted from this ChrisTitus script:                      https://github.com/ChrisTitusTech/win10script
# Adapted from this Sycnex script:                          https://github.com/Sycnex/Windows10Debloater
# Adapted from this kalaspuffar/Daniel Persson script:      https://github.com/kalaspuffar/windows-debloat

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Initialize all Path variables used to Registry Tweaks
$Global:PathToAccessibility             = "HKCU:\Control Panel\Accessibility"
$Global:PathToEdgeUserPol               = "HKCU:\SOFTWARE\Policies\Microsoft\Edge"
$Global:PathToExplorer                  = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
$Global:PathToExplorerAdvanced          = "$PathToExplorer\Advanced"
$Global:PathToLiveTiles                 = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
$Global:PathToNewsAndInterest           = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds"
$Global:PathToSearch                    = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"

Function PersonalTweaks {

    Title1 -Text "My Personal Tweaks"

    Push-Location -Path "..\utils\"
        Write-Host "[+] Enabling Dark theme..."
        regedit /s dark-theme.reg
        Write-Host "[-] Disabling Cortana..."
        regedit /s disable-cortana.reg
        Write-Host "[+] Enabling photo viewer..."
        regedit /s enable-photo-viewer.reg
    Pop-Location

    Section1 -Text "Windows Explorer Tweaks"

    Write-Host "[-] Hiding Quick Access from Windows Explorer..."
    Set-ItemProperty -Path "$PathToExplorer" -Name "ShowFrequent" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToExplorer" -Name "ShowRecent" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToExplorer" -Name "HubMode" -Type DWord -Value 1

    Section1 -Text "Personalization"
    Section1 -Text "TaskBar Tweaks"
    
    Write-Host "[@] (0 = Hide completely, 1 = Show icon only, 2 = Show long Search Box)"
    Write-Host "[-] Hiding the search box from taskbar..."
    Set-ItemProperty -Path "$PathToSearch" -Name "SearchboxTaskbarMode" -Type DWord -Value 0

    Write-Host "[@] (0 = Hide Task view, 1 = Show Task view)"
    Write-Host "[-] Hiding the Task View from taskbar..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "ShowTaskViewButton" -Type DWord -Value 0

    Write-Host "[@] (0 = Disable, 1 = Enable)"
    Write-Host "[-] Disabling Open on Hover from News and Interest from taskbar..."
    Set-ItemProperty -Path "$PathToNewsAndInterest" -Name "ShellFeedsTaskbarOpenOnHover" -Type DWord -Value 0

    Write-Host "[@] (0 = Enable, 1 = Enable Icon only, 2 = Disable)"
    Write-Host "[-] Disabling News and Interest from taskbar..."
    Set-ItemProperty -Path "$PathToNewsAndInterest" -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 2

    Write-Host "[-] Hiding People icon..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced\People" -Name "PeopleBand" -Type DWord -Value 0

    Write-Host "[-] Disabling Live Tiles..."
    If (!(Test-Path "$PathToLiveTiles")) {
        New-Item -Path "$PathToLiveTiles" -Force | Out-Null
    }
    Set-ItemProperty -Path $PathToLiveTiles -Name "NoTileApplicationNotification" -Type DWord -Value 1

    Write-Host "[=] Enabling Auto tray icons..."
    Set-ItemProperty -Path "$PathToExplorer" -Name "EnableAutoTray" -Type DWord -Value 1

    Write-Host "[+] Showing This PC shortcut on desktop..."
    If (!(Test-Path "$PathToExplorer\HideDesktopIcons\ClassicStartMenu")) {
        New-Item -Path "$PathToExplorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToExplorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
    If (!(Test-Path "$PathToExplorer\HideDesktopIcons\NewStartPanel")) {
        New-Item -Path "$PathToExplorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToExplorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0

    # Disable creation of Thumbs.db thumbnail cache files
    Write-Host "[-] Disabling creation of Thumbs.db..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "DisableThumbnailCache" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "DisableThumbsDBOnNetworkFolders" -Type DWord -Value 1

    Caption1 -Text "Colors"

    Write-Host "[-] Disabling taskbar transparency."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value 0

    Section1 -Text "System"
    Caption1 -Text "Multitasking"

    Write-Host "[-] Disabling Edge multi tabs showing on Alt + Tab..."
    Set-ItemProperty -Path "$PathToExplorerAdvanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 3

    Section1 -Text "Devices"
    Caption1 -Text "Bluetooth & other devices"

    Write-Host "[+] Enabling driver download over metered connections..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup" -Name "CostedNetworkPolicy" -Type DWord -Value 1
    
    Section1 -Text "Cortana Tweaks"

    Write-Host "[-] Disabling Bing Search in Start Menu..."
    Set-ItemProperty -Path "$PathToSearch" -Name "BingSearchEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "$PathToSearch" -Name "CortanaConsent" -Type DWord -Value 0

    Section1 -Text "Ease of Access"
    Caption1 -Text "Keyboard"

    Write-Output "- Disabling Sticky Keys..."
    Set-ItemProperty -Path "$PathToAccessibility\StickyKeys" -Name "Flags" -Value "506"
    Set-ItemProperty -Path "$PathToAccessibility\Keyboard Response" -Name "Flags" -Value "122"
    Set-ItemProperty -Path "$PathToAccessibility\ToggleKeys" -Name "Flags" -Value "58"

    Section1 -Text "Microsoft Edge Policies"
    Caption1 -Text "Privacy, search and services / Address bar and search"

    Write-Host "[=] Show me search and site suggestions using my typed characters..."
    Remove-ItemProperty -Path "$PathToEdgeUserPol" -Name "SearchSuggestEnabled" -Force
    Write-Host "[=] Show me history and favorite suggestions and other data using my typed characters..."
    Remove-ItemProperty -Path "$PathToEdgeUserPol" -Name "LocalProvidersEnabled" -Force

    Write-Host "[+] Keep ENABLED Error reporting..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 0

    Write-Host "[+] Setting time to UTC..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type DWord -Value 1
    
    Write-Host "[+] Setting up the DNS from Google (ipv4 and ipv6)..."
    #Get-DnsClientServerAddress # To look up the current config.
    Set-DNSClientServerAddress -InterfaceAlias "Ethernet*" -ServerAddresses ("8.8.8.8","8.8.4.4"), ("2001:4860:4860::8888", "2001:4860:4860::8844")
    Set-DNSClientServerAddress -InterfaceAlias "Wi-Fi*" -ServerAddresses ("8.8.8.8","8.8.4.4"), ("2001:4860:4860::8888", "2001:4860:4860::8844")
    
    Write-Host "[+] Bringing back F8 alternative Boot Modes..."
    bcdedit /set `{current`} bootmenupolicy Legacy

    Write-Host "[+] Fixing Xbox Game Bar FPS Counter... (LIMITED BY LANGUAGE)"
    net localgroup "Performance Log Users" "$env:USERNAME" /add         # ENG
    net localgroup "Usuários de log de desempenho" "$env:USERNAME" /add # PT-BR

    Section1 -Text "Power Plan Tweaks"

    Write-Host "[=] Fix Hibernate not working..."
    powercfg -h on
    powercfg -h -type full

    Write-Host "[+] Setting the Monitor Timeout to 10 min (AC = Alternating Current, DC = Direct Current)"
    powercfg -Change Monitor-Timeout-AC 10
    powercfg -Change Monitor-Timeout-DC 10

    Write-Host "[+] Setting the Disk Timeout to 10 min"
    powercfg -Change Disk-Timeout-AC 10
    powercfg -Change Disk-Timeout-DC 10

    Write-Host "[+] Setting the Standby Timeout to 10 min"
    powercfg -Change Standby-Timeout-AC 10
    powercfg -Change Standby-Timeout-DC 10

    Write-Host "[+] Setting the Hibernate Timeout to 10 min"
    powercfg -Change Hibernate-Timeout-AC 10
    powercfg -Change Hibernate-Timeout-DC 10

}

PersonalTweaks  # Personal UI, Network, Energy and Accessibility Optimizations