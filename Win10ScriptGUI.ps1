function QuickPrivilegesElevation() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function LoadLibs() {

    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Root Folder $PSScriptRoot"
    Push-Location "$PSScriptRoot"
	
    Push-Location -Path "src\lib\"
    Get-ChildItem -Recurse *.ps*1 | Unblock-File

    Import-Module -DisableNameChecking .\"install-package.psm1"     # Make software install with validation easier
    Import-Module -DisableNameChecking .\"set-gui-layout.psm1"      # Set all variables used in GUI
    Import-Module -DisableNameChecking .\"set-script-policy.psm1"
    Import-Module -DisableNameChecking .\"setup-console-style.psm1" # Make the Console look how i want
    Import-Module -DisableNameChecking .\"simple-message-box.psm1"
    Import-Module -DisableNameChecking .\"title-templates.psm1"
    Pop-Location

}

function PromptPcRestart() {

    $Ask = "If you want to see the changes restart your computer!
    Do you want to Restart now?"
    
    switch (ShowQuestion -Title "Read carefully" -Message $Ask) {
        'Yes' {
            Write-Host "You choose Yes."
            Restart-Computer        
        }
        'No' {
            Write-Host "You choose to Restart later"
            Write-Host "You choose No. (No = Cancel)"
        }
        'Cancel' {
            # With Yes, No and Cancel, the user can press Esc to exit
            Write-Host "You choose to Restart later"
            Write-Host "You choose Cancel. (Cancel = No)"
        }
    }
    
}

# https://docs.microsoft.com/pt-br/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.1
# Adapted majorly from https://github.com/ChrisTitusTech/win10script and https://github.com/Sycnex/Windows10Debloater
function PrepareGUI() {

    SetGuiLayout # Load the GUI Layout

    # <=== AFTER PROCESS ===>

    $Global:NeedRestart = $false
    $DoneTitle = "Done"
    $DoneMessage = "Proccess Completed!"

    # <=== DISPLAYED GUI ===>

    # Main Window:
    $Form = New-Object System.Windows.Forms.Form
    $Form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
    $Form.FormBorderStyle = 'FixedSingle'   # Not adjustable
    $Form.MinimizeBox = $true               # Remove the Minimize Button
    $Form.MaximizeBox = $false              # Remove the Maximize Button
    $Form.Size = New-Object System.Drawing.Size($MaxWidth, $MaxHeight)
    $Form.StartPosition = 'CenterScreen'    # Appears on the center
    $Form.Text = "Windows 10 Smart Debloat - by LeDragoX"
    $Form.TopMost = $false

    # Icon: https://stackoverflow.com/a/53377253
    $IconBase64 = [Convert]::ToBase64String((Get-Content ".\src\lib\images\windows-11-logo.png" -Encoding Byte))
    $IconBytes = [Convert]::FromBase64String($IconBase64)
    $Stream = New-Object IO.MemoryStream($IconBytes, 0, $IconBytes.Length)
    $Stream.Write($IconBytes, 0, $IconBytes.Length);
    $Form.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $Stream).GetHIcon())
    
    # Panel 1 to put Labels and Buttons
    $Panel1 = New-Object system.Windows.Forms.Panel
    $Panel1.Width = $PWidth
    $Panel1.Height = $PHeight
    $Panel1.Location = Invoke-Expression "$PLocation"
    
    # Panel 2 to put Labels and Buttons
    $Panel2 = New-Object system.Windows.Forms.Panel
    $Panel2.Width = $PWidth
    $Panel2.Height = $PHeight
    $Panel2.Location = Invoke-Expression "$PLocation"

    # Panel 3 to put Title and Labels
    $Panel3 = New-Object system.Windows.Forms.Panel
    $Panel3.Width = ($PWidth * 2) + 1
    $Panel3.Height = $PHeight
    $Panel3.Location = Invoke-Expression "$PLocation"
    $Panel3.HorizontalScroll.Enabled = $false
    $Panel3.HorizontalScroll.Visible = $false
    $Panel3.AutoScroll = $true

    # Panel 3.1 to put Labels and Buttons
    $Panel3_1 = New-Object system.Windows.Forms.Panel
    $Panel3_1.Width = $PWidth
    $Panel3_1.Height = $PHeight * 2.1
    $Panel3_1.Location = New-Object System.Drawing.Point(0 , 0)

    # Panel 3.2 to put Labels and Buttons
    $Panel3_2 = New-Object system.Windows.Forms.Panel
    $Panel3_2.Width = $PWidth
    $Panel3_2.Height = $PHeight * 2.1
    $CurrentPanelIndex++
    $Panel3_2.Location = New-Object System.Drawing.Point($PWidth , 0)
    
    # Panel 1 ~> Title Label 1
    $TitleLabel1 = New-Object system.Windows.Forms.Label
    $TitleLabel1.Text = "System Tweaks"
    $TitleLabel1.Width = $TLWidth
    $TitleLabel1.Height = $TLHeight
    $TitleLabel1.Location = $TLLocation
    $TitleLabel1.Font = $TLFont
    $TitleLabel1.ForeColor = $TLForeColor
    $TitleLabel1.TextAlign = $TextAlign

    # Panel 2 ~> Title Label 2
    $TitleLabel2 = New-Object system.Windows.Forms.Label
    $TitleLabel2.Text = "Customize Tweaks"
    $TitleLabel2.Width = $TLWidth
    $TitleLabel2.Height = $TLHeight
    $TitleLabel2.Location = $TLLocation
    $TitleLabel2.Font = $TLFont
    $TitleLabel2.ForeColor = $TLForeColor
    $TitleLabel2.TextAlign = $TextAlign

    # Panel 3 ~> Title Label 3
    $TitleLabel3 = New-Object system.Windows.Forms.Label
    $TitleLabel3.Text = "Software Install"
    $TitleLabel3.Width = $TLWidth * 2
    $TitleLabel3.Height = $TLHeight
    $TitleLabel3.Location = $TLLocation
    $TitleLabel3.Font = $TLFont
    $TitleLabel3.ForeColor = $TLForeColor
    $TitleLabel3.TextAlign = $TextAlign

    # Panel 3 ~> Caption Label 1
    $CaptionLabel1 = New-Object system.Windows.Forms.Label
    $CaptionLabel1.Text = "Winget = Native | Chocolatey = 3rd Party"
    $CaptionLabel1.Location = $CLLocation
    $CaptionLabel1.Width = $CLWidth * 2
    $CaptionLabel1.Height = $CLHeight
    $CaptionLabel1.Font = $CLFont
    $CaptionLabel1.ForeColor = $CLForeColor
    $CaptionLabel1.TextAlign = $TextAlign

    # Panel 1 ~> Button 1 (Big)
    $ApplyTweaks = New-Object system.Windows.Forms.Button
    $ApplyTweaks.Text = "Apply Tweaks"
    $ApplyTweaks.Width = $BBWidth
    $ApplyTweaks.Height = $BBHeight
    $ApplyTweaks.Location = $BBLocation
    $ApplyTweaks.Font = $BBFont
    $ApplyTweaks.ForeColor = $BBForeColor
    
    $NextYLocation = $ApplyTweaks.Location.Y + $ApplyTweaks.Height + $DistanceBetweenButtons
    # Panel 1 ~> Button 2
    $RepairWindows = New-Object system.Windows.Forms.Button
    $RepairWindows.Text = "Repair Windows"
    $RepairWindows.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $RepairWindows.Width = $SBWidth
    $RepairWindows.Height = $SBHeight
    $RepairWindows.Font = $SBFont
    $RepairWindows.ForeColor = $SBForeColor

    # Panel 2 ~> Button 1 (Big)
    $RevertScript = New-Object system.Windows.Forms.Button
    $RevertScript.Text = "Revert Tweaks"
    $RevertScript.Width = $BBWidth
    $RevertScript.Height = $BBHeight
    $RevertScript.Location = $BBLocation
    $RevertScript.Font = $BBFont
    $RevertScript.ForeColor = $BBForeColor    
    
    $NextYLocation = $RevertScript.Location.Y + $RevertScript.Height + $DistanceBetweenButtons
    # Panel 2 ~> Button 2
    $DarkMode = New-Object system.Windows.Forms.Button
    $DarkMode.Text = "Dark Mode"
    $DarkMode.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $DarkMode.Width = $SBWidth
    $DarkMode.Height = $SBHeight
    $DarkMode.Font = $SBFont
    $DarkMode.ForeColor = $SBForeColor
    
    $NextYLocation = $DarkMode.Location.Y + $DarkMode.Height + $DistanceBetweenButtons
    # Panel 2 ~> Button 3
    $LightMode = New-Object system.Windows.Forms.Button
    $LightMode.Text = "Light Mode"
    $LightMode.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $LightMode.Width = $SBWidth
    $LightMode.Height = $SBHeight
    $LightMode.Font = $SBFont
    $LightMode.ForeColor = $SBForeColor
    
    $NextYLocation = $LightMode.Location.Y + $LightMode.Height + $DistanceBetweenButtons
    # Panel 2 ~> Button 4
    $EnableCortana = New-Object system.Windows.Forms.Button
    $EnableCortana.Text = "Enable Cortana"
    $EnableCortana.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $EnableCortana.Width = $SBWidth
    $EnableCortana.Height = $SBHeight
    $EnableCortana.Font = $SBFont
    $EnableCortana.ForeColor = $SBForeColor
    
    $NextYLocation = $EnableCortana.Location.Y + $EnableCortana.Height + $DistanceBetweenButtons
    # Panel 2 ~> Button 5
    $DisableCortana = New-Object system.Windows.Forms.Button
    $DisableCortana.Text = "Disable Cortana"
    $DisableCortana.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $DisableCortana.Width = $SBWidth
    $DisableCortana.Height = $SBHeight
    $DisableCortana.Font = $SBFont
    $DisableCortana.ForeColor = $SBForeColor

    $NextYLocation = $DisableCortana.Location.Y + $DisableCortana.Height + $DistanceBetweenButtons
    # Panel 2 ~> Button 6
    $EnableTelemetry = New-Object system.Windows.Forms.Button
    $EnableTelemetry.Text = "Enable Full Telemetry"
    $EnableTelemetry.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $EnableTelemetry.Width = $SBWidth
    $EnableTelemetry.Height = $SBHeight
    $EnableTelemetry.Font = $SBFont
    $EnableTelemetry.ForeColor = $SBForeColor

    $NextYLocation = $EnableTelemetry.Location.Y + $EnableTelemetry.Height + $DistanceBetweenButtons
    # Panel 2 ~> Button 7
    $DisableTelemetry = New-Object system.Windows.Forms.Button
    $DisableTelemetry.Text = "Disable Telemetry"
    $DisableTelemetry.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $DisableTelemetry.Width = $SBWidth
    $DisableTelemetry.Height = $SBHeight
    $DisableTelemetry.Font = $SBFont
    $DisableTelemetry.ForeColor = $SBForeColor

    $NextYLocation = $DisableTelemetry.Location.Y + $DisableTelemetry.Height + $DistanceBetweenButtons
    # Panel 2 ~> Button 8
    $InstallOneDrive = New-Object system.Windows.Forms.Button
    $InstallOneDrive.Text = "Install OneDrive"
    $InstallOneDrive.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $InstallOneDrive.Width = $SBWidth
    $InstallOneDrive.Height = $SBHeight
    $InstallOneDrive.Font = $SBFont
    $InstallOneDrive.ForeColor = $SBForeColor

    # Panel 3.1 ~> Button 1 (Big)
    $InstallDrivers = New-Object system.Windows.Forms.Button
    $InstallDrivers.Text = "Install CPU/GPU Drivers (Winget/Chocolatey)"
    $InstallDrivers.Width = $BBWidth
    $InstallDrivers.Height = $BBHeight
    $InstallDrivers.Location = $BBLocation
    $InstallDrivers.Font = $BBFont
    $InstallDrivers.ForeColor = $BBForeColor

    $NextYLocation = $InstallDrivers.Location.Y + $InstallDrivers.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Caption Label 1
    $CaptionLabel3_1 = New-Object system.Windows.Forms.Label
    $CaptionLabel3_1.Text = "Web Browsers"
    $CaptionLabel3_1.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $CaptionLabel3_1.Width = $CLWidth
    $CaptionLabel3_1.Height = $CLHeight
    $CaptionLabel3_1.Font = $CLFont
    $CaptionLabel3_1.ForeColor = $CLForeColor
    $CaptionLabel3_1.TextAlign = $TextAlign
    
    $NextYLocation = $CaptionLabel3_1.Location.Y + $SBHeight + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 2
    $BraveBrowser = New-Object system.Windows.Forms.Button
    $BraveBrowser.Text = "Brave Browser"
    $BraveBrowser.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $BraveBrowser.Width = $SBWidth
    $BraveBrowser.Height = $SBHeight
    $BraveBrowser.Font = $SBFont
    $BraveBrowser.ForeColor = $SBForeColor
    
    $NextYLocation = $BraveBrowser.Location.Y + $BraveBrowser.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 3
    $GoogleChrome = New-Object system.Windows.Forms.Button
    $GoogleChrome.Text = "Google Chrome + uBlock"
    $GoogleChrome.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $GoogleChrome.Width = $SBWidth
    $GoogleChrome.Height = $SBHeight
    $GoogleChrome.Font = $SBFont
    $GoogleChrome.ForeColor = $SBForeColor

    $NextYLocation = $GoogleChrome.Location.Y + $GoogleChrome.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 4
    $MozillaFirefox = New-Object system.Windows.Forms.Button
    $MozillaFirefox.Text = "Mozilla Firefox"
    $MozillaFirefox.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $MozillaFirefox.Width = $SBWidth
    $MozillaFirefox.Height = $SBHeight
    $MozillaFirefox.Font = $SBFont
    $MozillaFirefox.ForeColor = $SBForeColor

    $NextYLocation = $MozillaFirefox.Location.Y + $MozillaFirefox.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Caption Label 2
    $CaptionLabel3_2 = New-Object system.Windows.Forms.Label
    $CaptionLabel3_2.Text = "Compression"
    $CaptionLabel3_2.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $CaptionLabel3_2.Width = $CLWidth
    $CaptionLabel3_2.Height = $CLHeight
    $CaptionLabel3_2.Font = $CLFont
    $CaptionLabel3_2.ForeColor = $CLForeColor
    $CaptionLabel3_2.TextAlign = $TextAlign

    $NextYLocation = $CaptionLabel3_2.Location.Y + $SBHeight + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 5
    $7Zip = New-Object system.Windows.Forms.Button
    $7Zip.Text = "7-Zip"
    $7Zip.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $7Zip.Width = $SBWidth
    $7Zip.Height = $SBHeight
    $7Zip.Font = $SBFont
    $7Zip.ForeColor = $SBForeColor
    
    $NextYLocation = $7Zip.Location.Y + $7Zip.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 6
    $WinRar = New-Object system.Windows.Forms.Button
    $WinRar.Text = "WinRar (Trial)"
    $WinRar.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $WinRar.Width = $SBWidth
    $WinRar.Height = $SBHeight
    $WinRar.Font = $SBFont
    $WinRar.ForeColor = $SBForeColor

    $NextYLocation = $WinRar.Location.Y + $WinRar.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Caption Label 3
    $CaptionLabel3_3 = New-Object system.Windows.Forms.Label
    $CaptionLabel3_3.Text = "Documents"
    $CaptionLabel3_3.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $CaptionLabel3_3.Width = $CLWidth
    $CaptionLabel3_3.Height = $CLHeight
    $CaptionLabel3_3.Font = $CLFont
    $CaptionLabel3_3.ForeColor = $CLForeColor
    $CaptionLabel3_3.TextAlign = $TextAlign

    $NextYLocation = $CaptionLabel3_3.Location.Y + $SBHeight + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 7
    $OnlyOffice = New-Object system.Windows.Forms.Button
    $OnlyOffice.Text = "ONLYOFFICE DesktopEditors"
    $OnlyOffice.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $OnlyOffice.Width = $SBWidth
    $OnlyOffice.Height = $SBHeight
    $OnlyOffice.Font = $SBFont
    $OnlyOffice.ForeColor = $SBForeColor
    
    $NextYLocation = $OnlyOffice.Location.Y + $OnlyOffice.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 8
    $LibreOffice = New-Object system.Windows.Forms.Button
    $LibreOffice.Text = "LibreOffice"
    $LibreOffice.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $LibreOffice.Width = $SBWidth
    $LibreOffice.Height = $SBHeight
    $LibreOffice.Font = $SBFont
    $LibreOffice.ForeColor = $SBForeColor

    $NextYLocation = $LibreOffice.Location.Y + $LibreOffice.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Caption Label 4
    $CaptionLabel3_4 = New-Object system.Windows.Forms.Label
    $CaptionLabel3_4.Text = "Imaging"
    $CaptionLabel3_4.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $CaptionLabel3_4.Width = $CLWidth
    $CaptionLabel3_4.Height = $CLHeight
    $CaptionLabel3_4.Font = $CLFont
    $CaptionLabel3_4.ForeColor = $CLForeColor
    $CaptionLabel3_4.TextAlign = $TextAlign

    $NextYLocation = $CaptionLabel3_4.Location.Y + $SBHeight + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 9
    $PaintNet = New-Object system.Windows.Forms.Button
    $PaintNet.Text = "Paint.NET"
    $PaintNet.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $PaintNet.Width = $SBWidth
    $PaintNet.Height = $SBHeight
    $PaintNet.Font = $SBFont
    $PaintNet.ForeColor = $SBForeColor
    
    $NextYLocation = $PaintNet.Location.Y + $PaintNet.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 10
    $Gimp = New-Object system.Windows.Forms.Button
    $Gimp.Text = "GIMP"
    $Gimp.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Gimp.Width = $SBWidth
    $Gimp.Height = $SBHeight
    $Gimp.Font = $SBFont
    $Gimp.ForeColor = $SBForeColor

    $NextYLocation = $Gimp.Location.Y + $Gimp.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 11
    $Inkscape = New-Object system.Windows.Forms.Button
    $Inkscape.Text = "Inkscape"
    $Inkscape.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Inkscape.Width = $SBWidth
    $Inkscape.Height = $SBHeight
    $Inkscape.Font = $SBFont
    $Inkscape.ForeColor = $SBForeColor

    $NextYLocation = $Inkscape.Location.Y + $Inkscape.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 12
    $IrfanView = New-Object system.Windows.Forms.Button
    $IrfanView.Text = "IrfanView"
    $IrfanView.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $IrfanView.Width = $SBWidth
    $IrfanView.Height = $SBHeight
    $IrfanView.Font = $SBFont
    $IrfanView.ForeColor = $SBForeColor

    $NextYLocation = $IrfanView.Location.Y + $IrfanView.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 13
    $Krita = New-Object system.Windows.Forms.Button
    $Krita.Text = "Krita"
    $Krita.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Krita.Width = $SBWidth
    $Krita.Height = $SBHeight
    $Krita.Font = $SBFont
    $Krita.ForeColor = $SBForeColor

    $NextYLocation = $Krita.Location.Y + $Krita.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 14
    $ShareX = New-Object system.Windows.Forms.Button
    $ShareX.Text = "ShareX"
    $ShareX.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $ShareX.Width = $SBWidth
    $ShareX.Height = $SBHeight
    $ShareX.Font = $SBFont
    $ShareX.ForeColor = $SBForeColor

    $NextYLocation = $ShareX.Location.Y + $ShareX.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Caption Label 5
    $CaptionLabel3_5 = New-Object system.Windows.Forms.Label
    $CaptionLabel3_5.Text = "Development"
    $CaptionLabel3_5.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $CaptionLabel3_5.Width = $CLWidth
    $CaptionLabel3_5.Height = $CLHeight
    $CaptionLabel3_5.Font = $CLFont
    $CaptionLabel3_5.ForeColor = $CLForeColor
    $CaptionLabel3_5.TextAlign = $TextAlign

    $NextYLocation = $CaptionLabel3_5.Location.Y + $SBHeight + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 15
    $WindowsTerminal = New-Object system.Windows.Forms.Button
    $WindowsTerminal.Text = "Windows Terminal"
    $WindowsTerminal.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $WindowsTerminal.Width = $SBWidth
    $WindowsTerminal.Height = $SBHeight
    $WindowsTerminal.Font = $SBFont
    $WindowsTerminal.ForeColor = $SBForeColor
    
    $NextYLocation = $WindowsTerminal.Location.Y + $WindowsTerminal.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 16
    $VSCode = New-Object system.Windows.Forms.Button
    $VSCode.Text = "Visual Studio Code"
    $VSCode.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $VSCode.Width = $SBWidth
    $VSCode.Height = $SBHeight
    $VSCode.Font = $SBFont
    $VSCode.ForeColor = $SBForeColor
    
    $NextYLocation = $VSCode.Location.Y + $VSCode.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 17
    $NotepadPlusPlus = New-Object system.Windows.Forms.Button
    $NotepadPlusPlus.Text = "Notepad++"
    $NotepadPlusPlus.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $NotepadPlusPlus.Width = $SBWidth
    $NotepadPlusPlus.Height = $SBHeight
    $NotepadPlusPlus.Font = $SBFont
    $NotepadPlusPlus.ForeColor = $SBForeColor

    $NextYLocation = $NotepadPlusPlus.Location.Y + $NotepadPlusPlus.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 18
    $GitAndKeysSetup = New-Object system.Windows.Forms.Button
    $GitAndKeysSetup.Text = "Git and Keys Setup"
    $GitAndKeysSetup.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $GitAndKeysSetup.Width = $SBWidth
    $GitAndKeysSetup.Height = $SBHeight
    $GitAndKeysSetup.Font = $SBFont
    $GitAndKeysSetup.ForeColor = $SBForeColor

    $NextYLocation = $GitAndKeysSetup.Location.Y + $GitAndKeysSetup.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 19
    $JavaJre = New-Object system.Windows.Forms.Button
    $JavaJre.Text = "Java JRE"
    $JavaJre.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $JavaJre.Width = $SBWidth
    $JavaJre.Height = $SBHeight
    $JavaJre.Font = $SBFont
    $JavaJre.ForeColor = $SBForeColor

    $NextYLocation = $JavaJre.Location.Y + $JavaJre.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 20
    $NodeJsLts = New-Object system.Windows.Forms.Button
    $NodeJsLts.Text = "NodeJS LTS"
    $NodeJsLts.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $NodeJsLts.Width = $SBWidth
    $NodeJsLts.Height = $SBHeight
    $NodeJsLts.Font = $SBFont
    $NodeJsLts.ForeColor = $SBForeColor

    $NextYLocation = $NodeJsLts.Location.Y + $NodeJsLts.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 21
    $NodeJs = New-Object system.Windows.Forms.Button
    $NodeJs.Text = "NodeJS"
    $NodeJs.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $NodeJs.Width = $SBWidth
    $NodeJs.Height = $SBHeight
    $NodeJs.Font = $SBFont
    $NodeJs.ForeColor = $SBForeColor

    $NextYLocation = $NodeJs.Location.Y + $NodeJs.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 22
    $Python3 = New-Object system.Windows.Forms.Button
    $Python3.Text = "Python 3"
    $Python3.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Python3.Width = $SBWidth
    $Python3.Height = $SBHeight
    $Python3.Font = $SBFont
    $Python3.ForeColor = $SBForeColor

    $NextYLocation = $Python3.Location.Y + $Python3.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 23
    $Ruby = New-Object system.Windows.Forms.Button
    $Ruby.Text = "Ruby with MSYS2"
    $Ruby.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Ruby.Width = $SBWidth
    $Ruby.Height = $SBHeight
    $Ruby.Font = $SBFont
    $Ruby.ForeColor = $SBForeColor

    $NextYLocation = $Ruby.Location.Y + $Ruby.Height + $DistanceBetweenButtons
    # Panel 3.1 ~> Button 24
    $AndroidStudio = New-Object system.Windows.Forms.Button
    $AndroidStudio.Text = "Android Studio"
    $AndroidStudio.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $AndroidStudio.Width = $SBWidth
    $AndroidStudio.Height = $SBHeight
    $AndroidStudio.Font = $SBFont
    $AndroidStudio.ForeColor = $SBForeColor
    
    # Panel 3.2 ~> Button 1 (Big)
    $InstallGamingDependencies = New-Object system.Windows.Forms.Button
    $InstallGamingDependencies.Text = "Install Gaming Dependencies"
    $InstallGamingDependencies.Width = $BBWidth
    $InstallGamingDependencies.Height = $BBHeight
    $InstallGamingDependencies.Location = $BBLocation
    $InstallGamingDependencies.Font = $BBFont
    $InstallGamingDependencies.ForeColor = $BBForeColor

    $NextYLocation = $InstallGamingDependencies.Location.Y + $InstallGamingDependencies.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Caption Label 6
    $CaptionLabel3_6 = New-Object system.Windows.Forms.Label
    $CaptionLabel3_6.Text = "Communication"
    $CaptionLabel3_6.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $CaptionLabel3_6.Width = $CLWidth
    $CaptionLabel3_6.Height = $CLHeight
    $CaptionLabel3_6.Font = $CLFont
    $CaptionLabel3_6.ForeColor = $CLForeColor
    $CaptionLabel3_6.TextAlign = $TextAlign

    $NextYLocation = $CaptionLabel3_6.Location.Y + $SBHeight + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 2
    $Discord = New-Object system.Windows.Forms.Button
    $Discord.Text = "Discord"
    $Discord.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Discord.Width = $SBWidth
    $Discord.Height = $SBHeight
    $Discord.Font = $SBFont
    $Discord.ForeColor = $SBForeColor

    $NextYLocation = $Discord.Location.Y + $Discord.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 3
    $MSTeams = New-Object system.Windows.Forms.Button
    $MSTeams.Text = "Microsoft Teams"
    $MSTeams.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $MSTeams.Width = $SBWidth
    $MSTeams.Height = $SBHeight
    $MSTeams.Font = $SBFont
    $MSTeams.ForeColor = $SBForeColor

    $NextYLocation = $MSTeams.Location.Y + $MSTeams.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 4
    $Slack = New-Object system.Windows.Forms.Button
    $Slack.Text = "Slack"
    $Slack.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Slack.Width = $SBWidth
    $Slack.Height = $SBHeight
    $Slack.Font = $SBFont
    $Slack.ForeColor = $SBForeColor

    $NextYLocation = $Slack.Location.Y + $Slack.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 5
    $Zoom = New-Object system.Windows.Forms.Button
    $Zoom.Text = "Zoom"
    $Zoom.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Zoom.Width = $SBWidth
    $Zoom.Height = $SBHeight
    $Zoom.Font = $SBFont
    $Zoom.ForeColor = $SBForeColor

    $NextYLocation = $Zoom.Location.Y + $Zoom.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 6
    $RocketChat = New-Object system.Windows.Forms.Button
    $RocketChat.Text = "Rocket Chat"
    $RocketChat.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $RocketChat.Width = $SBWidth
    $RocketChat.Height = $SBHeight
    $RocketChat.Font = $SBFont
    $RocketChat.ForeColor = $SBForeColor
    
    $NextYLocation = $RocketChat.Location.Y + $RocketChat.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Caption Label 7
    $CaptionLabel3_7 = New-Object system.Windows.Forms.Label
    $CaptionLabel3_7.Text = "Gaming"
    $CaptionLabel3_7.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $CaptionLabel3_7.Width = $CLWidth
    $CaptionLabel3_7.Height = $CLHeight
    $CaptionLabel3_7.Font = $CLFont
    $CaptionLabel3_7.ForeColor = $CLForeColor
    $CaptionLabel3_7.TextAlign = $TextAlign

    $NextYLocation = $CaptionLabel3_7.Location.Y + $SBHeight + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 7
    $Steam = New-Object system.Windows.Forms.Button
    $Steam.Text = "Steam"
    $Steam.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Steam.Width = $SBWidth
    $Steam.Height = $SBHeight
    $Steam.Font = $SBFont
    $Steam.ForeColor = $SBForeColor

    $NextYLocation = $Steam.Location.Y + $Steam.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 8
    $GogGalaxy = New-Object system.Windows.Forms.Button
    $GogGalaxy.Text = "GOG Galaxy"
    $GogGalaxy.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $GogGalaxy.Width = $SBWidth
    $GogGalaxy.Height = $SBHeight
    $GogGalaxy.Font = $SBFont
    $GogGalaxy.ForeColor = $SBForeColor    

    $NextYLocation = $GogGalaxy.Location.Y + $GogGalaxy.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 9
    $EpicGames = New-Object system.Windows.Forms.Button
    $EpicGames.Text = "Epic Games Launcher"
    $EpicGames.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $EpicGames.Width = $SBWidth
    $EpicGames.Height = $SBHeight
    $EpicGames.Font = $SBFont
    $EpicGames.ForeColor = $SBForeColor

    $NextYLocation = $EpicGames.Location.Y + $EpicGames.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 10
    $EADesktop = New-Object system.Windows.Forms.Button
    $EADesktop.Text = "EA Desktop"
    $EADesktop.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $EADesktop.Width = $SBWidth
    $EADesktop.Height = $SBHeight
    $EADesktop.Font = $SBFont
    $EADesktop.ForeColor = $SBForeColor

    $NextYLocation = $EADesktop.Location.Y + $EADesktop.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 11
    $UbisoftConnect = New-Object system.Windows.Forms.Button
    $UbisoftConnect.Text = "Ubisoft Connect"
    $UbisoftConnect.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $UbisoftConnect.Width = $SBWidth
    $UbisoftConnect.Height = $SBHeight
    $UbisoftConnect.Font = $SBFont
    $UbisoftConnect.ForeColor = $SBForeColor

    $NextYLocation = $UbisoftConnect.Location.Y + $UbisoftConnect.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Caption Label 8
    $CaptionLabel3_8 = New-Object system.Windows.Forms.Label
    $CaptionLabel3_8.Text = "Remote"
    $CaptionLabel3_8.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $CaptionLabel3_8.Width = $CLWidth
    $CaptionLabel3_8.Height = $CLHeight
    $CaptionLabel3_8.Font = $CLFont
    $CaptionLabel3_8.ForeColor = $CLForeColor
    $CaptionLabel3_8.TextAlign = $TextAlign

    $NextYLocation = $CaptionLabel3_8.Location.Y + $SBHeight + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 12
    $Parsec = New-Object system.Windows.Forms.Button
    $Parsec.Text = "Parsec"
    $Parsec.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Parsec.Width = $SBWidth
    $Parsec.Height = $SBHeight
    $Parsec.Font = $SBFont
    $Parsec.ForeColor = $SBForeColor

    $NextYLocation = $Parsec.Location.Y + $Parsec.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 13
    $TeamViewer = New-Object system.Windows.Forms.Button
    $TeamViewer.Text = "Team Viewer"
    $TeamViewer.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $TeamViewer.Width = $SBWidth
    $TeamViewer.Height = $SBHeight
    $TeamViewer.Font = $SBFont
    $TeamViewer.ForeColor = $SBForeColor

    $NextYLocation = $TeamViewer.Location.Y + $TeamViewer.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Caption Label 9
    $CaptionLabel3_9 = New-Object system.Windows.Forms.Label
    $CaptionLabel3_9.Text = "Streaming"
    $CaptionLabel3_9.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $CaptionLabel3_9.Width = $CLWidth
    $CaptionLabel3_9.Height = $CLHeight
    $CaptionLabel3_9.Font = $CLFont
    $CaptionLabel3_9.ForeColor = $CLForeColor
    $CaptionLabel3_9.TextAlign = $TextAlign

    $NextYLocation = $CaptionLabel3_9.Location.Y + $SBHeight + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 14
    $ObsStudio = New-Object system.Windows.Forms.Button
    $ObsStudio.Text = "OBS Studio"
    $ObsStudio.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $ObsStudio.Width = $SBWidth
    $ObsStudio.Height = $SBHeight
    $ObsStudio.Font = $SBFont
    $ObsStudio.ForeColor = $SBForeColor

    $NextYLocation = $ObsStudio.Location.Y + $ObsStudio.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 15
    $StreamlabsObs = New-Object system.Windows.Forms.Button
    $StreamlabsObs.Text = "Streamlabs OBS"
    $StreamlabsObs.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $StreamlabsObs.Width = $SBWidth
    $StreamlabsObs.Height = $SBHeight
    $StreamlabsObs.Font = $SBFont
    $StreamlabsObs.ForeColor = $SBForeColor

    $NextYLocation = $StreamlabsObs.Location.Y + $StreamlabsObs.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Caption Label 10
    $CaptionLabel3_10 = New-Object system.Windows.Forms.Label
    $CaptionLabel3_10.Text = "Torrent"
    $CaptionLabel3_10.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $CaptionLabel3_10.Width = $CLWidth
    $CaptionLabel3_10.Height = $CLHeight
    $CaptionLabel3_10.Font = $CLFont
    $CaptionLabel3_10.ForeColor = $CLForeColor
    $CaptionLabel3_10.TextAlign = $TextAlign

    $NextYLocation = $CaptionLabel3_10.Location.Y + $SBHeight + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 16
    $qBittorrent = New-Object system.Windows.Forms.Button
    $qBittorrent.Text = "qBittorrent"
    $qBittorrent.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $qBittorrent.Width = $SBWidth
    $qBittorrent.Height = $SBHeight
    $qBittorrent.Font = $SBFont
    $qBittorrent.ForeColor = $SBForeColor
    
    $NextYLocation = $qBittorrent.Location.Y + $qBittorrent.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Caption Label 11
    $CaptionLabel3_11 = New-Object system.Windows.Forms.Label
    $CaptionLabel3_11.Text = "Media Playing"
    $CaptionLabel3_11.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $CaptionLabel3_11.Width = $CLWidth
    $CaptionLabel3_11.Height = $CLHeight
    $CaptionLabel3_11.Font = $CLFont
    $CaptionLabel3_11.ForeColor = $CLForeColor
    $CaptionLabel3_11.TextAlign = $TextAlign

    $NextYLocation = $CaptionLabel3_11.Location.Y + $SBHeight + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 17
    $Spotify = New-Object system.Windows.Forms.Button
    $Spotify.Text = "Spotify"
    $Spotify.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Spotify.Width = $SBWidth
    $Spotify.Height = $SBHeight
    $Spotify.Font = $SBFont
    $Spotify.ForeColor = $SBForeColor

    $NextYLocation = $Spotify.Location.Y + $Spotify.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 18
    $Vlc = New-Object system.Windows.Forms.Button
    $Vlc.Text = "VLC"
    $Vlc.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Vlc.Width = $SBWidth
    $Vlc.Height = $SBHeight
    $Vlc.Font = $SBFont
    $Vlc.ForeColor = $SBForeColor

    $NextYLocation = $Vlc.Location.Y + $Vlc.Height + $DistanceBetweenButtons
    # Panel 3.2 ~> Button 19
    $MpcHc = New-Object system.Windows.Forms.Button
    $MpcHc.Text = "Media Player Classic"
    $MpcHc.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $MpcHc.Width = $SBWidth
    $MpcHc.Height = $SBHeight
    $MpcHc.Font = $SBFont
    $MpcHc.ForeColor = $SBForeColor
        
    # Image Logo from the Script
    $PictureBox1 = New-Object system.Windows.Forms.PictureBox
    $PictureBox1.Width = 150
    $PictureBox1.Height = 150
    $PictureBox1.Location = New-Object System.Drawing.Point((($PWidth * 0.72) - $PictureBox1.Width), (($PHeight * 0.90) - $PictureBox1.Height))
    $PictureBox1.imageLocation = "$PSScriptRoot\src\lib\images\script-logo.png"
    $PictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom

    # Add all Panels to the Form (Screen)
    $Form.Controls.AddRange(@($Panel1, $Panel2, $Panel3))
    # Add Elements to each Panel
    $Panel1.Controls.AddRange(@($TitleLabel1, $ApplyTweaks, $RepairWindows, $PictureBox1))
    $Panel2.Controls.AddRange(@($TitleLabel2, $RevertScript, $DarkMode, $LightMode, $CaptionLabel2, $EnableCortana, $DisableCortana, $EnableTelemetry, $DisableTelemetry, $InstallOneDrive))
    $Panel3.Controls.AddRange(@($TitleLabel3, $CaptionLabel1))
    $Panel3_1.Controls.AddRange(@($InstallDrivers, $CaptionLabel3_1, $BraveBrowser, $GoogleChrome, $MozillaFirefox))
    $Panel3_1.Controls.AddRange(@($CaptionLabel3_2, $7Zip, $WinRar, $CaptionLabel3_3, $OnlyOffice, $LibreOffice))
    $Panel3_1.Controls.AddRange(@($CaptionLabel3_4, $PaintNet, $Gimp, $Inkscape, $IrfanView, $Krita, $ShareX))
    $Panel3_1.Controls.AddRange(@($CaptionLabel3_5, $WindowsTerminal, $VSCode, $NotepadPlusPlus, $GitAndKeysSetup, $JavaJre, $NodeJsLts, $NodeJs, $Python3, $Ruby, $AndroidStudio))
    $Panel3_2.Controls.AddRange(@($TitleLabel4, $InstallGamingDependencies, $CaptionLabel3_6, $Discord, $MSTeams, $Slack, $Zoom, $RocketChat))
    $Panel3_2.Controls.AddRange(@($CaptionLabel3_7, $Steam, $GogGalaxy, $EpicGames, $EADesktop, $UbisoftConnect))
    $Panel3_2.Controls.AddRange(@($CaptionLabel3_8, $Parsec, $TeamViewer, $CaptionLabel3_9, $ObsStudio, $StreamlabsObs))
    $Panel3_2.Controls.AddRange(@($CaptionLabel3_10, $qBittorrent, $CaptionLabel3_11, $Spotify, $Vlc, $MpcHc))
    $Panel3.Controls.AddRange(@($Panel3_1, $Panel3_2))

    # <=== CLICK EVENTS ===>

    # Panel 1 Mouse Click listener
    $ApplyTweaks.Add_Click( {

            Push-Location -Path "src\scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
                
            $Scripts = @(
                # [Recommended order] List of Scripts
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
                Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }
            Pop-Location

            $PictureBox1.imageLocation = "$PSScriptRoot\src\lib\images\script-logo2.png"
            $PictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
            $Form.Update()

            $Global:NeedRestart = $true
            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
        })    

    # Panel 1 Mouse Click listener
    $RepairWindows.Add_Click( {

            Push-Location -Path "src\scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
            
            $Scripts = @(
                # [Recommended order] List of Scripts
                "backup-system.ps1",
                "repair-windows.ps1"
            )
        
            ForEach ($FileName in $Scripts) {
                Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }
            Pop-Location
        
            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 Mouse Click listener
    $RevertScript.Add_Click( {
            Push-Location -Path "src\scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
            
            $Global:Revert = $true
            $Scripts = @(
                # [Recommended order] List of Scripts
                "optimize-scheduled-tasks.ps1",
                "optimize-services.ps1",
                "optimize-privacy-and-performance.ps1",
                "personal-tweaks.ps1",
                "optimize-optional-features.ps1"
            )
          
            ForEach ($FileName in $Scripts) {
                Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }
            $Global:Revert = $false
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 Mouse Click listener
    $DarkMode.Add_Click( {

            Push-Location "src\utils\"
            Write-Host "[+] Enabling Dark theme..."
            regedit /s dark-theme.reg
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 Mouse Click listener
    $LightMode.Add_Click( {

            Push-Location "src\utils\"
            Write-Host "[+] Enabling Light theme..."
            regedit /s light-theme.reg
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 Mouse Click listener
    $EnableCortana.Add_Click( {

            Push-Location "src\utils\"
            Write-Host "[+] Enabling Cortana..."
            regedit /s enable-cortana.reg
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })
    
    # Panel 2 Mouse Click listener
    $DisableCortana.Add_Click( {

            Push-Location "src\utils\"
            Write-Host "[-] Disabling Cortana..."
            regedit /s disable-cortana.reg
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 Mouse Click listener
    $EnableTelemetry.Add_Click( {

            Push-Location "src\utils\"
            $FileName = "enable-telemetry.ps1"
            Import-Module -DisableNameChecking .\"$FileName" -Force
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 Mouse Click listener
    $DisableTelemetry.Add_Click( {

            Push-Location "src\utils\"
            $FileName = "disable-telemetry.ps1"
            Import-Module -DisableNameChecking .\"$FileName" -Force
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 Mouse Click listener
    $InstallOneDrive.Add_Click( {

            Push-Location "src\utils\"
            $FileName = "install-onedrive.ps1"
            Import-Module -DisableNameChecking .\"$FileName" -Force
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 3.1 Mouse Click listener
    $InstallDrivers.Add_Click( {

            Push-Location -Path "src\scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
        
            $Scripts = @(
                # [Recommended order] List of Scripts
                "install-drivers.ps1"
            )
        
            ForEach ($FileName in $Scripts) {
                Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }
            Pop-Location
        
            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 3.1 Mouse Click listener
    $BraveBrowser.Add_Click( {
        
            $InstallParams = @{
                Name         = $BraveBrowser.Text
                PackageName  = "BraveSoftware.BraveBrowser"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock
        
        })

    
    # Panel 3.1 Mouse Click listener
    $GoogleChrome.Add_Click( {
            
            $InstallParams = @{
                Name         = $GoogleChrome.Text
                PackageName  = "Google.Chrome"
                InstallBlock = { winget install --silent $PackageName; choco install -y "ublockorigin-chrome" }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock
            
        })

    # Panel 3.1 Mouse Click listener
    $MozillaFirefox.Add_Click( {
            
            $InstallParams = @{
                Name         = $MozillaFirefox.Text
                PackageName  = "Mozilla.Firefox"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock
            
        })
        
    # Panel 3.1 Mouse Click listener
    $7Zip.Add_Click( {
        
            $InstallParams = @{
                Name         = $7Zip.Text
                PackageName  = "7zip.7zip"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock
    
        })

    # Panel 3.1 Mouse Click listener
    $WinRar.Add_Click( {
            
            $InstallParams = @{
                Name         = $WinRar.Text
                PackageName  = "winrar"
                InstallBlock = { choco install -y $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })
                
    # Panel 3.1 Mouse Click listener
    $OnlyOffice.Add_Click( {
            
            $InstallParams = @{
                Name         = $OnlyOffice.Text
                PackageName  = "ONLYOFFICE.DesktopEditors"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
            
        })
        
    # Panel 3.1 Mouse Click listener
    $LibreOffice.Add_Click( {
            
            $InstallParams = @{
                Name         = $LibreOffice.Text
                PackageName  = "LibreOffice.LibreOffice"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
            
        })
        
    # Panel 3.1 Mouse Click listener
    $PaintNet.Add_Click( {

            $InstallParams = @{
                Name         = $PaintNet.Text
                PackageName  = "paint.net"
                InstallBlock = { choco install -y $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
            
        })
        
    # Panel 3.1 Mouse Click listener
    $Gimp.Add_Click( {

            $InstallParams = @{
                Name         = $Gimp.Text
                PackageName  = "GIMP.GIMP"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.1 Mouse Click listener
    $Inkscape.Add_Click( {

            $InstallParams = @{
                Name         = $Inkscape.Text
                PackageName  = "Inkscape.Inkscape"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.1 Mouse Click listener
    $IrfanView.Add_Click( {

            $InstallParams = @{
                Name         = $IrfanView.Text
                PackageName  = "IrfanSkiljan.IrfanView"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.1 Mouse Click listener
    $Krita.Add_Click( {
    
            $InstallParams = @{
                Name         = $Krita.Text
                PackageName  = "KDE.Krita"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
    
        })

    # Panel 3.1 Mouse Click listener
    $ShareX.Add_Click( {

            $InstallParams = @{
                Name         = $ShareX.Text
                PackageName  = "ShareX.ShareX"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.1 Mouse Click listener
    $WindowsTerminal.Add_Click( {

            $InstallParams = @{
                Name         = $WindowsTerminal.Text
                PackageName  = "Microsoft.WindowsTerminal"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.1 Mouse Click listener
    $VSCode.Add_Click( {
            
            $InstallParams = @{
                Name         = $VSCode.Text
                PackageName  = "Microsoft.VisualStudioCode"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
    
        })

    # Panel 3.1 Mouse Click listener
    $NotepadPlusPlus.Add_Click( {
        
            $InstallParams = @{
                Name         = $NotepadPlusPlus.Text
                PackageName  = "Notepad++.Notepad++"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
        
        })

    # Panel 3.1 Mouse Click listener
    $GitAndKeysSetup.Add_Click( {
        
            Push-Location "src\utils\"
            $FileName = "setup-git-keys-and-sign.ps1"
            Import-Module -DisableNameChecking .\"$FileName" -Force
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 3.1 Mouse Click listener
    $JavaJre.Add_Click( {
        
            $InstallParams = @{
                Name         = $JavaJre.Text
                PackageName  = "Oracle.JavaRuntimeEnvironment"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
    
        })

    # Panel 3.1 Mouse Click listener
    $NodeJsLts.Add_Click( {
        
            $InstallParams = @{
                Name         = $NodeJsLts.Text
                PackageName  = "OpenJS.NodeJSLTS"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
    
        })

    # Panel 3.1 Mouse Click listener
    $NodeJs.Add_Click( {
        
            $InstallParams = @{
                Name         = $NodeJs.Text
                PackageName  = "OpenJS.NodeJS"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
    
        })

    # Panel 3.1 Mouse Click listener
    $Python3.Add_Click( {
        
            $InstallParams = @{
                Name         = $Python3.Text
                PackageName  = "Python.Python.3"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
    
        })

    # Panel 3.1 Mouse Click listener
    $Ruby.Add_Click( {
        
            $InstallParams = @{
                Name         = $Ruby.Text
                PackageName  = "RubyInstallerTeam.RubyWithDevKit"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.1 Mouse Click listener
    $AndroidStudio.Add_Click( {
        
            $InstallParams = @{
                Name         = $AndroidStudio.Text
                PackageName  = "Google.AndroidStudio"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.2 Mouse Click listener
    $InstallGamingDependencies.Add_Click( {

            Push-Location -Path "src\scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
    
            $Scripts = @(
                # [Recommended order] List of Scripts
                "install-gaming-dependencies.ps1"
            )
    
            ForEach ($FileName in $Scripts) {
                Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }

            Pop-Location
    
            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 3.2 Mouse Click listener
    $Discord.Add_Click( {

            $InstallParams = @{
                Name         = $Discord.Text
                PackageName  = "Discord.Discord"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
        
        })

    # Panel 3.2 Mouse Click listener
    $MSTeams.Add_Click( {

            $InstallParams = @{
                Name         = $MSTeams.Text
                PackageName  = "Microsoft.Teams"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
    
        })

    # Panel 3.2 Mouse Click listener
    $Slack.Add_Click( {

            $InstallParams = @{
                Name         = $Slack.Text
                PackageName  = "SlackTechnologies.Slack"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.2 Mouse Click listener
    $Zoom.Add_Click( {

            $InstallParams = @{
                Name         = $Zoom.Text
                PackageName  = "Zoom.Zoom"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.2 Mouse Click listener
    $RocketChat.Add_Click( {

            $InstallParams = @{
                Name         = $RocketChat.Text
                PackageName  = "RocketChat.RocketChat"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.2 Mouse Click listener
    $Steam.Add_Click( {

            $InstallParams = @{
                Name         = $Steam.Text
                PackageName  = "Valve.Steam"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.2 Mouse Click listener
    $GogGalaxy.Add_Click( {

            $InstallParams = @{
                Name         = $GogGalaxy.Text
                PackageName  = "GOG.Galaxy"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.2 Mouse Click listener
    $EpicGames.Add_Click( {

            $InstallParams = @{
                Name         = $EpicGames.Text
                PackageName  = "EpicGames.EpicGamesLauncher"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.2 Mouse Click listener
    $EADesktop.Add_Click( {

            $InstallParams = @{
                Name         = $EADesktop.Text
                PackageName  = "ElectronicArts.EADesktop"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.2 Mouse Click listener
    $UbisoftConnect.Add_Click( {

            $InstallParams = @{
                Name         = $UbisoftConnect.Text
                PackageName  = "Ubisoft.Connect"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.2 Mouse Click listener
    $Parsec.Add_Click( {

            $InstallParams = @{
                Name         = $Parsec.Text
                PackageName  = "Parsec.Parsec"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.2 Mouse Click listener
    $TeamViewer.Add_Click( {

            $InstallParams = @{
                Name         = $TeamViewer.Text
                PackageName  = "TeamViewer.TeamViewer"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.2 Mouse Click listener
    $ObsStudio.Add_Click( {

            $InstallParams = @{
                Name         = $ObsStudio.Text
                PackageName  = "OBSProject.OBSStudio"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
    
        })

    # Panel 3.2 Mouse Click listener
    $StreamlabsObs.Add_Click( {

            $InstallParams = @{
                Name         = $StreamlabsObs.Text
                PackageName  = "Streamlabs.StreamlabsOBS"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3.2 Mouse Click listener
    $qBittorrent.Add_Click( {

            $InstallParams = @{
                Name         = $qBittorrent.Text
                PackageName  = "qBittorrent.qBittorrent"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock
        
        })
    
    # Panel 3.2 Mouse Click listener
    $Spotify.Add_Click( {
            
            $InstallParams = @{
                Name         = $Spotify.Text
                PackageName  = "Spotify.Spotify"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
            
        })
    
    # Panel 3.2 Mouse Click listener
    $Vlc.Add_Click( {
        
            $InstallParams = @{
                Name         = $Vlc.Text
                PackageName  = "VideoLAN.VLC"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
        
        })

    # Panel 3.2 Mouse Click listener
    $MpcHc.Add_Click( {
        
            $InstallParams = @{
                Name         = $MpcHc.Text
                PackageName  = "clsid2.mpc-hc"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
    
        })

    # Show the Window
    [void]$Form.ShowDialog()
    
    # When done, dispose of the GUI
    $Form.Dispose()

}

function Main() {
    
    Clear-Host                  # Clear the Powershell before it got an Output
    QuickPrivilegesElevation    # Check admin rights
    LoadLibs                    # Import modules from lib folder
    UnrestrictPermissions       # Unlock script usage
    SetupConsoleStyle           # Just fix the font on the PS console
    
    # Install Winget and Chocolatey already on the start
    Import-Module -DisableNameChecking .\"src\scripts\install-package-managers.ps1" -Force
    PrepareGUI                  # Load the GUI
    
    Write-Verbose "Restart: $Global:NeedRestart"
    If ($Global:NeedRestart) {
        PromptPcRestart         # Prompt options to Restart the PC
    }
    
    RestrictPermissions         # Lock script usage

}

Main