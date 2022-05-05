function Request-AdminPrivilege() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

# https://docs.microsoft.com/en-us/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.1
# Adapted majorly from https://github.com/ChrisTitusTech/win10script and https://github.com/Sycnex/Windows10Debloater
function Show-GUI() {
    Set-GUILayout # Load the GUI Layout

    $Script:NeedRestart = $false
    $DoneTitle = "Information"
    $DoneMessage = "Process Completed!"

    # Main Window:
    $Form = New-Form -Width ($FormWidth + 15) -Height $FormHeight -Text "Win 10+ S. D. Tools (LeDragoX) | $(Get-SystemSpec)" -BackColor "$WinDark" -Maximize $false # Loading the specs takes longer to load the script

    # Window Icon:
    $Form = New-FormIcon -Form $Form -ImageLocation "$PSScriptRoot\src\assets\windows-11-logo.png"

    # Panels to put Labels and Buttons
    $CurrentPanelIndex = 0
    $Panel1 = New-Panel -Width $PanelWidth -Height ($FormHeight - ($FormHeight * 0.1955)) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $Panel2 = New-Panel -Width $PanelWidth -Height ($FormHeight * 1.60) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY ($Panel1.Location.Y + $Panel1.Height)
    $CurrentPanelIndex++
    $Panel3 = New-Panel -Width ($PanelWidth - 15) -Height ($FormHeight * 2.40) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $CurrentPanelIndex++
    $Panel4 = New-Panel -Width ($PanelWidth - 15) -Height ($FormHeight * 2.40) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $CurrentPanelIndex++
    $Panel5 = New-Panel -Width $PanelWidth -Height ($FormHeight * 2.40) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    # Panel to put more Panels
    $FullPanel = New-Panel -Width (($PanelWidth * ($CurrentPanelIndex + 1))) -Height $FormHeight -LocationX 0 -LocationY 0 -HasVerticalScroll

    # Panels 1, 2, 3-4-5 ~> Title Label
    $TitleLabel1 = New-Label -Text "System Tweaks" -Width $LabelWidth -Height $TitleLabelHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $FontSize4 -FontStyle "Bold" -ForeColor $WinBlue
    $TitleLabel2 = New-Label -Text "Customize Tweaks" -Width $LabelWidth -Height $TitleLabelHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $FontSize4 -FontStyle "Bold" -ForeColor $WinBlue
    $TitleLabel3 = New-Label -Text "Software Install" -Width $LabelWidth -Height $TitleLabelHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $FontSize4 -FontStyle "Bold" -ForeColor $WinBlue

    # Panel 1, 3-4-5 ~> Caption Label
    $CaptionLabel1_1 = New-Label -Text "($((Split-Path -Path $PSCommandPath -Leaf).Split('.')[0]) v$((Get-Item "$(Split-Path -Path $PSCommandPath -Leaf)").LastWriteTimeUtc | Get-Date -Format "yyyy-MM-dd"))" -Width $PanelWidth -Height $CaptionLabelHeight -LocationX 0 -LocationY ($FirstButtonY - 27) -FontSize $FontSize1 -ForeColor $Purple
    $CaptionLabel1_2 = New-Label -Text "Package Managers: Winget and Chocolatey" -Width ($CaptionLabelWidth * 1.25) -Height $CaptionLabelHeight -LocationX (($PanelWidth * 2) - ($PanelWidth * 0.10)) -LocationY ($FirstButtonY - 27) -FontSize $FontSize1 -ForeColor $Purple

    # Panel 1 ~> Big Button
    $ApplyTweaks = New-Button -Text "✔ Apply Tweaks" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -ForeColor $WinBlue

    # Panel 2 ~> Big Button
    $NextYLocation = $ApplyTweaks.Location.Y + $ApplyTweaks.Height + $DistanceBetweenButtons
    $UndoTweaks = New-Button -Text "❌ Undo Tweaks" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1 -ForeColor $WarningColor

    # Panel 1 ~> Small Buttons
    $NextYLocation = $UndoTweaks.Location.Y + $UndoTweaks.Height + $DistanceBetweenButtons
    $RemoveXbox = New-Button -Text "Remove and Disable Xbox" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1 -ForeColor $WarningColor

    $NextYLocation = $RemoveXbox.Location.Y + $RemoveXbox.Height + $DistanceBetweenButtons
    $RepairWindows = New-Button -Text "Repair Windows" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $RepairWindows.Location.Y + $RepairWindows.Height + $DistanceBetweenButtons
    $InstallOneDrive = New-Button -Text "Install OneDrive" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $InstallOneDrive.Location.Y + $InstallOneDrive.Height + $DistanceBetweenButtons
    $ReinstallBloatApps = New-Button -Text "Reinstall Pre-Installed Apps" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ReinstallBloatApps.Location.Y + $ReinstallBloatApps.Height + $DistanceBetweenButtons
    $ShowDebloatInfo = New-Button -Text "Show Debloat Info" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ShowDebloatInfo.Location.Y + $ShowDebloatInfo.Height + $DistanceBetweenButtons
    # Image Logo from the Script
    $PictureBox1 = New-PictureBox -ImageLocation "$PSScriptRoot\src\assets\script-logo.png" -Width 150 -Height 150 -LocationX (($PanelWidth * 0.72) - 150) -LocationY $NextYLocation -SizeMode 'Zoom'

    # Panel 2 ~> Small Buttons
    $DarkThemeCheckBox = New-CheckBox -Text "Use Dark Theme" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize1

    $NextYLocation = $DarkThemeCheckBox.Location.Y + $DarkThemeCheckBox.Height + $DistanceBetweenButtons
    $BackgroundsAppsCheckBox = New-CheckBox -Text "Enable Background Apps" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $BackgroundsAppsCheckBox.Location.Y + $BackgroundsAppsCheckBox.Height + $DistanceBetweenButtons
    $ClipboardHistoryCheckBox = New-CheckBox -Text "Enable Clipboard History" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ClipboardHistoryCheckBox.Location.Y + $ClipboardHistoryCheckBox.Height + $DistanceBetweenButtons
    $CortanaCheckBox = New-CheckBox -Text "Enable Cortana" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $CortanaCheckBox.Location.Y + $CortanaCheckBox.Height + $DistanceBetweenButtons
    $OldVolumeControlCheckBox = New-CheckBox -Text "Enable Old Volume Control" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $OldVolumeControlCheckBox.Location.Y + $OldVolumeControlCheckBox.Height + $DistanceBetweenButtons
    $SearchIdxCheckBox = New-CheckBox -Text "Enable Search Indexing" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $SearchIdxCheckBox.Location.Y + $SearchIdxCheckBox.Height + $DistanceBetweenButtons
    $TelemetryCheckBox = New-CheckBox -Text "Enable Telemetry" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $TelemetryCheckBox.Location.Y + $TelemetryCheckBox.Height + $DistanceBetweenButtons
    $XboxGameBarAndDVRCheckBox = New-CheckBox -Text "Enable Xbox GameBar/DVR" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Big Button
    $InstallDrivers = New-Button -Text "Install CPU/GPU Drivers Updaters" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -ForeColor $WinBlue

    # --- Panel 3 ~> Caption Label
    $NextYLocation = $InstallDrivers.Location.Y + $InstallDrivers.Height + $DistanceBetweenButtons
    $CaptionLabel3_1 = New-Label -Text "Web Browsers" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_1.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $BraveBrowser = New-CheckBox -Text "Brave Browser" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $BraveBrowser.Location.Y + $BraveBrowser.Height + $DistanceBetweenButtons
    $GoogleChrome = New-CheckBox -Text "Google Chrome" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GoogleChrome.Location.Y + $GoogleChrome.Height + $DistanceBetweenButtons
    $MozillaFirefox = New-CheckBox -Text "Mozilla Firefox" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $MozillaFirefox.Location.Y + $MozillaFirefox.Height + $DistanceBetweenButtons
    $CaptionLabel3_2 = New-Label -Text "File Compression" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_2.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $7Zip = New-CheckBox -Text "7-Zip" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $7Zip.Location.Y + $7Zip.Height + $DistanceBetweenButtons
    $WinRAR = New-CheckBox -Text "WinRAR (Trial)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $WinRAR.Location.Y + $WinRAR.Height + $DistanceBetweenButtons
    $CaptionLabel3_3 = New-Label -Text "Document Editors" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_3.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $LibreOffice = New-CheckBox -Text "LibreOffice" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $LibreOffice.Location.Y + $LibreOffice.Height + $DistanceBetweenButtons
    $OnlyOffice = New-CheckBox -Text "ONLYOFFICE DesktopEditors" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $OnlyOffice.Location.Y + $OnlyOffice.Height + $DistanceBetweenButtons
    $PowerBI = New-CheckBox -Text "Power BI" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # --- Panel 3 ~> Caption Label
    $NextYLocation = $PowerBI.Location.Y + $PowerBI.Height + $DistanceBetweenButtons
    $CaptionLabel3_4 = New-Label -Text "Academic Research" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_4.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Zotero = New-CheckBox -Text "Zotero" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $Zotero.Location.Y + $Zotero.Height + $DistanceBetweenButtons
    $CaptionLabel3_5 = New-Label -Text "Networking" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_5.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Hamachi = New-CheckBox -Text "Hamachi (LAN)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Hamachi.Location.Y + $Hamachi.Height + $DistanceBetweenButtons
    $RadminVPN = New-CheckBox -Text "Radmin VPN (LAN)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $RadminVPN.Location.Y + $RadminVPN.Height + $DistanceBetweenButtons
    $CaptionLabel3_6 = New-Label -Text "2-Factor Authentication" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_6.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $TwilioAuthy = New-CheckBox -Text "Twilio Authy" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # --- Panel 3 ~> Caption Label
    $NextYLocation = $TwilioAuthy.Location.Y + $TwilioAuthy.Height + $DistanceBetweenButtons
    $CaptionLabel3_7 = New-Label -Text "⌨ Development (Windows)" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_7.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $WindowsTerminal = New-CheckBox -Text "Windows Terminal" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $WindowsTerminal.Location.Y + $WindowsTerminal.Height + $DistanceBetweenButtons
    $NerdFonts = New-CheckBox -Text "Install Nerd Fonts" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1 -ForeColor $WinBlue

    $NextYLocation = $NerdFonts.Location.Y + $NerdFonts.Height + $DistanceBetweenButtons
    $GitGnupgSshSetup = New-CheckBox -Text "Git + GnuPG + SSH (Setup)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1 -ForeColor $WinBlue

    $NextYLocation = $GitGnupgSshSetup.Location.Y + $GitGnupgSshSetup.Height + $DistanceBetweenButtons
    $ADB = New-CheckBox -Text "Android Debug Bridge (ADB)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ADB.Location.Y + $ADB.Height + $DistanceBetweenButtons
    $AndroidStudio = New-CheckBox -Text "Android Studio" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $AndroidStudio.Location.Y + $AndroidStudio.Height + $DistanceBetweenButtons
    $DockerDesktop = New-CheckBox -Text "Docker Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DockerDesktop.Location.Y + $DockerDesktop.Height + $DistanceBetweenButtons
    $Insomnia = New-CheckBox -Text "Insomnia" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Insomnia.Location.Y + $Insomnia.Height + $DistanceBetweenButtons
    $JavaJDKs = New-CheckBox -Text "Java - Adoptium JDK 8/11/18" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $JavaJDKs.Location.Y + $JavaJDKs.Height + $DistanceBetweenButtons
    $JavaJRE = New-CheckBox -Text "Java - Oracle JRE" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $JavaJRE.Location.Y + $JavaJRE.Height + $DistanceBetweenButtons
    $MySQL = New-CheckBox -Text "MySQL" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $MySQL.Location.Y + $MySQL.Height + $DistanceBetweenButtons
    $NodeJs = New-CheckBox -Text "NodeJS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $NodeJs.Location.Y + $NodeJs.Height + $DistanceBetweenButtons
    $NodeJsLTS = New-CheckBox -Text "NodeJS LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $NodeJsLTS.Location.Y + $NodeJsLTS.Height + $DistanceBetweenButtons
    $PostgreSQL = New-CheckBox -Text "PostgreSQL" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $PostgreSQL.Location.Y + $PostgreSQL.Height + $DistanceBetweenButtons
    $Python3 = New-CheckBox -Text "Python 3" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Python3.Location.Y + $Python3.Height + $DistanceBetweenButtons
    $PythonAnaconda3 = New-CheckBox -Text "Python - Anaconda3" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $PythonAnaconda3.Location.Y + $PythonAnaconda3.Height + $DistanceBetweenButtons
    $Ruby = New-CheckBox -Text "Ruby" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ruby.Location.Y + $Ruby.Height + $DistanceBetweenButtons
    $RubyMSYS = New-CheckBox -Text "Ruby (MSYS2)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $RubyMSYS.Location.Y + $RubyMSYS.Height + $DistanceBetweenButtons
    $RustGNU = New-CheckBox -Text "Rust (GNU)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $RustGNU.Location.Y + $RustGNU.Height + $DistanceBetweenButtons
    $RustMSVC = New-CheckBox -Text "Rust (MSVC)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Big Button
    $InstallSelected = New-Button -Text "Install Selected" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize1 -FontStyle "Bold" -ForeColor $LightGray

    $NextYLocation = $InstallSelected.Location.Y + $InstallSelected.Height + $DistanceBetweenButtons
    $UninstallMode = New-Button -Text "[OFF] Uninstall Mode" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1 -FontStyle "Bold" -ForeColor $LightGray

    # --- Panel 4 ~> Caption Label
    $NextYLocation = $UninstallMode.Location.Y + $UninstallMode.Height + $DistanceBetweenButtons
    $CaptionLabel4_1 = New-Label -Text "Image Tools" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_1.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Gimp = New-CheckBox -Text "GIMP" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Gimp.Location.Y + $Gimp.Height + $DistanceBetweenButtons
    $Inkscape = New-CheckBox -Text "Inkscape" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Inkscape.Location.Y + $Inkscape.Height + $DistanceBetweenButtons
    $IrfanView = New-CheckBox -Text "IrfanView" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $IrfanView.Location.Y + $IrfanView.Height + $DistanceBetweenButtons
    $Krita = New-CheckBox -Text "Krita" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Krita.Location.Y + $Krita.Height + $DistanceBetweenButtons
    $PaintNet = New-CheckBox -Text "Paint.NET" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $PaintNet.Location.Y + $PaintNet.Height + $DistanceBetweenButtons
    $ShareX = New-CheckBox -Text "ShareX (Screenshots/GIFs)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $ShareX.Location.Y + $ShareX.Height + $DistanceBetweenButtons
    $CaptionLabel4_2 = New-Label -Text "Text Editors / IDEs" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_2.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Atom = New-CheckBox -Text "Atom" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Atom.Location.Y + $Atom.Height + $DistanceBetweenButtons
    $NotepadPlusPlus = New-CheckBox -Text "Notepad++" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $NotepadPlusPlus.Location.Y + $NotepadPlusPlus.Height + $DistanceBetweenButtons
    $VSCode = New-CheckBox -Text "VS Code" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $VSCode.Location.Y + $VSCode.Height + $DistanceBetweenButtons
    $VSCodium = New-CheckBox -Text "VS Codium" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $VSCodium.Location.Y + $VSCodium.Height + $DistanceBetweenButtons
    $CaptionLabel4_3 = New-Label -Text "Cloud Storage" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_3.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Dropbox = New-CheckBox -Text "Dropbox" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Dropbox.Location.Y + $Dropbox.Height + $DistanceBetweenButtons
    $GoogleDrive = New-CheckBox -Text "Google Drive" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # --- Panel 4 ~> Caption Label
    $NextYLocation = $GoogleDrive.Location.Y + $GoogleDrive.Height + $DistanceBetweenButtons
    $CaptionLabel4_4 = New-Label -Text "Bootable USB" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_4.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $BalenaEtcher = New-CheckBox -Text "Etcher" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $BalenaEtcher.Location.Y + $BalenaEtcher.Height + $DistanceBetweenButtons
    $Rufus = New-CheckBox -Text "Rufus" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Rufus.Location.Y + $Rufus.Height + $DistanceBetweenButtons
    $Ventoy = New-CheckBox -Text "Ventoy" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $Ventoy.Location.Y + $Ventoy.Height + $DistanceBetweenButtons
    $CaptionLabel4_5 = New-Label -Text "Planning" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_5.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Notion = New-CheckBox -Text "Notion" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Notion.Location.Y + $Notion.Height + $DistanceBetweenButtons
    $Obsidian = New-CheckBox -Text "Obsidian" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $Obsidian.Location.Y + $Obsidian.Height + $DistanceBetweenButtons
    $CaptionLabel4_6 = New-Label -Text "⚒ Utilities" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_6.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $CPUZ = New-CheckBox -Text "CPU-Z" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $CPUZ.Location.Y + $CPUZ.Height + $DistanceBetweenButtons
    $CrystalDiskInfo = New-CheckBox -Text "Crystal Disk Info" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $CrystalDiskInfo.Location.Y + $CrystalDiskInfo.Height + $DistanceBetweenButtons
    $CrystalDiskMark = New-CheckBox -Text "Crystal Disk Mark" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $CrystalDiskMark.Location.Y + $CrystalDiskMark.Height + $DistanceBetweenButtons
    $GPUZ = New-CheckBox -Text "GPU-Z" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GPUZ.Location.Y + $GPUZ.Height + $DistanceBetweenButtons
    $NVCleanstall = New-CheckBox -Text "NVCleanstall" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # --- Panel 4 ~> Caption Label
    $NextYLocation = $NVCleanstall.Location.Y + $NVCleanstall.Height + $DistanceBetweenButtons
    $CaptionLabel4_7 = New-Label -Text "⌨ Windows Subsystem For Linux" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_7.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $WSLgOrPreview = New-CheckBox -Text "WSLg / Preview (Win 10+)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1 -ForeColor $WinBlue

    $NextYLocation = $WSLgOrPreview.Location.Y + $WSLgOrPreview.Height + $DistanceBetweenButtons
    $ArchWSL = New-CheckBox -Text "ArchWSL (x64)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1 -ForeColor $WinBlue

    $NextYLocation = $ArchWSL.Location.Y + $ArchWSL.Height + $DistanceBetweenButtons
    $Debian = New-CheckBox -Text "Debian GNU/Linux" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Debian.Location.Y + $Debian.Height + $DistanceBetweenButtons
    $KaliLinux = New-CheckBox -Text "Kali Linux Rolling" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $KaliLinux.Location.Y + $KaliLinux.Height + $DistanceBetweenButtons
    $OpenSuse = New-CheckBox -Text "Open SUSE 42" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $OpenSuse.Location.Y + $OpenSuse.Height + $DistanceBetweenButtons
    $SLES = New-CheckBox -Text "SLES v12" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $SLES.Location.Y + $SLES.Height + $DistanceBetweenButtons
    $Ubuntu = New-CheckBox -Text "Ubuntu" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu.Location.Y + $Ubuntu.Height + $DistanceBetweenButtons
    $Ubuntu16LTS = New-CheckBox -Text "Ubuntu 16.04 LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu16LTS.Location.Y + $Ubuntu16LTS.Height + $DistanceBetweenButtons
    $Ubuntu18LTS = New-CheckBox -Text "Ubuntu 18.04 LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu18LTS.Location.Y + $Ubuntu18LTS.Height + $DistanceBetweenButtons
    $Ubuntu20LTS = New-CheckBox -Text "Ubuntu 20.04 LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Big Button
    $InstallGamingDependencies = New-Button -Text "Install Gaming Dependencies" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -ForeColor $WinBlue

    # --- Panel 5 ~> Caption Label
    $NextYLocation = $InstallGamingDependencies.Location.Y + $InstallGamingDependencies.Height + $DistanceBetweenButtons
    $CaptionLabel5_1 = New-Label -Text "Communication" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_1.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Discord = New-CheckBox -Text "Discord" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Discord.Location.Y + $Discord.Height + $DistanceBetweenButtons
    $MSTeams = New-CheckBox -Text "Microsoft Teams" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $MSTeams.Location.Y + $MSTeams.Height + $DistanceBetweenButtons
    $RocketChat = New-CheckBox -Text "Rocket Chat" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $RocketChat.Location.Y + $RocketChat.Height + $DistanceBetweenButtons
    $Slack = New-CheckBox -Text "Slack" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Slack.Location.Y + $Slack.Height + $DistanceBetweenButtons
    $TelegramDesktop = New-CheckBox -Text "Telegram Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $TelegramDesktop.Location.Y + $TelegramDesktop.Height + $DistanceBetweenButtons
    $Zoom = New-CheckBox -Text "Zoom" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Caption Label
    $NextYLocation = $Zoom.Location.Y + $Zoom.Height + $DistanceBetweenButtons
    $CaptionLabel5_2 = New-Label -Text "Gaming" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_2.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $BorderlessGaming = New-CheckBox -Text "Borderless Gaming" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $BorderlessGaming.Location.Y + $BorderlessGaming.Height + $DistanceBetweenButtons
    $EADesktop = New-CheckBox -Text "EA Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EADesktop.Location.Y + $EADesktop.Height + $DistanceBetweenButtons
    $EpicGamesLauncher = New-CheckBox -Text "Epic Games Launcher" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EpicGamesLauncher.Location.Y + $EpicGamesLauncher.Height + $DistanceBetweenButtons
    $GogGalaxy = New-CheckBox -Text "GOG Galaxy" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GogGalaxy.Location.Y + $GogGalaxy.Height + $DistanceBetweenButtons
    $Steam = New-CheckBox -Text "Steam" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Steam.Location.Y + $Steam.Height + $DistanceBetweenButtons
    $UbisoftConnect = New-CheckBox -Text "Ubisoft Connect" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Caption Label
    $NextYLocation = $UbisoftConnect.Location.Y + $UbisoftConnect.Height + $DistanceBetweenButtons
    $CaptionLabel5_3 = New-Label -Text "Remote Connection" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_3.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $AnyDesk = New-CheckBox -Text "AnyDesk" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $AnyDesk.Location.Y + $AnyDesk.Height + $DistanceBetweenButtons
    $Parsec = New-CheckBox -Text "Parsec" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Parsec.Location.Y + $Parsec.Height + $DistanceBetweenButtons
    $ScrCpy = New-CheckBox -Text "ScrCpy (Android)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ScrCpy.Location.Y + $ScrCpy.Height + $DistanceBetweenButtons
    $TeamViewer = New-CheckBox -Text "Team Viewer" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # --- Panel 5 ~> Caption Label
    $NextYLocation = $TeamViewer.Location.Y + $TeamViewer.Height + $DistanceBetweenButtons
    $CaptionLabel5_4 = New-Label -Text "Recording and Streaming" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_4.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $HandBrake = New-CheckBox -Text "HandBrake (Transcode)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $HandBrake.Location.Y + $HandBrake.Height + $DistanceBetweenButtons
    $ObsStudio = New-CheckBox -Text "OBS Studio" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ObsStudio.Location.Y + $ObsStudio.Height + $DistanceBetweenButtons
    $StreamlabsObs = New-CheckBox -Text "Streamlabs OBS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Caption Label
    $NextYLocation = $StreamlabsObs.Location.Y + $StreamlabsObs.Height + $DistanceBetweenButtons
    $CaptionLabel5_5 = New-Label -Text "Media Playing" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_5.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $MpcHc = New-CheckBox -Text "Media Player Classic H. C." -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $MpcHc.Location.Y + $MpcHc.Height + $DistanceBetweenButtons
    $Spotify = New-CheckBox -Text "Spotify" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Spotify.Location.Y + $Spotify.Height + $DistanceBetweenButtons
    $Vlc = New-CheckBox -Text "VLC" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Caption Label
    $NextYLocation = $Vlc.Location.Y + $Vlc.Height + $DistanceBetweenButtons
    $CaptionLabel5_6 = New-Label -Text "Torrent" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_6.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $qBittorrent = New-CheckBox -Text "qBittorrent" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # --- Panel 5 ~> Caption Label
    $NextYLocation = $qBittorrent.Location.Y + $qBittorrent.Height + $DistanceBetweenButtons
    $CaptionLabel5_7 = New-Label -Text "Emulation" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_7.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Cemu = New-CheckBox -Text "Cemu (Wii U)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Cemu.Location.Y + $Cemu.Height + $DistanceBetweenButtons
    $Dolphin = New-CheckBox -Text "Dolphin Stable (GC/Wii)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Dolphin.Location.Y + $Dolphin.Height + $DistanceBetweenButtons
    $KegaFusion = New-CheckBox -Text "Kega Fusion (Sega Genesis)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $KegaFusion.Location.Y + $KegaFusion.Height + $DistanceBetweenButtons
    $MGba = New-CheckBox -Text "mGBA (GBA)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $MGba.Location.Y + $MGba.Height + $DistanceBetweenButtons
    $PCSX2 = New-CheckBox -Text "PCSX2 Stable (PS2 | Portable)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $PCSX2.Location.Y + $PCSX2.Height + $DistanceBetweenButtons
    $PPSSPP = New-CheckBox -Text "PPSSPP (PSP)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $PPSSPP.Location.Y + $PPSSPP.Height + $DistanceBetweenButtons
    $Project64 = New-CheckBox -Text "Project64 Dev (N64)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Project64.Location.Y + $Project64.Height + $DistanceBetweenButtons
    $RetroArch = New-CheckBox -Text "RetroArch (All In One)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $RetroArch.Location.Y + $RetroArch.Height + $DistanceBetweenButtons
    $Snes9x = New-CheckBox -Text "Snes9x (SNES)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Add all Panels to the Form (Screen)
    $Form.Controls.AddRange(@($FullPanel))
    # Add Elements to each Panel
    $FullPanel.Controls.AddRange(@($CaptionLabel1_2))
    $FullPanel.Controls.AddRange(@($Panel1, $Panel2, $Panel3, $Panel4, $Panel5))
    $Panel1.Controls.AddRange(@($TitleLabel1, $CaptionLabel1_1, $ApplyTweaks, $UndoTweaks, $RemoveXbox, $RepairWindows, $InstallOneDrive, $ReinstallBloatApps, $ShowDebloatInfo, $PictureBox1))
    $Panel2.Controls.AddRange(@($TitleLabel2, $DarkThemeCheckBox, $BackgroundsAppsCheckBox, $ClipboardHistoryCheckBox, $CortanaCheckBox, $OldVolumeControlCheckBox, $SearchIdxCheckBox, $TelemetryCheckBox, $XboxGameBarAndDVRCheckBox))
    $Panel3.Controls.AddRange(@($InstallDrivers, $CaptionLabel3_1, $BraveBrowser, $GoogleChrome, $MozillaFirefox))
    $Panel3.Controls.AddRange(@($CaptionLabel3_2, $7Zip, $WinRAR))
    $Panel3.Controls.AddRange(@($CaptionLabel3_3, $LibreOffice, $OnlyOffice, $PowerBI))
    $Panel3.Controls.AddRange(@($CaptionLabel3_4, $Zotero))
    $Panel3.Controls.AddRange(@($CaptionLabel3_5, $Hamachi, $RadminVPN))
    $Panel3.Controls.AddRange(@($CaptionLabel3_6, $TwilioAuthy))
    $Panel3.Controls.AddRange(@($CaptionLabel3_7, $WindowsTerminal, $NerdFonts, $GitGnupgSshSetup, $ADB, $AndroidStudio, $DockerDesktop, $Insomnia, $JavaJDKs, $JavaJRE, $MySQL, $NodeJs, $NodeJsLTS, $PostgreSQL, $Python3, $PythonAnaconda3, $Ruby, $RubyMSYS, $RustGNU, $RustMSVC))
    $Panel4.Controls.AddRange(@($TitleLabel3, $InstallSelected, $UninstallMode, $CaptionLabel4_1, $Gimp, $Inkscape, $IrfanView, $Krita, $PaintNet, $ShareX))
    $Panel4.Controls.AddRange(@($CaptionLabel4_2, $Atom, $NotepadPlusPlus, $VSCode, $VSCodium))
    $Panel4.Controls.AddRange(@($CaptionLabel4_3, $Dropbox, $GoogleDrive))
    $Panel4.Controls.AddRange(@($CaptionLabel4_4, $BalenaEtcher, $Rufus, $Ventoy))
    $Panel4.Controls.AddRange(@($CaptionLabel4_5, $Notion, $Obsidian))
    $Panel4.Controls.AddRange(@($CaptionLabel4_6, $CPUZ, $CrystalDiskInfo, $CrystalDiskMark, $GPUZ, $NVCleanstall))
    $Panel4.Controls.AddRange(@($CaptionLabel4_7, $WSLgOrPreview, $ArchWSL, $Debian, $KaliLinux, $OpenSuse, $SLES, $Ubuntu, $Ubuntu16LTS, $Ubuntu18LTS, $Ubuntu20LTS))
    $Panel5.Controls.AddRange(@($InstallGamingDependencies, $CaptionLabel5_1, $Discord, $MSTeams, $RocketChat, $Slack, $TelegramDesktop, $Zoom))
    $Panel5.Controls.AddRange(@($CaptionLabel5_2, $BorderlessGaming, $EADesktop, $EpicGamesLauncher, $GogGalaxy, $Steam, $UbisoftConnect))
    $Panel5.Controls.AddRange(@($CaptionLabel5_3, $AnyDesk, $Parsec, $ScrCpy, $TeamViewer))
    $Panel5.Controls.AddRange(@($CaptionLabel5_4, $HandBrake, $ObsStudio, $StreamlabsObs))
    $Panel5.Controls.AddRange(@($CaptionLabel5_5, $MpcHc, $Spotify, $Vlc))
    $Panel5.Controls.AddRange(@($CaptionLabel5_6, $qBittorrent))
    $Panel5.Controls.AddRange(@($CaptionLabel5_7, $Cemu, $Dolphin, $KegaFusion, $MGba, $PCSX2, $PPSSPP, $Project64, $RetroArch, $Snes9x))

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
                $DarkThemeCheckBox.Text = "[ON] ⚫ Use Dark Theme"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("use-light-theme.reg") -NoDialog
                $DarkThemeCheckBox.Text = "[OFF] ☀ Use Dark Theme"
            }
        })

    $BackgroundsAppsCheckBox.Add_Click( {
            If ($BackgroundsAppsCheckBox.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-bg-apps.reg") -NoDialog
                $BackgroundsAppsCheckBox.Text = "[ON] Background Apps"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-bg-apps.reg") -NoDialog
                $BackgroundsAppsCheckBox.Text = "[OFF] Background Apps"
            }
        })

    $ClipboardHistoryCheckBox.Add_Click( {
            If ($ClipboardHistoryCheckBox.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-clipboard-history.reg") -NoDialog
                $ClipboardHistoryCheckBox.Text = "[ON] Clipboard History"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-clipboard-history.reg") -NoDialog
                $ClipboardHistoryCheckBox.Text = "[OFF] Clipboard History"
            }
        })

    $CortanaCheckBox.Add_Click( {
            If ($CortanaCheckBox.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-cortana.reg") -NoDialog
                $CortanaCheckBox.Text = "[ON] Cortana"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-cortana.reg") -NoDialog
                $CortanaCheckBox.Text = "[OFF] Cortana"
            }
        })

    $OldVolumeControlCheckBox.Add_Click( {
            If ($OldVolumeControlCheckBox.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-old-volume-control.reg") -NoDialog
                $OldVolumeControlCheckBox.Text = "[ON] Old Volume Control"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-old-volume-control.reg") -NoDialog
                $OldVolumeControlCheckBox.Text = "[OFF] Old Volume Control"
            }
        })

    $SearchIdxCheckBox.Add_Click( {
            If ($SearchIdxCheckBox.CheckState -eq "Checked") {
                Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-search-idx.ps1") -NoDialog
                $SearchIdxCheckBox.Text = "[ON] Search Indexing"
            }
            Else {
                Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-search-idx.ps1") -NoDialog
                $SearchIdxCheckBox.Text = "[OFF] Search Indexing"
            }
        })

    $TelemetryCheckBox.Add_Click( {
            If ($TelemetryCheckBox.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-telemetry.reg") -NoDialog
                $TelemetryCheckBox.Text = "[ON] Telemetry"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-telemetry.reg") -NoDialog
                $TelemetryCheckBox.Text = "[OFF] Telemetry"
            }
        })

    $XboxGameBarAndDVRCheckBox.Add_Click( {
            If ($XboxGameBarAndDVRCheckBox.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-game-bar-dvr.reg") -NoDialog
                $XboxGameBarAndDVRCheckBox.Text = "[ON] Xbox GameBar/DVR"
            }
            Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-game-bar-dvr.reg") -NoDialog
                $XboxGameBarAndDVRCheckBox.Text = "[OFF] Xbox GameBar/DVR"
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

            If ($BraveBrowser.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("BraveSoftware.BraveBrowser")
                $BraveBrowser.CheckState = "Unchecked"
            }

            If ($GoogleChrome.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Google.Chrome")
                $GoogleChrome.CheckState = "Unchecked"
            }

            If ($MozillaFirefox.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Mozilla.Firefox")
                $MozillaFirefox.CheckState = "Unchecked"
            }

            If ($7Zip.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("7zip.7zip")
                $7Zip.CheckState = "Unchecked"
            }

            If ($WinRAR.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("RARLab.WinRAR")
                $WinRAR.CheckState = "Unchecked"
            }

            If ($LibreOffice.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("LibreOffice.LibreOffice")
                $LibreOffice.CheckState = "Unchecked"
            }

            If ($OnlyOffice.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("ONLYOFFICE.DesktopEditors")
                $OnlyOffice.CheckState = "Unchecked"
            }

            If ($PowerBI.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.PowerBI")
                $PowerBI.CheckState = "Unchecked"
            }

            If ($Zotero.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Zotero.Zotero")
                $Zotero.CheckState = "Unchecked"
            }

            If ($Hamachi.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("LogMeIn.Hamachi")
                $Hamachi.CheckState = "Unchecked"
            }

            If ($RadminVPN.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Radmin.VPN")
                $RadminVPN.CheckState = "Unchecked"
            }

            If ($TwilioAuthy.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Twilio.Authy")
                $TwilioAuthy.CheckState = "Unchecked"
            }

            If ($WindowsTerminal.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.WindowsTerminal")
                $WindowsTerminal.CheckState = "Unchecked"
            }

            If ($NerdFonts.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("install-nerd-fonts.ps1")
                }
                $NerdFonts.CheckState = "Unchecked"
            }

            If ($GitGnupgSshSetup.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("git-gnupg-ssh-keys-setup.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
                }
                Else {
                    $AppsSelected.WingetApps.AddRange(@("Git.Git", "GnuPG.GnuPG")) # Installed before inside the script
                }
                $GitGnupgSshSetup.CheckState = "Unchecked"
            }

            If ($ADB.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("adb")
                $ADB.CheckState = "Unchecked"
            }

            If ($AndroidStudio.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Google.AndroidStudio")
                $AndroidStudio.CheckState = "Unchecked"
            }

            If ($DockerDesktop.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Docker.DockerDesktop")
                $DockerDesktop.CheckState = "Unchecked"
            }

            If ($Insomnia.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Insomnia.Insomnia")
                $Insomnia.CheckState = "Unchecked"
            }

            If ($JavaJDKs.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.AddRange(@("EclipseAdoptium.Temurin.8", "EclipseAdoptium.Temurin.11", "EclipseAdoptium.Temurin.18"))
                $JavaJDKs.CheckState = "Unchecked"
            }

            If ($JavaJRE.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Oracle.JavaRuntimeEnvironment")
                $JavaJRE.CheckState = "Unchecked"
            }

            If ($MySQL.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Oracle.MySQL")
                $MySQL.CheckState = "Unchecked"
            }

            If ($NodeJs.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("OpenJS.NodeJS")
                $NodeJs.CheckState = "Unchecked"
            }

            If ($NodeJsLTS.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("OpenJS.NodeJSLTS")
                $NodeJsLTS.CheckState = "Unchecked"
            }

            If ($PostgreSQL.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("PostgreSQL.PostgreSQL")
                $PostgreSQL.CheckState = "Unchecked"
            }

            If ($Python3.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Python.Python.3")
                $Python3.CheckState = "Unchecked"
            }

            If ($PythonAnaconda3.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Anaconda.Anaconda3")
                $PythonAnaconda3.CheckState = "Unchecked"
            }

            If ($Ruby.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("RubyInstallerTeam.Ruby")
                $Ruby.CheckState = "Unchecked"
            }

            If ($RubyMSYS.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("RubyInstallerTeam.RubyWithDevKit")
                $RubyMSYS.CheckState = "Unchecked"
            }

            If ($RustGNU.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Rustlang.Rust.GNU")
                $RustGNU.CheckState = "Unchecked"
            }

            If ($RustMSVC.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Rustlang.Rust.MSVC")
                $RustMSVC.CheckState = "Unchecked"
            }

            If ($Gimp.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("GIMP.GIMP")
                $Gimp.CheckState = "Unchecked"
            }

            If ($Inkscape.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Inkscape.Inkscape")
                $Inkscape.CheckState = "Unchecked"
            }

            If ($IrfanView.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("IrfanSkiljan.IrfanView")
                $IrfanView.CheckState = "Unchecked"
            }

            If ($Krita.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("KDE.Krita")
                $Krita.CheckState = "Unchecked"
            }

            If ($PaintNet.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("paint.net")
                $PaintNet.CheckState = "Unchecked"
            }

            If ($ShareX.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("ShareX.ShareX")
                $ShareX.CheckState = "Unchecked"
            }

            If ($Atom.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("GitHub.Atom")
                $Atom.CheckState = "Unchecked"
            }

            If ($NotepadPlusPlus.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Notepad++.Notepad++")
                $NotepadPlusPlus.CheckState = "Unchecked"
            }

            If ($VSCode.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.VisualStudioCode")
                $VSCode.CheckState = "Unchecked"
            }

            If ($VSCodium.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("VSCodium.VSCodium")
                $VSCodium.CheckState = "Unchecked"
            }

            If ($Dropbox.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Dropbox.Dropbox")
                $Dropbox.CheckState = "Unchecked"
            }

            If ($GoogleDrive.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Google.Drive")
                $GoogleDrive.CheckState = "Unchecked"
            }

            If ($BalenaEtcher.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Balena.Etcher")
                $BalenaEtcher.CheckState = "Unchecked"
            }

            If ($Rufus.CheckState -eq "Checked") {
                $AppsSelected.MSStoreApps.Add("9PC3H3V7Q9CH")
                $Rufus.CheckState = "Unchecked"
            }

            If ($Ventoy.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("ventoy")
                $Ventoy.CheckState = "Unchecked"
            }

            If ($Notion.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Notion.Notion")
                $Notion.CheckState = "Unchecked"
            }

            If ($Obsidian.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Obsidian.Obsidian")
                $Obsidian.CheckState = "Unchecked"
            }

            If ($CPUZ.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("CPUID.CPU-Z")
                $CPUZ.CheckState = "Unchecked"
            }

            If ($CrystalDiskInfo.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("CrystalDewWorld.CrystalDiskInfo")
                $CrystalDiskInfo.CheckState = "Unchecked"
            }

            If ($CrystalDiskMark.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("CrystalDewWorld.CrystalDiskMark")
                $CrystalDiskMark.CheckState = "Unchecked"
            }

            If ($GPUZ.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("TechPowerUp.GPU-Z")
                $GPUZ.CheckState = "Unchecked"
            }

            If ($NVCleanstall.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("TechPowerUp.NVCleanstall")
                $NVCleanstall.CheckState = "Unchecked"
            }

            If ($WSLgOrPreview.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("install-wslg-or-preview.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
                }
                Else {
                    $AppsSelected.MSStoreApps.Add("9P9TQF7MRM4R")
                }
                $WSLgOrPreview.CheckState = "Unchecked"
            }

            If ($ArchWSL.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("install-archwsl.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
                }
                Else {
                    $AppsSelected.WSLDistros.Add("Arch")
                }
                $ArchWSL.CheckState = "Unchecked"
            }

            If ($Debian.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    $AppsSelected.WSLDistros.Add("Debian")
                }
                $Debian.CheckState = "Unchecked"
            }

            If ($KaliLinux.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("kali-linux")
                $KaliLinux.CheckState = "Unchecked"
            }

            If ($OpenSuse.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("openSUSE-42")
                $OpenSuse.CheckState = "Unchecked"
            }

            If ($SLES.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("SLES-12")
                $SLES.CheckState = "Unchecked"
            }

            If ($Ubuntu.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu")
                $Ubuntu.CheckState = "Unchecked"
            }

            If ($Ubuntu16LTS.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu-16.04")
                $Ubuntu16LTS.CheckState = "Unchecked"
            }

            If ($Ubuntu18LTS.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu-18.04")
                $Ubuntu18LTS.CheckState = "Unchecked"
            }

            If ($Ubuntu20LTS.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu-20.04")
                $Ubuntu20LTS.CheckState = "Unchecked"
            }

            If ($Discord.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Discord.Discord")
                $Discord.CheckState = "Unchecked"
            }

            If ($MSTeams.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.Teams")
                $MSTeams.CheckState = "Unchecked"
            }

            If ($RocketChat.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("RocketChat.RocketChat")
                $RocketChat.CheckState = "Unchecked"
            }

            If ($Slack.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("SlackTechnologies.Slack")
                $Slack.CheckState = "Unchecked"
            }

            If ($TelegramDesktop.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Telegram.TelegramDesktop")
                $TelegramDesktop.CheckState = "Unchecked"
            }

            If ($Zoom.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Zoom.Zoom")
                $Zoom.CheckState = "Unchecked"
            }

            If ($BorderlessGaming.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Codeusa.BorderlessGaming")
                $BorderlessGaming.CheckState = "Unchecked"
            }

            If ($EADesktop.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("ElectronicArts.EADesktop")
                $EADesktop.CheckState = "Unchecked"
            }

            If ($EpicGamesLauncher.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("EpicGames.EpicGamesLauncher")
                $EpicGamesLauncher.CheckState = "Unchecked"
            }

            If ($GogGalaxy.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("GOG.Galaxy")
                $GogGalaxy.CheckState = "Unchecked"
            }

            If ($Steam.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Valve.Steam")
                $Steam.CheckState = "Unchecked"
            }

            If ($UbisoftConnect.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Ubisoft.Connect")
                $UbisoftConnect.CheckState = "Unchecked"
            }

            If ($AnyDesk.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("AnyDeskSoftwareGmbH.AnyDesk")
                $AnyDesk.CheckState = "Unchecked"
            }

            If ($Parsec.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Parsec.Parsec")
                $Parsec.CheckState = "Unchecked"
            }

            If ($ScrCpy.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("scrcpy")
                $ScrCpy.CheckState = "Unchecked"
            }

            If ($TeamViewer.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("TeamViewer.TeamViewer")
                $TeamViewer.CheckState = "Unchecked"
            }

            If ($HandBrake.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("HandBrake.HandBrake")
                $HandBrake.CheckState = "Unchecked"
            }

            If ($ObsStudio.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("OBSProject.OBSStudio")
                $ObsStudio.CheckState = "Unchecked"
            }

            If ($StreamlabsObs.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Streamlabs.StreamlabsOBS")
                $StreamlabsObs.CheckState = "Unchecked"
            }

            If ($MpcHc.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("clsid2.mpc-hc")
                $MpcHc.CheckState = "Unchecked"
            }

            If ($Spotify.CheckState -eq "Checked") {
                $AppsSelected.MSStoreApps.Add("9NCBCSZSJRSB")
                $Spotify.CheckState = "Unchecked"
            }

            If ($Vlc.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("VideoLAN.VLC")
                $Vlc.CheckState = "Unchecked"
            }

            If ($qBittorrent.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("qBittorrent.qBittorrent")
                $qBittorrent.CheckState = "Unchecked"
            }

            If ($Cemu.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("cemu")
                $Cemu.CheckState = "Unchecked"
            }

            If ($Dolphin.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("DolphinEmulator.Dolphin")
                $Dolphin.CheckState = "Unchecked"
            }

            If ($KegaFusion.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("kega-fusion")
                $KegaFusion.CheckState = "Unchecked"
            }

            If ($MGba.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("JeffreyPfau.mGBA")
                $MGba.CheckState = "Unchecked"
            }

            If ($PCSX2.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("pcsx2.portable")
                $PCSX2.CheckState = "Unchecked"
            }

            If ($PPSSPP.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("PPSSPPTeam.PPSSPP")
                $PPSSPP.CheckState = "Unchecked"
            }

            If ($Project64.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Project64.Project64.Dev")
                $Project64.CheckState = "Unchecked"
            }

            If ($RetroArch.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("retroarch")
                $RetroArch.CheckState = "Unchecked"
            }

            If ($Snes9x.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("snes9x")
                $Snes9x.CheckState = "Unchecked"
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
                $UninstallMode.Text = "[ON] Uninstall Mode"
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
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"gui-helper.psm1" -Force
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