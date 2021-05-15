# Adapted from these Baboo videos:                          https://youtu.be/qWESrvP_uU8
# Adapted from this ChrisTitus script:                      https://github.com/ChrisTitusTech/win10script
# Adapted from this matthewjberger's script:                https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f
# Adapted from this Sycnex script:                          https://github.com/Sycnex/Windows10Debloater

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\Title-Templates.psm1

Function TweaksForServices {

    Title1 -Text "Services tweaks"
    Section1 -Text "Re-enabling Services"
    
    $EnableServices = @(
        "BITS"                                      # Background Intelligent Transfer Service
        "DPS"                                       # Diagnostic Policy Service
        "FontCache"                                 # Windows Font Cache Service
        "WMPNetworkSvc"                             # Windows Media Player Network Sharing Service (Miracast / Wi-Fi Direct)
    )
        
    ForEach ($Service in $EnableServices) {
        Write-Host "[Services] Re-enabling $Service at Startup and Starting..."
        Set-Service -Name $Service -StartupType Automatic
        Set-Service -Name $Service -Status Running
    }
    
    Section1 -Text "Disabling Services"
        
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
    
    ForEach ($Service in $DisableServices) {
        Write-Host "[Services] Disabling $Service at Startup and Stopping..."
        Set-Service -Name "$Service" -StartupType Disabled
        Set-Service -Name "$Service" -Status Stopped
    }

}

TweaksForServices   # Enable essential Services and Disable bloating Services
