function Request-AdminPrivileges() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

# https://docs.microsoft.com/en-us/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.1
# Adapted majorly from https://github.com/ChrisTitusTech/win10script and https://github.com/Sycnex/Windows10Debloater
function Show-GUI() {

    Set-GUILayout # Load the GUI Layout

    $Global:NeedRestart = $false
    $DoneTitle = "Done"
    $DoneMessage = "Process Completed!"

    # Main Window:
    $Form = New-Object System.Windows.Forms.Form
    $Form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
    $Form.FormBorderStyle = 'FixedSingle'   # Not adjustable
    $Form.MinimizeBox = $true               # Hide the Minimize Button
    $Form.MaximizeBox = $false              # Hide the Maximize Button
    $Form.Size = New-Object System.Drawing.Size(($FormWidth + 15), $FormHeight)
    $Form.StartPosition = 'CenterScreen'    # Appears on the center
    $Form.Text = "Win 10+ Smart Debloat Tools - by LeDragoX"
    $Form.TopMost = $false

    # Icon: https://stackoverflow.com/a/53377253
    $IconBase64 = [Convert]::ToBase64String((Get-Content "$PSScriptRoot\src\assets\windows-11-logo.png" -Encoding Byte))
    $IconBytes = [Convert]::FromBase64String($IconBase64)
    $Stream = New-Object IO.MemoryStream($IconBytes, 0, $IconBytes.Length)
    $Stream.Write($IconBytes, 0, $IconBytes.Length);
    $Form.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $Stream).GetHIcon())

    # Panels to put Labels and Buttons
    $Global:CurrentPanelIndex++
    $Panel1 = New-Panel -Width $PanelWidth -Height $FormHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $Global:CurrentPanelIndex++
    $Panel2 = New-Panel -Width $PanelWidth -Height ($FormHeight * 3.0) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $Global:CurrentPanelIndex++
    $Panel3 = New-Panel -Width ($PanelWidth - 15) -Height ($FormHeight * 3.0) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $Global:CurrentPanelIndex++
    $Panel4 = New-Panel -Width $PanelWidth -Height ($FormHeight * 3.0) -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0

    # Panel to put more Panels
    $FullPanel = New-Panel -Width (($PanelWidth * ($CurrentPanelIndex + 1))) -Height $FormHeight -LocationX 0 -LocationY 0 -HasVerticalScroll $true

    # Panels 1, 2, 3-4 ~> Title Label
    $TitleLabel1 = New-Label -Text "System Tweaks" -Width $LabelWidth -Height $TitleLabelHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $FontSize4 -FontStyle "Bold"
    $TitleLabel2 = New-Label -Text "Customize Tweaks" -Width $LabelWidth -Height $TitleLabelHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $FontSize4 -FontStyle "Bold"
    $TitleLabel3 = New-Label -Text "Software Install" -Width ($LabelWidth * 2) -Height $TitleLabelHeight -LocationX (($PanelWidth * ($CurrentPanelIndex - 1)) + $TitleLabelX) -LocationY $TitleLabelY -FontSize $FontSize4 -FontStyle "Bold"

    # Panel 3 ~> Caption Label
    $CaptionLabel1 = New-Label -Text "Package Managers: Winget and Chocolatey" -Width ($CaptionLabelWidth * 2) -Height $CaptionLabelHeight -LocationX ($PanelWidth * ($CurrentPanelIndex - 1)) -LocationY ($FirstButtonY - 25) -FontSize $FontSize1

    # Panel 1 ~> Big Button
    $ApplyTweaks = New-Button -Text "Apply Tweaks" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -FontStyle "Italic" -ForeColor $LightBlue

    # Panel 1 ~> Small Buttons
    $NextYLocation = $ApplyTweaks.Location.Y + $ApplyTweaks.Height + $DistanceBetweenButtons
    $RemoveXbox = New-Button -Text "Remove and Disable Xbox" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1 -ForeColor $WarningColor

    $NextYLocation = $RemoveXbox.Location.Y + $RemoveXbox.Height + $DistanceBetweenButtons
    $RepairWindows = New-Button -Text "Repair Windows" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $RepairWindows.Location.Y + $RepairWindows.Height + $DistanceBetweenButtons
    $InstallOneDrive = New-Button -Text "Install OneDrive" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $InstallOneDrive.Location.Y + $InstallOneDrive.Height + $DistanceBetweenButtons
    $ReinstallBloatApps = New-Button -Text "Reinstall Pre-Installed Apps" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 2 ~> Big Button
    $RevertScript = New-Button -Text "Revert Tweaks" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -FontStyle "Italic" -ForeColor $LightBlue

    # Panel 2 ~> Small Buttons
    $NextYLocation = $RevertScript.Location.Y + $RevertScript.Height + $DistanceBetweenButtons
    $DarkTheme = New-Button -Text "Dark Theme" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

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
    $InstallDrivers = New-Button -Text "Install CPU/GPU Drivers Updaters" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -FontStyle "Italic" -ForeColor $LightBlue

    # Panel 3 ~> Caption Label
    $NextYLocation = $InstallDrivers.Location.Y + $InstallDrivers.Height + $DistanceBetweenButtons
    $CaptionLabel3_1 = New-Label -Text "Web Browsers" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_1.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $BraveBrowser = New-Button -Text "Brave Browser" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $BraveBrowser.Location.Y + $BraveBrowser.Height + $DistanceBetweenButtons
    $GoogleChrome = New-Button -Text "Google Chrome + uBlock" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GoogleChrome.Location.Y + $GoogleChrome.Height + $DistanceBetweenButtons
    $MozillaFirefox = New-Button -Text "Mozilla Firefox" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $MozillaFirefox.Location.Y + $MozillaFirefox.Height + $DistanceBetweenButtons
    $CaptionLabel3_2 = New-Label -Text "File Compression" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_2.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $7Zip = New-Button -Text "7-Zip" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $7Zip.Location.Y + $7Zip.Height + $DistanceBetweenButtons
    $WinRar = New-Button -Text "WinRar (Trial)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $WinRar.Location.Y + $WinRar.Height + $DistanceBetweenButtons
    $CaptionLabel3_3 = New-Label -Text "Document Editors" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_3.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $OnlyOffice = New-Button -Text "ONLYOFFICE DesktopEditors" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $OnlyOffice.Location.Y + $OnlyOffice.Height + $DistanceBetweenButtons
    $LibreOffice = New-Button -Text "LibreOffice" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $LibreOffice.Location.Y + $LibreOffice.Height + $DistanceBetweenButtons
    $PowerBI = New-Button -Text "Power BI" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $PowerBI.Location.Y + $PowerBI.Height + $DistanceBetweenButtons
    $CaptionLabel3_4 = New-Label -Text "Image Tools" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_4.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $PaintNet = New-Button -Text "Paint.NET" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $PaintNet.Location.Y + $PaintNet.Height + $DistanceBetweenButtons
    $Gimp = New-Button -Text "GIMP" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Gimp.Location.Y + $Gimp.Height + $DistanceBetweenButtons
    $Inkscape = New-Button -Text "Inkscape" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Inkscape.Location.Y + $Inkscape.Height + $DistanceBetweenButtons
    $IrfanView = New-Button -Text "IrfanView" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $IrfanView.Location.Y + $IrfanView.Height + $DistanceBetweenButtons
    $Krita = New-Button -Text "Krita" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Krita.Location.Y + $Krita.Height + $DistanceBetweenButtons
    $ShareX = New-Button -Text "ShareX (Screenshots/GIFs)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $ShareX.Location.Y + $ShareX.Height + $DistanceBetweenButtons
    $CaptionLabel3_5 = New-Label -Text "Text Editors / IDEs" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_5.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $VSCode = New-Button -Text "Visual Studio Code" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $VSCode.Location.Y + $VSCode.Height + $DistanceBetweenButtons
    $NotepadPlusPlus = New-Button -Text "Notepad++" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $NotepadPlusPlus.Location.Y + $NotepadPlusPlus.Height + $DistanceBetweenButtons
    $CaptionLabel3_6 = New-Label -Text "Cloud Storage" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_6.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $GoogleDrive = New-Button -Text "Google Drive" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GoogleDrive.Location.Y + $GoogleDrive.Height + $DistanceBetweenButtons
    $Dropbox = New-Button -Text "Dropbox" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $Dropbox.Location.Y + $Dropbox.Height + $DistanceBetweenButtons
    $CaptionLabel3_7 = New-Label -Text "Academic Research" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_7.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Zotero = New-Button -Text "Zotero" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $Zotero.Location.Y + $Zotero.Height + $DistanceBetweenButtons
    $CaptionLabel3_8 = New-Label -Text "Networking" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_8.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $RadminVPN = New-Button -Text "Radmin VPN (LAN)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $RadminVPN.Location.Y + $RadminVPN.Height + $DistanceBetweenButtons
    $Hamachi = New-Button -Text "Hamachi (LAN)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $Hamachi.Location.Y + $Hamachi.Height + $DistanceBetweenButtons
    $CaptionLabel3_9 = New-Label -Text "2-Factor Authentication" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_9.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $AuthyDesktop = New-Button -Text "Authy Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $AuthyDesktop.Location.Y + $AuthyDesktop.Height + $DistanceBetweenButtons
    $CaptionLabel3_10 = New-Label -Text "Bootable USB" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_10.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Ventoy = New-Button -Text "Ventoy" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ventoy.Location.Y + $Ventoy.Height + $DistanceBetweenButtons
    $Rufus = New-Button -Text "Rufus" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Rufus.Location.Y + $Rufus.Height + $DistanceBetweenButtons
    $BalenaEtcher = New-Button -Text "Etcher" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Caption Label
    $NextYLocation = $BalenaEtcher.Location.Y + $BalenaEtcher.Height + $DistanceBetweenButtons
    $CaptionLabel3_11 = New-Label -Text "Development" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_11.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $WindowsTerminal = New-Button -Text "Windows Terminal" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $WindowsTerminal.Location.Y + $WindowsTerminal.Height + $DistanceBetweenButtons
    $GitAndKeysSetup = New-Button -Text "Git and Keys Setup" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GitAndKeysSetup.Location.Y + $GitAndKeysSetup.Height + $DistanceBetweenButtons
    $JavaJRE = New-Button -Text "Java JRE" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $JavaJRE.Location.Y + $JavaJRE.Height + $DistanceBetweenButtons
    $JavaJDKs = New-Button -Text "AdoptiumJDK 8, 11 and 17" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $JavaJDKs.Location.Y + $JavaJDKs.Height + $DistanceBetweenButtons
    $NodeJsLts = New-Button -Text "NodeJS LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $NodeJsLts.Location.Y + $NodeJsLts.Height + $DistanceBetweenButtons
    $NodeJs = New-Button -Text "NodeJS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $NodeJs.Location.Y + $NodeJs.Height + $DistanceBetweenButtons
    $Python3 = New-Button -Text "Python 3" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Python3.Location.Y + $Python3.Height + $DistanceBetweenButtons
    $Anaconda3 = New-Button -Text "Anaconda3 (Python)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Anaconda3.Location.Y + $Anaconda3.Height + $DistanceBetweenButtons
    $Ruby = New-Button -Text "Ruby with MSYS2" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ruby.Location.Y + $Ruby.Height + $DistanceBetweenButtons
    $ADB = New-Button -Text "Android Debug Bridge (ADB)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ADB.Location.Y + $ADB.Height + $DistanceBetweenButtons
    $AndroidStudio = New-Button -Text "Android Studio" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $AndroidStudio.Location.Y + $AndroidStudio.Height + $DistanceBetweenButtons
    $DockerDesktop = New-Button -Text "Docker Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DockerDesktop.Location.Y + $DockerDesktop.Height + $DistanceBetweenButtons
    $PostgreSQL = New-Button -Text "PostgreSQL" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $PostgreSQL.Location.Y + $PostgreSQL.Height + $DistanceBetweenButtons
    $MySQL = New-Button -Text "MySQL" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $MySQL.Location.Y + $MySQL.Height + $DistanceBetweenButtons
    $Insomnia = New-Button -Text "Insomnia" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Big Button
    $InstallGamingDependencies = New-Button -Text "Install Gaming Dependencies" -Width $ButtonWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -FontStyle "Italic" -ForeColor $LightBlue

    # Panel 4 ~> Caption Label
    $NextYLocation = $InstallGamingDependencies.Location.Y + $InstallGamingDependencies.Height + $DistanceBetweenButtons
    $CaptionLabel4_1 = New-Label -Text "Communication" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_1.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Discord = New-Button -Text "Discord" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Discord.Location.Y + $Discord.Height + $DistanceBetweenButtons
    $MSTeams = New-Button -Text "Microsoft Teams" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $MSTeams.Location.Y + $MSTeams.Height + $DistanceBetweenButtons
    $Slack = New-Button -Text "Slack" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Slack.Location.Y + $Slack.Height + $DistanceBetweenButtons
    $Zoom = New-Button -Text "Zoom" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Zoom.Location.Y + $Zoom.Height + $DistanceBetweenButtons
    $Telegram = New-Button -Text "Telegram Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Telegram.Location.Y + $Telegram.Height + $DistanceBetweenButtons
    $RocketChat = New-Button -Text "Rocket Chat" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $RocketChat.Location.Y + $RocketChat.Height + $DistanceBetweenButtons
    $CaptionLabel4_2 = New-Label -Text "Gaming" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_2.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Steam = New-Button -Text "Steam" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Steam.Location.Y + $Steam.Height + $DistanceBetweenButtons
    $GogGalaxy = New-Button -Text "GOG Galaxy" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GogGalaxy.Location.Y + $GogGalaxy.Height + $DistanceBetweenButtons
    $EpicGames = New-Button -Text "Epic Games Launcher" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EpicGames.Location.Y + $EpicGames.Height + $DistanceBetweenButtons
    $EADesktop = New-Button -Text "EA Desktop" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EADesktop.Location.Y + $EADesktop.Height + $DistanceBetweenButtons
    $UbisoftConnect = New-Button -Text "Ubisoft Connect" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $UbisoftConnect.Location.Y + $UbisoftConnect.Height + $DistanceBetweenButtons
    $BorderlessGaming = New-Button -Text "Borderless Gaming" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $BorderlessGaming.Location.Y + $BorderlessGaming.Height + $DistanceBetweenButtons
    $CaptionLabel4_3 = New-Label -Text "Planning" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_3.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Notion = New-Button -Text "Notion" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $Notion.Location.Y + $Notion.Height + $DistanceBetweenButtons
    $CaptionLabel4_4 = New-Label -Text "Remote Connection" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_4.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Parsec = New-Button -Text "Parsec" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Parsec.Location.Y + $Parsec.Height + $DistanceBetweenButtons
    $AnyDesk = New-Button -Text "AnyDesk" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $AnyDesk.Location.Y + $AnyDesk.Height + $DistanceBetweenButtons
    $TeamViewer = New-Button -Text "Team Viewer" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $TeamViewer.Location.Y + $TeamViewer.Height + $DistanceBetweenButtons
    $AndroidScrCpy = New-Button -Text "ScrCpy (Android)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $AndroidScrCpy.Location.Y + $AndroidScrCpy.Height + $DistanceBetweenButtons
    $CaptionLabel4_5 = New-Label -Text "Recording and Streaming" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_5.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $ObsStudio = New-Button -Text "OBS Studio" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ObsStudio.Location.Y + $ObsStudio.Height + $DistanceBetweenButtons
    $StreamlabsObs = New-Button -Text "Streamlabs OBS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $StreamlabsObs.Location.Y + $StreamlabsObs.Height + $DistanceBetweenButtons
    $HandBrake = New-Button -Text "HandBrake (Transcode)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $HandBrake.Location.Y + $HandBrake.Height + $DistanceBetweenButtons
    $CaptionLabel4_6 = New-Label -Text "Torrent" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_6.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $qBittorrent = New-Button -Text "qBittorrent" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $qBittorrent.Location.Y + $qBittorrent.Height + $DistanceBetweenButtons
    $CaptionLabel4_7 = New-Label -Text "Media Playing" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_7.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Vlc = New-Button -Text "VLC" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Vlc.Location.Y + $Vlc.Height + $DistanceBetweenButtons
    $MpcHc = New-Button -Text "Media Player Classic" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $MpcHc.Location.Y + $MpcHc.Height + $DistanceBetweenButtons
    $Spotify = New-Button -Text "Spotify" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $Spotify.Location.Y + $Spotify.Height + $DistanceBetweenButtons
    $CaptionLabel4_8 = New-Label -Text "Utilities" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_8.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $CPUZ = New-Button -Text "CPU-Z" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $CPUZ.Location.Y + $CPUZ.Height + $DistanceBetweenButtons
    $GPUZ = New-Button -Text "GPU-Z" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GPUZ.Location.Y + $GPUZ.Height + $DistanceBetweenButtons
    $CrystalDiskInfo = New-Button -Text "Crystal Disk Info" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $CrystalDiskInfo.Location.Y + $CrystalDiskInfo.Height + $DistanceBetweenButtons
    $CrystalDiskMark = New-Button -Text "Crystal Disk Mark" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $CrystalDiskMark.Location.Y + $CrystalDiskMark.Height + $DistanceBetweenButtons
    $NVCleanstall = New-Button -Text "NVCleanstall" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Caption Label
    $NextYLocation = $NVCleanstall.Location.Y + $NVCleanstall.Height + $DistanceBetweenButtons
    $CaptionLabel4_9 = New-Label -Text "Windows Subsystem For Linux" -Width $CaptionLabelWidth -Height $CaptionLabelHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 4 ~> Small Buttons
    $NextYLocation = $CaptionLabel4_9.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $WSL2 = New-Button -Text "WSL2 + WSLg (Win10/Insider)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $WSL2.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $WSLPreview = New-Button -Text "WSL Preview (Win 11)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $WSLPreview.Location.Y + $ButtonHeight + $DistanceBetweenButtons
    $Ubuntu = New-Button -Text "Ubuntu" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu.Location.Y + $Ubuntu.Height + $DistanceBetweenButtons
    $Debian = New-Button -Text "Debian GNU/Linux" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Debian.Location.Y + $Debian.Height + $DistanceBetweenButtons
    $KaliLinux = New-Button -Text "Kali Linux Rolling" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $KaliLinux.Location.Y + $KaliLinux.Height + $DistanceBetweenButtons
    $OpenSuse = New-Button -Text "Open SUSE 42" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $OpenSuse.Location.Y + $OpenSuse.Height + $DistanceBetweenButtons
    $SLES = New-Button -Text "SLES v12" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $SLES.Location.Y + $SLES.Height + $DistanceBetweenButtons
    $Ubuntu16LTS = New-Button -Text "Ubuntu 16.04 LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu16LTS.Location.Y + $Ubuntu16LTS.Height + $DistanceBetweenButtons
    $Ubuntu18LTS = New-Button -Text "Ubuntu 18.04 LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu18LTS.Location.Y + $Ubuntu18LTS.Height + $DistanceBetweenButtons
    $Ubuntu20LTS = New-Button -Text "Ubuntu 20.04 LTS" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu20LTS.Location.Y + $Ubuntu20LTS.Height + $DistanceBetweenButtons
    $ArchWSL = New-Button -Text "ArchWSL (x64)" -Width $ButtonWidth -Height $ButtonHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Image Logo from the Script
    $PictureBox1 = New-Object System.Windows.Forms.PictureBox
    $PictureBox1.Width = 150
    $PictureBox1.Height = 150
    $PictureBox1.Location = New-Object System.Drawing.Point((($PanelWidth * 0.72) - $PictureBox1.Width), (($FormHeight * 0.90) - $PictureBox1.Height))
    $PictureBox1.imageLocation = "$PSScriptRoot\src\assets\script-logo.png"
    $PictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom

    # Add all Panels to the Form (Screen)
    $Form.Controls.AddRange(@($FullPanel))

    # Add Elements to each Panel
    $FullPanel.Controls.AddRange(@($TitleLabel3, $CaptionLabel1))
    $FullPanel.Controls.AddRange(@($Panel1, $Panel2, $Panel3, $Panel4))

    $Panel1.Controls.AddRange(@($TitleLabel1, $ApplyTweaks, $RemoveXbox, $RepairWindows, $InstallOneDrive, $ReinstallBloatApps, $PictureBox1))
    $Panel2.Controls.AddRange(@($TitleLabel2, $RevertScript, $DarkTheme, $LightTheme, $EnableSearchIdx, $DisableSearchIdx, $EnableBgApps, $DisableBgApps, $EnableTelemetry, $DisableTelemetry, $EnableCortana, $DisableCortana, $EnableGameBarAndDVR, $DisableGameBarAndDVR, $EnableClipboardHistory, $DisableClipboardHistory, $EnableOldVolumeControl, $DisableOldVolumeControl))

    $Panel3.Controls.AddRange(@($InstallDrivers, $CaptionLabel3_1, $BraveBrowser, $GoogleChrome, $MozillaFirefox))
    $Panel3.Controls.AddRange(@($CaptionLabel3_2, $7Zip, $WinRar))
    $Panel3.Controls.AddRange(@($CaptionLabel3_3, $OnlyOffice, $LibreOffice, $PowerBI))
    $Panel3.Controls.AddRange(@($CaptionLabel3_4, $PaintNet, $Gimp, $Inkscape, $IrfanView, $Krita, $ShareX))
    $Panel3.Controls.AddRange(@($CaptionLabel3_5, $VSCode, $NotepadPlusPlus))
    $Panel3.Controls.AddRange(@($CaptionLabel3_6, $GoogleDrive, $Dropbox))
    $Panel3.Controls.AddRange(@($CaptionLabel3_7, $Zotero))
    $Panel3.Controls.AddRange(@($CaptionLabel3_8, $RadminVPN, $Hamachi))
    $Panel3.Controls.AddRange(@($CaptionLabel3_9, $AuthyDesktop))
    $Panel3.Controls.AddRange(@($CaptionLabel3_10, $Ventoy, $Rufus, $BalenaEtcher))
    $Panel3.Controls.AddRange(@($CaptionLabel3_11, $WindowsTerminal, $GitAndKeysSetup, $JavaJRE, $JavaJDKs, $NodeJsLts, $NodeJs, $Python3, $Anaconda3, $Ruby, $ADB, $AndroidStudio, $DockerDesktop, $PostgreSQL, $MySQL, $Insomnia))

    $Panel4.Controls.AddRange(@($InstallGamingDependencies, $CaptionLabel4_1, $Discord, $MSTeams, $Slack, $Zoom, $Telegram, $RocketChat))
    $Panel4.Controls.AddRange(@($CaptionLabel4_2, $Steam, $GogGalaxy, $EpicGames, $EADesktop, $UbisoftConnect, $BorderlessGaming))
    $Panel4.Controls.AddRange(@($CaptionLabel4_3, $Notion))
    $Panel4.Controls.AddRange(@($CaptionLabel4_4, $Parsec, $AnyDesk, $TeamViewer, $AndroidScrCpy))
    $Panel4.Controls.AddRange(@($CaptionLabel4_5, $ObsStudio, $StreamlabsObs, $HandBrake))
    $Panel4.Controls.AddRange(@($CaptionLabel4_6, $qBittorrent))
    $Panel4.Controls.AddRange(@($CaptionLabel4_7, $Vlc, $MpcHc, $Spotify))
    $Panel4.Controls.AddRange(@($CaptionLabel4_8, $CPUZ, $GPUZ, $CrystalDiskInfo, $CrystalDiskMark, $NVCleanstall))
    $Panel4.Controls.AddRange(@($CaptionLabel4_9, $WSL2, $WSLPreview, $Ubuntu, $Debian, $KaliLinux, $OpenSuse, $SLES, $Ubuntu16LTS, $Ubuntu18LTS, $Ubuntu20LTS, $ArchWSL))

    # <== CLICK EVENTS ==>

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
                "optimize-optional-features.ps1",
                "win11-wsl-preview-install.ps1"
            )

            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage

            $PictureBox1.imageLocation = "$PSScriptRoot\src\assets\script-logo2.png"
            $PictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
            $Form.Update()
            $Global:NeedRestart = $true
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
            Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $RevertScript.Add_Click( {
            $Global:Revert = $true
            $Scripts = @("optimize-scheduled-tasks.ps1", "optimize-services.ps1", "optimize-privacy-and-performance.ps1", "personal-tweaks.ps1", "optimize-optional-features.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
            $Global:Revert = $false
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
            Install-Software -Name $BraveBrowser.Text -PackageName "BraveSoftware.BraveBrowser"
        })

    $GoogleChrome.Add_Click( {
            Install-Software -Name $GoogleChrome.Text -PackageName "Google.Chrome" -InstallBlock { winget install --silent --source "winget" --id $Package; choco install -y "ublockorigin-chrome" }
        })

    $MozillaFirefox.Add_Click( {
            Install-Software -Name $MozillaFirefox.Text -PackageName "Mozilla.Firefox"
        })

    $7Zip.Add_Click( {
            Install-Software -Name $7Zip.Text -PackageName "7zip.7zip"
        })

    $WinRar.Add_Click( {
            Install-Software -Name $WinRar.Text -PackageName "winrar" -InstallBlock { choco install -y $Package }
        })

    $OnlyOffice.Add_Click( {
            Install-Software -Name $OnlyOffice.Text -PackageName "ONLYOFFICE.DesktopEditors"
        })

    $LibreOffice.Add_Click( {
            Install-Software -Name $LibreOffice.Text -PackageName "LibreOffice.LibreOffice"
        })

    $PowerBI.Add_Click( {
            Install-Software -Name $PowerBI.Text -PackageName "Microsoft.PowerBI"
        })

    $PaintNet.Add_Click( {
            Install-Software -Name $PaintNet.Text -PackageName "paint.net" -InstallBlock { choco install -y $Package }
        })

    $Gimp.Add_Click( {
            Install-Software -Name $Gimp.Text -PackageName "GIMP.GIMP"
        })

    $Inkscape.Add_Click( {
            Install-Software -Name $Inkscape.Text -PackageName "Inkscape.Inkscape"
        })

    $IrfanView.Add_Click( {
            Install-Software -Name $IrfanView.Text -PackageName "IrfanSkiljan.IrfanView"
        })

    $Krita.Add_Click( {
            Install-Software -Name $Krita.Text -PackageName "KDE.Krita"
        })

    $ShareX.Add_Click( {
            Install-Software -Name $ShareX.Text -PackageName "ShareX.ShareX"
        })

    $VSCode.Add_Click( {
            Install-Software -Name $VSCode.Text -PackageName "Microsoft.VisualStudioCode"
        })

    $NotepadPlusPlus.Add_Click( {
            Install-Software -Name $NotepadPlusPlus.Text -PackageName "Notepad++.Notepad++"
        })

    $GoogleDrive.Add_Click( {
            Install-Software -Name $GoogleDrive.Text -PackageName "Google.Drive"
        })

    $Dropbox.Add_Click( {
            Install-Software -Name $Dropbox.Text -PackageName "Dropbox.Dropbox"
        })

    $Zotero.Add_Click( {
            Install-Software -Name $Zotero.Text -PackageName "Zotero.Zotero"
        })

    $RadminVPN.Add_Click( {
            Install-Software -Name $RadminVPN.Text -PackageName "Radmin.VPN"
        })

    $Hamachi.Add_Click( {
            Install-Software -Name $Hamachi.Text -PackageName "LogMeIn.Hamachi"
        })

    $AuthyDesktop.Add_Click( {
            Install-Software -Name $AuthyDesktop.Text -PackageName "Twilio.Authy"
        })

    $Ventoy.Add_Click( {
            Install-Software -Name $Ventoy.Text -PackageName "Ventoy" -InstallBlock { choco install -y $Package }
        })

    $Rufus.Add_Click( {
            Install-Software -Name $Rufus.Text -PackageName "Rufus" -InstallBlock { choco install -y $Package }
        })

    $BalenaEtcher.Add_Click( {
            Install-Software -Name $BalenaEtcher.Text -PackageName "Balena.Etcher"
        })

    $WindowsTerminal.Add_Click( {
            Install-Software -Name $WindowsTerminal.Text -PackageName "Microsoft.WindowsTerminal"
        })

    $GitAndKeysSetup.Add_Click( {
            $Scripts = @("setup-git-keys-and-sign.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $JavaJRE.Add_Click( {
            Install-Software -Name $JavaJRE.Text -PackageName "Oracle.JavaRuntimeEnvironment"
        })

    $JavaJDKs.Add_Click( {
            Install-Software -Name $JavaJDKs.Text -PackageName @("EclipseAdoptium.Temurin.8", "EclipseAdoptium.Temurin.11", "EclipseAdoptium.Temurin.17")
        })

    $NodeJsLts.Add_Click( {
            Install-Software -Name $NodeJsLts.Text -PackageName "OpenJS.NodeJSLTS"
        })

    $NodeJs.Add_Click( {
            Install-Software -Name $NodeJs.Text -PackageName "OpenJS.NodeJS"
        })

    $Python3.Add_Click( {
            Install-Software -Name $Python3.Text -PackageName "Python.Python.3"
        })

    $Anaconda3.Add_Click( {
            Install-Software -Name $Anaconda3.Text -PackageName "Anaconda.Anaconda3"
        })

    $Ruby.Add_Click( {
            Install-Software -Name $Ruby.Text -PackageName "RubyInstallerTeam.RubyWithDevKit"
        })

    $ADB.Add_Click( {
            Install-Software -Name $ADB.Text -PackageName "adb" -InstallBlock { choco install -y $Package }
        })

    $AndroidStudio.Add_Click( {
            Install-Software -Name $AndroidStudio.Text -PackageName "Google.AndroidStudio"
        })

    $DockerDesktop.Add_Click( {
            Install-Software -Name $DockerDesktop.Text -PackageName "Docker.DockerDesktop"
        })

    $PostgreSQL.Add_Click( {
            Install-Software -Name $PostgreSQL.Text -PackageName "PostgreSQL.PostgreSQL"
        })

    $MySQL.Add_Click( {
            Install-Software -Name $MySQL.Text -PackageName "Oracle.MySQL"
        })

    $Insomnia.Add_Click( {
            Install-Software -Name $Insomnia.Text -PackageName "Insomnia.Insomnia"
        })

    $InstallGamingDependencies.Add_Click( {
            $Scripts = @("install-gaming-dependencies.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $Discord.Add_Click( {
            Install-Software -Name $Discord.Text -PackageName "Discord.Discord"
        })

    $MSTeams.Add_Click( {
            Install-Software -Name $MSTeams.Text -PackageName "Microsoft.Teams"
        })

    $Slack.Add_Click( {
            Install-Software -Name $Slack.Text -PackageName "SlackTechnologies.Slack"
        })

    $Zoom.Add_Click( {
            Install-Software -Name $Zoom.Text -PackageName "Zoom.Zoom"
        })

    $Telegram.Add_Click( {
            Install-Software -Name $Telegram.Text -PackageName "Telegram.TelegramDesktop"
        })

    $RocketChat.Add_Click( {
            Install-Software -Name $RocketChat.Text -PackageName "RocketChat.RocketChat"
        })

    $Steam.Add_Click( {
            Install-Software -Name $Steam.Text -PackageName "Valve.Steam"
        })

    $GogGalaxy.Add_Click( {
            Install-Software -Name $GogGalaxy.Text -PackageName "GOG.Galaxy"
        })

    $EpicGames.Add_Click( {
            Install-Software -Name $EpicGames.Text -PackageName "EpicGames.EpicGamesLauncher"
        })

    $EADesktop.Add_Click( {
            Install-Software -Name $EADesktop.Text -PackageName "ElectronicArts.EADesktop"
        })

    $UbisoftConnect.Add_Click( {
            Install-Software -Name $UbisoftConnect.Text -PackageName "Ubisoft.Connect"
        })

    $BorderlessGaming.Add_Click( {
            Install-Software -Name $BorderlessGaming.Text -PackageName "Codeusa.BorderlessGaming"
        })

    $Notion.Add_Click( {
            Install-Software -Name $Notion.Text -PackageName "Notion.Notion"
        })

    $Parsec.Add_Click( {
            Install-Software -Name $Parsec.Text -PackageName "Parsec.Parsec"
        })

    $AnyDesk.Add_Click( {
            Install-Software -Name $AnyDesk.Text -PackageName "AnyDeskSoftwareGmbH.AnyDesk"
        })

    $TeamViewer.Add_Click( {
            Install-Software -Name $TeamViewer.Text -PackageName "TeamViewer.TeamViewer"
        })

    $AndroidScrCpy.Add_Click( {
            Install-Software -Name $AndroidScrCpy.Text -PackageName "scrcpy" -InstallBlock { choco install -y $Package }
        })

    $ObsStudio.Add_Click( {
            Install-Software -Name $ObsStudio.Text -PackageName "OBSProject.OBSStudio"
        })

    $StreamlabsObs.Add_Click( {
            Install-Software -Name $StreamlabsObs.Text -PackageName "Streamlabs.StreamlabsOBS"
        })

    $HandBrake.Add_Click( {
            Install-Software -Name $HandBrake.Text -PackageName "HandBrake.HandBrake"
        })

    $qBittorrent.Add_Click( {
            Install-Software -Name $qBittorrent.Text -PackageName "qBittorrent.qBittorrent"
        })

    $Vlc.Add_Click( {
            Install-Software -Name $Vlc.Text -PackageName "VideoLAN.VLC"
        })

    $MpcHc.Add_Click( {
            Install-Software -Name $MpcHc.Text -PackageName "clsid2.mpc-hc"
        })

    $Spotify.Add_Click( {
            Install-Software -Name $Spotify.Text -PackageName "Spotify.Spotify"
        })

    $CPUZ.Add_Click( {
            Install-Software -Name $CPUZ.Text -PackageName "CPUID.CPU-Z"
        })

    $GPUZ.Add_Click( {
            Install-Software -Name $GPUZ.Text -PackageName "TechPowerUp.GPU-Z"
        })

    $CrystalDiskInfo.Add_Click( {
            Install-Software -Name $CrystalDiskInfo.Text -PackageName "CrystalDewWorld.CrystalDiskInfo"
        })

    $CrystalDiskMark.Add_Click( {
            Install-Software -Name $CrystalDiskMark.Text -PackageName "CrystalDewWorld.CrystalDiskMark"
        })

    $NVCleanstall.Add_Click( {
            Install-Software -Name $NVCleanstall.Text -PackageName "TechPowerUp.NVCleanstall"
        })

    $WSL2.Add_Click( {
            $Scripts = @("win10-wsl2-wslg-install.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $WSLPreview.Add_Click( {
            $Scripts = @("win11-wsl-preview-install.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $Ubuntu.Add_Click( {
            Install-Software -Name $Ubuntu.Text -PackageName "Ubuntu" -InstallBlock { wsl --install --distribution $Package }
        })

    $Debian.Add_Click( {
            Install-Software -Name $Debian.Text -PackageName "Debian" -InstallBlock { wsl --install --distribution $Package }
        })

    $KaliLinux.Add_Click( {
            Install-Software -Name $KaliLinux.Text -PackageName "kali-linux" -InstallBlock { wsl --install --distribution $Package }
        })

    $OpenSuse.Add_Click( {
            Install-Software -Name $OpenSuse.Text -PackageName "openSUSE-42" -InstallBlock { wsl --install --distribution $Package }
        })

    $SLES.Add_Click( {
            Install-Software -Name $SLES.Text -PackageName "SLES-12" -InstallBlock { wsl --install --distribution $Package }
        })

    $Ubuntu16LTS.Add_Click( {
            Install-Software -Name $Ubuntu16LTS.Text -PackageName "Ubuntu-16.04" -InstallBlock { wsl --install --distribution $Package }
        })

    $Ubuntu18LTS.Add_Click( {
            Install-Software -Name $Ubuntu18LTS.Text -PackageName "Ubuntu-18.04" -InstallBlock { wsl --install --distribution $Package }
        })

    $Ubuntu20LTS.Add_Click( {
            Install-Software -Name $Ubuntu20LTS.Text -PackageName "Ubuntu-20.04" -InstallBlock { wsl --install --distribution $Package }
        })

    $ArchWSL.Add_Click( {
            $Scripts = @("archwsl-install.ps1")
            Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    # Show the Window
    [void]$Form.ShowDialog()

    # When done, dispose of the GUI
    $Form.Dispose()

}

function Main() {

    Clear-Host
    Request-AdminPrivileges # Check admin rights

    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Root Folder $PSScriptRoot"
    Get-ChildItem -Recurse $PSScriptRoot\*.ps*1 | Unblock-File

    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"set-console-style.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"file-runner.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"install-software.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"gui-helper.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"set-script-policy.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"show-message-box.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"title-templates.psm1"

    Set-ConsoleStyle            # Makes the console look cooler
    Unlock-ScriptUsage
    Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts "install-package-managers.ps1" -DoneTitle $DoneTitle -DoneMessage $DoneMessage -ShowDoneWindow $false # Install Winget and Chocolatey at the beginning
    Write-ASCIIScriptName       # Thanks Figlet
    Show-GUI                    # Load the GUI

    Write-Verbose "Restart: $Global:NeedRestart"
    If ($Global:NeedRestart) {
        Request-PcRestart       # Prompt options to Restart the PC
    }
    Block-ScriptUsage

}

Main