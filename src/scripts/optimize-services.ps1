Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from this Baboo video:             https://youtu.be/qWESrvP_uU8
# Adapted from this ChrisTitus script:       https://github.com/ChrisTitusTech/win10script
# Adapted from this matthewjberger's script: https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f
# Adapted from this Sycnex script:           https://github.com/Sycnex/Windows10Debloater

Function TweaksForServices() {

    Title1 -Text "Services tweaks"
        
    $DisableServices = @(
        "BITS"                                      # Background Intelligent Transfer Service
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
        
        #"DPS"                                      # Diagnostic Policy Service
        #"FontCache"                                # Windows Font Cache Service
        #"NetTcpPortSharing"                        # Net.Tcp Port Sharing Service
        #"SharedAccess"                             # Internet Connection Sharing (ICS)
        #"stisvc"                                   # Windows Image Acquisition (WIA)
        #"WlanSvc"                                  # WLAN AutoConfig
        #"Wecsvc"                                   # Windows Event Collector
        #"WerSvc"                                   # Windows Error Reporting Service
        #"wscsvc"                                   # Windows Security Center Service
        #"WdiServiceHost"                           # Diagnostic Service Host
        #"WdiSystemHost"                            # Diagnostic System Host
        #"WMPNetworkSvc"                            # Windows Media Player Network Sharing Service (Miracast / Wi-Fi Direct)
        
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
        If (($Revert -eq $true) -and ($Service -match "RemoteRegistry")) {
            Write-Warning "[=][Services] Skipping $Service to avoiding a security breach..."
            Continue
        }

        Write-Host "$($EnableStatus[2]) $Service..."
        Invoke-Expression "$($Commands[2])"
        Write-Host "$($EnableStatus[0]) $Service at Startup..."
        Invoke-Expression "$($Commands[0])"
    }

}

function Main() {

    $EnableStatus = @(
        "[-][Services] Disabling",
        "[=][Services] Re-Enabling",
        "[-][Services] Stopping",
        "[+][Services] Starting"
    )
    $Commands = @(
        { Set-Service -Name "$Service" -StartupType Disabled },
        { Set-Service -Name "$Service" -StartupType Automatic },
        { Stop-Service -Name "$Service" -Force },
        { Set-Service -Name $Service -Status Running }
    )

    if (($Revert)) {
        Write-Warning "[<][Services] Reverting: $Revert"

        $EnableStatus = @(
            "[<][Services] Re-Enabling",
            "[<][Services] Re-Disabling",
            "[+][Services] Starting",
            "[-][Services] Stopping"
        )
        $Commands = @(
            { Set-Service -Name "$Service" -StartupType Automatic },
            { Set-Service -Name "$Service" -StartupType Disabled },
            { Set-Service -Name $Service -Status Running },
            { Stop-Service -Name "$Service" -Force }
        )
      
    }
    
    TweaksForServices   # Enable essential Services and Disable bloating Services

}

Main