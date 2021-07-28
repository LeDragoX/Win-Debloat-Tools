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

    #Import-Module -DisableNameChecking .\"check-os-info.psm1"      # Not Used
    Import-Module -DisableNameChecking .\"count-n-seconds.psm1"
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

    # Panel 1 ~> Title Label 1
    $TitleLabel1 = New-Object system.Windows.Forms.Label
    $TitleLabel1.Text = " System Tweaks"
    $TitleLabel1.Width = $TLWidth
    $TitleLabel1.Height = $TLHeight
    $TitleLabel1.Location = $TLLocation
    $TitleLabel1.Font = $TLFont
    $TitleLabel1.ForeColor = $TLForeColor

    # Panel 2 ~> Title Label 2
    $TitleLabel2 = New-Object system.Windows.Forms.Label
    $TitleLabel2.Text = "    Customize"
    $TitleLabel2.Width = $TLWidth
    $TitleLabel2.Height = $TLHeight
    $TitleLabel2.Location = $TLLocation
    $TitleLabel2.Font = $TLFont
    $TitleLabel2.ForeColor = $TLForeColor

    # Panel 3 ~> Title Label 3
    $TitleLabel3 = New-Object system.Windows.Forms.Label
    $TitleLabel3.Text = "Software Install"
    $TitleLabel3.Width = $TLWidth
    $TitleLabel3.Height = $TLHeight
    $TitleLabel3.Location = $TLLocation
    $TitleLabel3.Font = $TLFont
    $TitleLabel3.ForeColor = $TLForeColor

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
    
    # Panel 1 ~> Button 2
    $RepairWindows = New-Object system.Windows.Forms.Button
    $RepairWindows.Text = "Repair Windows"
    $NextYLocation = $ApplyTweaks.Location.Y + $ApplyTweaks.Height + $DistanceBetweenButtons
    $RepairWindows.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $RepairWindows.Width = $SBWidth
    $RepairWindows.Height = $SBHeight
    $RepairWindows.Font = $SBFont
    $RepairWindows.ForeColor = $SBForeColor

    # Panel 2 ~> Button 1 (Big)
    $RevertScript = New-Object system.Windows.Forms.Button
    $RevertScript.Text = "Revert Tweaks (WIP)"
    $RevertScript.Width = $BBWidth
    $RevertScript.Height = $BBHeight
    $RevertScript.Location = $BBLocation
    $RevertScript.Font = $BBFont
    $RevertScript.ForeColor = $BBForeColor    

    # Panel 2 ~> Button 2
    $DarkMode = New-Object system.Windows.Forms.Button
    $DarkMode.Text = "Dark Mode"
    $NextYLocation = $RevertScript.Location.Y + $RevertScript.Height + $DistanceBetweenButtons
    $DarkMode.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $DarkMode.Width = $SBWidth
    $DarkMode.Height = $SBHeight
    $DarkMode.Font = $SBFont
    $DarkMode.ForeColor = $SBForeColor
    
    # Panel 2 ~> Button 3
    $LightMode = New-Object system.Windows.Forms.Button
    $LightMode.Text = "Light Mode"
    $NextYLocation = $DarkMode.Location.Y + $DarkMode.Height + $DistanceBetweenButtons
    $LightMode.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $LightMode.Width = $SBWidth
    $LightMode.Height = $SBHeight
    $LightMode.Font = $SBFont
    $LightMode.ForeColor = $SBForeColor

    # Panel 2 ~> Button 4
    $EnableCortana = New-Object system.Windows.Forms.Button
    $EnableCortana.Text = "Enable Cortana"
    $NextYLocation = $LightMode.Location.Y + $LightMode.Height + $DistanceBetweenButtons
    $EnableCortana.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $EnableCortana.Width = $SBWidth
    $EnableCortana.Height = $SBHeight
    $EnableCortana.Font = $SBFont
    $EnableCortana.ForeColor = $SBForeColor

    # Panel 2 ~> Button 5
    $DisableCortana = New-Object system.Windows.Forms.Button
    $DisableCortana.Text = "Disable Cortana"
    $NextYLocation = $EnableCortana.Location.Y + $EnableCortana.Height + $DistanceBetweenButtons
    $DisableCortana.Location = New-Object System.Drawing.Point($ButtonX, $NextYLocation)
    $DisableCortana.Width = $SBWidth
    $DisableCortana.Height = $SBHeight
    $DisableCortana.Font = $SBFont
    $DisableCortana.ForeColor = $SBForeColor
    
    # Panel 3 ~> Button 1 (Big)
    $PkgSwInstaller = New-Object system.Windows.Forms.Button
    $PkgSwInstaller.Text = "Install Softwares (Winget/Choco)"
    $PkgSwInstaller.Width = $BBWidth
    $PkgSwInstaller.Height = $BBHeight
    $PkgSwInstaller.Location = $BBLocation
    $PkgSwInstaller.Font = $BBFont
    $PkgSwInstaller.ForeColor = $BBForeColor
    
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
    $Panel2.Controls.AddRange(@($TitleLabel2, $RevertScript, $DarkMode, $LightMode, $CaptionLabel2, $EnableCortana, $DisableCortana))
    $Panel3.Controls.AddRange(@($TitleLabel3, $CaptionLabel1, $PkgSwInstaller))

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
                "personal-optimizations.ps1"
                "optimize-security.ps1"
                "enable-optional-features.ps1"
                "remove-onedrive.ps1"
                "install-package-managers.ps1"
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
                "personal-optimizations.ps1"
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

    # Panel 3 ~> Button 1 Mouse Click listener
    $PkgSwInstaller.Add_Click( {

            Push-Location -Path "src\scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
        
            $Scripts = @(
                # [Recommended order] List of Scripts
                "install-package-managers.ps1"
                "software-installer.ps1"
            )
        
            ForEach ($FileName in $Scripts) {
                Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName" -Force
            }

            Pop-Location
        
            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
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
    
    PrepareGUI                  # Load the GUI
    
    Write-Verbose "Restart: $Global:NeedRestart"
    If ($Global:NeedRestart) {
        PromptPcRestart         # Prompt options to Restart the PC
    }
    
    RestrictPermissions         # Lock script usage
    Taskkill /F /IM $PID        # Kill this task by PID because it won't exit with the command 'exit'

}

Main