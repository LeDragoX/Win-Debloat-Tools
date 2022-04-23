function Request-AdminPrivilege() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

# https://docs.microsoft.com/en-us/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.1
# Adapted majorly from https://github.com/ChrisTitusTech/win10script and https://github.com/Sycnex/Windows10Debloater
function Show-GUI() {
    Set-GUILayout # Load the GUI Layout

    $Global:NeedRestart = $false
    $DoneTitle = "Information"
    $DoneMessage = "Process Completed!"

    # Main Window:
    $Form = New-Form -Width ($FormWidth + 15) -Height $FormHeight -Text "Win 10+ Smart Debloat Tools | $(Get-SystemSpec) | Made by LeDragoX" -BackColor "$WinDark" -Minimize $true # Loading the specs takes longer to load the script

    # Window Icon:
    $Form = New-FormIcon -Form $Form -ImageLocation "$PSScriptRoot\src\assets\windows-11-logo.png"

    # Panels to put Labels and Buttons
    $Global:CurrentPanelIndex++
    $Panel1 = New-Panel -Width $PanelWidth -Height ($FormHeight - ($FormHeight * 0.1955)) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $Panel2 = New-Panel -Width $PanelWidth -Height ($FormHeight * 1.50) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY ($Panel1.Location.Y + $Panel1.Height)
    $Global:CurrentPanelIndex++
    $Panel3 = New-Panel -Width ($PanelWidth - 15) -Height ($FormHeight * 2.30) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $Global:CurrentPanelIndex++
    $Panel4 = New-Panel -Width ($PanelWidth - 15) -Height ($FormHeight * 2.30) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $Global:CurrentPanelIndex++
    $Panel5 = New-Panel -Width $PanelWidth -Height ($FormHeight * 2.30) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    # Panel to put more Panels
    $FullPanel = New-Panel -Width (($PanelWidth * ($CurrentPanelIndex + 1))) -Height $FormHeight -LocationX 0 -LocationY 0 -HasVerticalScroll

    # Panels 1, 2, 3-4-5 ~> Title Label
    $TitleLabel1 = New-Label -Text "System Tweaks" -Width $LabelWidth -Height $TitleLabelHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $FontSize4 -FontStyle "Bold" -ForeColor $WinBlue
    $TitleLabel2 = New-Label -Text "Customize Tweaks" -Width $LabelWidth -Height $TitleLabelHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $FontSize4 -FontStyle "Bold" -ForeColor $WinBlue
    $TitleLabel3 = New-Label -Text "Software Install" -Width $LabelWidth -Height $TitleLabelHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $FontSize4 -FontStyle "Bold" -ForeColor $WinBlue

    # Panel 3-4-5 ~> Caption Label
    $CaptionLabel1 = New-Label -Text "Package Managers: Winget and Chocolatey" -Width ($CaptionLabelWidth * 1.25) -Height $CaptionLabelHeight -LocationX (($PanelWidth * 2) - ($PanelWidth * 0.10)) -LocationY ($FirstButtonY - 27) -FontSize $FontSize1 -ForeColor $Purple

    # Panel 1 ~> Big Button
    $ApplyTweaks = New-Button -Text "Apply Tweaks" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -FontStyle "Italic" -ForeColor $WinBlue

    # Panel 2 ~> Big Button
    $NextYLocation = $ApplyTweaks.Location.Y + $ApplyTweaks.Height + $DistanceBetweenButtons
    $RevertTweaks = New-Button -Text "Revert Tweaks" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1 -ForeColor $WarningColor

    # Panel 1 ~> Small Buttons
    $NextYLocation = $RevertTweaks.Location.Y + $RevertTweaks.Height + $DistanceBetweenButtons
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
    $DarkTheme = New-Button -Text "Dark Theme" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize1

    $NextYLocation = $DarkTheme.Location.Y + $DarkTheme.Height + $DistanceBetweenButtons
    $LightTheme = New-Button -Text "Light Theme" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $LightTheme.Location.Y + $LightTheme.Height + $DistanceBetweenButtons
    $EnableSearchIdx = New-Button -Text "Enable Search Indexing" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EnableSearchIdx.Location.Y + $EnableSearchIdx.Height + $DistanceBetweenButtons
    $DisableSearchIdx = New-Button -Text "Disable Search Indexing" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DisableSearchIdx.Location.Y + $DisableSearchIdx.Height + $DistanceBetweenButtons
    $EnableBgApps = New-Button -Text "Enable Background Apps" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EnableBgApps.Location.Y + $EnableBgApps.Height + $DistanceBetweenButtons
    $DisableBgApps = New-Button -Text "Disable Background Apps" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DisableBgApps.Location.Y + $DisableBgApps.Height + $DistanceBetweenButtons
    $EnableTelemetry = New-Button -Text "Enable Telemetry" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EnableTelemetry.Location.Y + $EnableTelemetry.Height + $DistanceBetweenButtons
    $DisableTelemetry = New-Button -Text "Disable Telemetry" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DisableTelemetry.Location.Y + $DisableTelemetry.Height + $DistanceBetweenButtons
    $EnableCortana = New-Button -Text "Enable Cortana" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EnableCortana.Location.Y + $EnableCortana.Height + $DistanceBetweenButtons
    $DisableCortana = New-Button -Text "Disable Cortana" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DisableCortana.Location.Y + $DisableCortana.Height + $DistanceBetweenButtons
    $EnableGameBarAndDVR = New-Button -Text "Enable Xbox GameBar/DVR" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EnableGameBarAndDVR.Location.Y + $EnableGameBarAndDVR.Height + $DistanceBetweenButtons
    $DisableGameBarAndDVR = New-Button -Text "Disable Xbox GameBar/DVR" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DisableGameBarAndDVR.Location.Y + $DisableGameBarAndDVR.Height + $DistanceBetweenButtons
    $EnableClipboardHistory = New-Button -Text "Enable Clipboard History" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EnableClipboardHistory.Location.Y + $EnableClipboardHistory.Height + $DistanceBetweenButtons
    $DisableClipboardHistory = New-Button -Text "Disable Clipboard History" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DisableClipboardHistory.Location.Y + $DisableClipboardHistory.Height + $DistanceBetweenButtons
    $EnableOldVolumeControl = New-Button -Text "Enable Old Volume Control" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EnableOldVolumeControl.Location.Y + $EnableOldVolumeControl.Height + $DistanceBetweenButtons
    $DisableOldVolumeControl = New-Button -Text "Disable Old Volume Control" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Big Button
    $InstallDrivers = New-Button -Text "Install CPU/GPU Drivers Updaters" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -FontStyle "Italic" -ForeColor $WinBlue

    # --- Panel 3 ~> Caption Label
    $NextYLocation = $InstallDrivers.Location.Y + $InstallDrivers.Height + $DistanceBetweenButtons
    $CaptionLabel3_1 = New-Label -Text "Web Browsers" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_1.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $BraveBrowser = New-Button -Text "Brave Browser" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $BraveBrowser.Location.Y + $BraveBrowser.Height + $DistanceBetweenButtons
    $GoogleChrome = New-Button -Text "Google Chrome" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GoogleChrome.Location.Y + $GoogleChrome.Height + $DistanceBetweenButtons
    $MozillaFirefox = New-Button -Text "Mozilla Firefox" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $MozillaFirefox.Location.Y + $MozillaFirefox.Height + $DistanceBetweenButtons
    $CaptionLabel3_2 = New-Label -Text "File Compression" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_2.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $7Zip = New-Button -Text "7-Zip" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $7Zip.Location.Y + $7Zip.Height + $DistanceBetweenButtons
    $WinRAR = New-Button -Text "WinRAR (Trial)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $WinRAR.Location.Y + $WinRAR.Height + $DistanceBetweenButtons
    $CaptionLabel3_3 = New-Label -Text "Document Editors" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_3.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $LibreOffice = New-Button -Text "LibreOffice" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $LibreOffice.Location.Y + $LibreOffice.Height + $DistanceBetweenButtons
    $OnlyOffice = New-Button -Text "ONLYOFFICE DesktopEditors" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $OnlyOffice.Location.Y + $OnlyOffice.Height + $DistanceBetweenButtons
    $PowerBI = New-Button -Text "Power BI" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # --- Panel 3 ~> Caption Label
    $NextYLocation = $PowerBI.Location.Y + $PowerBI.Height + $DistanceBetweenButtons
    $CaptionLabel3_4 = New-Label -Text "Academic Research" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_4.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Zotero = New-Button -Text "Zotero" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $Zotero.Location.Y + $Zotero.Height + $DistanceBetweenButtons
    $CaptionLabel3_5 = New-Label -Text "Networking" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_5.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Hamachi = New-Button -Text "Hamachi (LAN)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Hamachi.Location.Y + $Hamachi.Height + $DistanceBetweenButtons
    $RadminVPN = New-Button -Text "Radmin VPN (LAN)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $RadminVPN.Location.Y + $RadminVPN.Height + $DistanceBetweenButtons
    $CaptionLabel3_6 = New-Label -Text "2-Factor Authentication" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_6.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $TwilioAuthy = New-Button -Text "Twilio Authy" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # --- Panel 3 ~> Caption Label
    $NextYLocation = $TwilioAuthy.Location.Y + $TwilioAuthy.Height + $DistanceBetweenButtons
    $CaptionLabel3_7 = New-Label -Text "Development (Windows)" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_7.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $WindowsTerminalNerdFonts = New-Button -Text "Windows Terminal + Nerd Font" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $WindowsTerminalNerdFonts.Location.Y + $WindowsTerminalNerdFonts.Height + $DistanceBetweenButtons
    $GitGnupgSshSetup = New-Button -Text "Git + GnuPG + SSH (Setup)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $GitGnupgSshSetup.Location.Y + $GitGnupgSshSetup.Height + $DistanceBetweenButtons
    $ADB = New-Button -Text "Android Debug Bridge (ADB)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $ADB.Location.Y + $ADB.Height + $DistanceBetweenButtons
    $AndroidStudio = New-Button -Text "Android Studio" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $AndroidStudio.Location.Y + $AndroidStudio.Height + $DistanceBetweenButtons
    $DockerDesktop = New-Button -Text "Docker Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $DockerDesktop.Location.Y + $DockerDesktop.Height + $DistanceBetweenButtons
    $Insomnia = New-Button -Text "Insomnia" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Insomnia.Location.Y + $Insomnia.Height + $DistanceBetweenButtons
    $JavaJDKs = New-Button -Text "Java - Adoptium JDK v8/v11/v18" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $JavaJDKs.Location.Y + $JavaJDKs.Height + $DistanceBetweenButtons
    $JavaJRE = New-Button -Text "Java Runtime Environment (JRE)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $JavaJRE.Location.Y + $JavaJRE.Height + $DistanceBetweenButtons
    $MySQL = New-Button -Text "MySQL" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $MySQL.Location.Y + $MySQL.Height + $DistanceBetweenButtons
    $NodeJs = New-Button -Text "NodeJS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $NodeJs.Location.Y + $NodeJs.Height + $DistanceBetweenButtons
    $NodeJsLTS = New-Button -Text "NodeJS LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $NodeJsLTS.Location.Y + $NodeJsLTS.Height + $DistanceBetweenButtons
    $PostgreSQL = New-Button -Text "PostgreSQL" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $PostgreSQL.Location.Y + $PostgreSQL.Height + $DistanceBetweenButtons
    $Python3 = New-Button -Text "Python 3" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $Python3.Location.Y + $Python3.Height + $DistanceBetweenButtons
    $PythonAnaconda3 = New-Button -Text "Python - Anaconda3" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $PythonAnaconda3.Location.Y + $PythonAnaconda3.Height + $DistanceBetweenButtons
    $Ruby = New-Button -Text "Ruby" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $Ruby.Location.Y + $Ruby.Height + $DistanceBetweenButtons
    $RubyMSYS = New-Button -Text "Ruby (MSYS2)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $RubyMSYS.Location.Y + $RubyMSYS.Height + $DistanceBetweenButtons
    $RustGNU = New-Button -Text "Rust (GNU)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    $NextYLocation = $RustGNU.Location.Y + $RustGNU.Height + $DistanceBetweenButtons
    $RustMSVC = New-Button -Text "Rust (MSVC)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1
    
    # --- Panel 4 ~> Caption Label
    $CaptionLabel4_1 = New-Label -Text "Image Tools" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_1.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Gimp = New-Button -Text "GIMP" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Gimp.Location.Y + $Gimp.Height + $DistanceBetweenButtons
    $Inkscape = New-Button -Text "Inkscape" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Inkscape.Location.Y + $Inkscape.Height + $DistanceBetweenButtons
    $IrfanView = New-Button -Text "IrfanView" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $IrfanView.Location.Y + $IrfanView.Height + $DistanceBetweenButtons
    $Krita = New-Button -Text "Krita" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Krita.Location.Y + $Krita.Height + $DistanceBetweenButtons
    $PaintNet = New-Button -Text "Paint.NET" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $PaintNet.Location.Y + $PaintNet.Height + $DistanceBetweenButtons
    $ShareX = New-Button -Text "ShareX (Screenshots/GIFs)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $ShareX.Location.Y + $ShareX.Height + $DistanceBetweenButtons
    $CaptionLabel4_2 = New-Label -Text "Text Editors / IDEs" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_2.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Atom = New-Button -Text "Atom" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Atom.Location.Y + $Atom.Height + $DistanceBetweenButtons
    $NotepadPlusPlus = New-Button -Text "Notepad++" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $NotepadPlusPlus.Location.Y + $NotepadPlusPlus.Height + $DistanceBetweenButtons
    $VSCode = New-Button -Text "VS Code" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $VSCode.Location.Y + $VSCode.Height + $DistanceBetweenButtons
    $VSCodium = New-Button -Text "VS Codium" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $VSCodium.Location.Y + $VSCodium.Height + $DistanceBetweenButtons
    $CaptionLabel4_3 = New-Label -Text "Cloud Storage" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_3.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Dropbox = New-Button -Text "Dropbox" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Dropbox.Location.Y + $Dropbox.Height + $DistanceBetweenButtons
    $GoogleDrive = New-Button -Text "Google Drive" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # --- Panel 4 ~> Caption Label
    $NextYLocation = $GoogleDrive.Location.Y + $GoogleDrive.Height + $DistanceBetweenButtons
    $CaptionLabel4_4 = New-Label -Text "Bootable USB" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_4.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $BalenaEtcher = New-Button -Text "Etcher" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $BalenaEtcher.Location.Y + $BalenaEtcher.Height + $DistanceBetweenButtons
    $Rufus = New-Button -Text "Rufus" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Rufus.Location.Y + $Rufus.Height + $DistanceBetweenButtons
    $Ventoy = New-Button -Text "Ventoy" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $Ventoy.Location.Y + $Ventoy.Height + $DistanceBetweenButtons
    $CaptionLabel4_5 = New-Label -Text "Planning" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_5.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Notion = New-Button -Text "Notion" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Notion.Location.Y + $Notion.Height + $DistanceBetweenButtons
    $Obsidian = New-Button -Text "Obsidian" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $Obsidian.Location.Y + $Obsidian.Height + $DistanceBetweenButtons
    $CaptionLabel4_6 = New-Label -Text "Utilities" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_6.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $CPUZ = New-Button -Text "CPU-Z" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $CPUZ.Location.Y + $CPUZ.Height + $DistanceBetweenButtons
    $CrystalDiskInfo = New-Button -Text "Crystal Disk Info" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $CrystalDiskInfo.Location.Y + $CrystalDiskInfo.Height + $DistanceBetweenButtons
    $CrystalDiskMark = New-Button -Text "Crystal Disk Mark" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $CrystalDiskMark.Location.Y + $CrystalDiskMark.Height + $DistanceBetweenButtons
    $GPUZ = New-Button -Text "GPU-Z" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GPUZ.Location.Y + $GPUZ.Height + $DistanceBetweenButtons
    $NVCleanstall = New-Button -Text "NVCleanstall" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # --- Panel 4 ~> Caption Label
    $NextYLocation = $NVCleanstall.Location.Y + $NVCleanstall.Height + $DistanceBetweenButtons
    $CaptionLabel4_7 = New-Label -Text "Windows Subsystem For Linux" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_7.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $WSL2 = New-Button -Text "WSL2 + WSLg (Win10/Insider)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $WSL2.Location.Y + $WSL2.Height + $DistanceBetweenButtons
    $WSLPreview = New-Button -Text "WSL Preview (Win 11)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $WSLPreview.Location.Y + $WSLPreview.Height + $DistanceBetweenButtons
    $ArchWSL = New-Button -Text "ArchWSL (x64)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ArchWSL.Location.Y + $ArchWSL.Height + $DistanceBetweenButtons
    $Debian = New-Button -Text "Debian GNU/Linux" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Debian.Location.Y + $Debian.Height + $DistanceBetweenButtons
    $KaliLinux = New-Button -Text "Kali Linux Rolling" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $KaliLinux.Location.Y + $KaliLinux.Height + $DistanceBetweenButtons
    $OpenSuse = New-Button -Text "Open SUSE 42" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $OpenSuse.Location.Y + $OpenSuse.Height + $DistanceBetweenButtons
    $SLES = New-Button -Text "SLES v12" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $SLES.Location.Y + $SLES.Height + $DistanceBetweenButtons
    $Ubuntu = New-Button -Text "Ubuntu" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu.Location.Y + $Ubuntu.Height + $DistanceBetweenButtons
    $Ubuntu16LTS = New-Button -Text "Ubuntu 16.04 LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu16LTS.Location.Y + $Ubuntu16LTS.Height + $DistanceBetweenButtons
    $Ubuntu18LTS = New-Button -Text "Ubuntu 18.04 LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu18LTS.Location.Y + $Ubuntu18LTS.Height + $DistanceBetweenButtons
    $Ubuntu20LTS = New-Button -Text "Ubuntu 20.04 LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Big Button
    $InstallGamingDependencies = New-Button -Text "Install Gaming Dependencies" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -FontStyle "Italic" -ForeColor $WinBlue

    # --- Panel 5 ~> Caption Label
    $NextYLocation = $InstallGamingDependencies.Location.Y + $InstallGamingDependencies.Height + $DistanceBetweenButtons
    $CaptionLabel5_1 = New-Label -Text "Communication" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_1.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Discord = New-Button -Text "Discord" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Discord.Location.Y + $Discord.Height + $DistanceBetweenButtons
    $MSTeams = New-Button -Text "Microsoft Teams" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $MSTeams.Location.Y + $MSTeams.Height + $DistanceBetweenButtons
    $RocketChat = New-Button -Text "Rocket Chat" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $RocketChat.Location.Y + $RocketChat.Height + $DistanceBetweenButtons
    $Slack = New-Button -Text "Slack" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Slack.Location.Y + $Slack.Height + $DistanceBetweenButtons
    $Telegram = New-Button -Text "Telegram Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Telegram.Location.Y + $Telegram.Height + $DistanceBetweenButtons
    $Zoom = New-Button -Text "Zoom" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Caption Label
    $NextYLocation = $Zoom.Location.Y + $Zoom.Height + $DistanceBetweenButtons
    $CaptionLabel5_2 = New-Label -Text "Gaming" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_2.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $BorderlessGaming = New-Button -Text "Borderless Gaming" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $BorderlessGaming.Location.Y + $BorderlessGaming.Height + $DistanceBetweenButtons
    $EADesktop = New-Button -Text "EA Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EADesktop.Location.Y + $EADesktop.Height + $DistanceBetweenButtons
    $EpicGames = New-Button -Text "Epic Games Launcher" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EpicGames.Location.Y + $EpicGames.Height + $DistanceBetweenButtons
    $GogGalaxy = New-Button -Text "GOG Galaxy" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GogGalaxy.Location.Y + $GogGalaxy.Height + $DistanceBetweenButtons
    $Steam = New-Button -Text "Steam" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Steam.Location.Y + $Steam.Height + $DistanceBetweenButtons
    $UbisoftConnect = New-Button -Text "Ubisoft Connect" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Caption Label
    $NextYLocation = $UbisoftConnect.Location.Y + $UbisoftConnect.Height + $DistanceBetweenButtons
    $CaptionLabel5_3 = New-Label -Text "Remote Connection" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_3.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $AnyDesk = New-Button -Text "AnyDesk" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $AnyDesk.Location.Y + $AnyDesk.Height + $DistanceBetweenButtons
    $Parsec = New-Button -Text "Parsec" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Parsec.Location.Y + $Parsec.Height + $DistanceBetweenButtons
    $ScrCpy = New-Button -Text "ScrCpy (Android)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ScrCpy.Location.Y + $ScrCpy.Height + $DistanceBetweenButtons
    $TeamViewer = New-Button -Text "Team Viewer" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # --- Panel 5 ~> Caption Label
    $NextYLocation = $TeamViewer.Location.Y + $TeamViewer.Height + $DistanceBetweenButtons
    $CaptionLabel5_4 = New-Label -Text "Recording and Streaming" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_4.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $HandBrake = New-Button -Text "HandBrake (Transcode)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $HandBrake.Location.Y + $HandBrake.Height + $DistanceBetweenButtons
    $ObsStudio = New-Button -Text "OBS Studio" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ObsStudio.Location.Y + $ObsStudio.Height + $DistanceBetweenButtons
    $StreamlabsObs = New-Button -Text "Streamlabs OBS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Caption Label
    $NextYLocation = $StreamlabsObs.Location.Y + $StreamlabsObs.Height + $DistanceBetweenButtons
    $CaptionLabel5_5 = New-Label -Text "Media Playing" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_5.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $MpcHc = New-Button -Text "Media Player Classic" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $MpcHc.Location.Y + $MpcHc.Height + $DistanceBetweenButtons
    $Spotify = New-Button -Text "Spotify" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Spotify.Location.Y + $Spotify.Height + $DistanceBetweenButtons
    $Vlc = New-Button -Text "VLC" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Caption Label
    $NextYLocation = $Vlc.Location.Y + $Vlc.Height + $DistanceBetweenButtons
    $CaptionLabel5_6 = New-Label -Text "Torrent" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_6.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $qBittorrent = New-Button -Text "qBittorrent" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # --- Panel 5 ~> Caption Label
    $NextYLocation = $qBittorrent.Location.Y + $qBittorrent.Height + $DistanceBetweenButtons
    $CaptionLabel5_7 = New-Label -Text "Emulation" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 5 ~> Small Buttons
    $NextYLocation = $CaptionLabel5_7.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Cemu = New-Button -Text "Cemu (Wii U)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Cemu.Location.Y + $Cemu.Height + $DistanceBetweenButtons
    $Dolphin = New-Button -Text "Dolphin Stable (GC/Wii)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Dolphin.Location.Y + $Dolphin.Height + $DistanceBetweenButtons
    $MGba = New-Button -Text "mGBA (GBA)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $MGba.Location.Y + $MGba.Height + $DistanceBetweenButtons
    $PCSX2 = New-Button -Text "PCSX2 Stable (PS2 | Portable)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $PCSX2.Location.Y + $PCSX2.Height + $DistanceBetweenButtons
    $PPSSPP = New-Button -Text "PPSSPP (PSP)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $PPSSPP.Location.Y + $PPSSPP.Height + $DistanceBetweenButtons
    $Project64 = New-Button -Text "Project64 Dev (N64)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Project64.Location.Y + $Project64.Height + $DistanceBetweenButtons
    $RetroArch = New-Button -Text "RetroArch (All In One)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $RetroArch.Location.Y + $RetroArch.Height + $DistanceBetweenButtons
    $Snes9x = New-Button -Text "Snes9x (SNES)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Add all Panels to the Form (Screen)
    $Form.Controls.AddRange(@($FullPanel))
    # Add Elements to each Panel
    $FullPanel.Controls.AddRange(@($CaptionLabel1))
    $FullPanel.Controls.AddRange(@($Panel1, $Panel2, $Panel3, $Panel4, $Panel5))
    $Panel1.Controls.AddRange(@($TitleLabel1, $ApplyTweaks, $RevertTweaks, $RemoveXbox, $RepairWindows, $InstallOneDrive, $ReinstallBloatApps, $ShowDebloatInfo, $PictureBox1))
    $Panel2.Controls.AddRange(@($TitleLabel2, $DarkTheme, $LightTheme, $EnableSearchIdx, $DisableSearchIdx, $EnableBgApps, $DisableBgApps, $EnableTelemetry, $DisableTelemetry, $EnableCortana, $DisableCortana, $EnableGameBarAndDVR, $DisableGameBarAndDVR, $EnableClipboardHistory, $DisableClipboardHistory, $EnableOldVolumeControl, $DisableOldVolumeControl))
    $Panel3.Controls.AddRange(@($InstallDrivers, $CaptionLabel3_1, $BraveBrowser, $GoogleChrome, $MozillaFirefox))
    $Panel3.Controls.AddRange(@($CaptionLabel3_2, $7Zip, $WinRAR))
    $Panel3.Controls.AddRange(@($CaptionLabel3_3, $LibreOffice, $OnlyOffice, $PowerBI))
    $Panel3.Controls.AddRange(@($CaptionLabel3_4, $Zotero))
    $Panel3.Controls.AddRange(@($CaptionLabel3_5, $Hamachi, $RadminVPN))
    $Panel3.Controls.AddRange(@($CaptionLabel3_6, $TwilioAuthy))
    $Panel3.Controls.AddRange(@($CaptionLabel3_7, $WindowsTerminalNerdFonts, $GitGnupgSshSetup, $ADB, $AndroidStudio, $DockerDesktop, $Insomnia, $JavaJDKs, $JavaJRE, $MySQL, $NodeJs, $NodeJsLTS, $PostgreSQL, $Python3, $PythonAnaconda3, $Ruby, $RubyMSYS, $RustGNU, $RustMSVC))
    $Panel4.Controls.AddRange(@($TitleLabel3, $CaptionLabel4_1, $Gimp, $Inkscape, $IrfanView, $Krita, $PaintNet, $ShareX))
    $Panel4.Controls.AddRange(@($CaptionLabel4_2, $Atom, $NotepadPlusPlus, $VSCode, $VSCodium))
    $Panel4.Controls.AddRange(@($CaptionLabel4_3, $Dropbox, $GoogleDrive))
    $Panel4.Controls.AddRange(@($CaptionLabel4_4, $BalenaEtcher, $Rufus, $Ventoy))
    $Panel4.Controls.AddRange(@($CaptionLabel4_5, $Notion, $Obsidian))
    $Panel4.Controls.AddRange(@($CaptionLabel4_6, $CPUZ, $CrystalDiskInfo, $CrystalDiskMark, $GPUZ, $NVCleanstall))
    $Panel4.Controls.AddRange(@($CaptionLabel4_7, $WSL2, $WSLPreview, $ArchWSL, $Debian, $KaliLinux, $OpenSuse, $SLES, $Ubuntu, $Ubuntu16LTS, $Ubuntu18LTS, $Ubuntu20LTS))
    $Panel5.Controls.AddRange(@($InstallGamingDependencies, $CaptionLabel5_1, $Discord, $MSTeams, $RocketChat, $Slack, $Telegram, $Zoom))
    $Panel5.Controls.AddRange(@($CaptionLabel5_2, $BorderlessGaming, $EADesktop, $EpicGames, $GogGalaxy, $Steam, $UbisoftConnect))
    $Panel5.Controls.AddRange(@($CaptionLabel5_3, $AnyDesk, $Parsec, $ScrCpy, $TeamViewer))
    $Panel5.Controls.AddRange(@($CaptionLabel5_4, $HandBrake, $ObsStudio, $StreamlabsObs))
    $Panel5.Controls.AddRange(@($CaptionLabel5_5, $MpcHc, $Spotify, $Vlc))
    $Panel5.Controls.AddRange(@($CaptionLabel5_6, $qBittorrent))
    $Panel5.Controls.AddRange(@($CaptionLabel5_7, $Cemu, $Dolphin, $MGba, $PCSX2, $PPSSPP, $Project64, $RetroArch, $Snes9x))

    # <===== CLICK EVENTS =====>

    $ApplyTweaks.Add_Click( {
            $Scripts = @(
                # [Recommended order]
                "backup-system.ps1",
                "silent-debloat-softwares.ps1",
                "optimize-scheduled-tasks.ps1",
                "optimize-services.ps1",
                "remove-bloatware-apps.ps1",
                "optimize-privacy-and-performance.ps1",
                "personal-tweaks.ps1",
                "optimize-security.ps1",
                "remove-onedrive.ps1",
                "optimize-windows-features.ps1",
                "win11-wsl-preview-install.ps1"
            )

            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
            $PictureBox1.imageLocation = "$PSScriptRoot\src\assets\script-logo2.png"
            $PictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
            $Form.Update()
            $Global:NeedRestart = $true
        })

    $RevertTweaks.Add_Click( {
            $Global:Revert = $true
            $Scripts = @(
                "optimize-scheduled-tasks.ps1",
                "optimize-services.ps1",
                "optimize-privacy-and-performance.ps1",
                "personal-tweaks.ps1",
                "optimize-windows-features.ps1",
                "reinstall-pre-installed-apps.ps1"
            )
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
            $Global:Revert = $false
        })

    $RemoveXbox.Add_Click( {
            $Scripts = @("remove-and-disable-xbox.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $RepairWindows.Add_Click( {
            $Scripts = @("backup-system.ps1", "repair-windows.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $InstallOneDrive.Add_Click( {
            $Scripts = @("install-onedrive.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $ReinstallBloatApps.Add_Click( {
            $Scripts = @("reinstall-pre-installed-apps.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $ShowDebloatInfo.Add_Click( {
            Show-DebloatInfo
        })

    $DarkTheme.Add_Click( {
            $Scripts = @("use-dark-theme.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[+] Dark Theme enabled!"
        })

    $LightTheme.Add_Click( {
            $Scripts = @("use-light-theme.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[+] Light Theme enabled!"
        })

    $EnableSearchIdx.Add_Click( {
            $Scripts = @("enable-search-idx.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $DisableSearchIdx.Add_Click( {
            $Scripts = @("disable-search-idx.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $EnableBgApps.Add_Click( {
            $Scripts = @("enable-bg-apps.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[+] Background Apps enabled!"
        })

    $DisableBgApps.Add_Click( {
            $Scripts = @("disable-bg-apps.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[-] Background Apps disabled!"
        })

    $EnableTelemetry.Add_Click( {
            $Scripts = @("enable-telemetry.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[+] Telemetry enabled!"
        })

    $DisableTelemetry.Add_Click( {
            $Scripts = @("disable-telemetry.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[-] Telemetry disabled!"
        })

    $EnableCortana.Add_Click( {
            $Scripts = @("enable-cortana.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[+] Cortana enabled!"
        })

    $DisableCortana.Add_Click( {
            $Scripts = @("disable-cortana.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[-] Cortana disabled!"
        })

    $EnableGameBarAndDVR.Add_Click( {
            $Scripts = @("enable-game-bar-dvr.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[+] Xbox GameBar/DVR enabled!"
        })

    $DisableGameBarAndDVR.Add_Click( {
            $Scripts = @("disable-game-bar-dvr.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[-] Xbox GameBar/DVR disabled!"
        })

    $EnableClipboardHistory.Add_Click( {
            $Scripts = @("enable-clipboard-history.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[+] Clipboard History enabled!"
        })

    $DisableClipboardHistory.Add_Click( {
            $Scripts = @("disable-clipboard-history.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[-] Clipboard History disabled!"
        })

    $EnableOldVolumeControl.Add_Click( {
            $Scripts = @("enable-old-volume-control.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[+] Old Volume Control enabled!"
        })

    $DisableOldVolumeControl.Add_Click( {
            $Scripts = @("disable-old-volume-control.reg")
            Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage "[-] Old Volume Control disabled!"
        })

    $InstallDrivers.Add_Click( {
            $Scripts = @("install-drivers-updaters.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $BraveBrowser.Add_Click( {
            Install-Software -Name $BraveBrowser.Text -Packages "BraveSoftware.BraveBrowser"
        })

    $GoogleChrome.Add_Click( {
            Install-Software -Name $GoogleChrome.Text -Packages "Google.Chrome"
        })

    $MozillaFirefox.Add_Click( {
            Install-Software -Name $MozillaFirefox.Text -Packages "Mozilla.Firefox"
        })

    $7Zip.Add_Click( {
            Install-Software -Name $7Zip.Text -Packages "7zip.7zip"
        })

    $WinRAR.Add_Click( {
            Install-Software -Name $WinRAR.Text -Packages "RARLab.WinRAR"
        })

    $LibreOffice.Add_Click( {
            Install-Software -Name $LibreOffice.Text -Packages "LibreOffice.LibreOffice"
        })

    $OnlyOffice.Add_Click( {
            Install-Software -Name $OnlyOffice.Text -Packages "ONLYOFFICE.DesktopEditors"
        })

    $PowerBI.Add_Click( {
            Install-Software -Name $PowerBI.Text -Packages "Microsoft.PowerBI"
        })

    $Zotero.Add_Click( {
            Install-Software -Name $Zotero.Text -Packages "Zotero.Zotero"
        })

    $Hamachi.Add_Click( {
            Install-Software -Name $Hamachi.Text -Packages "LogMeIn.Hamachi"
        })

    $RadminVPN.Add_Click( {
            Install-Software -Name $RadminVPN.Text -Packages "Radmin.VPN"
        })

    $TwilioAuthy.Add_Click( {
            Install-Software -Name $TwilioAuthy.Text -Packages "Twilio.Authy"
        })

    $WindowsTerminalNerdFonts.Add_Click( {
            Install-Software -Name $WindowsTerminalNerdFonts.Text -Packages "Microsoft.WindowsTerminal"
            $URI = "https://github.com/romkatv/powerlevel10k-media/raw/master"
            $FontFiles = @("MesloLGS NF Regular.ttf", "MesloLGS NF Bold.ttf", "MesloLGS NF Italic.ttf", "MesloLGS NF Bold Italic.ttf")

            ForEach ($Font in $FontFiles) {
                Request-FileDownload -FileURI "$URI/$Font" -OutputFolder "Fonts" -OutputFile "$Font"
            }

            Install-Font -FontSourceFolder "$PSScriptRoot\src\tmp\Fonts"
        })

    $GitGnupgSshSetup.Add_Click( {
            $Scripts = @("git-gnupg-ssh-keys-setup.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $ADB.Add_Click( {
            Install-Software -Name $ADB.Text -Packages "adb" -UseChocolatey
        })

    $AndroidStudio.Add_Click( {
            Install-Software -Name $AndroidStudio.Text -Packages "Google.AndroidStudio"
        })

    $DockerDesktop.Add_Click( {
            Install-Software -Name $DockerDesktop.Text -Packages "Docker.DockerDesktop"
        })

    $Insomnia.Add_Click( {
            Install-Software -Name $Insomnia.Text -Packages "Insomnia.Insomnia"
        })

    $JavaJDKs.Add_Click( {
            Install-Software -Name $JavaJDKs.Text -Packages @("EclipseAdoptium.Temurin.8", "EclipseAdoptium.Temurin.11", "EclipseAdoptium.Temurin.18")
        })

    $JavaJRE.Add_Click( {
            Install-Software -Name $JavaJRE.Text -Packages "Oracle.JavaRuntimeEnvironment"
        })

    $MySQL.Add_Click( {
            Install-Software -Name $MySQL.Text -Packages "Oracle.MySQL"
        })

    $NodeJs.Add_Click( {
            Install-Software -Name $NodeJs.Text -Packages "OpenJS.NodeJS"
        })

    $NodeJsLTS.Add_Click( {
            Install-Software -Name $NodeJsLTS.Text -Packages "OpenJS.NodeJSLTS"
        })

    $PostgreSQL.Add_Click( {
            Install-Software -Name $PostgreSQL.Text -Packages "PostgreSQL.PostgreSQL"
        })

    $Python3.Add_Click( {
            Install-Software -Name $Python3.Text -Packages "Python.Python.3"
        })

    $PythonAnaconda3.Add_Click( {
            Install-Software -Name $PythonAnaconda3.Text -Packages "Anaconda.Anaconda3"
        })

    $Ruby.Add_Click( {
            Install-Software -Name $Ruby.Text -Packages "RubyInstallerTeam.Ruby"
        })

    $RubyMSYS.Add_Click( {
            Install-Software -Name $RubyMSYS.Text -Packages "RubyInstallerTeam.RubyWithDevKit"
        })

    $RustGNU.Add_Click( {
            Install-Software -Name $RustGNU.Text -Packages "Rustlang.Rust.GNU"
        })

    $RustMSVC.Add_Click( {
            Install-Software -Name $RustMSVC.Text -Packages "Rustlang.Rust.MSVC"
        })

    $Gimp.Add_Click( {
            Install-Software -Name $Gimp.Text -Packages "GIMP.GIMP"
        })

    $Inkscape.Add_Click( {
            Install-Software -Name $Inkscape.Text -Packages "Inkscape.Inkscape"
        })

    $IrfanView.Add_Click( {
            Install-Software -Name $IrfanView.Text -Packages "IrfanSkiljan.IrfanView"
        })

    $Krita.Add_Click( {
            Install-Software -Name $Krita.Text -Packages "KDE.Krita"
        })

    $PaintNet.Add_Click( {
            Install-Software -Name $PaintNet.Text -Packages "paint.net" -UseChocolatey
        })

    $ShareX.Add_Click( {
            Install-Software -Name $ShareX.Text -Packages "ShareX.ShareX"
        })

    $Atom.Add_Click( {
            Install-Software -Name $Atom.Text -Packages "GitHub.Atom"
        })

    $NotepadPlusPlus.Add_Click( {
            Install-Software -Name $NotepadPlusPlus.Text -Packages "Notepad++.Notepad++"
        })

    $VSCode.Add_Click( {
            Install-Software -Name $VSCode.Text -Packages "Microsoft.VisualStudioCode"
        })

    $VSCodium.Add_Click( {
            Install-Software -Name $VSCodium.Text -Packages "VSCodium.VSCodium"
        })

    $Dropbox.Add_Click( {
            Install-Software -Name $Dropbox.Text -Packages "Dropbox.Dropbox"
        })

    $GoogleDrive.Add_Click( {
            Install-Software -Name $GoogleDrive.Text -Packages "Google.Drive"
        })

    $BalenaEtcher.Add_Click( {
            Install-Software -Name $BalenaEtcher.Text -Packages "Balena.Etcher"
        })

    $Rufus.Add_Click( {
            Install-Software -Name $Rufus.Text -Packages "9PC3H3V7Q9CH" -UseMSStore
        })

    $Ventoy.Add_Click( {
            Install-Software -Name $Ventoy.Text -Packages "ventoy" -UseChocolatey
        })

    $Notion.Add_Click( {
            Install-Software -Name $Notion.Text -Packages "Notion.Notion"
        })

    $Obsidian.Add_Click( {
            Install-Software -Name $Obsidian.Text -Packages "Obsidian.Obsidian"
        })

    $CPUZ.Add_Click( {
            Install-Software -Name $CPUZ.Text -Packages "CPUID.CPU-Z"
        })

    $CrystalDiskInfo.Add_Click( {
            Install-Software -Name $CrystalDiskInfo.Text -Packages "CrystalDewWorld.CrystalDiskInfo"
        })

    $CrystalDiskMark.Add_Click( {
            Install-Software -Name $CrystalDiskMark.Text -Packages "CrystalDewWorld.CrystalDiskMark"
        })

    $GPUZ.Add_Click( {
            Install-Software -Name $GPUZ.Text -Packages "TechPowerUp.GPU-Z"
        })

    $NVCleanstall.Add_Click( {
            Install-Software -Name $NVCleanstall.Text -Packages "TechPowerUp.NVCleanstall"
        })

    $WSL2.Add_Click( {
            $Scripts = @("win10-wsl2-wslg-install.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $WSLPreview.Add_Click( {
            $Scripts = @("win11-wsl-preview-install.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $ArchWSL.Add_Click( {
            $Scripts = @("archwsl-install.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $Debian.Add_Click( {
            Install-Software -Name $Debian.Text -Packages "Debian" -UseWSL
        })

    $KaliLinux.Add_Click( {
            Install-Software -Name $KaliLinux.Text -Packages "kali-linux" -UseWSL
        })

    $OpenSuse.Add_Click( {
            Install-Software -Name $OpenSuse.Text -Packages "openSUSE-42" -UseWSL
        })

    $SLES.Add_Click( {
            Install-Software -Name $SLES.Text -Packages "SLES-12" -UseWSL
        })

    $Ubuntu.Add_Click( {
            Install-Software -Name $Ubuntu.Text -Packages "Ubuntu" -UseWSL
        })

    $Ubuntu16LTS.Add_Click( {
            Install-Software -Name $Ubuntu16LTS.Text -Packages "Ubuntu-16.04" -UseWSL
        })

    $Ubuntu18LTS.Add_Click( {
            Install-Software -Name $Ubuntu18LTS.Text -Packages "Ubuntu-18.04" -UseWSL
        })

    $Ubuntu20LTS.Add_Click( {
            Install-Software -Name $Ubuntu20LTS.Text -Packages "Ubuntu-20.04" -UseWSL
        })

    $InstallGamingDependencies.Add_Click( {
            $Scripts = @("install-gaming-dependencies.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $Discord.Add_Click( {
            Install-Software -Name $Discord.Text -Packages "Discord.Discord"
        })

    $MSTeams.Add_Click( {
            Install-Software -Name $MSTeams.Text -Packages "Microsoft.Teams"
        })

    $RocketChat.Add_Click( {
            Install-Software -Name $RocketChat.Text -Packages "RocketChat.RocketChat"
        })

    $Slack.Add_Click( {
            Install-Software -Name $Slack.Text -Packages "SlackTechnologies.Slack"
        })

    $Telegram.Add_Click( {
            Install-Software -Name $Telegram.Text -Packages "Telegram.TelegramDesktop"
        })

    $Zoom.Add_Click( {
            Install-Software -Name $Zoom.Text -Packages "Zoom.Zoom"
        })

    $BorderlessGaming.Add_Click( {
            Install-Software -Name $BorderlessGaming.Text -Packages "Codeusa.BorderlessGaming"
        })

    $EADesktop.Add_Click( {
            Install-Software -Name $EADesktop.Text -Packages "ElectronicArts.EADesktop"
        })

    $EpicGames.Add_Click( {
            Install-Software -Name $EpicGames.Text -Packages "EpicGames.EpicGamesLauncher"
        })

    $GogGalaxy.Add_Click( {
            Install-Software -Name $GogGalaxy.Text -Packages "GOG.Galaxy"
        })

    $Steam.Add_Click( {
            Install-Software -Name $Steam.Text -Packages "Valve.Steam"
        })

    $UbisoftConnect.Add_Click( {
            Install-Software -Name $UbisoftConnect.Text -Packages "Ubisoft.Connect"
        })

    $AnyDesk.Add_Click( {
            Install-Software -Name $AnyDesk.Text -Packages "AnyDeskSoftwareGmbH.AnyDesk"
        })

    $Parsec.Add_Click( {
            Install-Software -Name $Parsec.Text -Packages "Parsec.Parsec"
        })

    $ScrCpy.Add_Click( {
            Install-Software -Name $ScrCpy.Text -Packages "scrcpy" -UseChocolatey
        })

    $TeamViewer.Add_Click( {
            Install-Software -Name $TeamViewer.Text -Packages "TeamViewer.TeamViewer"
        })

    $HandBrake.Add_Click( {
            Install-Software -Name $HandBrake.Text -Packages "HandBrake.HandBrake"
        })

    $ObsStudio.Add_Click( {
            Install-Software -Name $ObsStudio.Text -Packages "OBSProject.OBSStudio"
        })

    $StreamlabsObs.Add_Click( {
            Install-Software -Name $StreamlabsObs.Text -Packages "Streamlabs.StreamlabsOBS"
        })

    $MpcHc.Add_Click( {
            Install-Software -Name $MpcHc.Text -Packages "clsid2.mpc-hc"
        })

    $Spotify.Add_Click( {
            Install-Software -Name $Spotify.Text -Packages "9NCBCSZSJRSB" -UseMSStore
        })

    $Vlc.Add_Click( {
            Install-Software -Name $Vlc.Text -Packages "VideoLAN.VLC"
        })

    $qBittorrent.Add_Click( {
            Install-Software -Name $qBittorrent.Text -Packages "qBittorrent.qBittorrent"
        })

    $Cemu.Add_Click( {
            Install-Software -Name $Cemu.Text -Packages "cemu" -UseChocolatey
        })

    $Dolphin.Add_Click( {
            Install-Software -Name $Dolphin.Text -Packages "DolphinEmulator.Dolphin"
        })

    $MGba.Add_Click( {
            Install-Software -Name $MGba.Text -Packages "JeffreyPfau.mGBA"
        })

    $PCSX2.Add_Click( {
            Install-Software -Name $PCSX2.Text -Packages "pcsx2.portable" -UseChocolatey
        })

    $PPSSPP.Add_Click( {
            Install-Software -Name $PPSSPP.Text -Packages "PPSSPPTeam.PPSSPP"
        })

    $Project64.Add_Click( {
            Install-Software -Name $Project64.Text -Packages "Project64.Project64.Dev"
        })

    $RetroArch.Add_Click( {
            Install-Software -Name $RetroArch.Text -Packages "retroarch" -UseChocolatey
        })

    $Snes9x.Add_Click( {
            Install-Software -Name $Snes9x.Text -Packages "snes9x" -UseChocolatey
        })

    [void]$Form.ShowDialog() # Show the Window
    $Form.Dispose() # When done, dispose of the GUI
}

function Main() {
    Clear-Host
    Request-AdminPrivilege # Check admin rights
    Get-ChildItem -Recurse $PSScriptRoot\*.ps*1 | Unblock-File

    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"download-web-file.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"get-os-info.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"gui-helper.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"file-runner.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"install-font.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"install-software.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"set-console-style.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"set-script-policy.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"show-dialog-window.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"show-debloat-info.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"start-logging.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"title-templates.psm1"

    Start-Logging -File (Split-Path -Path $PSCommandPath -Leaf).Split(".")[0]
    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Root Folder $PSScriptRoot"
    Set-ConsoleStyle            # Makes the console look cooler
    Unlock-ScriptUsage
    Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts "install-package-managers.ps1" -DoneTitle $DoneTitle -DoneMessage $DoneMessage -NoDialog # Install Winget and Chocolatey at the beginning
    Write-ScriptLogo            # Thanks Figlet
    Show-GUI                    # Load the GUI

    Write-Verbose "Restart: $Global:NeedRestart"
    If ($Global:NeedRestart) {
        Request-PcRestart       # Prompt options to Restart the PC
    }
    Stop-Logging
    Block-ScriptUsage
}

Main