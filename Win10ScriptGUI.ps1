Function QuickPrivilegesElevation {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

Function LoadLibs {

    Write-Host "Current Script Folder $PSScriptRoot"
    Write-Host ""
    Push-Location $PSScriptRoot
	
    Push-Location -Path .\lib
        Get-ChildItem -Recurse *.ps*1 | Unblock-File
    Pop-Location

    #Import-Module -DisableNameChecking $PSScriptRoot\lib\"Check-OS-Info.psm1"		# Not Used
    Import-Module -DisableNameChecking $PSScriptRoot\lib\"Count-N-Seconds.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\lib\"Set-Script-Policy.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\lib\"Setup-Console-Style.psm1" # Make the Console look how i want
    Import-Module -DisableNameChecking $PSScriptRoot\lib\"Simple-Message-Box.psm1"
    Import-Module -DisableNameChecking $PSScriptRoot\lib\"Title-Templates.psm1"

}

Function PromptPcRestart {

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
        'Cancel' { # With Yes, No and Cancel, the user can press Esc to exit
            Write-Host "You choose to Restart later"
            Write-Host "You choose Cancel. (Cancel = No)"
        }
    }
    
}

# https://docs.microsoft.com/pt-br/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.1
# Adapted majorly from https://github.com/ChrisTitusTech/win10script and https://github.com/Sycnex/Windows10Debloater
Function PrepareGUI {

    # <=== WHEN DONE BUTTON ===>

    $DoneTitle          = "Done"
    $DoneMessage        = "Proccess Completed!"

    # <=== SIZES ===>

    $MaxWidth           = 854
    $MaxHeight          = 480
    [int]$PanelWidth    = ($MaxWidth/3) # 214
    $TitleLabelWidth    = 25
    $TitleLabelHeight   = 10
    $ButtonWidth        = 150
    $ButtonHeight       = 30
    $BigButtonHeight    = 70

    # <=== LOCATIONS ===>

    [int]$TitleLabelX   = $PanelWidth*0.15
    [int]$TitleLabelY   = $MaxHeight*0.01
    [int]$CaptionLabelX = $PanelWidth*0.25
    [int]$ButtonX       = $PanelWidth*0.15

    # <=== COLORS ===>

    $Black              = "#000000"
    $DarkGray           = "#111111"
    $Green              = "#1fff00"
    $LightBlue          = "#00ffff"
    $LightGray          = "#eeeeee"
    $White              = "#ffffff"
    $WinBlue            = "#2376bc"
    $WinDark            = "#252525"
    $WinGray            = "#e6e6e6"

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # Main Window:
    $Form                               = New-Object System.Windows.Forms.Form
    $Form.Text                          = "Windows 10 Smart Debloat - by LeDragoX"
    $Form.Size                          = New-Object System.Drawing.Size($MaxWidth, $MaxHeight)
    $Form.StartPosition                 = 'CenterScreen'    # Appears on the center
    $Form.FormBorderStyle               = 'FixedSingle'     # Not adjustable
    $Form.MinimizeBox                   = $true             # Remove the Minimize Button
    $Form.MaximizeBox                   = $false            # Remove the Maximize Button
    $Form.TopMost                       = $false
    $Form.BackColor                     = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
    
    # Icon: https://stackoverflow.com/a/53377253
    $iconBase64                         = [Convert]::ToBase64String((Get-Content ".\lib\images\Script-icon.png" -Encoding Byte))
    $iconBytes                          = [Convert]::FromBase64String($iconBase64)
    $stream                             = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
    $stream.Write($iconBytes, 0, $iconBytes.Length);
    $Form.Icon                          = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())
    
    # Panel 1 to put Labels and Buttons
    $Panel1                             = New-Object system.Windows.Forms.Panel
    $Panel1.width                       = $PanelWidth
    $Panel1.height                      = $MaxHeight
    $Panel1.location                    = New-Object System.Drawing.Point(0,0)
    
    # Panel 1 ~> Title Label 1
    $TitleLabel1                        = New-Object system.Windows.Forms.Label
    $TitleLabel1.text                   = "System Tweaks"
    $TitleLabel1.AutoSize               = $true
    $TitleLabel1.width                  = $TitleLabelWidth
    $TitleLabel1.height                 = $TitleLabelHeight
    $TitleLabel1.location               = New-Object System.Drawing.Point($TitleLabelX, $TitleLabelY)
    $TitleLabel1.Font                   = New-Object System.Drawing.Font('Arial', 16, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $TitleLabel1.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("$Green") # Green
    $Panel1.Controls.Add($TitleLabel1)
    
    # Panel 1 ~> Button 1
    $ApplyTweaks                        = New-Object system.Windows.Forms.Button
    $ApplyTweaks.text                   = "Apply Tweaks"
    $ApplyTweaks.width                  = $ButtonWidth
    $ApplyTweaks.height                 = $BigButtonHeight
    $ApplyTweaks.location               = New-Object System.Drawing.Point($ButtonX, 40)
    $ApplyTweaks.Font                   = New-Object System.Drawing.Font('Arial', 12, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $ApplyTweaks.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("$LightBlue") # Light Blue
    $Panel1.Controls.Add($ApplyTweaks)
    
    # Panel 1 ~> Button 2
    $uiTweaks                           = New-Object system.Windows.Forms.Button
    $uiTweaks.text                      = "UI/UX Tweaks"
    $uiTweaks.width                     = $ButtonWidth
    $uiTweaks.height                    = $ButtonHeight
    $uiTweaks.location                  = New-Object System.Drawing.Point($ButtonX, 125)
    $uiTweaks.Font                      = New-Object System.Drawing.Font('Arial', 12)
    $uiTweaks.ForeColor                 = [System.Drawing.ColorTranslator]::FromHtml("$LightGray") # Light Gray
    $Panel1.Controls.Add($uiTweaks)

    # Panel 1 ~> Button 3
    $RepairWindows                      = New-Object system.Windows.Forms.Button
    $RepairWindows.text                 = "Repair Windows"
    $RepairWindows.width                = $ButtonWidth
    $RepairWindows.height               = $ButtonHeight
    $RepairWindows.location             = New-Object System.Drawing.Point($ButtonX, 160)
    $RepairWindows.Font                 = New-Object System.Drawing.Font('Arial', 12)
    $RepairWindows.ForeColor            = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
    $Panel1.Controls.Add($RepairWindows)    

    # Panel 2 to put Labels and Buttons
    $Panel2                             = New-Object system.Windows.Forms.Panel
    $Panel2.width                       = $PanelWidth
    $Panel2.height                      = $MaxHeight
    $Panel2.location                    = New-Object System.Drawing.Point($PanelWidth, 0)

    # Panel 2 ~> Title Label 2
    $TitleLabel2                        = New-Object system.Windows.Forms.Label
    $TitleLabel2.text                   = "Misc. Tweaks"
    $TitleLabel2.AutoSize               = $true
    $TitleLabel2.width                  = $TitleLabelWidth
    $TitleLabel2.height                 = $TitleLabelHeight
    $TitleLabel2.location               = New-Object System.Drawing.Point($TitleLabelX, $TitleLabelY)
    $TitleLabel2.Font                   = New-Object System.Drawing.Font('Arial', 16, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $TitleLabel2.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("$Green")
    $Panel2.Controls.Add($TitleLabel2)

    # Panel 2 ~> Caption Label 1
    $CaptionLabel1                      = New-Object system.Windows.Forms.Label
    $CaptionLabel1.text                 = "- Theme -"
    $CaptionLabel1.AutoSize             = $true
    $CaptionLabel1.width                = 25
    $CaptionLabel1.height               = 10
    $CaptionLabel1.location             = New-Object System.Drawing.Point($CaptionLabelX, 35)
    $CaptionLabel1.Font                 = New-Object System.Drawing.Font('Arial', 14)
    $CaptionLabel1.ForeColor            = [System.Drawing.ColorTranslator]::FromHtml("$Green")
    $Panel2.Controls.Add($CaptionLabel1)    

    # Panel 2 ~> Button 1
    $DarkMode                           = New-Object system.Windows.Forms.Button
    $DarkMode.text                      = "Dark Mode"
    $DarkMode.width                     = $ButtonWidth
    $DarkMode.height                    = $ButtonHeight
    $DarkMode.location                  = New-Object System.Drawing.Point($ButtonX, 65)
    $DarkMode.Font                      = New-Object System.Drawing.Font('Arial', 12)
    $DarkMode.ForeColor                 = [System.Drawing.ColorTranslator]::FromHtml("$White")
    $DarkMode.BackColor                 = [System.Drawing.ColorTranslator]::FromHtml("$Black")
    $Panel2.Controls.Add($DarkMode)
    
    # Panel 2 ~> Button 2
    $LightMode                          = New-Object system.Windows.Forms.Button
    $LightMode.text                     = "Light Mode"
    $LightMode.width                    = $ButtonWidth
    $LightMode.height                   = $ButtonHeight
    $LightMode.location                 = New-Object System.Drawing.Point($ButtonX, 100)
    $LightMode.Font                     = New-Object System.Drawing.Font('Arial', 12)
    $LightMode.ForeColor                = [System.Drawing.ColorTranslator]::FromHtml("$Black")
    $LightMode.BackColor                = [System.Drawing.ColorTranslator]::FromHtml("$White")
    $Panel2.Controls.Add($LightMode)

    # Panel 2 ~> Caption Label 2
    $CaptionLabel2                      = New-Object system.Windows.Forms.Label
    $CaptionLabel2.text                 = "- Cortana -"
    $CaptionLabel2.AutoSize             = $true
    $CaptionLabel2.width                = 25
    $CaptionLabel2.height               = 10
    $CaptionLabel2.location             = New-Object System.Drawing.Point($CaptionLabelX, 135)
    $CaptionLabel2.Font                 = New-Object System.Drawing.Font('Arial', 14)
    $CaptionLabel2.ForeColor            = [System.Drawing.ColorTranslator]::FromHtml("$Green")
    $Panel2.Controls.Add($CaptionLabel2)

    # Panel 2 ~> Button 3
    $EnableCortana                      = New-Object system.Windows.Forms.Button
    $EnableCortana.text                 = "Enable"
    $EnableCortana.width                = $ButtonWidth
    $EnableCortana.height               = $ButtonHeight
    $EnableCortana.location             = New-Object System.Drawing.Point($ButtonX, 165)
    $EnableCortana.Font                 = New-Object System.Drawing.Font('Arial', 12)
    $EnableCortana.ForeColor            = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
    $Panel2.Controls.Add($EnableCortana)

    # Panel 2 ~> Button 4
    $DisableCortana                     = New-Object system.Windows.Forms.Button
    $DisableCortana.text                = "Disable"
    $DisableCortana.width               = $ButtonWidth
    $DisableCortana.height              = $ButtonHeight
    $DisableCortana.location            = New-Object System.Drawing.Point($ButtonX, 200)
    $DisableCortana.Font                = New-Object System.Drawing.Font('Arial', 12)
    $DisableCortana.ForeColor           = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
    $Panel2.Controls.Add($DisableCortana)
    
    # Panel 3 to put Labels and Buttons
    $Panel3                             = New-Object system.Windows.Forms.Panel
    $Panel3.width                       = $PanelWidth
    $Panel3.height                      = $MaxHeight-[int]($MaxHeight*0.5)
    $Panel3.location                    = New-Object System.Drawing.Point(($PanelWidth*2), 0)
    
    # Panel 3 ~> Title Label 3
    $TitleLabel3                        = New-Object system.Windows.Forms.Label
    $TitleLabel3.text                   = "Software Install"
    $TitleLabel3.AutoSize               = $true
    $TitleLabel3.width                  = $TitleLabelWidth
    $TitleLabel3.height                 = $TitleLabelHeight
    $TitleLabel3.location               = New-Object System.Drawing.Point($TitleLabelX,$TitleLabelY)
    $TitleLabel3.Font                   = New-Object System.Drawing.Font('Arial', 16, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $TitleLabel3.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("$Green")
    $Panel3.Controls.Add($TitleLabel3)
    
    # Panel 3 ~> Button 1
    $ChocolateySwInstaller              = New-Object system.Windows.Forms.Button
    $ChocolateySwInstaller.text         = "Install Basic Programs (Chocolatey)"
    $ChocolateySwInstaller.width        = $ButtonWidth
    $ChocolateySwInstaller.height       = $BigButtonHeight
    $ChocolateySwInstaller.location     = New-Object System.Drawing.Point($ButtonX, 40)
    $ChocolateySwInstaller.Font         = New-Object System.Drawing.Font('Arial', 12)
    $ChocolateySwInstaller.ForeColor    = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
    $Panel3.Controls.Add($ChocolateySwInstaller)    
    
    # Image Logo from the Script
    $PictureBox1                        = New-Object system.Windows.Forms.PictureBox
    $PictureBox1.width                  = 150
    $PictureBox1.height                 = 150
    $PictureBox1.location               = New-Object System.Drawing.Point(($MaxWidth*0.72), ($MaxHeight*0.5))
    $PictureBox1.imageLocation          = ".\lib\images\Script-logo.png"
    $PictureBox1.SizeMode               = [System.Windows.Forms.PictureBoxSizeMode]::zoom

    # Panel 1 ~> Button 1 Mouse Click listener
    $ApplyTweaks.Add_Click({

        $Global:NeedRestart = $true
        Push-Location -Path .\scripts
    
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
            $PictureBox1.imageLocation      = ".\lib\images\Script-logo2.png"
            $Form.Update()    
            
            Clear-Host
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
            )
        
            ForEach ($FileName in $Scripts) {
                Title2 -Text "$FileName"
                Import-Module -DisableNameChecking .\"$FileName"
                # pause ### FOR DEBUGGING PURPOSES
            }
                
        Pop-Location

        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })    

    # Panel 1 ~> Button 2 Mouse Click listener
    $uiTweaks.Add_Click({

        $Global:NeedRestart = $true
        Push-Location -Path .\scripts
        
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
            
            Clear-Host
            $Scripts = @(
                # [Recommended order] List of Scripts
                "manual-debloat-softwares.ps1"
            )
        
            ForEach ($FileName in $Scripts) {
                Title2 -Text "$FileName"
                Import-Module -DisableNameChecking .\"$FileName"
                # pause ### FOR DEBUGGING PURPOSES
            }
        
        Pop-Location

        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })

    # Panel 1 ~> Button 3 Mouse Click listener
    $RepairWindows.Add_Click({

        $Global:NeedRestart = $true
        Push-Location -Path .\scripts
    
            Get-ChildItem -Recurse *.ps*1 | Unblock-File

            Clear-Host
            $Scripts = @(
                # [Recommended order] List of Scripts
                "backup-system.ps1"
                "repair-windows.ps1"
            )
        
            ForEach ($FileName in $Scripts) {
                Title2 -Text "$FileName"
                Import-Module -DisableNameChecking .\"$FileName"
                # pause ### FOR DEBUGGING PURPOSES
            }

        Pop-Location
        
        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })

    # Panel 2 ~> Button 1 Mouse Click listener
    $DarkMode.Add_Click({

        Push-Location ".\utils"
            Write-Host "[+] Enabling Dark theme..."
            regedit /s dark-theme.reg
        Pop-Location

        $Form.BackColor                     = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")

        $ApplyTweaks.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("$LightBlue")
        $uiTweaks.ForeColor                 = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
        $RepairWindows.ForeColor            = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
        $ChocolateySwInstaller.ForeColor    = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
        $EnableCortana.ForeColor            = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
        $DisableCortana.ForeColor           = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")


        $ApplyTweaks.BackColor              = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
        $uiTweaks.BackColor                 = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
        $RepairWindows.BackColor            = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
        $ChocolateySwInstaller.BackColor    = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
        $EnableCortana.BackColor            = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
        $DisableCortana.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")

        $Form.Update()
        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })

    # Panel 2 ~> Button 2 Mouse Click listener
    $LightMode.Add_Click({

        Push-Location ".\utils"
            Write-Host "[+] Enabling Light theme..."
            regedit /s light-theme.reg
        Pop-Location

        $Form.BackColor                     = [System.Drawing.ColorTranslator]::FromHtml("$White")

        $ApplyTweaks.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("$WinBlue")
        $uiTweaks.ForeColor                 = [System.Drawing.ColorTranslator]::FromHtml("$DarkGray")
        $RepairWindows.ForeColor            = [System.Drawing.ColorTranslator]::FromHtml("$DarkGray")
        $ChocolateySwInstaller.ForeColor    = [System.Drawing.ColorTranslator]::FromHtml("$DarkGray")
        $EnableCortana.ForeColor            = [System.Drawing.ColorTranslator]::FromHtml("$DarkGray")
        $DisableCortana.ForeColor           = [System.Drawing.ColorTranslator]::FromHtml("$DarkGray")

        $ApplyTweaks.BackColor              = [System.Drawing.ColorTranslator]::FromHtml("$WinGray")
        $uiTweaks.BackColor                 = [System.Drawing.ColorTranslator]::FromHtml("$WinGray")
        $RepairWindows.BackColor            = [System.Drawing.ColorTranslator]::FromHtml("$WinGray")
        $ChocolateySwInstaller.BackColor    = [System.Drawing.ColorTranslator]::FromHtml("$WinGray")
        $EnableCortana.BackColor            = [System.Drawing.ColorTranslator]::FromHtml("$WinGray")
        $DisableCortana.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("$WinGray")

        $Form.Update()
        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })

    # Panel 2 ~> Button 3 Mouse Click listener
    $EnableCortana.Add_Click({

        Push-Location ".\utils"
            Write-Host "[+] Enabling Cortana..."
            regedit /s enable-cortana.reg
        Pop-Location

        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })
    
    # Panel 2 ~> Button 4 Mouse Click listener
    $DisableCortana.Add_Click({

        Push-Location ".\utils"
            Write-Host "[-] Disabling Cortana..."
            regedit /s disable-cortana.reg
        Pop-Location

        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })

    # Panel 3 ~> Button 1 Mouse Click listener
    $ChocolateySwInstaller.Add_Click({

        Push-Location -Path .\scripts
    
            Get-ChildItem -Recurse *.ps*1 | Unblock-File

            Clear-Host
            $Scripts = @(
                # [Recommended order] List of Scripts
                "choco-sw-installer.ps1"
            )
        
            ForEach ($FileName in $Scripts) {
                Title2 -Text "$FileName"
                Import-Module -DisableNameChecking .\"$FileName"
                # pause ### FOR DEBUGGING PURPOSES
            }

        Pop-Location
        
        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })
    
    # Add all Panels to the Form (Screen)
    $Form.controls.AddRange(@($Panel1,$Panel2,$Panel3,$Panel4,$PictureBox1))
    
    # Show the Window
    [void]$Form.ShowDialog()
    
    # When done, dispose of the GUI
    $Form.Dispose()

}

Clear-Host                  # Clear the Powershell before it got an Output
QuickPrivilegesElevation    # Check admin rights
LoadLibs                    # Import modules from lib folder
UnrestrictPermissions       # Unlock script usage
SetupConsoleStyle           # Just fix the font on the PS console

$Global:NeedRestart = $false
PrepareGUI                  # Load the GUI

If ($NeedRestart -eq $true) {
    PromptPcRestart             # Prompt options to Restart the PC
}

RestrictPermissions         # Lock script usage
Taskkill /F /IM $PID        # Kill this task by PID because it won't exit with the command 'exit'