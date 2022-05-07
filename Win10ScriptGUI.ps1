# Learned from: https://docs.microsoft.com/en-us/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.1
# Adapted majorly from https://github.com/ChrisTitusTech/win10script and https://github.com/Sycnex/Windows10Debloater
# Take Ownership tweak from: https://www.howtogeek.com/howto/windows-vista/add-take-ownership-to-explorer-right-click-menu-in-vista/

function Request-AdminPrivilege() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function Show-GUI() {
    Write-Status -Symbol "@" -Status "Loading GUI Layout..."
    # Loading System Libs
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles() # Rounded Buttons :3

    Set-UIFont # Load the Layout Font

    $Script:NeedRestart = $false
    $DoneTitle = "Information"
    $DoneMessage = "Process Completed!"

    # <===== PERSONAL LAYOUT =====>

    # To Forms
    $FormWidth = 1366 * 0.85 # ~ 1162
    $FormHeight = 768 * 0.85 # ~ 653
    # To Panels
    $NumOfPanels = 4
    [Int] $PanelWidth = ($FormWidth / $NumOfPanels)
    # To Labels
    $TitleLabelHeight = 35
    $CaptionLabelHeight = 20
    # To Buttons
    $ButtonWidth = $PanelWidth * 0.91
    $ButtonHeight = 30
    $DistanceBetweenButtons = 5
    # To Fonts
    $Header1 = 20
    $Header3 = 14

    [Int] $TitleLabelX = $PanelWidth * 0
    [Int] $TitleLabelY = $FormHeight * 0.01
    [Int] $ButtonX = $PanelWidth * 0.01
    [Int] $FirstButtonY = $TitleLabelY + $TitleLabelHeight + 30 # 70

    $WarningYellow = "#EED202"
    $White = "#FFFFFF"
    $WinBlue = "#08ABF7"
    $WinDark = "#252525"

    $CaptionLabelWidth = $PanelWidth - ($PanelWidth - $ButtonWidth) # & $CaptionLabelHeight
    $BBHeight = ($ButtonHeight * 2) + $DistanceBetweenButtons

    # <===== UI =====>

    # Main Window:
    $Form = New-Form -Width ($FormWidth + 15) -Height $FormHeight -Text "Win 10+ S. D. Tools (LeDragoX) | $(Get-SystemSpec)" -BackColor "$WinDark" -Maximize $false # Loading the specs takes longer to load the script

    # Window Icon:
    $Form = New-FormIcon -Form $Form -ImageLocation "$PSScriptRoot\src\assets\windows-11-logo.png"

    # Panels to put Labels and Buttons
    $CurrentPanelIndex = 0
    $Panel1 = New-Panel -Width $PanelWidth -Height ($FormHeight - ($FormHeight * 0.1955)) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $Panel2 = New-Panel -Width $PanelWidth -Height ($FormHeight * 1.00) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY ($Panel1.Location.Y + $Panel1.Height)
    $CurrentPanelIndex++
    $Panel3 = New-Panel -Width ($PanelWidth - 15) -Height ($FormHeight * 2.40) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $CurrentPanelIndex++
    $Panel4 = New-Panel -Width ($PanelWidth - 15) -Height ($FormHeight * 2.40) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $CurrentPanelIndex++
    $Panel5 = New-Panel -Width $PanelWidth -Height ($FormHeight * 2.40) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    # Panel to put more Panels
    $FullPanel = New-Panel -Width (($PanelWidth * ($CurrentPanelIndex + 1))) -Height $FormHeight -LocationX 0 -LocationY 0 -HasVerticalScroll

    # Panels 1, 2, 3-4-5 ~> Title Label
    $TitleLabel1 = New-Label -Text "System Tweaks" -Width $PanelWidth -Height $TitleLabelHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $Header1 -FontStyle "Bold" -ForeColor $WinBlue
    $TitleLabel2 = New-Label -Text "Customize Tweaks" -Width $PanelWidth -Height $TitleLabelHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $Header1 -FontStyle "Bold" -ForeColor $WinBlue
    $TitleLabel3 = New-Label -Text "Software Install" -Width $PanelWidth -Height $TitleLabelHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $Header1 -FontStyle "Bold" -ForeColor $WinBlue

    # Panel 1, 2, 3-4-5 ~> Caption Label
    $CaptionLabel1_1 = New-Label -Text "($((Split-Path -Path $PSCommandPath -Leaf).Split('.')[0]) v$((Get-Item "$(Split-Path -Path $PSCommandPath -Leaf)").LastWriteTimeUtc | Get-Date -Format "yyyy-MM-dd"))" -Width $PanelWidth -Height $CaptionLabelHeight -LocationX 0 -LocationY ($FirstButtonY - 27) -ForeColor $White
    $CaptionLabel1_2 = New-Label -Text "Enable/Disable Features" -Width $PanelWidth -Height $CaptionLabelHeight -LocationX 0 -LocationY ($FirstButtonY - 27) -ForeColor $White
    $CaptionLabel1_3 = New-Label -Text "Package Managers: Winget and Chocolatey" -Width ($CaptionLabelWidth * 1.25) -Height $CaptionLabelHeight -LocationX (($PanelWidth * 2) - ($PanelWidth * 0.10)) -LocationY ($FirstButtonY - 27) -ForeColor $White

    # ==> Panel 1
    $ApplyTweaks = New-Button -Text "✔ Apply Tweaks" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $Header3 -ForeColor $WinBlue

    $NextYLocation = $ApplyTweaks.Location.Y + $ApplyTweaks.Height + $DistanceBetweenButtons
    $UndoTweaks = New-Button -Text "❌ Undo Tweaks" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -ForeColor $WarningYellow

    $NextYLocation = $UndoTweaks.Location.Y + $UndoTweaks.Height + $DistanceBetweenButtons
    $RemoveXbox = New-Button -Text "Remove and Disable Xbox" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -ForeColor $WarningYellow

    $NextYLocation = $RemoveXbox.Location.Y + $RemoveXbox.Height + $DistanceBetweenButtons
    # Logo from the Script
    $PictureBox1 = New-PictureBox -ImageLocation "$PSScriptRoot\src\assets\script-logo.png" -Width $ButtonWidth -Height (($BBHeight * 2) + $DistanceBetweenButtons) -LocationX $ButtonX -LocationY $NextYLocation -SizeMode 'Zoom'

    $NextYLocation = $PictureBox1.Location.Y + $PictureBox1.Height + $DistanceBetweenButtons
    $InstallOneDrive = New-Button -Text "Install OneDrive" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallOneDrive.Location.Y + $InstallOneDrive.Height + $DistanceBetweenButtons
    $ReinstallBloatApps = New-Button -Text "Reinstall Pre-Installed Apps" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $ReinstallBloatApps.Location.Y + $ReinstallBloatApps.Height + $DistanceBetweenButtons
    $RepairWindows = New-Button -Text "Repair Windows" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $RepairWindows.Location.Y + $RepairWindows.Height + $DistanceBetweenButtons
    $ShowDebloatInfo = New-Button -Text "Show Debloat Info" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    # ==> Panel 2
    $DarkThemeCheckBox = New-CheckBox -Text "Use Dark Theme" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $FirstButtonY

    $NextYLocation = $DarkThemeCheckBox.Location.Y + $DarkThemeCheckBox.Height + $DistanceBetweenButtons
    $CbActivityHistory = New-CheckBox -Text "Enable Activity History" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CbActivityHistory.Location.Y + $CbActivityHistory.Height + $DistanceBetweenButtons
    $CbBackgroundsApps = New-CheckBox -Text "Enable Background Apps" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CbBackgroundsApps.Location.Y + $CbBackgroundsApps.Height + $DistanceBetweenButtons
    $CbClipboardHistory = New-CheckBox -Text "Enable Clipboard History" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CbClipboardHistory.Location.Y + $CbClipboardHistory.Height + $DistanceBetweenButtons
    $CbCortana = New-CheckBox -Text "Enable Cortana" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CbCortana.Location.Y + $CbCortana.Height + $DistanceBetweenButtons
    $CbOldVolumeControl = New-CheckBox -Text "Enable Old Volume Control" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CbOldVolumeControl.Location.Y + $CbOldVolumeControl.Height + $DistanceBetweenButtons
    $CbSearchIdx = New-CheckBox -Text "Enable Search Indexing" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CbSearchIdx.Location.Y + $CbSearchIdx.Height + $DistanceBetweenButtons
    $CbTelemetry = New-CheckBox -Text "Enable Telemetry" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CbTelemetry.Location.Y + $CbTelemetry.Height + $DistanceBetweenButtons
    $CbXboxGameBarAndDVR = New-CheckBox -Text "Enable Xbox GameBar/DVR" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CbXboxGameBarAndDVR.Location.Y + $CbXboxGameBarAndDVR.Height + $DistanceBetweenButtons
    $CaptionLabel2_1 = New-Label -Text "Miscellaneous Features" -Width $PanelWidth -Height $CaptionLabelHeight -LocationX 0 -LocationY $NextYLocation -ForeColor $White

    $NextYLocation = $CaptionLabel2_1.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $CbGodMode = New-CheckBox -Text "Enable God Mode" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CbGodMode.Location.Y + $CbGodMode.Height + $DistanceBetweenButtons
    $CbTakeOwnership = New-CheckBox -Text "Enable Take Ownership menu" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CbTakeOwnership.Location.Y + $CbTakeOwnership.Height + $DistanceBetweenButtons
    $CbShutdownPCShortcut = New-CheckBox -Text "Enable Shutdown PC shortcut" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    # ==> Panel 3
    $InstallDrivers = New-Button -Text "Install CPU/GPU Drivers Updaters" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $Header3 -ForeColor $WinBlue

    $NextYLocation = $InstallDrivers.Location.Y + $InstallDrivers.Height + $DistanceBetweenButtons
    $CaptionLabel3_1 = New-Label -Text "Web Browsers" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel3_1.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallBraveBrowser = New-CheckBox -Text "Brave Browser" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallBraveBrowser.Location.Y + $InstallBraveBrowser.Height + $DistanceBetweenButtons
    $InstallGoogleChrome = New-CheckBox -Text "Google Chrome" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallGoogleChrome.Location.Y + $InstallGoogleChrome.Height + $DistanceBetweenButtons
    $InstallMozillaFirefox = New-CheckBox -Text "Mozilla Firefox" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallMozillaFirefox.Location.Y + $InstallMozillaFirefox.Height + $DistanceBetweenButtons
    $CaptionLabel3_2 = New-Label -Text "File Compression" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel3_2.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Install7Zip = New-CheckBox -Text "7-Zip" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $Install7Zip.Location.Y + $Install7Zip.Height + $DistanceBetweenButtons
    $InstallWinRar = New-CheckBox -Text "WinRAR (Trial)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallWinRar.Location.Y + $InstallWinRar.Height + $DistanceBetweenButtons
    $CaptionLabel3_3 = New-Label -Text "Document Editors/Readers" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel3_3.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallLibreOffice = New-CheckBox -Text "LibreOffice" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallLibreOffice.Location.Y + $InstallLibreOffice.Height + $DistanceBetweenButtons
    $InstallOnlyOffice = New-CheckBox -Text "ONLYOFFICE DesktopEditors" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallOnlyOffice.Location.Y + $InstallOnlyOffice.Height + $DistanceBetweenButtons
    $InstallPowerBi = New-CheckBox -Text "Power BI" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallPowerBi.Location.Y + $InstallPowerBi.Height + $DistanceBetweenButtons
    $CaptionLabel3_4 = New-Label -Text "Academic Research" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel3_4.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallZotero = New-CheckBox -Text "Zotero" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallZotero.Location.Y + $InstallZotero.Height + $DistanceBetweenButtons
    $CaptionLabel3_5 = New-Label -Text "Network Management" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel3_5.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallHamachi = New-CheckBox -Text "Hamachi (LAN)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallHamachi.Location.Y + $InstallHamachi.Height + $DistanceBetweenButtons
    $InstallRadminVpn = New-CheckBox -Text "Radmin VPN (LAN)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallRadminVpn.Location.Y + $InstallRadminVpn.Height + $DistanceBetweenButtons
    $CaptionLabel3_6 = New-Label -Text "2-Factor Authentication" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel3_6.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallTwilioAuthy = New-CheckBox -Text "Twilio Authy" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallTwilioAuthy.Location.Y + $InstallTwilioAuthy.Height + $DistanceBetweenButtons
    $CaptionLabel3_7 = New-Label -Text "⌨ Development on Windows" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel3_7.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallWindowsTerminal = New-CheckBox -Text "Windows Terminal" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallWindowsTerminal.Location.Y + $InstallWindowsTerminal.Height + $DistanceBetweenButtons
    $InstallNerdFonts = New-CheckBox -Text "Install Nerd Fonts" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -ForeColor $WinBlue

    $NextYLocation = $InstallNerdFonts.Location.Y + $InstallNerdFonts.Height + $DistanceBetweenButtons
    $InstallGitGnupgSshSetup = New-CheckBox -Text "Git + GnuPG + SSH (Setup)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -ForeColor $WinBlue

    $NextYLocation = $InstallGitGnupgSshSetup.Location.Y + $InstallGitGnupgSshSetup.Height + $DistanceBetweenButtons
    $InstallAdb = New-CheckBox -Text "Android Debug Bridge (ADB)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallAdb.Location.Y + $InstallAdb.Height + $DistanceBetweenButtons
    $InstallAndroidStudio = New-CheckBox -Text "Android Studio" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallAndroidStudio.Location.Y + $InstallAndroidStudio.Height + $DistanceBetweenButtons
    $InstallDockerDesktop = New-CheckBox -Text "Docker Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallDockerDesktop.Location.Y + $InstallDockerDesktop.Height + $DistanceBetweenButtons
    $InstallInsomnia = New-CheckBox -Text "Insomnia" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallInsomnia.Location.Y + $InstallInsomnia.Height + $DistanceBetweenButtons
    $InstallJavaJdks = New-CheckBox -Text "Java - Adoptium JDK 8/11/18" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallJavaJdks.Location.Y + $InstallJavaJdks.Height + $DistanceBetweenButtons
    $InstallJavaJre = New-CheckBox -Text "Java - Oracle JRE" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallJavaJre.Location.Y + $InstallJavaJre.Height + $DistanceBetweenButtons
    $InstallMySql = New-CheckBox -Text "MySQL" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallMySql.Location.Y + $InstallMySql.Height + $DistanceBetweenButtons
    $InstallNodeJs = New-CheckBox -Text "NodeJS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallNodeJs.Location.Y + $InstallNodeJs.Height + $DistanceBetweenButtons
    $InstallNodeJsLts = New-CheckBox -Text "NodeJS LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallNodeJsLts.Location.Y + $InstallNodeJsLts.Height + $DistanceBetweenButtons
    $InstallPostgreSql = New-CheckBox -Text "PostgreSQL" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallPostgreSql.Location.Y + $InstallPostgreSql.Height + $DistanceBetweenButtons
    $InstallPython3 = New-CheckBox -Text "Python 3" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallPython3.Location.Y + $InstallPython3.Height + $DistanceBetweenButtons
    $InstallPythonAnaconda3 = New-CheckBox -Text "Python - Anaconda3" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallPythonAnaconda3.Location.Y + $InstallPythonAnaconda3.Height + $DistanceBetweenButtons
    $InstallRuby = New-CheckBox -Text "Ruby" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallRuby.Location.Y + $InstallRuby.Height + $DistanceBetweenButtons
    $InstallRubyMsys = New-CheckBox -Text "Ruby (MSYS2)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallRubyMsys.Location.Y + $InstallRubyMsys.Height + $DistanceBetweenButtons
    $InstallRustGnu = New-CheckBox -Text "Rust (GNU)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallRustGnu.Location.Y + $InstallRustGnu.Height + $DistanceBetweenButtons
    $InstallRustMsvc = New-CheckBox -Text "Rust (MSVC)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    # ==> Panel 4
    $InstallSelected = New-Button -Text "Install Selected" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontStyle "Bold"

    $NextYLocation = $InstallSelected.Location.Y + $InstallSelected.Height + $DistanceBetweenButtons
    $UninstallMode = New-Button -Text "[OFF] Uninstall Mode" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontStyle "Bold"

    $NextYLocation = $UninstallMode.Location.Y + $UninstallMode.Height + $DistanceBetweenButtons
    $CaptionLabel4_1 = New-Label -Text "Image Tools" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel4_1.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallGimp = New-CheckBox -Text "GIMP" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallGimp.Location.Y + $InstallGimp.Height + $DistanceBetweenButtons
    $InstallInkscape = New-CheckBox -Text "Inkscape" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallInkscape.Location.Y + $InstallInkscape.Height + $DistanceBetweenButtons
    $InstallIrfanView = New-CheckBox -Text "IrfanView" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallIrfanView.Location.Y + $InstallIrfanView.Height + $DistanceBetweenButtons
    $InstallKrita = New-CheckBox -Text "Krita" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallKrita.Location.Y + $InstallKrita.Height + $DistanceBetweenButtons
    $InstallPaintNet = New-CheckBox -Text "Paint.NET" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallPaintNet.Location.Y + $InstallPaintNet.Height + $DistanceBetweenButtons
    $InstallShareX = New-CheckBox -Text "ShareX (Screenshots/GIFs)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallShareX.Location.Y + $InstallShareX.Height + $DistanceBetweenButtons
    $CaptionLabel4_2 = New-Label -Text "Text Editors/IDEs" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel4_2.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallAtom = New-CheckBox -Text "Atom" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallAtom.Location.Y + $InstallAtom.Height + $DistanceBetweenButtons
    $InstallNotepadPlusPlus = New-CheckBox -Text "Notepad++" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallNotepadPlusPlus.Location.Y + $InstallNotepadPlusPlus.Height + $DistanceBetweenButtons
    $InstallVSCode = New-CheckBox -Text "VS Code" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallVSCode.Location.Y + $InstallVSCode.Height + $DistanceBetweenButtons
    $InstallVSCodium = New-CheckBox -Text "VS Codium" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallVSCodium.Location.Y + $InstallVSCodium.Height + $DistanceBetweenButtons
    $CaptionLabel4_3 = New-Label -Text "Cloud Storage" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel4_3.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallDropbox = New-CheckBox -Text "Dropbox" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallDropbox.Location.Y + $InstallDropbox.Height + $DistanceBetweenButtons
    $InstallGoogleDrive = New-CheckBox -Text "Google Drive" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallGoogleDrive.Location.Y + $InstallGoogleDrive.Height + $DistanceBetweenButtons
    $CaptionLabel4_4 = New-Label -Text "Bootable USB" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel4_4.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallBalenaEtcher = New-CheckBox -Text "Etcher" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallBalenaEtcher.Location.Y + $InstallBalenaEtcher.Height + $DistanceBetweenButtons
    $InstallRufus = New-CheckBox -Text "Rufus" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallRufus.Location.Y + $InstallRufus.Height + $DistanceBetweenButtons
    $InstallVentoy = New-CheckBox -Text "Ventoy" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallVentoy.Location.Y + $InstallVentoy.Height + $DistanceBetweenButtons
    $CaptionLabel4_5 = New-Label -Text "Planning/Productivity" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel4_5.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallNotion = New-CheckBox -Text "Notion" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallNotion.Location.Y + $InstallNotion.Height + $DistanceBetweenButtons
    $InstallObsidian = New-CheckBox -Text "Obsidian" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallObsidian.Location.Y + $InstallObsidian.Height + $DistanceBetweenButtons
    $CaptionLabel4_6 = New-Label -Text "⚒ Utilities" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel4_6.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallCpuZ = New-CheckBox -Text "CPU-Z" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallCpuZ.Location.Y + $InstallCpuZ.Height + $DistanceBetweenButtons
    $InstallCrystalDiskInfo = New-CheckBox -Text "Crystal Disk Info" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallCrystalDiskInfo.Location.Y + $InstallCrystalDiskInfo.Height + $DistanceBetweenButtons
    $InstallCrystalDiskMark = New-CheckBox -Text "Crystal Disk Mark" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallCrystalDiskMark.Location.Y + $InstallCrystalDiskMark.Height + $DistanceBetweenButtons
    $InstallGpuZ = New-CheckBox -Text "GPU-Z" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallGpuZ.Location.Y + $InstallGpuZ.Height + $DistanceBetweenButtons
    $InstallNVCleanstall = New-CheckBox -Text "NVCleanstall" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallNVCleanstall.Location.Y + $InstallNVCleanstall.Height + $DistanceBetweenButtons
    $CaptionLabel4_7 = New-Label -Text "⌨ Windows Subsystem For Linux" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel4_7.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallWSLgOrPreview = New-CheckBox -Text "Install WSLg/Preview" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -ForeColor $WinBlue

    $NextYLocation = $InstallWSLgOrPreview.Location.Y + $InstallWSLgOrPreview.Height + $DistanceBetweenButtons
    $InstallArchWSL = New-CheckBox -Text "ArchWSL (x64)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -ForeColor $WinBlue

    $NextYLocation = $InstallArchWSL.Location.Y + $InstallArchWSL.Height + $DistanceBetweenButtons
    $InstallDebian = New-CheckBox -Text "Debian GNU/Linux" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallDebian.Location.Y + $InstallDebian.Height + $DistanceBetweenButtons
    $InstallKaliLinux = New-CheckBox -Text "Kali Linux Rolling" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallKaliLinux.Location.Y + $InstallKaliLinux.Height + $DistanceBetweenButtons
    $InstallOpenSuse = New-CheckBox -Text "Open SUSE 42" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallOpenSuse.Location.Y + $InstallOpenSuse.Height + $DistanceBetweenButtons
    $InstallSles = New-CheckBox -Text "SLES v12" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallSles.Location.Y + $InstallSles.Height + $DistanceBetweenButtons
    $InstallUbuntu = New-CheckBox -Text "Ubuntu" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallUbuntu.Location.Y + $InstallUbuntu.Height + $DistanceBetweenButtons
    $InstallUbuntu16Lts = New-CheckBox -Text "Ubuntu 16.04 LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallUbuntu16Lts.Location.Y + $InstallUbuntu16Lts.Height + $DistanceBetweenButtons
    $InstallUbuntu18Lts = New-CheckBox -Text "Ubuntu 18.04 LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallUbuntu18Lts.Location.Y + $InstallUbuntu18Lts.Height + $DistanceBetweenButtons
    $InstallUbuntu20Lts = New-CheckBox -Text "Ubuntu 20.04 LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    # ==> Panel 5
    $InstallGamingDependencies = New-Button -Text "Install Gaming Dependencies" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $Header3 -ForeColor $WinBlue

    $NextYLocation = $InstallGamingDependencies.Location.Y + $InstallGamingDependencies.Height + $DistanceBetweenButtons
    $CaptionLabel5_1 = New-Label -Text "Communication" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel5_1.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallDiscord = New-CheckBox -Text "Discord" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallDiscord.Location.Y + $InstallDiscord.Height + $DistanceBetweenButtons
    $InstallMSTeams = New-CheckBox -Text "Microsoft Teams" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallMSTeams.Location.Y + $InstallMSTeams.Height + $DistanceBetweenButtons
    $InstalRocketChat = New-CheckBox -Text "Rocket Chat" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstalRocketChat.Location.Y + $InstalRocketChat.Height + $DistanceBetweenButtons
    $InstallSlack = New-CheckBox -Text "Slack" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallSlack.Location.Y + $InstallSlack.Height + $DistanceBetweenButtons
    $InstallTelegramDesktop = New-CheckBox -Text "Telegram Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallTelegramDesktop.Location.Y + $InstallTelegramDesktop.Height + $DistanceBetweenButtons
    $InstallZoom = New-CheckBox -Text "Zoom" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallZoom.Location.Y + $InstallZoom.Height + $DistanceBetweenButtons
    $CaptionLabel5_2 = New-Label -Text "Gaming" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel5_2.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallBorderlessGaming = New-CheckBox -Text "Borderless Gaming" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallBorderlessGaming.Location.Y + $InstallBorderlessGaming.Height + $DistanceBetweenButtons
    $InstallEADesktop = New-CheckBox -Text "EA Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallEADesktop.Location.Y + $InstallEADesktop.Height + $DistanceBetweenButtons
    $InstallEpicGamesLauncher = New-CheckBox -Text "Epic Games Launcher" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallEpicGamesLauncher.Location.Y + $InstallEpicGamesLauncher.Height + $DistanceBetweenButtons
    $InstallGogGalaxy = New-CheckBox -Text "GOG Galaxy" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallGogGalaxy.Location.Y + $InstallGogGalaxy.Height + $DistanceBetweenButtons
    $InstallSteam = New-CheckBox -Text "Steam" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallSteam.Location.Y + $InstallSteam.Height + $DistanceBetweenButtons
    $InstallUbisoftConnect = New-CheckBox -Text "Ubisoft Connect" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallUbisoftConnect.Location.Y + $InstallUbisoftConnect.Height + $DistanceBetweenButtons
    $CaptionLabel5_3 = New-Label -Text "Remote Connection" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel5_3.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallAnyDesk = New-CheckBox -Text "AnyDesk" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallAnyDesk.Location.Y + $InstallAnyDesk.Height + $DistanceBetweenButtons
    $InstallParsec = New-CheckBox -Text "Parsec" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallParsec.Location.Y + $InstallParsec.Height + $DistanceBetweenButtons
    $InstallScrCpy = New-CheckBox -Text "ScrCpy (Android)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallScrCpy.Location.Y + $InstallScrCpy.Height + $DistanceBetweenButtons
    $InstallTeamViewer = New-CheckBox -Text "Team Viewer" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallTeamViewer.Location.Y + $InstallTeamViewer.Height + $DistanceBetweenButtons
    $CaptionLabel5_4 = New-Label -Text "Recording and Streaming" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel5_4.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallHandBrake = New-CheckBox -Text "HandBrake (Transcode)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallHandBrake.Location.Y + $InstallHandBrake.Height + $DistanceBetweenButtons
    $InstallObsStudio = New-CheckBox -Text "OBS Studio" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallObsStudio.Location.Y + $InstallObsStudio.Height + $DistanceBetweenButtons
    $InstallStreamlabsObs = New-CheckBox -Text "Streamlabs OBS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallStreamlabsObs.Location.Y + $InstallStreamlabsObs.Height + $DistanceBetweenButtons
    $CaptionLabel5_5 = New-Label -Text "Audio/Video Tools" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel5_5.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallMpcHc = New-CheckBox -Text "MPC-HC from clsid2 (Player)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallMpcHc.Location.Y + $InstallMpcHc.Height + $DistanceBetweenButtons
    $InstallSpotify = New-CheckBox -Text "Spotify (Player)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallSpotify.Location.Y + $InstallSpotify.Height + $DistanceBetweenButtons
    $InstallVlc = New-CheckBox -Text "VLC (Player)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallVlc.Location.Y + $InstallVlc.Height + $DistanceBetweenButtons
    $CaptionLabel5_6 = New-Label -Text "Torrent" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel5_6.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallqBittorrent = New-CheckBox -Text "qBittorrent" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallqBittorrent.Location.Y + $InstallqBittorrent.Height + $DistanceBetweenButtons
    $CaptionLabel5_7 = New-Label -Text "Emulation" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $CaptionLabel5_7.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $InstallCemu = New-CheckBox -Text "Cemu (Wii U)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallCemu.Location.Y + $InstallCemu.Height + $DistanceBetweenButtons
    $InstallDolphin = New-CheckBox -Text "Dolphin Stable (GC/Wii)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallDolphin.Location.Y + $InstallDolphin.Height + $DistanceBetweenButtons
    $InstallKegaFusion = New-CheckBox -Text "Kega Fusion (Sega Genesis)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallKegaFusion.Location.Y + $InstallKegaFusion.Height + $DistanceBetweenButtons
    $InstallMGba = New-CheckBox -Text "mGBA (GBA)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallMGba.Location.Y + $InstallMGba.Height + $DistanceBetweenButtons
    $InstallPCSX2 = New-CheckBox -Text "PCSX2 Stable (PS2 | Portable)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallPCSX2.Location.Y + $InstallPCSX2.Height + $DistanceBetweenButtons
    $InstallPPSSPP = New-CheckBox -Text "PPSSPP (PSP)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallPPSSPP.Location.Y + $InstallPPSSPP.Height + $DistanceBetweenButtons
    $InstallProject64 = New-CheckBox -Text "Project64 Dev (N64)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallProject64.Location.Y + $InstallProject64.Height + $DistanceBetweenButtons
    $InstallRetroArch = New-CheckBox -Text "RetroArch (All In One)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    $NextYLocation = $InstallRetroArch.Location.Y + $InstallRetroArch.Height + $DistanceBetweenButtons
    $InstallSnes9x = New-CheckBox -Text "Snes9x (SNES)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation

    # Add all Panels to the Form (Screen)
    $Form.Controls.AddRange(@($FullPanel))
    # Add Elements to each Panel
    $FullPanel.Controls.AddRange(@($CaptionLabel1_3))
    $FullPanel.Controls.AddRange(@($Panel1, $Panel2, $Panel3, $Panel4, $Panel5))
    $Panel1.Controls.AddRange(@($TitleLabel1, $CaptionLabel1_1, $ApplyTweaks, $UndoTweaks, $RemoveXbox, $InstallOneDrive, $ReinstallBloatApps, $RepairWindows, $ShowDebloatInfo, $PictureBox1))
    $Panel2.Controls.AddRange(@($TitleLabel2, $CaptionLabel1_2, $DarkThemeCheckBox, $CbActivityHistory, $CbBackgroundsApps, $CbClipboardHistory, $CbCortana, $CbOldVolumeControl, $CbSearchIdx, $CbTelemetry, $CbXboxGameBarAndDVR))
    $Panel2.Controls.AddRange(@($CaptionLabel2_1, $CbGodMode, $CbTakeOwnership, $CbShutdownPCShortcut))
    $Panel3.Controls.AddRange(@($InstallDrivers, $CaptionLabel3_1, $InstallBraveBrowser, $InstallGoogleChrome, $InstallMozillaFirefox))
    $Panel3.Controls.AddRange(@($CaptionLabel3_2, $Install7Zip, $InstallWinRar))
    $Panel3.Controls.AddRange(@($CaptionLabel3_3, $InstallLibreOffice, $InstallOnlyOffice, $InstallPowerBi))
    $Panel3.Controls.AddRange(@($CaptionLabel3_4, $InstallZotero))
    $Panel3.Controls.AddRange(@($CaptionLabel3_5, $InstallHamachi, $InstallRadminVpn))
    $Panel3.Controls.AddRange(@($CaptionLabel3_6, $InstallTwilioAuthy))
    $Panel3.Controls.AddRange(@($CaptionLabel3_7, $InstallWindowsTerminal, $InstallNerdFonts, $InstallGitGnupgSshSetup, $InstallAdb, $InstallAndroidStudio, $InstallDockerDesktop, $InstallInsomnia, $InstallJavaJdks, $InstallJavaJre, $InstallMySql, $InstallNodeJs, $InstallNodeJsLts, $InstallPostgreSql, $InstallPython3, $InstallPythonAnaconda3, $InstallRuby, $InstallRubyMsys, $InstallRustGnu, $InstallRustMsvc))
    $Panel4.Controls.AddRange(@($TitleLabel3, $InstallSelected, $UninstallMode, $CaptionLabel4_1, $InstallGimp, $InstallInkscape, $InstallIrfanView, $InstallKrita, $InstallPaintNet, $InstallShareX))
    $Panel4.Controls.AddRange(@($CaptionLabel4_2, $InstallAtom, $InstallNotepadPlusPlus, $InstallVSCode, $InstallVSCodium))
    $Panel4.Controls.AddRange(@($CaptionLabel4_3, $InstallDropbox, $InstallGoogleDrive))
    $Panel4.Controls.AddRange(@($CaptionLabel4_4, $InstallBalenaEtcher, $InstallRufus, $InstallVentoy))
    $Panel4.Controls.AddRange(@($CaptionLabel4_5, $InstallNotion, $InstallObsidian))
    $Panel4.Controls.AddRange(@($CaptionLabel4_6, $InstallCpuZ, $InstallCrystalDiskInfo, $InstallCrystalDiskMark, $InstallGpuZ, $InstallNVCleanstall))
    $Panel4.Controls.AddRange(@($CaptionLabel4_7, $InstallWSLgOrPreview, $InstallArchWSL, $InstallDebian, $InstallKaliLinux, $InstallOpenSuse, $InstallSles, $InstallUbuntu, $InstallUbuntu16Lts, $InstallUbuntu18Lts, $InstallUbuntu20Lts))
    $Panel5.Controls.AddRange(@($InstallGamingDependencies, $CaptionLabel5_1, $InstallDiscord, $InstallMSTeams, $InstalRocketChat, $InstallSlack, $InstallTelegramDesktop, $InstallZoom))
    $Panel5.Controls.AddRange(@($CaptionLabel5_2, $InstallBorderlessGaming, $InstallEADesktop, $InstallEpicGamesLauncher, $InstallGogGalaxy, $InstallSteam, $InstallUbisoftConnect))
    $Panel5.Controls.AddRange(@($CaptionLabel5_3, $InstallAnyDesk, $InstallParsec, $InstallScrCpy, $InstallTeamViewer))
    $Panel5.Controls.AddRange(@($CaptionLabel5_4, $InstallHandBrake, $InstallObsStudio, $InstallStreamlabsObs))
    $Panel5.Controls.AddRange(@($CaptionLabel5_5, $InstallMpcHc, $InstallSpotify, $InstallVlc))
    $Panel5.Controls.AddRange(@($CaptionLabel5_6, $InstallqBittorrent))
    $Panel5.Controls.AddRange(@($CaptionLabel5_7, $InstallCemu, $InstallDolphin, $InstallKegaFusion, $InstallMGba, $InstallPCSX2, $InstallPPSSPP, $InstallProject64, $InstallRetroArch, $InstallSnes9x))

    # <===== CLICK EVENTS =====>

    $ApplyTweaks.Add_Click( {
            $Scripts = @(
                # [Recommended order]
                "backup-system.ps1",
                "silent-debloat-softwares.ps1",
                "optimize-scheduled-tasks.ps1",
                "optimize-services.ps1",
                "remove-bloatware-apps.ps1",
                "optimize-privacy.ps1",
                "optimize-performance.ps1",
                "personal-tweaks.ps1",
                "optimize-security.ps1",
                "remove-onedrive.ps1",
                "optimize-windows-features.ps1"
            )

            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
            $PictureBox1.imageLocation = "$PSScriptRoot\src\assets\script-logo2.png"
            $PictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
            $Form.Update()
            $Script:NeedRestart = $true
        })

    $UndoTweaks.Add_Click( {
            $Global:Revert = $true
            $Scripts = @(
                "optimize-scheduled-tasks.ps1",
                "optimize-services.ps1",
                "optimize-privacy.ps1",
                "optimize-performance.ps1",
                "personal-tweaks.ps1",
                "optimize-windows-features.ps1",
                "reinstall-pre-installed-apps.ps1"
            )
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
            $Global:Revert = $false
        })

    $RemoveXbox.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("remove-and-disable-xbox.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
            $PictureBox1.imageLocation = "$PSScriptRoot\src\assets\script-logo2.png"
            $PictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
            $Form.Update()
        })

    $RepairWindows.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("backup-system.ps1", "repair-windows.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $InstallOneDrive.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("install-onedrive.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $ReinstallBloatApps.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("reinstall-pre-installed-apps.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $ShowDebloatInfo.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("show-debloat-info.ps1") -NoDialog
        })

    $DarkThemeCheckBox.Add_Click( {
            If ($DarkThemeCheckBox.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("use-dark-theme.reg") -NoDialog
                $DarkThemeCheckBox.Text = "[ON]  ⚫ Use Dark Theme"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("use-light-theme.reg") -NoDialog
                $DarkThemeCheckBox.Text = "[OFF] ☀ Use Dark Theme (D.)"
            }
        })

    $CbActivityHistory.Add_Click( {
            If ($CbActivityHistory.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-activity-history.reg") -NoDialog
                $CbActivityHistory.Text = "[ON]  Activity History (Default)"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-activity-history.reg") -NoDialog
                $CbActivityHistory.Text = "[OFF] Activity History"
            }
        })

    $CbBackgroundsApps.Add_Click( {
            If ($CbBackgroundsApps.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-bg-apps.reg") -NoDialog
                $CbBackgroundsApps.Text = "[ON]  Background Apps (D.)"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-bg-apps.reg") -NoDialog
                $CbBackgroundsApps.Text = "[OFF] Background Apps"
            }
        })

    $CbClipboardHistory.Add_Click( {
            If ($CbClipboardHistory.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-clipboard-history.reg") -NoDialog
                $CbClipboardHistory.Text = "[ON]  Clipboard History (D.)"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-clipboard-history.reg") -NoDialog
                $CbClipboardHistory.Text = "[OFF] Clipboard History"
            }
        })

    $CbCortana.Add_Click( {
            If ($CbCortana.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-cortana.reg") -NoDialog
                $CbCortana.Text = "[ON]  Cortana (Default)"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-cortana.reg") -NoDialog
                $CbCortana.Text = "[OFF] Cortana"
            }
        })

    $CbOldVolumeControl.Add_Click( {
            If ($CbOldVolumeControl.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-old-volume-control.reg") -NoDialog
                $CbOldVolumeControl.Text = "[ON]  Old Volume Control"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-old-volume-control.reg") -NoDialog
                $CbOldVolumeControl.Text = "[OFF] Old Volume Control (D.)"
            }
        })

    $CbSearchIdx.Add_Click( {
            If ($CbSearchIdx.CheckState -eq "Checked") {
                Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-search-idx-service.ps1") -NoDialog
                $CbSearchIdx.Text = "[ON]  Search Indexing (Default)"
            }
            Else {
                Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-search-idx-service.ps1") -NoDialog
                $CbSearchIdx.Text = "[OFF] Search Indexing"
            }
        })

    $CbTelemetry.Add_Click( {
            If ($CbTelemetry.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-telemetry.reg") -NoDialog
                $CbTelemetry.Text = "[ON]  Telemetry (Default)"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-telemetry.reg") -NoDialog
                $CbTelemetry.Text = "[OFF] Telemetry"
            }
        })

    $CbXboxGameBarAndDVR.Add_Click( {
            If ($CbXboxGameBarAndDVR.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-game-bar-dvr.reg") -NoDialog
                $CbXboxGameBarAndDVR.Text = "[ON]  Xbox GameBar/DVR (D.)"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-game-bar-dvr.reg") -NoDialog
                $CbXboxGameBarAndDVR.Text = "[OFF] Xbox GameBar/DVR"
            }
        })

    $CbGodMode.Add_Click( {
            If ($CbGodMode.CheckState -eq "Checked") {
                Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-god-mode.ps1") -NoDialog
                $CbGodMode.Text = "[ON]  God Mode"
            }
            Else {
                Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-god-mode.ps1") -NoDialog
                $CbGodMode.Text = "[OFF] God Mode (Default)"
            }
        })

    $CbTakeOwnership.Add_Click( {
            If ($CbTakeOwnership.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-take-ownership-context-menu.reg") -NoDialog
                $CbTakeOwnership.Text = "[ON]  Take Ownership menu"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-take-ownership-context-menu.reg") -NoDialog
                $CbTakeOwnership.Text = "[OFF] Take Ownership... (D.)"
            }
        })

    $CbShutdownPCShortcut.Add_Click( {
            If ($CbShutdownPCShortcut.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-shutdown-pc-shortcut.ps1") -NoDialog
                $CbShutdownPCShortcut.Text = "[ON]  Shutdown PC shortcut"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-shutdown-pc-shortcut.ps1") -NoDialog
                $CbShutdownPCShortcut.Text = "[OFF] Shutdown PC... (Default)"
            }
        })

    $InstallDrivers.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("install-drivers-updaters.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $InstallGamingDependencies.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("install-gaming-dependencies.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $InstallSelected.Add_Click( {
            $AppsSelected = @{
                WingetApps     = [System.Collections.ArrayList]@()
                MSStoreApps    = [System.Collections.ArrayList]@()
                ChocolateyApps = [System.Collections.ArrayList]@()
                WSLDistros     = [System.Collections.ArrayList]@()
            }

            If ($InstallBraveBrowser.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("BraveSoftware.BraveBrowser")
                $InstallBraveBrowser.CheckState = "Unchecked"
            }

            If ($InstallGoogleChrome.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Google.Chrome")
                $InstallGoogleChrome.CheckState = "Unchecked"
            }

            If ($InstallMozillaFirefox.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Mozilla.Firefox")
                $InstallMozillaFirefox.CheckState = "Unchecked"
            }

            If ($Install7Zip.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("7zip.7zip")
                $Install7Zip.CheckState = "Unchecked"
            }

            If ($InstallWinRar.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("RARLab.WinRAR")
                $InstallWinRar.CheckState = "Unchecked"
            }

            If ($InstallLibreOffice.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("LibreOffice.LibreOffice")
                $InstallLibreOffice.CheckState = "Unchecked"
            }

            If ($InstallOnlyOffice.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("ONLYOFFICE.DesktopEditors")
                $InstallOnlyOffice.CheckState = "Unchecked"
            }

            If ($InstallPowerBi.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.PowerBI")
                $InstallPowerBi.CheckState = "Unchecked"
            }

            If ($InstallZotero.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Zotero.Zotero")
                $InstallZotero.CheckState = "Unchecked"
            }

            If ($InstallHamachi.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("LogMeIn.Hamachi")
                $InstallHamachi.CheckState = "Unchecked"
            }

            If ($InstallRadminVpn.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Radmin.VPN")
                $InstallRadminVpn.CheckState = "Unchecked"
            }

            If ($InstallTwilioAuthy.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Twilio.Authy")
                $InstallTwilioAuthy.CheckState = "Unchecked"
            }

            If ($InstallWindowsTerminal.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.WindowsTerminal")
                $InstallWindowsTerminal.CheckState = "Unchecked"
            }

            If ($InstallNerdFonts.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("install-nerd-fonts.ps1")
                }
                $InstallNerdFonts.CheckState = "Unchecked"
            }

            If ($InstallGitGnupgSshSetup.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("git-gnupg-ssh-keys-setup.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
                }
                Else {
                    $AppsSelected.WingetApps.AddRange(@("Git.Git", "GnuPG.GnuPG")) # Installed before inside the script
                }
                $InstallGitGnupgSshSetup.CheckState = "Unchecked"
            }

            If ($InstallAdb.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("adb")
                $InstallAdb.CheckState = "Unchecked"
            }

            If ($InstallAndroidStudio.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Google.AndroidStudio")
                $InstallAndroidStudio.CheckState = "Unchecked"
            }

            If ($InstallDockerDesktop.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Docker.DockerDesktop")
                $InstallDockerDesktop.CheckState = "Unchecked"
            }

            If ($InstallInsomnia.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Insomnia.Insomnia")
                $InstallInsomnia.CheckState = "Unchecked"
            }

            If ($InstallJavaJdks.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.AddRange(@("EclipseAdoptium.Temurin.8", "EclipseAdoptium.Temurin.11", "EclipseAdoptium.Temurin.18"))
                $InstallJavaJdks.CheckState = "Unchecked"
            }

            If ($InstallJavaJre.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Oracle.JavaRuntimeEnvironment")
                $InstallJavaJre.CheckState = "Unchecked"
            }

            If ($InstallMySql.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Oracle.MySQL")
                $InstallMySql.CheckState = "Unchecked"
            }

            If ($InstallNodeJs.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("OpenJS.NodeJS")
                $InstallNodeJs.CheckState = "Unchecked"
            }

            If ($InstallNodeJsLts.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("OpenJS.NodeJSLTS")
                $InstallNodeJsLts.CheckState = "Unchecked"
            }

            If ($InstallPostgreSql.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("PostgreSQL.PostgreSQL")
                $InstallPostgreSql.CheckState = "Unchecked"
            }

            If ($InstallPython3.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Python.Python.3")
                $InstallPython3.CheckState = "Unchecked"
            }

            If ($InstallPythonAnaconda3.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Anaconda.Anaconda3")
                $InstallPythonAnaconda3.CheckState = "Unchecked"
            }

            If ($InstallRuby.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("RubyInstallerTeam.Ruby")
                $InstallRuby.CheckState = "Unchecked"
            }

            If ($InstallRubyMsys.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("RubyInstallerTeam.RubyWithDevKit")
                $InstallRubyMsys.CheckState = "Unchecked"
            }

            If ($InstallRustGnu.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Rustlang.Rust.GNU")
                $InstallRustGnu.CheckState = "Unchecked"
            }

            If ($InstallRustMsvc.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Rustlang.Rust.MSVC")
                $InstallRustMsvc.CheckState = "Unchecked"
            }

            If ($InstallGimp.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("GIMP.GIMP")
                $InstallGimp.CheckState = "Unchecked"
            }

            If ($InstallInkscape.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Inkscape.Inkscape")
                $InstallInkscape.CheckState = "Unchecked"
            }

            If ($InstallIrfanView.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("IrfanSkiljan.IrfanView")
                $InstallIrfanView.CheckState = "Unchecked"
            }

            If ($InstallKrita.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("KDE.Krita")
                $InstallKrita.CheckState = "Unchecked"
            }

            If ($InstallPaintNet.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("paint.net")
                $InstallPaintNet.CheckState = "Unchecked"
            }

            If ($InstallShareX.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("ShareX.ShareX")
                $InstallShareX.CheckState = "Unchecked"
            }

            If ($InstallAtom.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("GitHub.Atom")
                $InstallAtom.CheckState = "Unchecked"
            }

            If ($InstallNotepadPlusPlus.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Notepad++.Notepad++")
                $InstallNotepadPlusPlus.CheckState = "Unchecked"
            }

            If ($InstallVSCode.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.VisualStudioCode")
                $InstallVSCode.CheckState = "Unchecked"
            }

            If ($InstallVSCodium.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("VSCodium.VSCodium")
                $InstallVSCodium.CheckState = "Unchecked"
            }

            If ($InstallDropbox.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Dropbox.Dropbox")
                $InstallDropbox.CheckState = "Unchecked"
            }

            If ($InstallGoogleDrive.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Google.Drive")
                $InstallGoogleDrive.CheckState = "Unchecked"
            }

            If ($InstallBalenaEtcher.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Balena.Etcher")
                $InstallBalenaEtcher.CheckState = "Unchecked"
            }

            If ($InstallRufus.CheckState -eq "Checked") {
                $AppsSelected.MSStoreApps.Add("9PC3H3V7Q9CH")
                $InstallRufus.CheckState = "Unchecked"
            }

            If ($InstallVentoy.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("ventoy")
                $InstallVentoy.CheckState = "Unchecked"
            }

            If ($InstallNotion.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Notion.Notion")
                $InstallNotion.CheckState = "Unchecked"
            }

            If ($InstallObsidian.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Obsidian.Obsidian")
                $InstallObsidian.CheckState = "Unchecked"
            }

            If ($InstallCpuZ.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("CPUID.CPU-Z")
                $InstallCpuZ.CheckState = "Unchecked"
            }

            If ($InstallCrystalDiskInfo.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("CrystalDewWorld.CrystalDiskInfo")
                $InstallCrystalDiskInfo.CheckState = "Unchecked"
            }

            If ($InstallCrystalDiskMark.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("CrystalDewWorld.CrystalDiskMark")
                $InstallCrystalDiskMark.CheckState = "Unchecked"
            }

            If ($InstallGpuZ.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("TechPowerUp.GPU-Z")
                $InstallGpuZ.CheckState = "Unchecked"
            }

            If ($InstallNVCleanstall.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("TechPowerUp.NVCleanstall")
                $InstallNVCleanstall.CheckState = "Unchecked"
            }

            If ($InstallWSLgOrPreview.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("install-wslg-or-preview.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
                }
                Else {
                    $AppsSelected.MSStoreApps.Add("9P9TQF7MRM4R")
                }
                $InstallWSLgOrPreview.CheckState = "Unchecked"
            }

            If ($InstallArchWSL.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("install-archwsl.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
                }
                Else {
                    $AppsSelected.WSLDistros.Add("Arch")
                }
                $InstallArchWSL.CheckState = "Unchecked"
            }

            If ($InstallDebian.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    $AppsSelected.WSLDistros.Add("Debian")
                }
                $InstallDebian.CheckState = "Unchecked"
            }

            If ($InstallKaliLinux.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("kali-linux")
                $InstallKaliLinux.CheckState = "Unchecked"
            }

            If ($InstallOpenSuse.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("openSUSE-42")
                $InstallOpenSuse.CheckState = "Unchecked"
            }

            If ($InstallSles.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("SLES-12")
                $InstallSles.CheckState = "Unchecked"
            }

            If ($InstallUbuntu.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu")
                $InstallUbuntu.CheckState = "Unchecked"
            }

            If ($InstallUbuntu16Lts.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu-16.04")
                $InstallUbuntu16Lts.CheckState = "Unchecked"
            }

            If ($InstallUbuntu18Lts.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu-18.04")
                $InstallUbuntu18Lts.CheckState = "Unchecked"
            }

            If ($InstallUbuntu20Lts.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu-20.04")
                $InstallUbuntu20Lts.CheckState = "Unchecked"
            }

            If ($InstallDiscord.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Discord.Discord")
                $InstallDiscord.CheckState = "Unchecked"
            }

            If ($InstallMSTeams.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.Teams")
                $InstallMSTeams.CheckState = "Unchecked"
            }

            If ($InstalRocketChat.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("RocketChat.RocketChat")
                $InstalRocketChat.CheckState = "Unchecked"
            }

            If ($InstallSlack.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("SlackTechnologies.Slack")
                $InstallSlack.CheckState = "Unchecked"
            }

            If ($InstallTelegramDesktop.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Telegram.TelegramDesktop")
                $InstallTelegramDesktop.CheckState = "Unchecked"
            }

            If ($InstallZoom.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Zoom.Zoom")
                $InstallZoom.CheckState = "Unchecked"
            }

            If ($InstallBorderlessGaming.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Codeusa.BorderlessGaming")
                $InstallBorderlessGaming.CheckState = "Unchecked"
            }

            If ($InstallEADesktop.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("ElectronicArts.EADesktop")
                $InstallEADesktop.CheckState = "Unchecked"
            }

            If ($InstallEpicGamesLauncher.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("EpicGames.EpicGamesLauncher")
                $InstallEpicGamesLauncher.CheckState = "Unchecked"
            }

            If ($InstallGogGalaxy.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("GOG.Galaxy")
                $InstallGogGalaxy.CheckState = "Unchecked"
            }

            If ($InstallSteam.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Valve.Steam")
                $InstallSteam.CheckState = "Unchecked"
            }

            If ($InstallUbisoftConnect.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Ubisoft.Connect")
                $InstallUbisoftConnect.CheckState = "Unchecked"
            }

            If ($InstallAnyDesk.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("AnyDeskSoftwareGmbH.AnyDesk")
                $InstallAnyDesk.CheckState = "Unchecked"
            }

            If ($InstallParsec.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Parsec.Parsec")
                $InstallParsec.CheckState = "Unchecked"
            }

            If ($InstallScrCpy.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("scrcpy")
                $InstallScrCpy.CheckState = "Unchecked"
            }

            If ($InstallTeamViewer.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("TeamViewer.TeamViewer")
                $InstallTeamViewer.CheckState = "Unchecked"
            }

            If ($InstallHandBrake.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("HandBrake.HandBrake")
                $InstallHandBrake.CheckState = "Unchecked"
            }

            If ($InstallObsStudio.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("OBSProject.OBSStudio")
                $InstallObsStudio.CheckState = "Unchecked"
            }

            If ($InstallStreamlabsObs.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Streamlabs.StreamlabsOBS")
                $InstallStreamlabsObs.CheckState = "Unchecked"
            }

            If ($InstallMpcHc.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("clsid2.mpc-hc")
                $InstallMpcHc.CheckState = "Unchecked"
            }

            If ($InstallSpotify.CheckState -eq "Checked") {
                $AppsSelected.MSStoreApps.Add("9NCBCSZSJRSB")
                $InstallSpotify.CheckState = "Unchecked"
            }

            If ($InstallVlc.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("VideoLAN.VLC")
                $InstallVlc.CheckState = "Unchecked"
            }

            If ($InstallqBittorrent.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("qBittorrent.qBittorrent")
                $InstallqBittorrent.CheckState = "Unchecked"
            }

            If ($InstallCemu.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("cemu")
                $InstallCemu.CheckState = "Unchecked"
            }

            If ($InstallDolphin.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("DolphinEmulator.Dolphin")
                $InstallDolphin.CheckState = "Unchecked"
            }

            If ($InstallKegaFusion.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("kega-fusion")
                $InstallKegaFusion.CheckState = "Unchecked"
            }

            If ($InstallMGba.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("JeffreyPfau.mGBA")
                $InstallMGba.CheckState = "Unchecked"
            }

            If ($InstallPCSX2.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("pcsx2.portable")
                $InstallPCSX2.CheckState = "Unchecked"
            }

            If ($InstallPPSSPP.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("PPSSPPTeam.PPSSPP")
                $InstallPPSSPP.CheckState = "Unchecked"
            }

            If ($InstallProject64.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Project64.Project64.Dev")
                $InstallProject64.CheckState = "Unchecked"
            }

            If ($InstallRetroArch.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("retroarch")
                $InstallRetroArch.CheckState = "Unchecked"
            }

            If ($InstallSnes9x.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("snes9x")
                $InstallSnes9x.CheckState = "Unchecked"
            }

            If (!($Script:UninstallSwitch)) {
                If ($AppsSelected.WingetApps) {
                    Install-Software -Name "Apps from selection" -Packages $AppsSelected.WingetApps
                }
                If ($AppsSelected.MSStoreApps) {
                    Install-Software -Name "Apps from selection" -Packages $AppsSelected.MSStoreApps -ViaMSStore
                }
                If ($AppsSelected.ChocolateyApps) {
                    Install-Software -Name "Apps from selection" -Packages $AppsSelected.ChocolateyApps -ViaChocolatey
                }
                If ($AppsSelected.WSLDistros) {
                    Install-Software -Name "Apps from selection" -Packages $AppsSelected.WSLDistros -ViaWSL
                }
            }
            Else {
                If ($AppsSelected.WingetApps) {
                    Uninstall-Software -Name "Apps from selection" -Packages $AppsSelected.WingetApps
                }
                If ($AppsSelected.MSStoreApps) {
                    Uninstall-Software -Name "Apps from selection" -Packages $AppsSelected.MSStoreApps -ViaMSStore
                }
                If ($AppsSelected.ChocolateyApps) {
                    Uninstall-Software -Name "Apps from selection" -Packages $AppsSelected.ChocolateyApps -ViaChocolatey
                }
                If ($AppsSelected.WSLDistros) {
                    Uninstall-Software -Name "Apps from selection" -Packages $AppsSelected.WSLDistros -ViaWSL
                }
            }
        })

    $UninstallMode.Add_Click( {
            If ($UninstallSwitch) {
                $Script:UninstallSwitch = $false
                $InstallSelected.Text = "Install Selected"
                $UninstallMode.Text = "[OFF] Uninstall Mode"
            }
            Else {
                $Script:UninstallSwitch = $true
                $InstallSelected.Text = "Uninstall Selected"
                $UninstallMode.Text = "[ON]  Uninstall Mode"
            }
        })

    [void]$Form.ShowDialog() # Show the Window
    $Form.Dispose() # When done, dispose of the GUI
}

function Main() {
    Clear-Host
    Request-AdminPrivilege # Check admin rights
    Get-ChildItem -Recurse $PSScriptRoot\*.ps*1 | Unblock-File

    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"download-web-file.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"get-hardware-info.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"ui-helper.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"open-file.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"install-software.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"set-console-style.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"set-script-policy.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"show-dialog-window.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"start-logging.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"title-templates.psm1" -Force

    Set-ConsoleStyle            # Makes the console look cooler
    Start-Logging -File (Split-Path -Path $PSCommandPath -Leaf).Split(".")[0]
    Write-Caption "$((Split-Path -Path $PSCommandPath -Leaf).Split('.')[0]) v$((Get-Item "$(Split-Path -Path $PSCommandPath -Leaf)").LastWriteTimeUtc | Get-Date -Format "yyyy-MM-dd")"
    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Root Folder $PSScriptRoot"
    Unlock-ScriptUsage
    Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts "install-package-managers.ps1" -NoDialog # Install Winget and Chocolatey at the beginning
    Write-ScriptLogo            # Thanks Figlet
    Show-GUI                    # Load the GUI

    Write-Verbose "Restart: $Script:NeedRestart"
    If ($Script:NeedRestart) {
        Request-PcRestart       # Prompt options to Restart the PC
    }
    Stop-Logging
    Block-ScriptUsage
}

Main