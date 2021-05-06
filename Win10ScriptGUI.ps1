function QuickPrivilegesElevation {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function LoadLibs {

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

function PromptPcRestart {

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
function PrepareGUI {

    $DoneTitle      = "Done"
    $DoneMessage    = "Proccess Completed!"

    # <=== COLORS ===>

    $Black      = "#000000"
    $DarkGray   = "#111111"
    $Green      = "#1fff00"
    $LightBlue  = "#00ffff"
    $LightGray  = "#eeeeee"
    $WinBlue    = "#2376bc"
    $WinDark    = "#252525"
    $WinGray    = "#e6e6e6"
    $White      = "#ffffff"

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # Main Window:
    $Form                               = New-Object System.Windows.Forms.Form
    $Form.Text                          = "Windows 10 Smart Debloat - by LeDragoX"
    $Form.Size                          = New-Object System.Drawing.Size(854,480)
    $Form.StartPosition                 = 'CenterScreen'    # Appears on the center
    $Form.FormBorderStyle               = 'FixedSingle'     # Not adjustable
    $Form.MinimizeBox                   = $false            # Remove the Minimize Button
    $Form.MaximizeBox                   = $false            # Remove the Maximize Button
    $Form.TopMost                       = $false
    $Form.BackColor                     = [System.Drawing.ColorTranslator]::FromHtml("$WinDark") # Windows Dark
    
    # Icon: https://stackoverflow.com/a/53377253
    $iconBase64                         = [Convert]::ToBase64String((Get-Content ".\lib\images\Windows-10-logo_icon.png" -Encoding Byte))
    $iconBytes                          = [Convert]::FromBase64String($iconBase64)
    $stream                             = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
    $stream.Write($iconBytes, 0, $iconBytes.Length);
    $Form.Icon                          = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())
    
    # Panel 1 to put Labels and Buttons
    $Panel1                             = New-Object system.Windows.Forms.Panel
    $Panel1.width                       = 284
    $Panel1.height                      = 480
    $Panel1.location                    = New-Object System.Drawing.Point(0,0)
    
    # Panel 1 ~> Title Label 1
    $TitleLabel1                        = New-Object system.Windows.Forms.Label
    $TitleLabel1.text                   = "System Tweaks"
    $TitleLabel1.AutoSize               = $true
    $TitleLabel1.width                  = 25
    $TitleLabel1.height                 = 10
    $TitleLabel1.location               = New-Object System.Drawing.Point(50,3)
    $TitleLabel1.Font                   = New-Object System.Drawing.Font('Arial',16)
    $TitleLabel1.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("$Green") # Green
    $Panel1.Controls.Add($TitleLabel1)
    
    # Panel 1 ~> Button 1
    $automatedTweaks                    = New-Object system.Windows.Forms.Button
    $automatedTweaks.text               = "Automated Tweaks"
    $automatedTweaks.width              = 200
    $automatedTweaks.height             = 70
    $automatedTweaks.location           = New-Object System.Drawing.Point(25,40)
    $automatedTweaks.Font               = New-Object System.Drawing.Font('Arial',12)
    $automatedTweaks.ForeColor          = [System.Drawing.ColorTranslator]::FromHtml("$LightBlue") # Light Blue
    $Panel1.Controls.Add($automatedTweaks)
    
    # Panel 1 ~> Button 2
    $uiTweaks                           = New-Object system.Windows.Forms.Button
    $uiTweaks.text                      = "UI/UX Tweaks (WinAero)"
    $uiTweaks.width                     = 200
    $uiTweaks.height                    = 70
    $uiTweaks.location                  = New-Object System.Drawing.Point(25,130)
    $uiTweaks.Font                      = New-Object System.Drawing.Font('Arial',12)
    $uiTweaks.ForeColor                 = [System.Drawing.ColorTranslator]::FromHtml("$LightGray") # Light Gray
    $Panel1.Controls.Add($uiTweaks)

    # Panel 1 ~> Button 3
    $FixProblems                        = New-Object system.Windows.Forms.Button
    $FixProblems.text                   = "Fix Windows Problems"
    $FixProblems.width                  = 200
    $FixProblems.height                 = 70
    $FixProblems.location               = New-Object System.Drawing.Point(25,220)
    $FixProblems.Font                   = New-Object System.Drawing.Font('Arial',12)
    $FixProblems.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
    $Panel1.Controls.Add($FixProblems)    

    # Panel 2 to put Labels and Buttons
    $Panel2                             = New-Object system.Windows.Forms.Panel
    $Panel2.width                       = 284
    $Panel2.height                      = 250
    $Panel2.location                    = New-Object System.Drawing.Point(300,0)

    # Panel 2 ~> Title Label 2
    $TitleLabel2                        = New-Object system.Windows.Forms.Label
    $TitleLabel2.text                   = "Miscellaneous Tweaks"
    $TitleLabel2.AutoSize               = $true
    $TitleLabel2.width                  = 25
    $TitleLabel2.height                 = 10
    $TitleLabel2.location               = New-Object System.Drawing.Point(10,3)
    $TitleLabel2.Font                   = New-Object System.Drawing.Font('Arial',16)
    $TitleLabel2.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("$Green")
    $Panel2.Controls.Add($TitleLabel2)

    # Panel 2 ~> Caption Label 1
    $CaptionLabel1                      = New-Object system.Windows.Forms.Label
    $CaptionLabel1.text                 = "- Theme -"
    $CaptionLabel1.AutoSize             = $true
    $CaptionLabel1.width                = 25
    $CaptionLabel1.height               = 10
    $CaptionLabel1.location             = New-Object System.Drawing.Point(80,35)
    $CaptionLabel1.Font                 = New-Object System.Drawing.Font('Arial',14)
    $CaptionLabel1.ForeColor            = [System.Drawing.ColorTranslator]::FromHtml("$Green")
    $Panel2.Controls.Add($CaptionLabel1)    

    # Panel 2 ~> Button 1
    $DarkMode                           = New-Object system.Windows.Forms.Button
    $DarkMode.text                      = "Dark Mode"
    $DarkMode.width                     = 200
    $DarkMode.height                    = 30
    $DarkMode.location                  = New-Object System.Drawing.Point(25,65)
    $DarkMode.Font                      = New-Object System.Drawing.Font('Arial',12)
    $DarkMode.ForeColor                 = [System.Drawing.ColorTranslator]::FromHtml("$White")
    $DarkMode.BackColor                 = [System.Drawing.ColorTranslator]::FromHtml("$Black")
    $Panel2.Controls.Add($DarkMode)
    
    # Panel 2 ~> Button 2
    $LightMode                          = New-Object system.Windows.Forms.Button
    $LightMode.text                     = "Light Mode"
    $LightMode.width                    = 200
    $LightMode.height                   = 30
    $LightMode.location                 = New-Object System.Drawing.Point(25,100)
    $LightMode.Font                     = New-Object System.Drawing.Font('Arial',12)
    $LightMode.ForeColor                = [System.Drawing.ColorTranslator]::FromHtml("$Black")
    $LightMode.BackColor                = [System.Drawing.ColorTranslator]::FromHtml("$White")
    $Panel2.Controls.Add($LightMode)

    # Panel 2 ~> Caption Label 2
    $CaptionLabel2                      = New-Object system.Windows.Forms.Label
    $CaptionLabel2.text                 = "- Cortana -"
    $CaptionLabel2.AutoSize             = $true
    $CaptionLabel2.width                = 25
    $CaptionLabel2.height               = 10
    $CaptionLabel2.location             = New-Object System.Drawing.Point(80,135)
    $CaptionLabel2.Font                 = New-Object System.Drawing.Font('Arial',14)
    $CaptionLabel2.ForeColor            = [System.Drawing.ColorTranslator]::FromHtml("$Green")
    $Panel2.Controls.Add($CaptionLabel2)

    # Panel 2 ~> Button 3
    $EnableCortana                           = New-Object system.Windows.Forms.Button
    $EnableCortana.text                      = "Enable"
    $EnableCortana.width                     = 200
    $EnableCortana.height                    = 30
    $EnableCortana.location                  = New-Object System.Drawing.Point(25,165)
    $EnableCortana.Font                      = New-Object System.Drawing.Font('Arial',12)
    $EnableCortana.ForeColor                 = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
    $Panel2.Controls.Add($EnableCortana)

    # Panel 2 ~> Button 4
    $DisableCortana                           = New-Object system.Windows.Forms.Button
    $DisableCortana.text                      = "Disable"
    $DisableCortana.width                     = 200
    $DisableCortana.height                    = 30
    $DisableCortana.location                  = New-Object System.Drawing.Point(25,200)
    $DisableCortana.Font                      = New-Object System.Drawing.Font('Arial',12)
    $DisableCortana.ForeColor                 = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
    $Panel2.Controls.Add($DisableCortana)
    
    # Panel 3 to put Labels and Buttons
    $Panel3                             = New-Object system.Windows.Forms.Panel
    $Panel3.width                       = 284
    $Panel3.height                      = 250
    $Panel3.location                    = New-Object System.Drawing.Point(600,0)
    
    # Panel 3 ~> Title Label 3
    $TitleLabel3                        = New-Object system.Windows.Forms.Label
    $TitleLabel3.text                   = "Software Install/Upg."
    $TitleLabel3.AutoSize               = $true
    $TitleLabel3.width                  = 25
    $TitleLabel3.height                 = 10
    $TitleLabel3.location               = New-Object System.Drawing.Point(10,3)
    $TitleLabel3.Font                   = New-Object System.Drawing.Font('Arial',16)
    $TitleLabel3.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("$Green")
    $Panel3.Controls.Add($TitleLabel3)
    
    # Panel 3 ~> Button 1
    $ChocolateySwInstaller              = New-Object system.Windows.Forms.Button
    $ChocolateySwInstaller.text         = "Install Basic Programs (Chocolatey)"
    $ChocolateySwInstaller.width        = 200
    $ChocolateySwInstaller.height       = 70
    $ChocolateySwInstaller.location     = New-Object System.Drawing.Point(10,40)
    $ChocolateySwInstaller.Font         = New-Object System.Drawing.Font('Arial',12)
    $ChocolateySwInstaller.ForeColor    = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
    $Panel3.Controls.Add($ChocolateySwInstaller)    
    
    # Image Logo from the Script
    $PictureBox1                        = New-Object system.Windows.Forms.PictureBox
    $PictureBox1.width                  = 120
    $PictureBox1.height                 = 120
    $PictureBox1.location               = New-Object System.Drawing.Point(650,250)
    $PictureBox1.imageLocation          = ".\lib\images\Script-logo.png"
    $PictureBox1.SizeMode               = [System.Windows.Forms.PictureBoxSizeMode]::zoom

    # Panel 1 ~> Button 1 Mouse Click listener
    $automatedTweaks.Add_Click({

        $Global:NeedRestart = $true
        Push-Location -Path .\scripts
    
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
            
            Title2 -Text "backup-system.ps1"
            Import-Module -DisableNameChecking .\"backup-system.ps1"
            # pause ### FOR DEBUGGING PURPOSES
        
            Title2 -Text "all-in-one-tweaks.ps1"
            Import-Module -DisableNameChecking .\"all-in-one-tweaks.ps1"
            # pause ### FOR DEBUGGING PURPOSES
    
            Title2 -Text "fix-privacy-settings.ps1"
            Import-Module -DisableNameChecking .\"fix-privacy-settings.ps1"
            # pause ### FOR DEBUGGING PURPOSES
    
            Title2 -Text "optimize-user-interface.ps1"
            Import-Module -DisableNameChecking .\"optimize-user-interface.ps1"
            # pause ### FOR DEBUGGING PURPOSES
            
            Title2 -Text "remove-onedrive.ps1"
            Import-Module -DisableNameChecking .\"remove-onedrive.ps1"
            # pause ### FOR DEBUGGING PURPOSES
                
        Pop-Location

        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })    

    # Panel 1 ~> Button 2 Mouse Click listener
    $uiTweaks.Add_Click({

        $Global:NeedRestart = $true
        Push-Location -Path .\scripts
        
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
            
            Clear-Host
            Title2 -Text "manual-debloat-softwares.ps1"
            Import-Module -DisableNameChecking .\"manual-debloat-softwares.ps1"
            # pause ### FOR DEBUGGING PURPOSES
        
        Pop-Location
        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

    })

    # Panel 1 ~> Button 3 Mouse Click listener
    $FixProblems.Add_Click({

        $Global:NeedRestart = $true
        Push-Location -Path .\scripts
    
            Get-ChildItem -Recurse *.ps*1 | Unblock-File

            Clear-Host
            Title2 -Text "backup-system.ps1"
            Import-Module -DisableNameChecking .\"backup-system.ps1"
            # pause ### FOR DEBUGGING PURPOSES

            $Ask = "This part is OPTIONAL, only do this if you want to repair your Windows.
            Do you want to continue?"
    
            switch (ShowQuestion -Title "Read carefully" -Message $Ask) {
                'Yes' {
                    Write-Host "You choose Yes."
    
                    Title2 -Text "repair-windows.ps1"
                    Import-Module -DisableNameChecking .\"repair-windows.ps1"
                }
                'No' {
                    Write-Host "You choose No. (No = Cancel)"
                }
                'Cancel' { # With Yes, No and Cancel, the user can press Esc to exit
                    Write-Host "You choose Cancel. (Cancel = No)"
                }
            }

        Pop-Location
        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"

    })

    # Panel 2 ~> Button 1 Mouse Click listener
    $DarkMode.Add_Click({

        Push-Location ".\utils"
            Write-Host "+ Enabling Dark theme..."
            regedit /s dark-theme.reg
        Pop-Location

        $Form.BackColor                     = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")

        $automatedTweaks.ForeColor          = [System.Drawing.ColorTranslator]::FromHtml("$LightBlue")
        $uiTweaks.ForeColor                 = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
        $FixProblems.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
        $ChocolateySwInstaller.ForeColor    = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
        $EnableCortana.ForeColor            = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")
        $DisableCortana.ForeColor           = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")


        $automatedTweaks.BackColor          = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
        $uiTweaks.BackColor                 = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
        $FixProblems.BackColor              = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
        $ChocolateySwInstaller.BackColor    = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
        $EnableCortana.BackColor            = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
        $DisableCortana.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")

        $Form.Update()
        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })

    # Panel 2 ~> Button 2 Mouse Click listener
    $LightMode.Add_Click({

        Push-Location ".\utils"
            Write-Host "+ Enabling Light theme..."
            regedit /s light-theme.reg
        Pop-Location

        $Form.BackColor                     = [System.Drawing.ColorTranslator]::FromHtml("$White")

        $automatedTweaks.ForeColor          = [System.Drawing.ColorTranslator]::FromHtml("$WinBlue")
        $uiTweaks.ForeColor                 = [System.Drawing.ColorTranslator]::FromHtml("$DarkGray")
        $FixProblems.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("$DarkGray")
        $ChocolateySwInstaller.ForeColor    = [System.Drawing.ColorTranslator]::FromHtml("$DarkGray")
        $EnableCortana.ForeColor            = [System.Drawing.ColorTranslator]::FromHtml("$DarkGray")
        $DisableCortana.ForeColor           = [System.Drawing.ColorTranslator]::FromHtml("$DarkGray")

        $automatedTweaks.BackColor          = [System.Drawing.ColorTranslator]::FromHtml("$WinGray")
        $uiTweaks.BackColor                 = [System.Drawing.ColorTranslator]::FromHtml("$WinGray")
        $FixProblems.BackColor              = [System.Drawing.ColorTranslator]::FromHtml("$WinGray")
        $ChocolateySwInstaller.BackColor    = [System.Drawing.ColorTranslator]::FromHtml("$WinGray")
        $EnableCortana.BackColor            = [System.Drawing.ColorTranslator]::FromHtml("$WinGray")
        $DisableCortana.BackColor           = [System.Drawing.ColorTranslator]::FromHtml("$WinGray")

        $Form.Update()
        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })

    # Panel 2 ~> Button 3 Mouse Click listener
    $EnableCortana.Add_Click({

        Push-Location ".\utils"
            Write-Host "+ Enabling Cortana..."
            regedit /s enable-cortana.reg
        Pop-Location

        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })
    
    # Panel 2 ~> Button 4 Mouse Click listener
    $DisableCortana.Add_Click({

        Push-Location ".\utils"
            Write-Host "- Disabling Cortana..."
            regedit /s disable-cortana.reg
        Pop-Location

        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })

    # Panel 3 ~> Button 1 Mouse Click listener
    $ChocolateySwInstaller.Add_Click({

        Push-Location -Path .\scripts
    
            Get-ChildItem -Recurse *.ps*1 | Unblock-File

            Clear-Host
            Title2 -Text "choco-sw-installer.ps1"
            Import-Module -DisableNameChecking .\"choco-sw-installer.ps1"
            # pause ### FOR DEBUGGING PURPOSES

        Pop-Location
        
        ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
    })
    
    # Add all Panels to the Form (Screen)
    $Form.controls.AddRange(@($Panel1,$Panel2,$Panel3,$Panel4,$PictureBox1))
    
    # Show the Window
    [void]$Form.ShowDialog()
    
    # when done, dispose of the form
    $Form.Dispose()

}

Clear-Host                  # Clear the Powershell before it got an Output
QuickPrivilegesElevation    # Check admin rights
LoadLibs                    # Import modules from lib folder
UnrestrictPermissions       # Unlock script usage
SetupConsoleStyle           # Just fix the font on the PS console

$Global:NeedRestart = $false
PrepareGUI                  # Load the GUI

if ($NeedRestart -eq $true) {
    PromptPcRestart             # Prompt options to Restart the PC
}

RestrictPermissions         # Lock script usage
Taskkill /F /IM $PID        # Kill this task by PID because it won't exit with the command 'exit'