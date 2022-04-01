Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"remove-uwp-apps.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Remove-BloatwareAppsList() {
    Write-Title -Text "Remove Bloatware Apps"

    $Apps = @(
        # Default Windows 10+ apps
        "Microsoft.3DBuilder"                   # 3D Builder
        "Microsoft.Appconnector"
        "Microsoft.BingFinance"                 # Finance
        "Microsoft.BingFoodAndDrink"            # Food And Drink
        "Microsoft.BingHealthAndFitness"        # Health And Fitness
        "Microsoft.BingNews"                    # News
        "Microsoft.BingSports"                  # Sports
        "Microsoft.BingTranslator"              # Translator
        "Microsoft.BingTravel"                  # Travel
        "Microsoft.BingWeather"                 # Weather
        "Microsoft.CommsPhone"
        "Microsoft.ConnectivityStore"
        "Microsoft.GamingServices"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftPowerBIForWindows"
        "Microsoft.MicrosoftSolitaireCollection"# MS Solitaire
        "Microsoft.MixedReality.Portal"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.Office.OneNote"              # MS Office One Note
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.People"                      # People
        "Microsoft.MSPaint"                     # Paint 3D (Where every artist truly start as a kid, i mean, on original Paint, not this 3D)
        "Microsoft.Print3D"                     # Print 3D
        "Microsoft.SkypeApp"                    # Skype (Who still uses Skype? Use Discord)
        "Microsoft.Todos"                       # Microsoft To Do
        "Microsoft.Wallet"
        "Microsoft.Whiteboard"                  # Microsoft Whiteboard
        "Microsoft.WindowsAlarms"               # Alarms
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsMaps"                 # Maps
        "Microsoft.WindowsPhone"
        "Microsoft.WindowsReadingList"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.XboxApp"                     # Xbox Console Companion (Replaced by new App)
        "Microsoft.XboxGameCallableUI"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.YourPhone"                   # Your Phone
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"                   # Movies & TV

        # Default Windows 11 apps
        "MicrosoftWindows.Client.WebExperience" # Taskbar Widgets
        "MicrosoftTeams"                        # Microsoft Teams / Preview

        # 3rd party Apps
        "*ACGMediaPlayer*"
        "*ActiproSoftwareLLC*"
        "*AdobePhotoshopExpress*"               # Adobe Photoshop Express
        "*Amazon.com.Amazon*"                   # Amazon Shop
        "*Asphalt8Airborne*"                    # Asphalt 8 Airbone
        "*AutodeskSketchBook*"
        "*BubbleWitch3Saga*"                    # Bubble Witch 3 Saga
        "*CaesarsSlotsFreeCasino*"
        "*CandyCrush*"                          # Candy Crush
        "*COOKINGFEVER*"
        "*CyberLinkMediaSuiteEssentials*"
        "*DisneyMagicKingdoms*"
        "*Dolby*"                               # Dolby Products (Like Atmos)
        "*DrawboardPDF*"
        "*Duolingo-LearnLanguagesforFree*"      # Duolingo
        "*EclipseManager*"
        "*Facebook*"                            # Facebook
        "*FarmVille2CountryEscape*"
        "*FitbitCoach*"
        "*Flipboard*"                           # Flipboard
        "*HiddenCity*"
        "*Hulu*"
        "*iHeartRadio*"
        "*Keeper*"
        "*LinkedInforWindows*"
        "*MarchofEmpires*"
        "*NYTCrossword*"
        "*OneCalendar*"
        "*PandoraMediaInc*"
        "*PhototasticCollage*"
        "*PicsArt-PhotoStudio*"
        "*Plex*"                                # Plex
        "*PolarrPhotoEditorAcademicEdition*"
        "*RoyalRevolt*"                         # Royal Revolt
        "*Shazam*"
        "*Sidia.LiveWallpaper*"                 # Live Wallpaper
        "*SlingTV*"
        "*Speed Test*"
        "*Sway*"
        "*TuneInRadio*"
        "*Twitter*"                             # Twitter
        "*Viber*"
        "*WinZipUniversal*"
        "*Wunderlist*"
        "*XING*"

        # SAMSUNG Bloat

        #"SAMSUNGELECTRONICSCO.LTD.SamsungSettings1.2"          # Allow user to Tweak some hardware settings
        "SAMSUNGELECTRONICSCO.LTD.1412377A9806A"
        "SAMSUNGELECTRONICSCO.LTD.NewVoiceNote"
        "SAMSUNGELECTRONICSCoLtd.SamsungNotes"
        "SAMSUNGELECTRONICSCoLtd.SamsungFlux"
        "SAMSUNGELECTRONICSCO.LTD.StudioPlus"
        "SAMSUNGELECTRONICSCO.LTD.SamsungWelcome"
        "SAMSUNGELECTRONICSCO.LTD.SamsungUpdate"
        "SAMSUNGELECTRONICSCO.LTD.SamsungSecurity1.2"
        "SAMSUNGELECTRONICSCO.LTD.SamsungScreenRecording"
        #"SAMSUNGELECTRONICSCO.LTD.SamsungRecovery"             # Used to Factory Reset
        "SAMSUNGELECTRONICSCO.LTD.SamsungQuickSearch"
        "SAMSUNGELECTRONICSCO.LTD.SamsungPCCleaner"
        "SAMSUNGELECTRONICSCO.LTD.SamsungCloudBluetoothSync"
        "SAMSUNGELECTRONICSCO.LTD.PCGallery"
        "SAMSUNGELECTRONICSCO.LTD.OnlineSupportSService"
        "4AE8B7C2.BOOKING.COMPARTNERAPPSAMSUNGEDITION"

        # Apps which other apps depend on
        "Microsoft.Advertising.Xaml"

        # <==========[ DIY ]==========> (Remove the # to Unninstall)

        # [DIY] Default apps i'll keep

        #"Microsoft.FreshPaint"             # Paint
        #"Microsoft.MicrosoftEdge"          # Microsoft Edge
        #"Microsoft.MicrosoftStickyNotes"   # Sticky Notes
        #"Microsoft.WindowsCalculator"      # Calculator
        #"Microsoft.WindowsCamera"          # Camera
        #"Microsoft.ScreenSketch"           # Snip and Sketch (now called Snipping tool, replaces the Win32 version in clean installs)
        #"Microsoft.WindowsFeedbackHub"     # Feedback Hub
        #"Microsoft.Windows.Photos"         # Photos

        # [DIY] Xbox Apps and Dependencies

        #"Microsoft.XboxGamingOverlay"      # Xbox Game Bar
        #"Microsoft.XboxIdentityProvider"   # Xbox Identity Provider (Xbox Dependency)
        #"Microsoft.Xbox.TCUI"              # Xbox Live API communication (Xbox Dependency)

        # [DIY] Common Streaming services

        #"*Netflix*"                        # Netflix
        #"*SpotifyMusic*"                   # Spotify

        # [DIY] Can't be reinstalled

        #"Microsoft.WindowsStore"           # Windows Store

        # Apps which cannot be removed using Remove-AppxPackage
        #"Microsoft.BioEnrollment"
        #"Microsoft.Windows.Cortana"        # Cortana
        #"Microsoft.WindowsFeedback"        # Feedback Module
        #"Windows.ContactSupport"
    )

    Remove-UWPAppsList -Apps $Apps
}

function Main() {
    Remove-BloatwareAppsList # Remove the main Bloat from Pre-installed Apps
}

Main