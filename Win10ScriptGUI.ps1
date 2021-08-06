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

    # Panel 3 to put Labels and Buttons
    $Panel3 = New-Object system.Windows.Forms.Panel
    $Panel3.Width = $PWidth
    $Panel3.Height = $PHeight
    $Panel3.Location = Invoke-Expression "$PLocation"

    # Panel 4 to put Labels and Buttons
    $Panel4 = New-Object system.Windows.Forms.Panel
    $Panel4.Width = $PWidth
    $Panel4.Height = $PHeight
    $Panel4.Location = Invoke-Expression "$PLocation"
    
    # Panel 1 ~> Title Label 1
    $TitleLabel1 = New-Object system.Windows.Forms.Label
    $TitleLabel1.Text = "   System Tweaks"
    $TitleLabel1.Width = $TLWidth
    $TitleLabel1.Height = $TLHeight
    $TitleLabel1.Location = $TLLocation
    $TitleLabel1.Font = $TLFont
    $TitleLabel1.ForeColor = $TLForeColor

    # Panel 2 ~> Title Label 2
    $TitleLabel2 = New-Object system.Windows.Forms.Label
    $TitleLabel2.Text = "Customize Tweaks"
    $TitleLabel2.Width = $TLWidth
    $TitleLabel2.Height = $TLHeight
    $TitleLabel2.Location = $TLLocation
    $TitleLabel2.Font = $TLFont
    $TitleLabel2.ForeColor = $TLForeColor

    # Panel 3 ~> Title Label 3
    $TitleLabel3 = New-Object system.Windows.Forms.Label
    $TitleLabel3.Text = "   Software Install"
    $TitleLabel3.Width = $TLWidth
    $TitleLabel3.Height = $TLHeight
    $TitleLabel3.Location = $TLLocation
    $TitleLabel3.Font = $TLFont
    $TitleLabel3.ForeColor = $TLForeColor

    # Panel 4 ~> Title Label 4
    $TitleLabel4 = New-Object system.Windows.Forms.Label
    $TitleLabel4.Text = " Software Install 2"
    $TitleLabel4.Width = $TLWidth
    $TitleLabel4.Height = $TLHeight
    $TitleLabel4.Location = $TLLocation
    $TitleLabel4.Font = $TLFont
    $TitleLabel4.ForeColor = $TLForeColor

    # Panel 3 ~> Caption Label 1
    $CaptionLabel1 = New-Object system.Windows.Forms.Label
    $CaptionLabel1.Text = "Winget = Native"
    $CaptionLabel1.Location = $CLLocation
    $CaptionLabel1.Width = $CLWidth
    $CaptionLabel1.Height = $CLHeight
    $CaptionLabel1.Font = $CLFont
    $CaptionLabel1.ForeColor = $CLForeColor
    
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

    # Panel 3 ~> Button 1 (Big)
    $InstallDrivers = New-Object system.Windows.Forms.Button
    $InstallDrivers.Text = "Install CPU/GPU Drivers (Winget/Chocolatey)"
    $InstallDrivers.Width = $BBWidth
    $InstallDrivers.Height = $BBHeight
    $InstallDrivers.Location = $BBLocation
    $InstallDrivers.Font = $BBFont
    $InstallDrivers.ForeColor = $BBForeColor
    
    $NextYLocation = $InstallDrivers.Location.Y + $InstallDrivers.Height + $DistanceBetweenButtons
    # Panel 3 ~> Button 2
    $BraveBrowser = New-Object system.Windows.Forms.Button
    $BraveBrowser.Text = "Brave Browser"
    $BraveBrowser.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $BraveBrowser.Width = $SBWidth
    $BraveBrowser.Height = $SBHeight
    $BraveBrowser.Font = $SBFont
    $BraveBrowser.ForeColor = $SBForeColor
    
    $NextYLocation = $BraveBrowser.Location.Y + $BraveBrowser.Height + $DistanceBetweenButtons
    # Panel 3 ~> Button 3
    $GoogleChrome = New-Object system.Windows.Forms.Button
    $GoogleChrome.Text = "Google Chrome + uBlock"
    $GoogleChrome.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $GoogleChrome.Width = $SBWidth
    $GoogleChrome.Height = $SBHeight
    $GoogleChrome.Font = $SBFont
    $GoogleChrome.ForeColor = $SBForeColor

    $NextYLocation = $GoogleChrome.Location.Y + $GoogleChrome.Height + $DistanceBetweenButtons
    # Panel 3 ~> Button 4
    $MozillaFirefox = New-Object system.Windows.Forms.Button
    $MozillaFirefox.Text = "Mozilla Firefox"
    $MozillaFirefox.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $MozillaFirefox.Width = $SBWidth
    $MozillaFirefox.Height = $SBHeight
    $MozillaFirefox.Font = $SBFont
    $MozillaFirefox.ForeColor = $SBForeColor

    $NextYLocation = $MozillaFirefox.Location.Y + $MozillaFirefox.Height + $DistanceBetweenButtons
    # Panel 3 ~> Button 5
    $7Zip = New-Object system.Windows.Forms.Button
    $7Zip.Text = "7-Zip"
    $7Zip.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $7Zip.Width = $SBWidth
    $7Zip.Height = $SBHeight
    $7Zip.Font = $SBFont
    $7Zip.ForeColor = $SBForeColor
    
    $NextYLocation = $7Zip.Location.Y + $7Zip.Height + $DistanceBetweenButtons
    # Panel 3 ~> Button 6
    $WinRar = New-Object system.Windows.Forms.Button
    $WinRar.Text = "WinRar"
    $WinRar.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $WinRar.Width = $SBWidth
    $WinRar.Height = $SBHeight
    $WinRar.Font = $SBFont
    $WinRar.ForeColor = $SBForeColor
    
    $NextYLocation = $WinRar.Location.Y + $WinRar.Height + $DistanceBetweenButtons
    # Panel 3 ~> Button 7
    $VSCode = New-Object system.Windows.Forms.Button
    $VSCode.Text = "Visual Studio Code"
    $VSCode.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $VSCode.Width = $SBWidth
    $VSCode.Height = $SBHeight
    $VSCode.Font = $SBFont
    $VSCode.ForeColor = $SBForeColor
    
    $NextYLocation = $VSCode.Location.Y + $VSCode.Height + $DistanceBetweenButtons
    # Panel 3 ~> Button 8
    $NotepadPlusPlus = New-Object system.Windows.Forms.Button
    $NotepadPlusPlus.Text = "Notepad++"
    $NotepadPlusPlus.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $NotepadPlusPlus.Width = $SBWidth
    $NotepadPlusPlus.Height = $SBHeight
    $NotepadPlusPlus.Font = $SBFont
    $NotepadPlusPlus.ForeColor = $SBForeColor

    $NextYLocation = $NotepadPlusPlus.Location.Y + $NotepadPlusPlus.Height + $DistanceBetweenButtons
    # Panel 3 ~> Button 9
    $OnlyOffice = New-Object system.Windows.Forms.Button
    $OnlyOffice.Text = "ONLYOFFICE DesktopEditors"
    $OnlyOffice.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $OnlyOffice.Width = $SBWidth
    $OnlyOffice.Height = $SBHeight
    $OnlyOffice.Font = $SBFont
    $OnlyOffice.ForeColor = $SBForeColor
    
    $NextYLocation = $OnlyOffice.Location.Y + $OnlyOffice.Height + $DistanceBetweenButtons
    # Panel 3 ~> Button 10
    $qBittorrent = New-Object system.Windows.Forms.Button
    $qBittorrent.Text = "qBittorrent"
    $qBittorrent.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $qBittorrent.Width = $SBWidth
    $qBittorrent.Height = $SBHeight
    $qBittorrent.Font = $SBFont
    $qBittorrent.ForeColor = $SBForeColor
    
    $NextYLocation = $qBittorrent.Location.Y + $qBittorrent.Height + $DistanceBetweenButtons
    # Panel 3 ~> Button 11
    $Vlc = New-Object system.Windows.Forms.Button
    $Vlc.Text = "VideoLAN VLC"
    $Vlc.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Vlc.Width = $SBWidth
    $Vlc.Height = $SBHeight
    $Vlc.Font = $SBFont
    $Vlc.ForeColor = $SBForeColor
    
    $NextYLocation = $Vlc.Location.Y + $Vlc.Height + $DistanceBetweenButtons
    # Panel 3 ~> Button 12
    $Gimp = New-Object system.Windows.Forms.Button
    $Gimp.Text = "GIMP"
    $Gimp.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Gimp.Width = $SBWidth
    $Gimp.Height = $SBHeight
    $Gimp.Font = $SBFont
    $Gimp.ForeColor = $SBForeColor
    
    # Panel 4 ~> Button 1 (Big)
    $InstallGamingDependencies = New-Object system.Windows.Forms.Button
    $InstallGamingDependencies.Text = "Install Gaming Dependencies"
    $InstallGamingDependencies.Width = $BBWidth
    $InstallGamingDependencies.Height = $BBHeight
    $InstallGamingDependencies.Location = $BBLocation
    $InstallGamingDependencies.Font = $BBFont
    $InstallGamingDependencies.ForeColor = $BBForeColor

    $NextYLocation = $InstallGamingDependencies.Location.Y + $InstallGamingDependencies.Height + $DistanceBetweenButtons
    # Panel 4 ~> Button 2
    $Discord = New-Object system.Windows.Forms.Button
    $Discord.Text = "Discord"
    $Discord.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Discord.Width = $SBWidth
    $Discord.Height = $SBHeight
    $Discord.Font = $SBFont
    $Discord.ForeColor = $SBForeColor

    $NextYLocation = $Discord.Location.Y + $Discord.Height + $DistanceBetweenButtons
    # Panel 4 ~> Button 3
    $Steam = New-Object system.Windows.Forms.Button
    $Steam.Text = "Steam"
    $Steam.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Steam.Width = $SBWidth
    $Steam.Height = $SBHeight
    $Steam.Font = $SBFont
    $Steam.ForeColor = $SBForeColor

    $NextYLocation = $Steam.Location.Y + $Steam.Height + $DistanceBetweenButtons
    # Panel 4 ~> Button 4
    $Parsec = New-Object system.Windows.Forms.Button
    $Parsec.Text = "Parsec"
    $Parsec.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Parsec.Width = $SBWidth
    $Parsec.Height = $SBHeight
    $Parsec.Font = $SBFont
    $Parsec.ForeColor = $SBForeColor

    $NextYLocation = $Parsec.Location.Y + $Parsec.Height + $DistanceBetweenButtons
    # Panel 4 ~> Button 5
    $ObsStudio = New-Object system.Windows.Forms.Button
    $ObsStudio.Text = "OBS Studio"
    $ObsStudio.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $ObsStudio.Width = $SBWidth
    $ObsStudio.Height = $SBHeight
    $ObsStudio.Font = $SBFont
    $ObsStudio.ForeColor = $SBForeColor

    $NextYLocation = $ObsStudio.Location.Y + $ObsStudio.Height + $DistanceBetweenButtons
    # Panel 4 ~> Button 6
    $Spotify = New-Object system.Windows.Forms.Button
    $Spotify.Text = "Spotify"
    $Spotify.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $Spotify.Width = $SBWidth
    $Spotify.Height = $SBHeight
    $Spotify.Font = $SBFont
    $Spotify.ForeColor = $SBForeColor
        
    # Image Logo from the Script
    $PictureBox1 = New-Object system.Windows.Forms.PictureBox
    $PictureBox1.Width = 150
    $PictureBox1.Height = 150
    $PictureBox1.Location = New-Object System.Drawing.Point((($PWidth * 0.72) - $PictureBox1.Width), (($PHeight * 0.90) - $PictureBox1.Height))
    $PictureBox1.imageLocation = "$PSScriptRoot\src\lib\images\script-logo.png"
    $PictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom

    # Add all Panels to the Form (Screen)
    $Form.Controls.AddRange(@($Panel1, $Panel2, $Panel3, $Panel4))
    # Add Elements to each Panel
    $Panel1.Controls.AddRange(@($TitleLabel1, $ApplyTweaks, $RepairWindows, $PictureBox1))
    $Panel2.Controls.AddRange(@($TitleLabel2, $RevertScript, $DarkMode, $LightMode, $CaptionLabel2, $EnableCortana, $DisableCortana, $EnableTelemetry, $DisableTelemetry))
    $Panel3.Controls.AddRange(@($TitleLabel3, $CaptionLabel1, $InstallDrivers, $InstallSoftwares, $BraveBrowser, $GoogleChrome, $MozillaFirefox, $7Zip, $WinRar, $VSCode, $NotepadPlusPlus, $OnlyOffice, $qBittorrent, $Vlc, $Gimp))
    $Panel4.Controls.AddRange(@($TitleLabel4, $InstallGamingDependencies, $Discord, $Steam, $Parsec, $ObsStudio, $Spotify))

    # <=== CLICK EVENTS ===>

    # Panel 1 ~> Button 1 Mouse Click listener
    $ApplyTweaks.Add_Click( {

            Push-Location -Path "src\scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
                
            $Scripts = @(
                # [Recommended order] List of Scripts
                "backup-system.ps1"
                "silent-debloat-softwares.ps1"
                "optimize-scheduled-tasks.ps1"
                "optimize-services.ps1"
                "remove-bloatware-apps.ps1"
                "optimize-privacy-and-performance.ps1"
                "personal-tweaks.ps1"
                "optimize-security.ps1"
                "optimize-optional-features.ps1"
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

    # Panel 1 ~> Button 2 Mouse Click listener
    $RepairWindows.Add_Click( {

            Push-Location -Path "src\scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
            
            $Scripts = @(
                # [Recommended order] List of Scripts
                "backup-system.ps1"
                "repair-windows.ps1"
            )
        
            ForEach ($FileName in $Scripts) {
                Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }
            Pop-Location
        
            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 ~> Button 1 Mouse Click listener
    $RevertScript.Add_Click( {
            Push-Location -Path "src\scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
            
            $Global:Revert = $true
            $Scripts = @(
                # [Recommended order] List of Scripts
                "optimize-scheduled-tasks.ps1"
                "optimize-services.ps1"
                "optimize-privacy-and-performance.ps1"
                "personal-tweaks.ps1"
            )
          
            ForEach ($FileName in $Scripts) {
                Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }
            $Global:Revert = $false
          
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 ~> Button 2 Mouse Click listener
    $DarkMode.Add_Click( {

            Push-Location "src\utils\"
            Write-Host "[+] Enabling Dark theme..."
            regedit /s dark-theme.reg
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 ~> Button 3 Mouse Click listener
    $LightMode.Add_Click( {

            Push-Location "src\utils\"
            Write-Host "[+] Enabling Light theme..."
            regedit /s light-theme.reg
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 ~> Button 4 Mouse Click listener
    $EnableCortana.Add_Click( {

            Push-Location "src\utils\"
            Write-Host "[+] Enabling Cortana..."
            regedit /s enable-cortana.reg
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })
    
    # Panel 2 ~> Button 5 Mouse Click listener
    $DisableCortana.Add_Click( {

            Push-Location "src\utils\"
            Write-Host "[-] Disabling Cortana..."
            regedit /s disable-cortana.reg
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 ~> Button 5 Mouse Click listener
    $EnableTelemetry.Add_Click( {

            Push-Location "src\utils\"
            $FileName = "enable-telemetry.ps1"
            Import-Module -DisableNameChecking .\"$FileName" -Force
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 2 ~> Button 5 Mouse Click listener
    $DisableTelemetry.Add_Click( {

            Push-Location "src\utils\"
            $FileName = "disable-telemetry.ps1"
            Import-Module -DisableNameChecking .\"$FileName" -Force
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

        })

    # Panel 3 ~> Button 1 Mouse Click listener
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

    # Panel 3 ~> Button 2 Mouse Click listener
    $BraveBrowser.Add_Click( {
        
            $InstallParams = @{
                Name         = $BraveBrowser.Text
                PackageName  = "BraveSoftware.BraveBrowser"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock
        
        })

    
    # Panel 3 ~> Button 3 Mouse Click listener
    $GoogleChrome.Add_Click( {
            
            $InstallParams = @{
                Name         = $GoogleChrome.Text
                PackageName  = "Google.Chrome"
                InstallBlock = { winget install --silent $PackageName; choco install -y "ublockorigin-chrome" }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock
            
        })

    # Panel 3 ~> Button 4 Mouse Click listener
    $MozillaFirefox.Add_Click( {
            
            $InstallParams = @{
                Name         = $MozillaFirefox.Text
                PackageName  = "Mozilla.Firefox"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock
            
        })
        
    # Panel 3 ~> Button 5 Mouse Click listener
    $7Zip.Add_Click( {
        
            $InstallParams = @{
                Name         = $7Zip.Text
                PackageName  = "7zip.7zip"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock
    
        })

    # Panel 3 ~> Button 6 Mouse Click listener
    $WinRar.Add_Click( {
            
            $InstallParams = @{
                Name         = $WinRar.Text
                PackageName  = "winrar"
                InstallBlock = { choco install -y $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })
        
    # Panel 3 ~> Button 7 Mouse Click listener
    $VSCode.Add_Click( {
            
            $InstallParams = @{
                Name         = $VSCode.Text
                PackageName  = "Microsoft.VisualStudioCode"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
        
        })

    # Panel 3 ~> Button 8 Mouse Click listener
    $NotepadPlusPlus.Add_Click( {
            
            $InstallParams = @{
                Name         = $NotepadPlusPlus.Text
                PackageName  = "Notepad++.Notepad++"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
            
        })
        
    # Panel 3 ~> Button 9 Mouse Click listener
    $OnlyOffice.Add_Click( {
            
            $InstallParams = @{
                Name         = $OnlyOffice.Text
                PackageName  = "ONLYOFFICE.DesktopEditors"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
            
        })
        
    # Panel 3 ~> Button 10 Mouse Click listener
    $qBittorrent.Add_Click( {
            
            $InstallParams = @{
                Name         = $qBittorrent.Text
                PackageName  = "qBittorrent.qBittorrent"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
            
        })
        
    # Panel 3 ~> Button 11 Mouse Click listener
    $Vlc.Add_Click( {
            
            $InstallParams = @{
                Name         = $Vlc.Text
                PackageName  = "VideoLAN.VLC"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
            
        })
        
    # Panel 3 ~> Button 12 Mouse Click listener
    $Gimp.Add_Click( {

            $InstallParams = @{
                Name         = $Gimp.Text
                PackageName  = "GIMP.GIMP"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
                    
        })

    # Panel 4 ~> Button 1 Mouse Click listener
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

    # Panel 3 ~> Button 2 Mouse Click listener
    $Discord.Add_Click( {

            $InstallParams = @{
                Name         = $Discord.Text
                PackageName  = "Discord.Discord"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
        
        })
    # Panel 3 ~> Button 3 Mouse Click listener
    $Steam.Add_Click( {

            $InstallParams = @{
                Name         = $Steam.Text
                PackageName  = "Valve.Steam"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        

        })

    # Panel 3 ~> Button 4 Mouse Click listener
    $Parsec.Add_Click( {
        
            $InstallParams = @{
                Name         = $Parsec.Text
                PackageName  = "Parsec.Parsec"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
        
        })

    # Panel 3 ~> Button 5 Mouse Click listener
    $ObsStudio.Add_Click( {

            $InstallParams = @{
                Name         = $ObsStudio.Text
                PackageName  = "OBSProject.OBSStudio"
                InstallBlock = { winget install --silent $PackageName }
            }
            InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock        
    
        })

    # Panel 3 ~> Button 6 Mouse Click listener
    $Spotify.Add_Click( {
            
            $InstallParams = @{
                Name         = $Spotify.Text
                PackageName  = "Spotify.Spotify"
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
    Taskkill /F /IM $PID        # Kill this task by PID because it won't exit with the command 'exit'

}

Main