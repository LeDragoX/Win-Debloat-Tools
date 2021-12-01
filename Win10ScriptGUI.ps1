function Request-PrivilegesElevation() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

# https://docs.microsoft.com/pt-br/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.1
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
    $Form.Size = New-Object System.Drawing.Size($MaxWidth, $MaxHeight)
    $Form.StartPosition = 'CenterScreen'    # Appears on the center
    $Form.Text = "Windows 10+ Smart Debloat - by LeDragoX"
    $Form.TopMost = $false

    # Icon: https://stackoverflow.com/a/53377253
    $IconBase64 = [Convert]::ToBase64String((Get-Content "$PSScriptRoot\src\assets\windows-11-logo.png" -Encoding Byte))
    $IconBytes = [Convert]::FromBase64String($IconBase64)
    $Stream = New-Object IO.MemoryStream($IconBytes, 0, $IconBytes.Length)
    $Stream.Write($IconBytes, 0, $IconBytes.Length);
    $Form.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $Stream).GetHIcon())

    # Panels to put Labels and Buttons
    $Global:CurrentPanelIndex++
    $Panel1 = Create-Panel -Width $PWidth -Height $PHeight -LocationX ($PWidth * $CurrentPanelIndex) -LocationY 0
    $Global:CurrentPanelIndex++
    $Panel2 = Create-Panel -Width $PWidth -Height $PHeight -LocationX ($PWidth * $CurrentPanelIndex) -LocationY 0

    # Panels to put Title, Labels and more Panels
    $Global:CurrentPanelIndex++
    $Panel3 = Create-Panel -Width (($PWidth * 2) - 15) -Height $PHeight -LocationX ($PWidth * $CurrentPanelIndex) -LocationY 0 -HasVerticalScroll $true

    # Panels to put Labels and Buttons
    $Panel3_1 = Create-Panel -Width ($PWidth - 15) -Height ($PHeight * 2.9) -LocationX 0 -LocationY 0
    $Global:CurrentPanelIndex++
    $Panel3_2 = Create-Panel -Width $PWidth -Height ($PHeight * 2.9) -LocationX ($PWidth - 15) -LocationY 0

    # Panels 1, 2, 3 ~> Title Label
    $TitleLabel1 = Create-Label -Text "System Tweaks" -Width $TLWidth -Height $TLHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $FontSize4 -FontStyle "Bold"
    $TitleLabel2 = Create-Label -Text "Customize Tweaks" -Width $TLWidth -Height $TLHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $FontSize4 -FontStyle "Bold"
    $TitleLabel3 = Create-Label -Text "Software Install" -Width ($TLWidth * 2) -Height $TLHeight -LocationX $TitleLabelX -LocationY $TitleLabelY -FontSize $FontSize4 -FontStyle "Bold"

    # Panel 3 ~> Caption Label
    $CaptionLabel1 = Create-Label -Text "Winget = Native | Chocolatey = 3rd Party" -Width ($CLWidth * 2) -Height $CLHeight -LocationX 0 -LocationY ($FirstButtonY - 25) -FontSize $FontSize1

    # Panel 1 ~> Big Button
    $ApplyTweaks = Create-Button -Text "Apply Tweaks" -Width $BBWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -FontStyle "Italic" -ForeColor $LightBlue

    # Panel 1 ~> Small Buttons
    $NextYLocation = $ApplyTweaks.Location.Y + $ApplyTweaks.Height + $DistanceBetweenButtons
    $RemoveXbox = Create-Button -Text "Remove and Disable Xbox" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1 -ForeColor $WarningColor

    $NextYLocation = $RemoveXbox.Location.Y + $RemoveXbox.Height + $DistanceBetweenButtons
    $RepairWindows = Create-Button -Text "Repair Windows" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $RepairWindows.Location.Y + $RepairWindows.Height + $DistanceBetweenButtons
    $InstallOneDrive = Create-Button -Text "Install OneDrive" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $InstallOneDrive.Location.Y + $InstallOneDrive.Height + $DistanceBetweenButtons
    $ReinstallBloatApps = Create-Button -Text "Reinstall Pre-Installed Apps" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 2 ~> Big Button
    $RevertScript = Create-Button -Text "Revert Tweaks" -Width $BBWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -FontStyle "Italic" -ForeColor $LightBlue

    # Panel 2 ~> Small Buttons
    $NextYLocation = $RevertScript.Location.Y + $RevertScript.Height + $DistanceBetweenButtons
    $DarkMode = Create-Button -Text "Dark Mode" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DarkMode.Location.Y + $DarkMode.Height + $DistanceBetweenButtons
    $LightMode = Create-Button -Text "Light Mode" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $LightMode.Location.Y + $LightMode.Height + $DistanceBetweenButtons
    $EnableSearchIdx = Create-Button -Text "Enable Search Indexing" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EnableSearchIdx.Location.Y + $EnableSearchIdx.Height + $DistanceBetweenButtons
    $DisableSearchIdx = Create-Button -Text "Disable Search Indexing" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DisableSearchIdx.Location.Y + $DisableSearchIdx.Height + $DistanceBetweenButtons
    $EnableBgApps = Create-Button -Text "Enable Background Apps" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EnableBgApps.Location.Y + $EnableBgApps.Height + $DistanceBetweenButtons
    $DisableBgApps = Create-Button -Text "Disable Background Apps" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DisableBgApps.Location.Y + $DisableBgApps.Height + $DistanceBetweenButtons
    $EnableTelemetry = Create-Button -Text "Enable Full Telemetry" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EnableTelemetry.Location.Y + $EnableTelemetry.Height + $DistanceBetweenButtons
    $DisableTelemetry = Create-Button -Text "Disable Telemetry" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DisableTelemetry.Location.Y + $DisableTelemetry.Height + $DistanceBetweenButtons
    $EnableCortana = Create-Button -Text "Enable Cortana" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EnableCortana.Location.Y + $EnableCortana.Height + $DistanceBetweenButtons
    $DisableCortana = Create-Button -Text "Disable Cortana" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Big Button
    $InstallDrivers = Create-Button -Text "Install CPU/GPU Drivers Updaters" -Width $BBWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -FontStyle "Italic" -ForeColor $LightBlue

    # Panel 3.1 ~> Caption Label
    $NextYLocation = $InstallDrivers.Location.Y + $InstallDrivers.Height + $DistanceBetweenButtons
    $CaptionLabel3_1_1 = Create-Label -Text "Web Browsers" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_1_1.Location.Y + $SBHeight + $DistanceBetweenButtons
    $BraveBrowser = Create-Button -Text "Brave Browser" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $BraveBrowser.Location.Y + $BraveBrowser.Height + $DistanceBetweenButtons
    $GoogleChrome = Create-Button -Text "Google Chrome + uBlock" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GoogleChrome.Location.Y + $GoogleChrome.Height + $DistanceBetweenButtons
    $MozillaFirefox = Create-Button -Text "Mozilla Firefox" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Caption Label
    $NextYLocation = $MozillaFirefox.Location.Y + $MozillaFirefox.Height + $DistanceBetweenButtons
    $CaptionLabel3_1_2 = Create-Label -Text "Compression" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_1_2.Location.Y + $SBHeight + $DistanceBetweenButtons
    $7Zip = Create-Button -Text "7-Zip" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $7Zip.Location.Y + $7Zip.Height + $DistanceBetweenButtons
    $WinRar = Create-Button -Text "WinRar (Trial)" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Caption Label
    $NextYLocation = $WinRar.Location.Y + $WinRar.Height + $DistanceBetweenButtons
    $CaptionLabel3_1_3 = Create-Label -Text "Documents" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_1_3.Location.Y + $SBHeight + $DistanceBetweenButtons
    $OnlyOffice = Create-Button -Text "ONLYOFFICE DesktopEditors" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $OnlyOffice.Location.Y + $OnlyOffice.Height + $DistanceBetweenButtons
    $LibreOffice = Create-Button -Text "LibreOffice" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $LibreOffice.Location.Y + $LibreOffice.Height + $DistanceBetweenButtons
    $PowerBI = Create-Button -Text "Power BI" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Caption Label
    $NextYLocation = $PowerBI.Location.Y + $PowerBI.Height + $DistanceBetweenButtons
    $CaptionLabel3_1_4 = Create-Label -Text "Imaging" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_1_4.Location.Y + $SBHeight + $DistanceBetweenButtons
    $PaintNet = Create-Button -Text "Paint.NET" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $PaintNet.Location.Y + $PaintNet.Height + $DistanceBetweenButtons
    $Gimp = Create-Button -Text "GIMP" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Gimp.Location.Y + $Gimp.Height + $DistanceBetweenButtons
    $Inkscape = Create-Button -Text "Inkscape" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Inkscape.Location.Y + $Inkscape.Height + $DistanceBetweenButtons
    $IrfanView = Create-Button -Text "IrfanView" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $IrfanView.Location.Y + $IrfanView.Height + $DistanceBetweenButtons
    $Krita = Create-Button -Text "Krita" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Krita.Location.Y + $Krita.Height + $DistanceBetweenButtons
    $ShareX = Create-Button -Text "ShareX" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Caption Label
    $NextYLocation = $ShareX.Location.Y + $ShareX.Height + $DistanceBetweenButtons
    $CaptionLabel3_1_5 = Create-Label -Text "Text Editors | IDEs" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_1_5.Location.Y + $SBHeight + $DistanceBetweenButtons
    $VSCode = Create-Button -Text "Visual Studio Code" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $VSCode.Location.Y + $VSCode.Height + $DistanceBetweenButtons
    $NotepadPlusPlus = Create-Button -Text "Notepad++" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Caption Label
    $NextYLocation = $NotepadPlusPlus.Location.Y + $NotepadPlusPlus.Height + $DistanceBetweenButtons
    $CaptionLabel3_1_6 = Create-Label -Text "Cloud Storage" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_1_6.Location.Y + $SBHeight + $DistanceBetweenButtons
    $GoogleDrive = Create-Button -Text "Google Drive" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GoogleDrive.Location.Y + $GoogleDrive.Height + $DistanceBetweenButtons
    $Dropbox = Create-Button -Text "Dropbox" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Caption Label
    $NextYLocation = $Dropbox.Location.Y + $Dropbox.Height + $DistanceBetweenButtons
    $CaptionLabel3_1_7 = Create-Label -Text "2-Factor Authentication" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_1_7.Location.Y + $SBHeight + $DistanceBetweenButtons
    $AuthyDesktop = Create-Button -Text "Authy Desktop" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Caption Label
    $NextYLocation = $AuthyDesktop.Location.Y + $AuthyDesktop.Height + $DistanceBetweenButtons
    $CaptionLabel3_1_8 = Create-Label -Text "Development" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.1 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_1_8.Location.Y + $SBHeight + $DistanceBetweenButtons
    $WindowsTerminal = Create-Button -Text "Windows Terminal" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $WindowsTerminal.Location.Y + $WindowsTerminal.Height + $DistanceBetweenButtons
    $GitAndKeysSetup = Create-Button -Text "Git and Keys Setup" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GitAndKeysSetup.Location.Y + $GitAndKeysSetup.Height + $DistanceBetweenButtons
    $JavaJRE = Create-Button -Text "Java JRE" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $JavaJRE.Location.Y + $JavaJRE.Height + $DistanceBetweenButtons
    $JavaJDKs = Create-Button -Text "AdoptOpenJDK 8, 11 and 16" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $JavaJDKs.Location.Y + $JavaJDKs.Height + $DistanceBetweenButtons
    $NodeJsLts = Create-Button -Text "NodeJS LTS" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $NodeJsLts.Location.Y + $NodeJsLts.Height + $DistanceBetweenButtons
    $NodeJs = Create-Button -Text "NodeJS" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $NodeJs.Location.Y + $NodeJs.Height + $DistanceBetweenButtons
    $Python3 = Create-Button -Text "Python 3" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Python3.Location.Y + $Python3.Height + $DistanceBetweenButtons
    $Anaconda3 = Create-Button -Text "Anaconda3 (Python)" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Anaconda3.Location.Y + $Anaconda3.Height + $DistanceBetweenButtons
    $Ruby = Create-Button -Text "Ruby with MSYS2" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ruby.Location.Y + $Ruby.Height + $DistanceBetweenButtons
    $ADB = Create-Button -Text "Android Debug Bridge (ADB)" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ADB.Location.Y + $ADB.Height + $DistanceBetweenButtons
    $AndroidStudio = Create-Button -Text "Android Studio" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $AndroidStudio.Location.Y + $AndroidStudio.Height + $DistanceBetweenButtons
    $DockerDesktop = Create-Button -Text "Docker Desktop" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $DockerDesktop.Location.Y + $DockerDesktop.Height + $DistanceBetweenButtons
    $PostgreSQL = Create-Button -Text "PostgreSQL" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $PostgreSQL.Location.Y + $PostgreSQL.Height + $DistanceBetweenButtons
    $MySQL = Create-Button -Text "MySQL" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Big Button
    $InstallGamingDependencies = Create-Button -Text "Install Gaming Dependencies" -Width $BBWidth -Height $BBHeight -LocationX $ButtonX -LocationY $FirstButtonY -FontSize $FontSize2 -FontStyle "Italic" -ForeColor $LightBlue

    # Panel 3.2 ~> Caption Label
    $NextYLocation = $InstallGamingDependencies.Location.Y + $InstallGamingDependencies.Height + $DistanceBetweenButtons
    $CaptionLabel3_2_1 = Create-Label -Text "Communication" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_2_1.Location.Y + $SBHeight + $DistanceBetweenButtons
    $Discord = Create-Button -Text "Discord" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Discord.Location.Y + $Discord.Height + $DistanceBetweenButtons
    $MSTeams = Create-Button -Text "Microsoft Teams" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $MSTeams.Location.Y + $MSTeams.Height + $DistanceBetweenButtons
    $Slack = Create-Button -Text "Slack" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Slack.Location.Y + $Slack.Height + $DistanceBetweenButtons
    $Zoom = Create-Button -Text "Zoom" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Zoom.Location.Y + $Zoom.Height + $DistanceBetweenButtons
    $RocketChat = Create-Button -Text "Rocket Chat" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Caption Label
    $NextYLocation = $RocketChat.Location.Y + $RocketChat.Height + $DistanceBetweenButtons
    $CaptionLabel3_2_2 = Create-Label -Text "Gaming" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_2_2.Location.Y + $SBHeight + $DistanceBetweenButtons
    $Steam = Create-Button -Text "Steam" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Steam.Location.Y + $Steam.Height + $DistanceBetweenButtons
    $GogGalaxy = Create-Button -Text "GOG Galaxy" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GogGalaxy.Location.Y + $GogGalaxy.Height + $DistanceBetweenButtons
    $EpicGames = Create-Button -Text "Epic Games Launcher" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EpicGames.Location.Y + $EpicGames.Height + $DistanceBetweenButtons
    $EADesktop = Create-Button -Text "EA Desktop" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $EADesktop.Location.Y + $EADesktop.Height + $DistanceBetweenButtons
    $UbisoftConnect = Create-Button -Text "Ubisoft Connect" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Caption Label
    $NextYLocation = $UbisoftConnect.Location.Y + $UbisoftConnect.Height + $DistanceBetweenButtons
    $CaptionLabel3_2_3 = Create-Label -Text "Planning" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_2_3.Location.Y + $SBHeight + $DistanceBetweenButtons
    $Notion = Create-Button -Text "Notion" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Caption Label
    $NextYLocation = $Notion.Location.Y + $Notion.Height + $DistanceBetweenButtons
    $CaptionLabel3_2_4 = Create-Label -Text "Remote" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_2_4.Location.Y + $SBHeight + $DistanceBetweenButtons
    $Parsec = Create-Button -Text "Parsec" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Parsec.Location.Y + $Parsec.Height + $DistanceBetweenButtons
    $TeamViewer = Create-Button -Text "Team Viewer" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Caption Label
    $NextYLocation = $TeamViewer.Location.Y + $TeamViewer.Height + $DistanceBetweenButtons
    $CaptionLabel3_2_5 = Create-Label -Text "Streaming" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_2_5.Location.Y + $SBHeight + $DistanceBetweenButtons
    $ObsStudio = Create-Button -Text "OBS Studio" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $ObsStudio.Location.Y + $ObsStudio.Height + $DistanceBetweenButtons
    $StreamlabsObs = Create-Button -Text "Streamlabs OBS" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Caption Label
    $NextYLocation = $StreamlabsObs.Location.Y + $StreamlabsObs.Height + $DistanceBetweenButtons
    $CaptionLabel3_2_6 = Create-Label -Text "Torrent" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_2_6.Location.Y + $SBHeight + $DistanceBetweenButtons
    $qBittorrent = Create-Button -Text "qBittorrent" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Caption Label
    $NextYLocation = $qBittorrent.Location.Y + $qBittorrent.Height + $DistanceBetweenButtons
    $CaptionLabel3_2_7 = Create-Label -Text "Media Playing" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_2_7.Location.Y + $SBHeight + $DistanceBetweenButtons
    $Spotify = Create-Button -Text "Spotify" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Spotify.Location.Y + $Spotify.Height + $DistanceBetweenButtons
    $Vlc = Create-Button -Text "VLC" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Vlc.Location.Y + $Vlc.Height + $DistanceBetweenButtons
    $MpcHc = Create-Button -Text "Media Player Classic" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Caption Label
    $NextYLocation = $MpcHc.Location.Y + $MpcHc.Height + $DistanceBetweenButtons
    $CaptionLabel3_2_8 = Create-Label -Text "Utilities" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_2_8.Location.Y + $SBHeight + $DistanceBetweenButtons
    $CPUZ = Create-Button -Text "CPU-Z" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $CPUZ.Location.Y + $CPUZ.Height + $DistanceBetweenButtons
    $GPUZ = Create-Button -Text "GPU-Z" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $GPUZ.Location.Y + $GPUZ.Height + $DistanceBetweenButtons
    $CrystalDiskInfo = Create-Button -Text "Crystal Disk Info" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $CrystalDiskInfo.Location.Y + $CrystalDiskInfo.Height + $DistanceBetweenButtons
    $CrystalDiskMark = Create-Button -Text "Crystal Disk Mark" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Caption Label
    $NextYLocation = $CrystalDiskMark.Location.Y + $CrystalDiskMark.Height + $DistanceBetweenButtons
    $CaptionLabel3_2_9 = Create-Label -Text "WSL 2" -Width $CLWidth -Height $CLHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Panel 3.2 ~> Small Buttons
    $NextYLocation = $CaptionLabel3_2_9.Location.Y + $SBHeight + $DistanceBetweenButtons
    $WSL2 = Create-Button -Text "WSL2 + WSLg (x64/ARM64)" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $WSL2.Location.Y + $SBHeight + $DistanceBetweenButtons
    $Ubuntu = Create-Button -Text "Ubuntu" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu.Location.Y + $Ubuntu.Height + $DistanceBetweenButtons
    $Debian = Create-Button -Text "Debian GNU/Linux" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Debian.Location.Y + $Debian.Height + $DistanceBetweenButtons
    $KaliLinux = Create-Button -Text "Kali Linux Rolling" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $KaliLinux.Location.Y + $KaliLinux.Height + $DistanceBetweenButtons
    $OpenSuse = Create-Button -Text "Open SUSE 42" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $OpenSuse.Location.Y + $OpenSuse.Height + $DistanceBetweenButtons
    $SLES = Create-Button -Text "SLES v12" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $SLES.Location.Y + $SLES.Height + $DistanceBetweenButtons
    $Ubuntu16LTS = Create-Button -Text "Ubuntu 16.04 LTS" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu16LTS.Location.Y + $Ubuntu16LTS.Height + $DistanceBetweenButtons
    $Ubuntu18LTS = Create-Button -Text "Ubuntu 18.04 LTS" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    $NextYLocation = $Ubuntu18LTS.Location.Y + $Ubuntu18LTS.Height + $DistanceBetweenButtons
    $Ubuntu20LTS = Create-Button -Text "Ubuntu 20.04 LTS" -Width $SBWidth -Height $SBHeight -LocationX $ButtonX -LocationY $NextYLocation -FontSize $FontSize1

    # Image Logo from the Script
    $PictureBox1 = New-Object System.Windows.Forms.PictureBox
    $PictureBox1.Width = 150
    $PictureBox1.Height = 150
    $PictureBox1.Location = New-Object System.Drawing.Point((($PWidth * 0.72) - $PictureBox1.Width), (($PHeight * 0.90) - $PictureBox1.Height))
    $PictureBox1.imageLocation = "$PSScriptRoot\src\assets\script-logo.png"
    $PictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom

    # Add all Panels to the Form (Screen)
    $Form.Controls.AddRange(@($Panel1, $Panel2, $Panel3))

    # Add Elements to each Panel
    $Panel1.Controls.AddRange(@($TitleLabel1, $ApplyTweaks, $RemoveXbox, $RepairWindows, $InstallOneDrive, $ReinstallBloatApps, $PictureBox1))
    $Panel2.Controls.AddRange(@($TitleLabel2, $RevertScript, $DarkMode, $LightMode, $EnableSearchIdx, $DisableSearchIdx, $EnableBgApps, $DisableBgApps, $EnableTelemetry, $DisableTelemetry, $EnableCortana, $DisableCortana))
    $Panel3.Controls.AddRange(@($TitleLabel3, $CaptionLabel1))
    $Panel3.Controls.AddRange(@($Panel3_1, $Panel3_2))

    $Panel3_1.Controls.AddRange(@($InstallDrivers, $CaptionLabel3_1_1, $BraveBrowser, $GoogleChrome, $MozillaFirefox))
    $Panel3_1.Controls.AddRange(@($CaptionLabel3_1_2, $7Zip, $WinRar))
    $Panel3_1.Controls.AddRange(@($CaptionLabel3_1_3, $OnlyOffice, $LibreOffice, $PowerBI))
    $Panel3_1.Controls.AddRange(@($CaptionLabel3_1_4, $PaintNet, $Gimp, $Inkscape, $IrfanView, $Krita, $ShareX))
    $Panel3_1.Controls.AddRange(@($CaptionLabel3_1_5, $VSCode, $NotepadPlusPlus))
    $Panel3_1.Controls.AddRange(@($CaptionLabel3_1_6, $GoogleDrive, $Dropbox))
    $Panel3_1.Controls.AddRange(@($CaptionLabel3_1_7, $AuthyDesktop))
    $Panel3_1.Controls.AddRange(@($CaptionLabel3_1_8, $WindowsTerminal, $GitAndKeysSetup, $JavaJRE, $JavaJDKs, $NodeJsLts, $NodeJs, $Python3, $Anaconda3, $Ruby, $ADB, $AndroidStudio, $DockerDesktop, $PostgreSQL, $MySQL))

    $Panel3_2.Controls.AddRange(@($TitleLabel4, $InstallGamingDependencies, $CaptionLabel3_2_1, $Discord, $MSTeams, $Slack, $Zoom, $RocketChat))
    $Panel3_2.Controls.AddRange(@($CaptionLabel3_2_2, $Steam, $GogGalaxy, $EpicGames, $EADesktop, $UbisoftConnect))
    $Panel3_2.Controls.AddRange(@($CaptionLabel3_2_3, $Notion))
    $Panel3_2.Controls.AddRange(@($CaptionLabel3_2_4, $Parsec, $TeamViewer))
    $Panel3_2.Controls.AddRange(@($CaptionLabel3_2_5, $ObsStudio, $StreamlabsObs))
    $Panel3_2.Controls.AddRange(@($CaptionLabel3_2_6, $qBittorrent))
    $Panel3_2.Controls.AddRange(@($CaptionLabel3_2_7, $Spotify, $Vlc, $MpcHc))
    $Panel3_2.Controls.AddRange(@($CaptionLabel3_2_8, $CPUZ, $GPUZ, $CrystalDiskInfo, $CrystalDiskMark))
    $Panel3_2.Controls.AddRange(@($CaptionLabel3_2_9, $WSL2, $Ubuntu, $Debian, $KaliLinux, $OpenSuse, $SLES, $Ubuntu16LTS, $Ubuntu18LTS, $Ubuntu20LTS))

    # <== CLICK EVENTS ==>

    $ApplyTweaks.Add_Click( {
            Push-Location -Path "$PSScriptRoot\src\scripts\"
            Get-ChildItem -Recurse *.ps*1 | Unblock-File

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
                "optimize-optional-features.ps1",
                "remove-onedrive.ps1"
            )
            ForEach ($FileName in $Scripts) {
                Write-TitleCounter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }
            Pop-Location

            $PictureBox1.imageLocation = "$PSScriptRoot\src\assets\script-logo2.png"
            $PictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
            $Form.Update()
            $Global:NeedRestart = $true
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $RemoveXbox.Add_Click( {
            Push-Location -Path "$PSScriptRoot\src\utils\"
            Get-ChildItem -Recurse *.ps*1 | Unblock-File

            $Scripts = @(
                "remove-and-disable-xbox.ps1"
            )
            ForEach ($FileName in $Scripts) {
                Write-TitleCounter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })


    $RepairWindows.Add_Click( {
            Push-Location -Path "$PSScriptRoot\src\scripts\"
            Get-ChildItem -Recurse *.ps*1 | Unblock-File

            $Scripts = @(
                # [Recommended order]
                "backup-system.ps1",
                "repair-windows.ps1"
            )

            ForEach ($FileName in $Scripts) {
                Write-TitleCounter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }
            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $InstallOneDrive.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            $FileName = "install-onedrive.ps1"
            Import-Module -DisableNameChecking .\"$FileName" -Force

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $ReinstallBloatApps.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            $FileName = "reinstall-pre-installed-apps.ps1"
            Import-Module -DisableNameChecking .\"$FileName" -Force

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $RevertScript.Add_Click( {
            Push-Location -Path "$PSScriptRoot\src\scripts\"
            Get-ChildItem -Recurse *.ps*1 | Unblock-File

            $Global:Revert = $true
            $Scripts = @(
                # [Recommended order]
                "optimize-scheduled-tasks.ps1",
                "optimize-services.ps1",
                "optimize-privacy-and-performance.ps1",
                "personal-tweaks.ps1",
                "optimize-optional-features.ps1"
            )
            ForEach ($FileName in $Scripts) {
                Write-TitleCounter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }
            Pop-Location
            $Global:Revert = $false
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $DarkMode.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            Write-Host "[+] Enabling Dark theme..."
            regedit /s use-dark-theme.reg

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $LightMode.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            Write-Host "[+] Enabling Light theme..."
            regedit /s use-light-theme.reg

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $EnableSearchIdx.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            $FileName = "enable-search-idx.ps1"
            Import-Module -DisableNameChecking .\"$FileName" -Force

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $DisableSearchIdx.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            $FileName = "disable-search-idx.ps1"
            Import-Module -DisableNameChecking .\"$FileName" -Force

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $EnableBgApps.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            Write-Host "[+] Enabling Background Apps..."
            regedit /s enable-bg-apps.reg

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $DisableBgApps.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            Write-Host "[-] Disabling Background Apps..."
            regedit /s disable-bg-apps.reg

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $EnableTelemetry.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            Write-Host "[+] Enabling Telemetry..."
            regedit /s enable-full-telemetry.reg

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $DisableTelemetry.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            Write-Host "[-] Disabling Telemetry..."
            regedit /s disable-telemetry.reg

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $EnableCortana.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            Write-Host "[+] Enabling Cortana..."
            regedit /s enable-cortana.reg

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $DisableCortana.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            Write-Host "[-] Disabling Cortana..."
            regedit /s disable-cortana.reg

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $InstallDrivers.Add_Click( {
            Push-Location -Path "$PSScriptRoot\src\scripts\"
            Get-ChildItem -Recurse *.ps*1 | Unblock-File

            $Scripts = @(
                "install-drivers-updaters.ps1"
            )

            ForEach ($FileName in $Scripts) {
                Write-TitleCounter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $BraveBrowser.Add_Click( {
            Install-Package -Name $BraveBrowser.Text -PackageName "BraveSoftware.BraveBrowser"
        })

    $GoogleChrome.Add_Click( {
            Install-Package -Name $GoogleChrome.Text -PackageName "Google.Chrome" -InstallBlock { winget install --silent --source "winget" --id $Package; choco install -y "ublockorigin-chrome" }
        })

    $MozillaFirefox.Add_Click( {
            Install-Package -Name $MozillaFirefox.Text -PackageName "Mozilla.Firefox"
        })

    $7Zip.Add_Click( {
            Install-Package -Name $7Zip.Text -PackageName "7zip.7zip"
        })

    $WinRar.Add_Click( {
            Install-Package -Name $WinRar.Text -PackageName "winrar" -InstallBlock { choco install -y $Package }
        })

    $OnlyOffice.Add_Click( {
            Install-Package -Name $OnlyOffice.Text -PackageName "ONLYOFFICE.DesktopEditors"
        })

    $LibreOffice.Add_Click( {
            Install-Package -Name $LibreOffice.Text -PackageName "LibreOffice.LibreOffice"
        })

    $PowerBI.Add_Click( {
            Install-Package -Name $PowerBI.Text -PackageName "Microsoft.PowerBI"
        })

    $PaintNet.Add_Click( {
            Install-Package -Name $PaintNet.Text -PackageName "paint.net" -InstallBlock { choco install -y $Package }
        })

    $Gimp.Add_Click( {
            Install-Package -Name $Gimp.Text -PackageName "GIMP.GIMP"
        })

    $Inkscape.Add_Click( {
            Install-Package -Name $Inkscape.Text -PackageName "Inkscape.Inkscape"
        })

    $IrfanView.Add_Click( {
            Install-Package -Name $IrfanView.Text -PackageName "IrfanSkiljan.IrfanView"
        })

    $Krita.Add_Click( {
            Install-Package -Name $Krita.Text -PackageName "KDE.Krita"
        })

    $ShareX.Add_Click( {
            Install-Package -Name $ShareX.Text -PackageName "ShareX.ShareX"
        })

    $VSCode.Add_Click( {
            Install-Package -Name $VSCode.Text -PackageName "Microsoft.VisualStudioCode"
        })

    $NotepadPlusPlus.Add_Click( {
            Install-Package -Name $NotepadPlusPlus.Text -PackageName "Notepad++.Notepad++"
        })

    $GoogleDrive.Add_Click( {
            Install-Package -Name $GoogleDrive.Text -PackageName "Google.Drive"
        })

    $Dropbox.Add_Click( {
            Install-Package -Name $Dropbox.Text -PackageName "Dropbox.Dropbox"
        })

    $AuthyDesktop.Add_Click( {
            Install-Package -Name $AuthyDesktop.Text -PackageName "Twilio.Authy"
        })

    $WindowsTerminal.Add_Click( {
            Install-Package -Name $WindowsTerminal.Text -PackageName "Microsoft.WindowsTerminal"
        })

    $GitAndKeysSetup.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            $FileName = "setup-git-keys-and-sign.ps1"
            Import-Module -DisableNameChecking .\"$FileName" -Force

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $JavaJRE.Add_Click( {
            Install-Package -Name $JavaJRE.Text -PackageName "Oracle.JavaRuntimeEnvironment"
        })

    $JavaJDKs.Add_Click( { # Be vigilant as Eclipse Adoptium will become the newest owner
            Install-Package -Name $JavaJDKs.Text -PackageName @("AdoptOpenJDK.OpenJDK.8", "AdoptOpenJDK.OpenJDK.11", "AdoptOpenJDK.OpenJDK.16")
        })

    $NodeJsLts.Add_Click( {
            Install-Package -Name $NodeJsLts.Text -PackageName "OpenJS.NodeJSLTS"
        })

    $NodeJs.Add_Click( {
            Install-Package -Name $NodeJs.Text -PackageName "OpenJS.NodeJS"
        })

    $Python3.Add_Click( {
            Install-Package -Name $Python3.Text -PackageName "Python.Python.3"
        })

    $Anaconda3.Add_Click( {
            Install-Package -Name $Anaconda3.Text -PackageName "Anaconda.Anaconda3"
        })

    $Ruby.Add_Click( {
            Install-Package -Name $Ruby.Text -PackageName "RubyInstallerTeam.RubyWithDevKit"
        })

    $ADB.Add_Click( {
            Install-Package -Name $ADB.Text -PackageName "adb" -InstallBlock { choco install -y $Package }
        })

    $AndroidStudio.Add_Click( {
            Install-Package -Name $AndroidStudio.Text -PackageName "Google.AndroidStudio"
        })

    $DockerDesktop.Add_Click( {
            Install-Package -Name $DockerDesktop.Text -PackageName "Docker.DockerDesktop"
        })

    $PostgreSQL.Add_Click( {
            Install-Package -Name $PostgreSQL.Text -PackageName "PostgreSQL.PostgreSQL"
        })

    $MySQL.Add_Click( {
            Install-Package -Name $MySQL.Text -PackageName "Oracle.MySQL"
        })

    $InstallGamingDependencies.Add_Click( {
            Push-Location -Path "$PSScriptRoot\src\scripts\"
            Get-ChildItem -Recurse *.ps*1 | Unblock-File

            $Scripts = @(
                "install-gaming-dependencies.ps1"
            )
            ForEach ($FileName in $Scripts) {
                Write-TitleCounter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $Discord.Add_Click( {
            Install-Package -Name $Discord.Text -PackageName "Discord.Discord"
        })

    $MSTeams.Add_Click( {
            Install-Package -Name $MSTeams.Text -PackageName "Microsoft.Teams"
        })

    $Slack.Add_Click( {
            Install-Package -Name $Slack.Text -PackageName "SlackTechnologies.Slack"
        })

    $Zoom.Add_Click( {
            Install-Package -Name $Zoom.Text -PackageName "Zoom.Zoom"
        })

    $RocketChat.Add_Click( {
            Install-Package -Name $RocketChat.Text -PackageName "RocketChat.RocketChat"
        })

    $Steam.Add_Click( {
            Install-Package -Name $Steam.Text -PackageName "Valve.Steam"
        })

    $GogGalaxy.Add_Click( {
            Install-Package -Name $GogGalaxy.Text -PackageName "GOG.Galaxy"
        })

    $EpicGames.Add_Click( {
            Install-Package -Name $EpicGames.Text -PackageName "EpicGames.EpicGamesLauncher"
        })

    $EADesktop.Add_Click( {
            Install-Package -Name $EADesktop.Text -PackageName "ElectronicArts.EADesktop"
        })

    $UbisoftConnect.Add_Click( {
            Install-Package -Name $UbisoftConnect.Text -PackageName "Ubisoft.Connect"
        })

    $Notion.Add_Click( {
            Install-Package -Name $Notion.Text -PackageName "Notion.Notion"
        })


    $Parsec.Add_Click( {
            Install-Package -Name $Parsec.Text -PackageName "Parsec.Parsec"
        })

    $TeamViewer.Add_Click( {
            Install-Package -Name $TeamViewer.Text -PackageName "TeamViewer.TeamViewer"
        })

    $ObsStudio.Add_Click( {
            Install-Package -Name $ObsStudio.Text -PackageName "OBSProject.OBSStudio"
        })

    $StreamlabsObs.Add_Click( {
            Install-Package -Name $StreamlabsObs.Text -PackageName "Streamlabs.StreamlabsOBS"
        })

    $qBittorrent.Add_Click( {
            Install-Package -Name $qBittorrent.Text -PackageName "qBittorrent.qBittorrent"
        })

    $Spotify.Add_Click( {
            Install-Package -Name $Spotify.Text -PackageName "Spotify.Spotify"
        })

    $Vlc.Add_Click( {
            Install-Package -Name $Vlc.Text -PackageName "VideoLAN.VLC"
        })

    $MpcHc.Add_Click( {
            Install-Package -Name $MpcHc.Text -PackageName "clsid2.mpc-hc"
        })

    $CPUZ.Add_Click( {
            Install-Package -Name $CPUZ.Text -PackageName "CPUID.CPU-Z"
        })

    $GPUZ.Add_Click( {
            Install-Package -Name $GPUZ.Text -PackageName "TechPowerUp.GPU-Z"
        })

    $CrystalDiskInfo.Add_Click( {
            Install-Package -Name $CrystalDiskInfo.Text -PackageName "CrystalDewWorld.CrystalDiskInfo"
        })

    $CrystalDiskMark.Add_Click( {
            Install-Package -Name $CrystalDiskMark.Text -PackageName "CrystalDewWorld.CrystalDiskMark"
        })

    $WSL2.Add_Click( {
            Push-Location "$PSScriptRoot\src\utils\"

            $FileName = "full-wsl2-x64-arm64.ps1"
            Import-Module -DisableNameChecking .\"$FileName" -Force

            Pop-Location
            Show-Message -Title "$DoneTitle" -Message "$DoneMessage"
        })

    $Ubuntu.Add_Click( {
            Install-Package -Name $Ubuntu.Text -PackageName "Ubuntu" -InstallBlock { wsl --install --distribution $Package }
        })

    $Debian.Add_Click( {
            Install-Package -Name $Debian.Text -PackageName "Debian" -InstallBlock { wsl --install --distribution $Package }
        })

    $KaliLinux.Add_Click( {
            Install-Package -Name $KaliLinux.Text -PackageName "kali-linux" -InstallBlock { wsl --install --distribution $Package }
        })

    $OpenSuse.Add_Click( {
            Install-Package -Name $OpenSuse.Text -PackageName "openSUSE-42" -InstallBlock { wsl --install --distribution $Package }
        })

    $SLES.Add_Click( {
            Install-Package -Name $SLES.Text -PackageName "SLES-12" -InstallBlock { wsl --install --distribution $Package }
        })

    $Ubuntu16LTS.Add_Click( {
            Install-Package -Name $Ubuntu16LTS.Text -PackageName "Ubuntu-16.04" -InstallBlock { wsl --install --distribution $Package }
        })

    $Ubuntu18LTS.Add_Click( {
            Install-Package -Name $Ubuntu18LTS.Text -PackageName "Ubuntu-18.04" -InstallBlock { wsl --install --distribution $Package }
        })

    $Ubuntu20LTS.Add_Click( {
            Install-Package -Name $Ubuntu20LTS.Text -PackageName "Ubuntu-20.04" -InstallBlock { wsl --install --distribution $Package }
        })

    # Show the Window
    [void]$Form.ShowDialog()

    # When done, dispose of the GUI
    $Form.Dispose()

}

function Main() {

    Clear-Host                  # Clear the Powershell before it got an Output
    Request-PrivilegesElevation   # Check admin rights

    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Root Folder $PSScriptRoot"
    Get-ChildItem -Recurse $PSScriptRoot\*.ps*1 | Unblock-File

    Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\set-console-style.psm1"
    Set-ConsoleStyle            # Makes the console look cooler
    Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\install-package.psm1"
    Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\gui-helper.psm1"
    Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\set-script-policy.psm1"
    Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\simple-message-box.psm1"
    Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\title-templates.psm1"

    Set-UnrestrictedPermissions # Unlock script usage
    Import-Module -DisableNameChecking "$PSScriptRoot\src\scripts\install-package-managers.ps1" -Force # Install Winget and Chocolatey at the beginning
    Show-GUI                    # Load the GUI

    Write-Verbose "Restart: $Global:NeedRestart"
    If ($Global:NeedRestart) {
        Request-PcRestart       # Prompt options to Restart the PC
    }
    Set-RestrictedPermissions   # Lock script usage

}

Main