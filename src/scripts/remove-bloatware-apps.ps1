Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function RemoveBloatwareApps() {

    Title1 -Text "Remove Bloatware Apps"

    $Apps = @(
        # [Alphabetic order] Default Windows 10 apps
        "Microsoft.3DBuilder"                       # 3D Builder
        "Microsoft.Appconnector"
        "Microsoft.BingFinance"                     # Finance
        "Microsoft.BingFoodAndDrink"                # Food And Drink
        "Microsoft.BingHealthAndFitness"            # Health And Fitness
        "Microsoft.BingNews"                        # News
        "Microsoft.BingSports"                      # Sports
        "Microsoft.BingTranslator"                  # Translator
        "Microsoft.BingTravel"                      # Travel
        "Microsoft.BingWeather"                     # Weather
        "Microsoft.CommsPhone"
        "Microsoft.ConnectivityStore"
        "Microsoft.GamingServices"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftPowerBIForWindows"
        "Microsoft.MicrosoftSolitaireCollection"    # MS Solitaire
        "Microsoft.MixedReality.Portal"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.Office.OneNote"                  # MS Office One Note
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.People"                          # People
        "Microsoft.MSPaint"                         # Paint 3D (Where every artist truly start as a kid, i mean, on original Paint, not this 3D)
        "Microsoft.Print3D"                         # Print 3D
        "Microsoft.ScreenSketch"
        "Microsoft.SkypeApp"                        # Skype (Who still uses Skype? Use Discord)
        "Microsoft.Todos"                           # Microsoft To Do
        "Microsoft.Wallet"
        "Microsoft.WindowsAlarms"                   # Alarms
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsMaps"                     # Maps
        "Microsoft.WindowsPhone"
        "Microsoft.WindowsReadingList"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.XboxApp"                         # Xbox Console Companion (Replaced by new App)
        "Microsoft.XboxGameCallableUI"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxIdentityProvider"            # Xbox Dependency
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.Xbox.TCUI"
        "Microsoft.YourPhone"                       # Your Phone
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"

        # [Alphabetic order] Default Windows 11 apps
        "MicrosoftWindows.Client.WebExperience"     # Taskbar Widgets
        
        # [Alphabetic order] 3rd party Apps
        "*ACGMediaPlayer*"
        "*ActiproSoftwareLLC*"
        "*AdobePhotoshopExpress*"                   # Adobe Photoshop Express
        "*Asphalt8Airborne*"                        # Asphalt 8 Airbone
        "*AutodeskSketchBook*"
        "*BubbleWitch3Saga*"                        # Bubble Witch 3 Saga
        "*CaesarsSlotsFreeCasino*"
        "*CandyCrush*"                              # Candy Crush
        "*COOKINGFEVER*"
        "*CyberLinkMediaSuiteEssentials*"
        "*DisneyMagicKingdoms*"
        "*Dolby*"                                   # Dolby Products (Like Atmos)
        "*DrawboardPDF*"
        "*Duolingo-LearnLanguagesforFree*"          # Duolingo
        "*EclipseManager*"
        "*Facebook*"                                # Facebook
        "*FarmVille2CountryEscape*"
        "*FitbitCoach*"
        "*Flipboard*"
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
        "*Plex*"
        "*PolarrPhotoEditorAcademicEdition*"
        "*RoyalRevolt*"                         # Royal Revolt
        "*Shazam*"
        "*SlingTV*"
        "*Speed Test*"
        "*Sway*"
        "*TuneInRadio*"
        "*Twitter*"                             # Twitter
        "*Viber*"
        "*WinZipUniversal*"
        "*Wunderlist*"
        "*XING*"
        
        # Apps which other apps depend on
        "Microsoft.Advertising.Xaml"

        # <==========[ DIY ]==========> (Remove the # to Unninstall)

        # [DIY] Default apps i'll keep

        #"Microsoft.FreshPaint"
        #"Microsoft.MicrosoftEdge"          # This browser finally became something
        #"Microsoft.MicrosoftStickyNotes"   # Productivity
        #"Microsoft.WindowsCalculator"      # How much is (98357489.253 x 5347658.845937) / 924 ?
        #"Microsoft.WindowsCamera"          # Keep to test Camera
        #"Microsoft.Windows.Photos"         # Reproduce GIFs
        
        # [DIY] Xbox Apps and Dependencies
        
        #"Microsoft.XboxGamingOverlay"      # Xbox Game Bar
        
        # [DIY] Common Streaming services
        
        #"*Netflix*"
        #"*SpotifyMusic*"

        # [DIY] Can't be reinstalled

        #"Microsoft.WindowsStore"
        #"Microsoft.WindowsFeedbackHub"

        # Apps which cannot be removed using Remove-AppxPackage
        #"Microsoft.BioEnrollment"
        #"Microsoft.Windows.Cortana"
        #"Microsoft.WindowsFeedback"
        #"Windows.ContactSupport"
    )

    ForEach ($Bloat in $Apps) {
        Write-Host "[-][UWP] Trying to remove $Bloat ..."
        Get-AppxPackage -AllUsers -Name $Bloat | Remove-AppxPackage    # App
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online -AllUsers  # Payload
    }

}

function Main() {
    
    RemoveBloatwareApps # Remove the main Bloat from Pre-installed Apps

}

Main