Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"get-hardware-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://youtu.be/qWESrvP_uU8
# Adapted from: https://github.com/ChrisTitusTech/win10script
# Adapted from: https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f
# Adapted from: https://github.com/Sycnex/Windows10Debloater

function Optimize-RunningServicesList() {
    [CmdletBinding()]
    param (
        [Switch] $Revert,
        $EnableStatus = @(
            @{
                Symbol = "-"; Status = "Setting Startup Type as 'Disabled' to";
                Command = { Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled }
            }
            @{
                Symbol = "-"; Status = "Setting Startup Type as 'Manual' to";
                Command = { Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Manual }
            }
            @{
                Symbol = "+"; Status = "Setting Startup Type as 'Automatic' to";
                Command = { Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic }
            }
        )
    )
    $TweakType = "Service"

    If (($Revert)) {
        Write-Status -Symbol "<" -Type $TweakType -Status "Reverting: $Revert." -Warning
        $EnableStatus = @( # Only switch between Manual and Disabled to Revert
            @{
                Symbol = "<"; Status = "Setting Startup Type as 'Manual' to";
                Command = { Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Manual }
            }
            @{
                Symbol = "<"; Status = "Setting Startup Type as 'Disabled' to";
                Command = { Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled }
            }
            @{
                Symbol = "<"; Status = "Setting Startup Type as 'Automatic' to";
                Command = { Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic }
            }
        )
    }

    $IsSystemDriveSSD = ($(Get-OSDriveType) -eq "SSD")
    $EnableServicesSSD = @(
        "SysMain" # SysMain / Superfetch (100% Disk on HDDs)
        "WSearch" # Windows Search (100% Disk on HDDs)
    )

    Write-Title -Text "Services tweaks"

    # Services which will be totally disabled
    $DisableServices = @(
        "DiagTrack"                                 # Connected User Experiences and Telemetry
        "diagnosticshub.standardcollector.service"  # Microsoft (R) Diagnostics Hub Standard Collector Service
        "dmwappushservice"                          # Device Management Wireless Application Protocol (WAP)
        "GraphicsPerfSvc"                           # Graphics performance monitor service
        "HomeGroupListener"                         # HomeGroup Listener
        "HomeGroupProvider"                         # HomeGroup Provider
        "lfsvc"                                     # Geolocation Service
        "MapsBroker"                                # Downloaded Maps Manager
        "PcaSvc"                                    # Program Compatibility Assistant (PCA)
        "RemoteAccess"                              # Routing and Remote Access
        "RemoteRegistry"                            # Remote Registry
        "SysMain"                                   # SysMain / Superfetch (100% Disk on HDDs)
        "TrkWks"                                    # Distributed Link Tracking Client
        "WbioSrvc"                                  # Windows Biometric Service (required for Fingerprint reader / facial detection)
        "WSearch"                                   # Windows Search (100% Disk on HDDs)
        # - Services which cannot be disabled ¯\_(ツ)_/¯
        #"wscsvc"                                   # | DEFAULT: Automatic | Windows Security Center Service
        #"WdNisSvc"                                 # | DEFAULT: Manual    | Windows Defender Network Inspection Service
    )

    ForEach ($Service in $DisableServices) {
        If (Get-Service $Service -ErrorAction SilentlyContinue) {
            If (($Revert -eq $true) -and ($Service -like "RemoteRegistry")) {
                Write-Status -Symbol "?" -Type $TweakType -Status "Skipping $Service to avoid a security vulnerability ($((Get-Service $Service).DisplayName)) ..."
                Continue
            }

            If (($IsSystemDriveSSD) -and ($Service -in $EnableServicesSSD)) {
                Write-Status -Symbol $EnableStatus[2].Symbol -Type $TweakType -Status "$($EnableStatus[2].Status) $Service because in SSDs will have more benefits ($((Get-Service $Service).DisplayName)) ..."
                Invoke-Expression "$($EnableStatus[2].Command)"
                Continue
            }

            Write-Status -Symbol $EnableStatus[0].Symbol -Type $TweakType -Status "$($EnableStatus[0].Status) $Service ($((Get-Service $Service).DisplayName)) ..."
            Invoke-Expression "$($EnableStatus[0].Command)"
        }
        Else {
            Write-Status -Symbol "?" -Type $TweakType -Status "$Service was not found." -Warning
        }
    }

    # Making the services to run only when needed as 'Manual' | Remove the # to set to Manual
    $ManualServices = @(
        "ndu"                    # | DEFAULT: Automatic | Windows Network Data Usage Monitoring Driver (Shows network usage per-process on Task Manager)
        #"NetTcpPortSharing"     # | DEFAULT: Disabled  | Net.Tcp Port Sharing Service
        "SharedAccess"           # | DEFAULT: Manual    | Internet Connection Sharing (ICS)
        "stisvc"                 # | DEFAULT: Automatic | Windows Image Acquisition (WIA)
        "Wecsvc"                 # | DEFAULT: Manual    | Windows Event Collector
        "WerSvc"                 # | DEFAULT: Manual    | Windows Error Reporting Service
        "WMPNetworkSvc"          # | DEFAULT: Manual    | Windows Media Player Network Sharing Service
        # - Diagnostic Services
        "DPS"                    # | DEFAULT: Automatic | Diagnostic Policy Service
        "WdiServiceHost"         # | DEFAULT: Manual    | Diagnostic Service Host
        "WdiSystemHost"          # | DEFAULT: Manual    | Diagnostic System Host
        # - Bluetooth services
        "BTAGService"            # | DEFAULT: Manual    | Bluetooth Audio Gateway Service
        "BthAvctpSvc"            # | DEFAULT: Manual    | AVCTP Service
        "bthserv"                # | DEFAULT: Manual    | Bluetooth Support Service
        "RtkBtManServ"           # | DEFAULT: Automatic | Realtek Bluetooth Device Manager Service
        # - Xbox services
        "XblAuthManager"         # | DEFAULT: Manual    | Xbox Live Auth Manager
        "XblGameSave"            # | DEFAULT: Manual    | Xbox Live Game Save Service
        "XboxGipSvc"             # | DEFAULT: Manual    | Xbox Accessory Management Service
        "XboxNetApiSvc"          # | DEFAULT: Manual    | Xbox Live Networking Service
        # - NVIDIA services
        "NvContainerLocalSystem" # | DEFAULT: Automatic | NVIDIA LocalSystem Container (GeForce Experience / NVIDIA Telemetry)
        # - Printer services
        #"PrintNotify"           # WARNING! REMOVING WILL TURN PRINTING LESS MANAGEABLE | DEFAULT: Manual    | Printer Extensions and Notifications
        #"Spooler"               # WARNING! REMOVING WILL DISABLE PRINTING              | DEFAULT: Automatic | Print Spooler
        # - Wi-Fi services
        #"WlanSvc"               # WARNING! REMOVING WILL DISABLE WI-FI | DEFAULT: Auto/Man. | WLAN AutoConfig
    )

    ForEach ($Service in $ManualServices) {
        If (Get-Service $Service -ErrorAction SilentlyContinue) {
            Write-Status -Symbol "-" -Type $TweakType -Status "Setting Startup Type as 'Manual' to $Service ($((Get-Service $Service).DisplayName)) ..."
            Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Manual
        }
        Else {
            Write-Status -Symbol "?" -Type $TweakType -Status "$Service was not found." -Warning
        }
    }
}

function Main() {
    # List all services: Get-Service | Select-Object StartType, Status, Name, DisplayName, ServiceType | Sort-Object StartType, Status, Name | Out-GridView
    If (!($Revert)) {
        Optimize-RunningServicesList # Enable essential Services and Disable bloating Services
    }
    Else {
        Optimize-RunningServicesList -Revert
    }
}

Main