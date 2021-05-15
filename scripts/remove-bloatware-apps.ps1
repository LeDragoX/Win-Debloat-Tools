Function RemoveBloatwareApps {

    Title1 -Text "Remove Bloatware Apps"

    $Apps = @(
        # [Alphabetic order] Default Windows 10 apps
        "Microsoft.3DBuilder"
        "Microsoft.Appconnector"
        "Microsoft.BingFinance"
        "Microsoft.BingFoodAndDrink"
        "Microsoft.BingHealthAndFitness"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingTranslator"
        "Microsoft.BingTravel"
        "Microsoft.BingWeather"
        "Microsoft.CommsPhone"
        "Microsoft.ConnectivityStore"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftPowerBIForWindows"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MinecraftUWP"
        "Microsoft.MixedReality.Portal"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.Office.OneNote"
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.ScreenSketch"
        "Microsoft.SkypeApp"                        # Who still uses Skype? Use Discord
        "Microsoft.Wallet"
        "Microsoft.WindowsAlarms"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsPhone"
        "Microsoft.WindowsReadingList"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.YourPhone"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        
        # [Alphabetic order] 3rd party Apps
        "*ACGMediaPlayer*"
        "*ActiproSoftwareLLC*"
        "*AdobePhotoshopExpress*"
        "*Asphalt8Airborne*"
        "*AutodeskSketchBook*"
        "*BubbleWitch3Saga*"
        "*CaesarsSlotsFreeCasino*"
        "*CandyCrush*"
        "*COOKINGFEVER*"
        "*CyberLinkMediaSuiteEssentials*"
        "*DisneyMagicKingdoms*"
        "*Dolby*"
        "*DrawboardPDF*"
        "*Duolingo-LearnLanguagesforFree*"
        "*EclipseManager*"
        "*Facebook*"
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
        "*RoyalRevolt*"
        "*Shazam*"
        "*SlingTV*"
        "*Speed Test*"
        "*Sway*"
        "*TuneInRadio*"
        "*Twitter*"
        "*Viber*"
        "*WinZipUniversal*"
        "*Wunderlist*"
        "*XING*"
        
        # Apps which other apps depend on
        "Microsoft.Advertising.Xaml"

        # <==========[ DIY ]==========> (Remove the # to Unninstall)

        # [DIY] Default apps i'll keep

        #"Microsoft.FreshPaint"
        #"Microsoft.GamingServices"
        #"Microsoft.MicrosoftEdge"
        #"Microsoft.MicrosoftStickyNotes"           # Productivity
        #"Microsoft.MSPaint"                        # Where every artist truly start as a kid
        #"Microsoft.WindowsCalculator"              # A basic need
        #"Microsoft.WindowsCamera"                  # People may use it
        #"Microsoft.Windows.Photos"                 # Reproduce GIFs
        
        # [DIY] Xbox Apps and Dependencies
        
        #"Microsoft.Xbox.TCUI"
        #"Microsoft.XboxApp"
        #"Microsoft.XboxGameOverlay"
        #"Microsoft.XboxGamingOverlay"
        #"Microsoft.XboxSpeechToTextOverlay"
        # Apps which cannot be removed using Remove-AppxPackage from Xbox
        #"Microsoft.XboxGameCallableUI"
        #"Microsoft.XboxIdentityProvider"
        
        # [DIY] Common Streaming services
        
        #"*Netflix*"
        #"*SpotifyMusic*"

        #"Microsoft.WindowsStore"                   # can't be re-installed

        # Apps which cannot be removed using Remove-AppxPackage
        #"Microsoft.BioEnrollment"
        #"Microsoft.Windows.Cortana"
        #"Microsoft.WindowsFeedback"
        #"Windows.ContactSupport"
    )

    ForEach ($Bloat in $Apps) {
        Write-Host "[-][UWP] Trying to remove $Bloat ..."
        Get-AppxPackage -Name $Bloat| Remove-AppxPackage    # App
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online  # Payload
    }

}

RemoveBloatwareApps             # Remove the main Bloat from Pre-installed Apps