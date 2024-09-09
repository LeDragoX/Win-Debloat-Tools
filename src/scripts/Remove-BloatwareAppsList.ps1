Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Remove-UWPApp.psm1"

function Remove-BloatwareAppsList() {
    $MSApps = @(
        # Default Windows 10+ apps
        "Microsoft.3DBuilder"                    # 3D Builder
        "Microsoft.549981C3F5F10"                # Cortana
        "Microsoft.Appconnector"
        "Microsoft.BingFinance"                  # Finance
        "Microsoft.BingFoodAndDrink"             # Food And Drink
        "Microsoft.BingHealthAndFitness"         # Health And Fitness
        "Microsoft.BingNews"                     # News
        "Microsoft.BingSports"                   # Sports
        "Microsoft.BingTranslator"               # Translator
        "Microsoft.BingTravel"                   # Travel
        "Microsoft.BingWeather"                  # Weather
        "Microsoft.CommsPhone"
        "Microsoft.ConnectivityStore"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftPowerBIForWindows"
        "Microsoft.MicrosoftSolitaireCollection" # MS Solitaire
        "Microsoft.MixedReality.Portal"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.Office.OneNote"               # MS Office One Note
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.MSPaint"                      # Paint 3D
        "Microsoft.People"                       # People
        "Microsoft.PowerAutomateDesktop"         # Power Automate
        "Microsoft.Print3D"                      # Print 3D
        "Microsoft.SkypeApp"                     # Skype (Who still uses Skype? Use Discord)
        "Microsoft.Todos"                        # Microsoft To Do
        "Microsoft.Wallet"
        "Microsoft.Whiteboard"                   # Microsoft Whiteboard
        "Microsoft.WindowsAlarms"                # Alarms
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"           # Feedback Hub
        "Microsoft.WindowsMaps"                  # Maps
        "Microsoft.WindowsPhone"
        "Microsoft.WindowsReadingList"
        "Microsoft.WindowsSoundRecorder"         # Windows Sound Recorder
        "Microsoft.XboxApp"                      # Xbox Console Companion (Replaced by new App)
        "Microsoft.YourPhone"                    # Your Phone
        "Microsoft.ZuneMusic"                    # Groove Music / (New) Windows Media Player
        "Microsoft.ZuneVideo"                    # Movies & TV

        # Apps which other apps depend on
        "Microsoft.Advertising.Xaml"

        # Default Windows 11 apps
        "Clipchamp.Clipchamp"				     # Clipchamp – Video Editor
        "Microsoft.OutlookForWindows"            # Microsoft Outlook
        "MicrosoftTeams"                         # Microsoft Teams
        "MicrosoftWindows.Client.WebExperience"  # Taskbar Widgets

        # [DIY] Remove the # to Uninstall

        # [DIY] Default apps i'll keep
        #"Microsoft.FreshPaint"             # Paint
        #"Microsoft.MicrosoftStickyNotes"   # Sticky Notes
        #"Microsoft.WindowsCalculator"      # Calculator
        #"Microsoft.WindowsCamera"          # Camera
        #"Microsoft.ScreenSketch"           # Snip and Sketch (now called Snipping tool, replaces the Win32 version in clean installs)
        #"Microsoft.Windows.DevHome"        # Dev Home
        #"Microsoft.Windows.Photos"         # Photos / Video Editor

        # [DIY] Can't be reinstalled
        #"Microsoft.WindowsStore"           # Windows Store

        # Apps which cannot be removed using Remove-AppxPackage
        #"Microsoft.BioEnrollment"
        #"Microsoft.WindowsFeedback"        # Feedback Module
        #"Windows.ContactSupport"
    )

    $ThirdPartyApps = @(
        "*ACGMediaPlayer*"
        "*ActiproSoftwareLLC*"
        "*AdobePhotoshopExpress*"           # Adobe Photoshop Express
        "Amazon.com.Amazon"                 # Amazon Shop
        "*Asphalt8Airborne*"                # Asphalt 8 Airbone
        "*AutodeskSketchBook*"
        "*BubbleWitch3Saga*"                # Bubble Witch 3 Saga
        "*CaesarsSlotsFreeCasino*"
        "*CandyCrush*"                      # Candy Crush
        "*COOKINGFEVER*"
        "*CyberLinkMediaSuiteEssentials*"
        "*DisneyMagicKingdoms*"
        "*Dolby*"                           # Dolby Products (Like Atmos)
        "*DrawboardPDF*"
        "*Duolingo-LearnLanguagesforFree*"  # Duolingo
        "*EclipseManager*"
        "*FarmVille2CountryEscape*"
        "*FitbitCoach*"
        "*Flipboard*"                       # Flipboard
        "*HiddenCity*"
        "*Keeper*"
        "*LinkedInforWindows*"
        "*MarchofEmpires*"
        "*NYTCrossword*"
        "*OneCalendar*"
        "*PandoraMediaInc*"
        "*PhototasticCollage*"
        "*PicsArt-PhotoStudio*"
        "*PolarrPhotoEditorAcademicEdition*"
        "*RoyalRevolt*"                     # Royal Revolt
        "*Shazam*"
        "*Sidia.LiveWallpaper*"             # Live Wallpaper
        "*Speed Test*"
        "*Sway*"
        "*WinZipUniversal*"
        "*Wunderlist*"
        "*XING*"
    )

    $ManufacturerApps = @(
        # Dell Bloat
        "DB6EA5DB.MediaSuiteEssentialsforDell"
        "DB6EA5DB.PowerDirectorforDell"
        "DB6EA5DB.Power2GoforDell"
        "DB6EA5DB.PowerMediaPlayerforDell"
        #"DellInc.423703F9C7E0E"                # Alienware OC Controls
        #"DellInc.6066037A8FCF7"                # Alienware Control Center
        #"DellInc.AlienwareCommandCenter"       # Alienware Command Center
        #"DellInc.AlienwareFXAW*"               # Alienware FX AWxx versions
        #"DellInc.AlienwareFXAW21"              # Alienware FX AW21
        "DellInc.DellCustomerConnect"           # Dell Customer Connect
        "DellInc.DellDigitalDelivery"           # Dell Digital Delivery
        "DellInc.DellHelpSupport"
        "DellInc.DellProductRegistration"
        "DellInc.MyDell"                        # My Dell

        # SAMSUNG Bloat
        #"SAMSUNGELECTRONICSCO.LTD.SamsungSettings1.2"      # Allow user to Tweak some hardware settings
        "SAMSUNGELECTRONICSCO.LTD.1412377A9806A"
        "SAMSUNGELECTRONICSCO.LTD.NewVoiceNote"
        "SAMSUNGELECTRONICSCoLtd.SamsungNotes"
        "SAMSUNGELECTRONICSCoLtd.SamsungFlux"
        "SAMSUNGELECTRONICSCO.LTD.StudioPlus"
        "SAMSUNGELECTRONICSCO.LTD.SamsungWelcome"
        "SAMSUNGELECTRONICSCO.LTD.SamsungUpdate"
        "SAMSUNGELECTRONICSCO.LTD.SamsungSecurity1.2"
        "SAMSUNGELECTRONICSCO.LTD.SamsungScreenRecording"
        #"SAMSUNGELECTRONICSCO.LTD.SamsungRecovery"         # Used to Factory Reset
        "SAMSUNGELECTRONICSCO.LTD.SamsungQuickSearch"
        "SAMSUNGELECTRONICSCO.LTD.SamsungPCCleaner"
        "SAMSUNGELECTRONICSCO.LTD.SamsungCloudBluetoothSync"
        "SAMSUNGELECTRONICSCO.LTD.PCGallery"
        "SAMSUNGELECTRONICSCO.LTD.OnlineSupportSService"
        "4AE8B7C2.BOOKING.COMPARTNERAPPSAMSUNGEDITION"
    )

    $SocialMediaApps = @(
        # "5319275A.WhatsAppDesktop"  # WhatsApp
        "BytedancePte.Ltd.TikTok"   # TikTok
        "FACEBOOK.317180B0BB486"    # Messenger
        "FACEBOOK.FACEBOOK"         # Facebook
        "Facebook.Instagram*"       # Instagram / Beta
        "*Twitter*"                 # Twitter
        "*Viber*"
    )

    $StreamingServicesApps = @(
        "AmazonVideo.PrimeVideo"    # Amazon Prime Video
        "*Hulu*"
        "*iHeartRadio*"
        "*Netflix*"                 # Netflix
        "*Plex*"                    # Plex
        "*SlingTV*"
        "SpotifyAB.SpotifyMusic"    # Spotify
        "*TuneInRadio*"
    )

    Write-Title "Remove Windows unneeded Apps (Bloatware)"
    Write-Section "Microsoft Apps"
    Remove-UWPApp -AppxPackages $MSApps
    Write-Section "3rd-party Apps"
    Remove-UWPApp -AppxPackages $ThirdPartyApps
    Write-Section "Manufacturer Apps"
    Remove-UWPApp -AppxPackages $ManufacturerApps
    Write-Section "Social Media Apps"
    Remove-UWPApp -AppxPackages $SocialMediaApps
    Write-Section "Streaming Services Apps"
    Remove-UWPApp -AppxPackages $StreamingServicesApps
}

# List all Packages:
#Get-AppxPackage | Select-Object -Property Name, Architecture, Version, Publisher, InstallLocation, IsFramework, IsBundle, IsDevelopmentMode, NonRemovable, SignatureKind, Status, Dependencies | Sort-Object Publisher, Name, Architecture | Format-Table

# List all Provisioned Packages:
#Get-AppxProvisionedPackage -Online | Select-Object -Property DisplayName, Architecture, Version, PublisherId, InstallLocation, Region, ResourceId | Sort-Object PublisherId, DisplayName, Architecture | Format-Table

Remove-BloatwareAppsList # Remove the main Bloat from Pre-installed Apps
