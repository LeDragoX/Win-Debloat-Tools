# Learned from: https://docs.microsoft.com/en-us/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.1
# Adapted majorly from https://github.com/ChrisTitusTech/win10script and https://github.com/Sycnex/Windows10Debloater
# Take Ownership tweak from: https://www.howtogeek.com/howto/windows-vista/add-take-ownership-to-explorer-right-click-menu-in-vista/

function Main() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateSet('CLI', 'GUI')]
        [String] $Mode = 'GUI'
    )

    Begin {
        $Script:NeedRestart = $false
        $Script:DoneTitle = "Information"
        $Script:DoneMessage = "Process Completed!"
        $Host.UI.RawUI.WindowTitle = '🚀 Win Debloat Tools'
    }

    Process {
        Clear-Host
        Request-AdminPrivilege # Check admin rights
        Get-ChildItem -Recurse $PSScriptRoot\*.ps*1 | Unblock-File

        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\Get-HardwareInfo.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\Open-File.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\Request-FileDownload.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\Set-ConsoleStyle.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\Set-RevertStatus.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\Start-Logging.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\Title-Templates.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\package-managers\Manage-Chocolatey.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\package-managers\Manage-DailyUpgradeJob.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\package-managers\Manage-Software.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\package-managers\Manage-Winget.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\package-managers\Update-AllPackage.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\ui\Get-CurrentResolution.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\ui\Get-DefaultColor.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\ui\New-LayoutPage.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\ui\Show-MessageDialog.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\lib\ui\Ui-Helper.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\utils\Individual-Tweaks.psm1" -Force
        Import-Module -DisableNameChecking "$PSScriptRoot\src\utils\Install-Individual-System-Apps.psm1" -Force

        Set-ConsoleStyle

        If ("$pwd" -notlike "$PSScriptRoot") {
            Write-Style "Wrong location detected, changing to script folder! ($pwd)" -Color Yellow -BackColor Black -Style Bold
            Set-Location -Path "$PSScriptRoot"
        }

        $CurrentFileName = (Split-Path -Path $PSCommandPath -Leaf).Split('.')[0]
        $CurrentFileLastModified = (Get-Item "$(Split-Path -Path $PSCommandPath -Leaf)").LastWriteTimeUtc | Get-Date -Format "yyyy.MM.dd"
        Start-Logging -File "$CurrentFileName-$(Get-Date -Format "yyyy-MM")"
        Write-Caption "$CurrentFileName v$CurrentFileLastModified"
        Write-Style "Your Current Folder $pwd" -Color Cyan -BackColor Black -Style Bold
        Write-Style "Script Root Folder $PSScriptRoot" -Color Cyan -BackColor Black -Style Bold
        Write-ScriptLogo

        If ($args) {
            Write-Caption "Arguments: $args"
        } Else { Write-Caption "Arguments: None, running GUI" }

        If ($Mode -eq 'CLI') {
            Open-DebloatScript -Mode $Mode
        } Else { Show-GUI }
    }

    End {
        Write-Verbose "Restart: $Script:NeedRestart"
        If ($Script:NeedRestart) {
            Request-PcRestart
        }
        Stop-Logging
    }
}

function Open-DebloatScript {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateSet('CLI', 'GUI')]
        [String] $Mode = 'GUI'
    )

    $Scripts = @(
        # [Recommended order]
        "Backup-System.ps1",
        "Invoke-DebloatSoftware.ps1",
        "Optimize-TaskScheduler.ps1",
        "Optimize-ServicesRunning.ps1",
        "Remove-BloatwareAppsList.ps1",
        "Optimize-Privacy.ps1",
        "Optimize-Performance.ps1",
        "Register-PersonalTweaksList.ps1",
        "Optimize-Security.ps1",
        "Remove-CapabilitiesList.ps1",
        "Optimize-WindowsFeaturesList.ps1"
    )

    If ($Mode -eq 'CLI') {
        Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage -OpenFromGUI $false
    } ElseIf ($Mode -eq 'GUI') {
        Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
    }

    $Script:NeedRestart = $true
}

function Request-AdminPrivilege() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Try {
            winget --version
            Start-Process -Verb RunAs -FilePath "wt.exe" -ArgumentList "--startingDirectory `"$PSScriptRoot`" --profile `"Windows PowerShell`"", "cmd /c powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $ArgsList"; taskkill.exe /f /im $PID; exit
        } Catch {
            Start-Process -Verb RunAs -FilePath powershell.exe -ArgumentList "-NoProfile", "-ExecutionPolicy Bypass", "-File `"$PSCommandPath`" $ArgsList" ; exit
        }
    }
}

function Show-GUI() {
    Write-Status -Types "@", "UI" -Status "Loading GUI Layout..."
    # Loading System Libs
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles() # Rounded Buttons :3

    $Colors, $BrandColors = Get-DefaultColor # Load the Colors used in this script
    Set-UIFont # Load the Layout Font

    # <===== Specific Layout =====>

    $LayoutT1 = New-LayoutPage -NumOfPanels 3 -PanelHeight 1065
    $LayoutT2 = New-LayoutPage -NumOfPanels 4 -PanelHeight 1785

    # <===== UI =====>

    # Main Window:
    $Form = New-Form -Width $LayoutT1.FormWidth -Height $LayoutT1.FormHeight -Text "Win Debloat Tools | $(Get-SystemSpec)" -BackColor $BrandColors.Win.Dark -FormBorderStyle 'Sizable' # Loading the specs takes longer time to load the GUI

    $Form = New-FormIcon -Form $Form -ImageLocation "$PSScriptRoot\src\assets\script-icon-32px.png"

    $FormTabControl = New-TabControl -Width ($LayoutT1.FormWidth - 8) -Height ($LayoutT1.FormHeight - 35) -LocationX -4 -LocationY 0
    $TabSystemTweaks = New-TabPage -Name "Tab1" -Text "System Tweaks"
    $TabSoftwareInstall = New-TabPage -Name "Tab2" -Text "Software Install"
    $TabSettings = New-TabPage -Name "Tab3" -Text "Settings"

    $TlSystemTweaks = New-Label -Text "System Tweaks" -Width $LayoutT1.TotalWidth -Height $LayoutT1.TitleLabelHeight -LocationX 0 -LocationY $TitleLabelY -FontSize $LayoutT1.Heading[0] -FontStyle "Bold" -ForeColor $Colors.Cyan
    $ClSystemTweaks = New-Label -Text "Version $CurrentFileLastModified" -Width $LayoutT1.TotalWidth -Height $LayoutT1.CaptionLabelHeight -LocationX 0 -FontSize $LayoutT1.Heading[1] -ElementBefore $TlSystemTweaks -MarginTop $LayoutT1.DistanceBetweenElements -ForeColor $Colors.White

    # ==> Tab 1
    $CurrentPanelIndex = 0
    $T1Panel1 = New-Panel -Width $LayoutT1.PanelWidth -Height $LayoutT1.PanelHeight -LocationX ($LayoutT1.PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSystemTweaks
    $CurrentPanelIndex++
    $T1Panel2 = New-Panel -Width $LayoutT1.PanelWidth -Height $LayoutT1.PanelHeight -LocationX ($LayoutT1.PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSystemTweaks
    $CurrentPanelIndex++
    $T1Panel3 = New-Panel -Width $LayoutT1.PanelWidth -Height $LayoutT1.PanelHeight -LocationX ($LayoutT1.PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSystemTweaks

    # ==> T1 Panel 1
    $ClCustomizeFeatures = New-Label -Text "Customize System Features" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CaptionLabelHeight -LocationX $LayoutT1.PanelElementX -LocationY 0 -FontSize $LayoutT1.Heading[2] -FontStyle 'Bold'
    $CbDarkTheme = New-CheckBox -Text "Enable Dark Theme" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $ClCustomizeFeatures
    $CbActivityHistory = New-CheckBox -Text "Enable Activity History" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbDarkTheme
    $CbBackgroundsApps = New-CheckBox -Text "Enable Background Apps" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbActivityHistory
    $CbClipboardHistory = New-CheckBox -Text "Enable Clipboard History" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbBackgroundsApps
    $CbClipboardSyncAcrossDevice = New-CheckBox -Text "Enable Clipboard Sync Across Devices" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbClipboardHistory
    $CbCortana = New-CheckBox -Text "Enable Cortana" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbClipboardSyncAcrossDevice
    $CbHibernate = New-CheckBox -Text "Enable Hibernate" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbCortana
    $CbLegacyContextMenu = New-CheckBox -Text "Enable Legacy Context Menu" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbHibernate
    $CbLocationTracking = New-CheckBox -Text "Enable Location Tracking" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbLegacyContextMenu
    $CbNewsAndInterest = New-CheckBox -Text "Enable News And Interest" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbLocationTracking
    $CbOldVolumeControl = New-CheckBox -Text "Enable Old Volume Control" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbNewsAndInterest
    $CbOnlineSpeechRecognition = New-CheckBox -Text "Enable Online Speech Recognition" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbOldVolumeControl
    $CbPhoneLink = New-CheckBox -Text "Enable Phone Link" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbOnlineSpeechRecognition
    $CbPhotoViewer = New-CheckBox -Text "Enable Photo Viewer" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbPhoneLink
    $CbSearchAppForUnknownExt = New-CheckBox -Text "Enable Search App for Unknown Ext." -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbPhotoViewer
    $CbTelemetry = New-CheckBox -Text "Enable Telemetry" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbSearchAppForUnknownExt
    $CbWindowsSpotlight = New-CheckBox -Text "Enable Windows Spotlight" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbTelemetry
    $CbXboxGameBarDVRandMode = New-CheckBox -Text "Enable Xbox Game Bar/DVR/Mode" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbWindowsSpotlight

    # ==> T1 Panel 2
    $ClDebloatTools = New-Label -Text "System Debloat Tools" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CaptionLabelHeight -LocationX $LayoutT1.PanelElementX -LocationY 0 -FontSize $LayoutT1.Heading[2] -FontStyle 'Bold'
    $ApplyTweaks = New-Button -Text "Apply Tweaks" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -ElementBefore $ClDebloatTools -FontSize $LayoutT1.Heading[3] -FontStyle 'Bold' -ForeColor $Colors.Cyan
    $UndoTweaks = New-Button -Text "Undo Tweaks" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $ApplyTweaks -MarginTop $LayoutT1.DistanceBetweenElements -ForeColor $Colors.WarningYellow
    $DiskCleanUp = New-Button -Text "Run a Disk Cleanup" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $UndoTweaks -MarginTop $LayoutT1.DistanceBetweenElements -ForeColor $Colors.Cyan
    $RemoveTemporaryFiles = New-Button -Text "Remove Temporary Files" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $DiskCleanUp -MarginTop $LayoutT1.DistanceBetweenElements -ForeColor $Colors.Cyan
    $RemoveWindowsOld = New-Button -Text "Remove Windows.old Folder" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $RemoveTemporaryFiles -MarginTop $LayoutT1.DistanceBetweenElements -ForeColor $Colors.WarningYellow
    $RemoveMSEdge = New-Button -Text "Remove Microsoft Edge" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $RemoveWindowsOld -MarginTop $LayoutT1.DistanceBetweenElements -ForeColor $Colors.WarningYellow
    $RemoveOneDrive = New-Button -Text "Remove OneDrive" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $RemoveMSEdge -MarginTop $LayoutT1.DistanceBetweenElements -ForeColor $Colors.WarningYellow
    $RemoveXbox = New-Button -Text "Remove Xbox" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $RemoveOneDrive -MarginTop $LayoutT1.DistanceBetweenElements -ForeColor $Colors.WarningYellow
    $PictureBox1 = New-PictureBox -ImageLocation "$PSScriptRoot\src\assets\script-image.png" -Width $LayoutT1.PanelElementWidth -Height (($LayoutT1.ButtonHeight * 4) + ($LayoutT1.DistanceBetweenElements * 4)) -LocationX $LayoutT1.PanelElementX -ElementBefore $RemoveXbox -MarginTop $LayoutT1.DistanceBetweenElements -SizeMode 'Zoom'

    $ClInstallSystemApps = New-Label -Text "Install System Apps" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CaptionLabelHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[2] -FontStyle 'Bold' -ElementBefore $PictureBox1
    $InstallDolbyAudio = New-Button -Text "Dolby Audio" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $ClInstallSystemApps -MarginTop $LayoutT1.DistanceBetweenElements
    $InstallMicrosoftEdge = New-Button -Text "Microsoft Edge" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $InstallDolbyAudio -MarginTop $LayoutT1.DistanceBetweenElements
    $InstallOneDrive = New-Button -Text "OneDrive" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $InstallMicrosoftEdge -MarginTop $LayoutT1.DistanceBetweenElements
    $InstallPaintPaint3D = New-Button -Text "Paint + Paint 3D" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $InstallOneDrive -MarginTop $LayoutT1.DistanceBetweenElements
    $InstallPhoneLink = New-Button -Text "Phone Link" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $InstallPaintPaint3D -MarginTop $LayoutT1.DistanceBetweenElements
    $InstallQuickAssist = New-Button -Text "Quick Assist" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $InstallPhoneLink -MarginTop $LayoutT1.DistanceBetweenElements
    $InstallSoundRecorder = New-Button -Text "Sound Recorder" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $InstallQuickAssist -MarginTop $LayoutT1.DistanceBetweenElements
    $InstallTaskbarWidgets = New-Button -Text "Taskbar Widgets" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $InstallSoundRecorder -MarginTop $LayoutT1.DistanceBetweenElements
    $InstallUWPWMediaPlayer = New-Button -Text "Windows Media Player (UWP)" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $InstallTaskbarWidgets -MarginTop $LayoutT1.DistanceBetweenElements
    $InstallXbox = New-Button -Text "Xbox" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $InstallUWPWMediaPlayer -MarginTop $LayoutT1.DistanceBetweenElements

    $ClOtherTools = New-Label -Text "Other Tools" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CaptionLabelHeight -LocationX $LayoutT1.PanelElementX -LocationY 0 -FontSize $LayoutT1.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallXbox
    $RandomizeSystemColor = New-Button -Text "Randomize System Color" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $ClOtherTools
    $ReinstallBloatApps = New-Button -Text "Reinstall Pre-Installed Apps" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $RandomizeSystemColor -MarginTop $LayoutT1.DistanceBetweenElements
    $RepairWindows = New-Button -Text "Repair Windows" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $ReinstallBloatApps -MarginTop $LayoutT1.DistanceBetweenElements
    $ShowDebloatInfo = New-Button -Text "Show Debloat Info" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.ButtonHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $RepairWindows -MarginTop $LayoutT1.DistanceBetweenElements

    # ==> T1 Panel 3
    $ClWindowsUpdate = New-Label -Text "Windows Update" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CaptionLabelHeight -LocationX $LayoutT1.PanelElementX -LocationY 0 -FontSize $LayoutT1.Heading[2] -FontStyle 'Bold'
    $CbAutomaticWindowsUpdate = New-CheckBox -Text "Enable Automatic Windows Update" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $ClWindowsUpdate

    $ClOptionalFeatures = New-Label -Text "Optional Features" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CaptionLabelHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[2] -FontStyle 'Bold' -ElementBefore $CbAutomaticWindowsUpdate
    $CbHyperV = New-CheckBox -Text "Hyper-V" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $ClOptionalFeatures
    $CbInternetExplorer = New-CheckBox -Text "Internet Explorer" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbHyperV
    $CbPrintToPDFServices = New-CheckBox -Text "Printing-PrintToPDFServices-Features" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbInternetExplorer
    $CbPrintingXPSServices = New-CheckBox -Text "Printing-XPSServices-Features" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbPrintToPDFServices
    $CbWindowsMediaPlayer = New-CheckBox -Text "Windows Media Player" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbPrintingXPSServices
    $CbWindowsSandbox = New-CheckBox -Text "Windows Sandbox" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbWindowsMediaPlayer

    $ClTaskScheduler = New-Label -Text "Task Scheduler" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CaptionLabelHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[2] -FontStyle 'Bold' -ElementBefore $CbWindowsSandbox
    $CbFamilySafety = New-CheckBox -Text "Family Safety Features" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $ClTaskScheduler

    $ClServices = New-Label -Text "Services" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CaptionLabelHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[2] -FontStyle 'Bold' -ElementBefore $CbFamilySafety
    $CbWindowsSearch = New-CheckBox -Text "Windows Search Indexing" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $ClServices

    $ClWindowsCapabilities = New-Label -Text "Windows Capabilities" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CaptionLabelHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[2] -FontStyle 'Bold' -ElementBefore $CbWindowsSearch
    $CbPowerShellISE = New-CheckBox -Text "PowerShell ISE" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $ClWindowsCapabilities

    $ClMiscFeatures = New-Label -Text "Miscellaneous Features" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CaptionLabelHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[2] -FontStyle 'Bold' -ElementBefore $CbPowerShellISE
    $CbEncryptedDNS = New-CheckBox -Text "Enable Encrypted DNS" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $ClMiscFeatures
    $CbGodMode = New-CheckBox -Text "Enable God Mode" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbEncryptedDNS
    $CbMouseAcceleration = New-CheckBox -Text "Enable Mouse Acceleration" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbGodMode
    $CbMouseNaturalScroll = New-CheckBox -Text "Enable Mouse Natural Scroll" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbMouseAcceleration
    $CbTakeOwnership = New-CheckBox -Text "Enable Take Ownership menu" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbMouseNaturalScroll
    $CbFastShutdownPCShortcut = New-CheckBox -Text "Enable Fast Shutdown shortcut" -Width $LayoutT1.PanelElementWidth -Height $LayoutT1.CheckBoxHeight -LocationX $LayoutT1.PanelElementX -FontSize $LayoutT1.Heading[3] -ElementBefore $CbTakeOwnership

    # ==> Tab 2
    $TlSoftwareInstall = New-Label -Text "Software Install" -Width $LayoutT2.TotalWidth -Height $LayoutT2.TitleLabelHeight -LocationX 0 -LocationY $TitleLabelY -FontSize $LayoutT2.Heading[0] -FontStyle "Bold" -ForeColor $Colors.Cyan

    $ClSoftwareInstall = New-Label -Text "Install/Uninstall" -Width $LayoutT2.TotalWidth -Height $LayoutT2.CaptionLabelHeight -LocationX 0 -FontSize $LayoutT1.Heading[1] -ElementBefore $T3PanelPackageManagersSettings -MarginTop $LayoutT2.DistanceBetweenElements -ForeColor $Colors.LightGreen

    $CurrentPanelIndex = 0
    $T2Panel1 = New-Panel -Width $LayoutT2.PanelWidth -Height $LayoutT2.PanelHeight -LocationX ($LayoutT2.PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSoftwareInstall
    $CurrentPanelIndex++
    $T2Panel2 = New-Panel -Width $LayoutT2.PanelWidth -Height $LayoutT2.PanelHeight -LocationX ($LayoutT2.PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSoftwareInstall
    $CurrentPanelIndex++
    $T2Panel3 = New-Panel -Width $LayoutT2.PanelWidth -Height $LayoutT2.PanelHeight -LocationX ($LayoutT2.PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSoftwareInstall
    $CurrentPanelIndex++
    $T2Panel4 = New-Panel -Width $LayoutT2.PanelWidth -Height $LayoutT2.PanelHeight -LocationX ($LayoutT2.PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSoftwareInstall

    # ==> T2 Panel 1
    $UpgradeAll = New-Button -Text "Upgrade All Softwares" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.ButtonHeight -LocationX $LayoutT2.PanelElementX -LocationY 0 -FontSize $LayoutT2.Heading[3] -FontStyle 'Bold' -ForeColor $Colors.Cyan

    $ClCpuGpuDrivers = New-Label -Text "CPU/GPU Drivers" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $UpgradeAll
    $InstallAmdRyzenChipsetDriver = New-CheckBox -Text "AMD Ryzen Chipset Driver" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClCpuGpuDrivers -ForeColor $BrandColors.AMD.Ryzen
    $InstallIntelDSA = New-CheckBox -Text "Intel® DSA" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallAmdRyzenChipsetDriver -ForeColor $BrandColors.Intel
    $InstallNvidiaGeForceExperience = New-CheckBox -Text "NVIDIA GeForce Experience" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallIntelDSA -ForeColor $BrandColors.NVIDIA
    $InstallDDU = New-CheckBox -Text "Display Driver Uninstaller" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallNvidiaGeForceExperience
    $InstallNVCleanstall = New-CheckBox -Text "NVCleanstall" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallDDU

    $ClApplicationRequirements = New-Label -Text "Application Requirements" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallNVCleanstall
    $InstallDirectX = New-CheckBox -Text "DirectX End-User Runtime" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClApplicationRequirements
    $InstallMsDotNetFramework = New-CheckBox -Text "Microsoft .NET Framework" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallDirectX
    $InstallMsVCppX64 = New-CheckBox -Text "MSVC Redist 2005-2022 (x64)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallMsDotNetFramework
    $InstallMsVCppX86 = New-CheckBox -Text "MSVC Redist 2005-2022 (x86)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallMsVCppX64

    $ClFileCompression = New-Label -Text "File Compression" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallMsVCppX86
    $Install7Zip = New-CheckBox -Text "7-Zip" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClFileCompression
    $InstallWinRar = New-CheckBox -Text "WinRAR (Trial)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $Install7Zip

    $ClDocuments = New-Label -Text "Document Editors/Readers" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallWinRar
    $InstallAdobeReaderDC = New-CheckBox -Text "Adobe Reader DC (x64)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClDocuments
    $InstallLibreOffice = New-CheckBox -Text "LibreOffice" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallAdobeReaderDC
    $InstallOnlyOffice = New-CheckBox -Text "ONLYOFFICE DesktopEditors" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallLibreOffice
    $InstallPDFCreator = New-CheckBox -Text "PDFCreator (PDF Converter)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallOnlyOffice
    $InstallPowerBi = New-CheckBox -Text "Power BI" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallPDFCreator
    $InstallSumatraPDF = New-CheckBox -Text "Sumatra PDF" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallPowerBi

    $ClTorrent = New-Label -Text "Torrent" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallSumatraPDF
    $InstallqBittorrent = New-CheckBox -Text "qBittorrent" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClTorrent

    $ClAcademicResearch = New-Label -Text "Academic Research" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallqBittorrent
    $InstallZotero = New-CheckBox -Text "Zotero" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClAcademicResearch

    $Cl2fa = New-Label -Text "2-Factor Authentication" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallZotero
    $InstallTwilioAuthy = New-CheckBox -Text "Twilio Authy" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $Cl2fa

    $ClBootableUsb = New-Label -Text "Bootable USB" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallTwilioAuthy
    $InstallBalenaEtcher = New-CheckBox -Text "Etcher" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClBootableUsb
    $InstallRufus = New-CheckBox -Text "Rufus" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallBalenaEtcher
    $InstallVentoy = New-CheckBox -Text "Ventoy" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallRufus

    $ClVirtualMachines = New-Label -Text "Virtual Machines" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallVentoy
    $InstallOracleVirtualBox = New-CheckBox -Text "Oracle VM VirtualBox" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClVirtualMachines
    $InstallQemu = New-CheckBox -Text "QEMU" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallOracleVirtualBox
    $InstallVmWarePlayer = New-CheckBox -Text "VMware Workstation Player" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallQemu

    $ClCloudStorage = New-Label -Text "Cloud Storage" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallVmWarePlayer
    $InstallDropbox = New-CheckBox -Text "Dropbox" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClCloudStorage
    $InstallGoogleDrive = New-CheckBox -Text "Google Drive" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallDropbox

    $ClUICustomization = New-Label -Text "UI Customization" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallGoogleDrive
    $InstallRoundedTB = New-CheckBox -Text "RoundedTB" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClUICustomization
    $InstallTranslucentTB = New-CheckBox -Text "TranslucentTB" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallRoundedTB

    # ==> T2 Panel 2
    $InstallSelected = New-Button -Text "Install Selected" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.ButtonHeight -LocationX $LayoutT2.PanelElementX -LocationY 0 -FontSize $LayoutT2.Heading[3] -FontStyle "Bold"

    $ClWebBrowsers = New-Label -Text "Web Browsers" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallSelected
    $InstallBraveBrowser = New-CheckBox -Text "Brave Browser" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClWebBrowsers
    $InstallGoogleChrome = New-CheckBox -Text "Google Chrome" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallBraveBrowser
    $InstallMozillaFirefox = New-CheckBox -Text "Mozilla Firefox" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallGoogleChrome

    $ClAudioVideoTools = New-Label -Text "Audio/Video Tools" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallMozillaFirefox
    $InstallAudacity = New-CheckBox -Text "Audacity (Editor)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClAudioVideoTools
    $InstallMpcHc = New-CheckBox -Text "MPC-HC (Player)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallAudacity
    $InstallVlc = New-CheckBox -Text "VLC (Player)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallMpcHc

    $ClImageTools = New-Label -Text "Image Tools" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallVlc
    $InstallGimp = New-CheckBox -Text "GIMP" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClImageTools
    $InstallInkscape = New-CheckBox -Text "Inkscape" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallGimp
    $InstallIrfanView = New-CheckBox -Text "IrfanView" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallInkscape
    $InstallKrita = New-CheckBox -Text "Krita" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallIrfanView
    $InstallPaintNet = New-CheckBox -Text "Paint.NET" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallKrita
    $InstallShareX = New-CheckBox -Text "ShareX (Screenshots/GIFs)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallPaintNet

    $ClStreamingServices = New-Label -Text "Streaming Services" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallShareX
    $InstallAmazonPrimeVideo = New-CheckBox -Text "Amazon Prime Video" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClStreamingServices
    $InstallDisneyPlus = New-CheckBox -Text "Disney+" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallAmazonPrimeVideo
    $InstallNetflix = New-CheckBox -Text "Netflix" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallDisneyPlus
    $InstallSpotify = New-CheckBox -Text "Spotify" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallNetflix

    $ClPlanningProductivity = New-Label -Text "Planning/Productivity" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallSpotify
    $InstallNotion = New-CheckBox -Text "Notion" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClPlanningProductivity
    $InstallObsidian = New-CheckBox -Text "Obsidian" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallNotion

    $ClUtilities = New-Label -Text "⚒ Utilities" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallObsidian
    $InstallCpuZ = New-CheckBox -Text "CPU-Z" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClUtilities
    $InstallCrystalDiskInfo = New-CheckBox -Text "Crystal Disk Info" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallCpuZ
    $InstallCrystalDiskMark = New-CheckBox -Text "Crystal Disk Mark" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallCrystalDiskInfo
    $InstallGeekbench6 = New-CheckBox -Text "Geekbench 6" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallCrystalDiskMark
    $InstallGpuZ = New-CheckBox -Text "GPU-Z" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallGeekbench6
    $InstallHwInfo = New-CheckBox -Text "HWiNFO" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallGpuZ
    $InstallInternetDownloadManager = New-CheckBox -Text "Internet Download Manager (Trial)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallHwInfo
    $InstallMsiAfterburner = New-CheckBox -Text "MSI Afterburner" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallInternetDownloadManager
    $InstallRtxVoice = New-CheckBox -Text "RTX Voice" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallMsiAfterburner
    $InstallVoicemod = New-CheckBox -Text "Voicemod" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallRtxVoice
    $InstallVoiceMeeter = New-CheckBox -Text "Voicemeeter Potato" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallVoicemod
    $InstallWizTree = New-CheckBox -Text "WizTree" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallVoiceMeeter

    $ClNetworkManagement = New-Label -Text "Network Management" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallWizTree
    $InstallHamachi = New-CheckBox -Text "Hamachi (LAN)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClNetworkManagement
    $InstallPuTty = New-CheckBox -Text "PuTTY" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallHamachi
    $InstallRadminVpn = New-CheckBox -Text "Radmin VPN (LAN)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallPuTty
    $InstallWinScp = New-CheckBox -Text "WinSCP" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallRadminVpn
    $InstallWireshark = New-CheckBox -Text "Wireshark" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallWinScp

    # ==> T2 Panel 3
    $UninstallMode = New-Button -Text "[OFF] Uninstall Mode" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.ButtonHeight -LocationX $LayoutT2.PanelElementX -LocationY 0 -FontSize $LayoutT2.Heading[3] -FontStyle "Bold"

    $ClCommunication = New-Label -Text "Communication" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $UninstallMode
    $InstallDiscord = New-CheckBox -Text "Discord" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClCommunication
    $InstallMSTeams = New-CheckBox -Text "Microsoft Teams" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallDiscord
    $InstallRocketChat = New-CheckBox -Text "Rocket Chat" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallMSTeams
    $InstallSignal = New-CheckBox -Text "Signal" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallRocketChat
    $InstallSkype = New-CheckBox -Text "Skype" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallSignal
    $InstallSlack = New-CheckBox -Text "Slack" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallSkype
    $InstallTelegramDesktop = New-CheckBox -Text "Telegram Desktop" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallSlack
    $InstallWhatsAppDesktop = New-CheckBox -Text "WhatsApp Desktop" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallTelegramDesktop
    $InstallZoom = New-CheckBox -Text "Zoom" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallWhatsAppDesktop

    $ClGaming = New-Label -Text "Gaming" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallZoom
    $InstallBorderlessGaming = New-CheckBox -Text "Borderless Gaming" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClGaming
    $InstallEADesktop = New-CheckBox -Text "EA Desktop" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallBorderlessGaming
    $InstallEpicGamesLauncher = New-CheckBox -Text "Epic Games Launcher" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallEADesktop
    $InstallGogGalaxy = New-CheckBox -Text "GOG Galaxy" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallEpicGamesLauncher
    $InstallSteam = New-CheckBox -Text "Steam" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallGogGalaxy
    $InstallUbisoftConnect = New-CheckBox -Text "Ubisoft Connect" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallSteam

    $ClRemoteConnection = New-Label -Text "Remote Connection" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallUbisoftConnect
    $InstallAnyDesk = New-CheckBox -Text "AnyDesk" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClRemoteConnection
    $InstallParsec = New-CheckBox -Text "Parsec" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallAnyDesk
    $InstallScrCpy = New-CheckBox -Text "ScrCpy (Android)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallParsec
    $InstallTeamViewer = New-CheckBox -Text "Team Viewer" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallScrCpy

    $ClRecordingAndStreaming = New-Label -Text "Recording and Streaming" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallTeamViewer
    $InstallElgatoStreamDeck = New-CheckBox -Text "Elgato Stream Deck" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClRecordingAndStreaming
    $InstallHandBrake = New-CheckBox -Text "HandBrake (Transcode)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallElgatoStreamDeck
    $InstallObsStudio = New-CheckBox -Text "OBS Studio" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallHandBrake
    $InstallStreamlabs = New-CheckBox -Text "Streamlabs" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallObsStudio

    $ClEmulation = New-Label -Text "Emulation" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallStreamlabs
    $InstallCemu = New-CheckBox -Text "Cemu (Wii U)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClEmulation
    $InstallDolphin = New-CheckBox -Text "Dolphin Stable (GC/Wii)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallCemu
    $InstallDuckstation = New-CheckBox -Text "Duckstation (PS1)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallDolphin
    $InstallKegaFusion = New-CheckBox -Text "Kega Fusion (SG/CD/32X/MS/GG)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallDuckstation
    $InstallMGba = New-CheckBox -Text "mGBA (GBA)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallKegaFusion
    $InstallPPSSPP = New-CheckBox -Text "PPSSPP (PSP)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallMGba
    $InstallRetroArch = New-CheckBox -Text "RetroArch (All In One)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallPPSSPP
    $InstallRyujinx = New-CheckBox -Text "Ryujinx (Switch)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallRetroArch
    $InstallSnes9x = New-CheckBox -Text "Snes9x (SNES)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallRyujinx

    # ==> T2 Panel 4
    $ClTextEditors = New-Label -Text "Text Editors/IDEs" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -ElementBefore $InstallSelected -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold'
    $InstallJetBrainsToolbox = New-CheckBox -Text "JetBrains Toolbox" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClTextEditors
    $InstallNotepadPlusPlus = New-CheckBox -Text "Notepad++" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallJetBrainsToolbox
    $InstallVisualStudioCommunity = New-CheckBox -Text "Visual Studio 2022 Community" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallNotepadPlusPlus
    $InstallVSCode = New-CheckBox -Text "VS Code" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallVisualStudioCommunity
    $InstallVSCodium = New-CheckBox -Text "VS Codium" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallVSCode

    $ClWsl = New-Label -Text "Windows Subsystem For Linux" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallVSCodium
    $InstallWSL = New-CheckBox -Text "Install WSL" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClWsl -ForeColor $Colors.Cyan
    $InstallArchWSL = New-CheckBox -Text "ArchWSL (x64)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallWSL -ForeColor $Colors.Cyan
    $InstallDebian = New-CheckBox -Text "Debian GNU/Linux" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallArchWSL
    $InstallKaliLinux = New-CheckBox -Text "Kali Linux Rolling" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallDebian
    $InstallUbuntu = New-CheckBox -Text "Ubuntu" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallKaliLinux

    $ClDevelopment = New-Label -Text "⌨ Development on Windows" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CaptionLabelHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[2] -FontStyle 'Bold' -ElementBefore $InstallUbuntu
    $InstallWindowsTerminal = New-CheckBox -Text "Windows Terminal" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $ClDevelopment
    $InstallNerdFonts = New-CheckBox -Text "Install Nerd Fonts" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallWindowsTerminal -ForeColor $Colors.Cyan
    $InstallGitGnupgSshSetup = New-CheckBox -Text "Git + GnuPG + SSH (Setup)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallNerdFonts -ForeColor $Colors.Cyan
    $InstallAdb = New-CheckBox -Text "Android Debug Bridge (ADB)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallGitGnupgSshSetup
    $InstallAndroidStudio = New-CheckBox -Text "Android Studio" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallAdb
    $InstallDockerDesktop = New-CheckBox -Text "Docker Desktop" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallAndroidStudio
    $InstallInsomnia = New-CheckBox -Text "Insomnia" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallDockerDesktop
    $InstallJavaJdks = New-CheckBox -Text "Java - Adoptium JDK 8/11/18" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallInsomnia
    $InstallJavaJre = New-CheckBox -Text "Java - Oracle JRE" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallJavaJdks
    $InstallMySql = New-CheckBox -Text "MySQL" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallJavaJre
    $InstallNodeJs = New-CheckBox -Text "NodeJS" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallMySql
    $InstallNodeJsLts = New-CheckBox -Text "NodeJS LTS" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallNodeJs
    $InstallPostgreSql = New-CheckBox -Text "PostgreSQL" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallNodeJsLts
    $InstallPython3 = New-CheckBox -Text "Python 3" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallPostgreSql
    $InstallPythonAnaconda3 = New-CheckBox -Text "Python - Anaconda3" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallPython3
    $InstallRuby = New-CheckBox -Text "Ruby" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallPythonAnaconda3
    $InstallRubyMsys = New-CheckBox -Text "Ruby (MSYS2)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallRuby
    $InstallRustGnu = New-CheckBox -Text "Rust (GNU)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallRubyMsys
    $InstallRustMsvc = New-CheckBox -Text "Rust (MSVC)" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.CheckBoxHeight -LocationX $LayoutT2.PanelElementX -FontSize $LayoutT2.Heading[3] -ElementBefore $InstallRustGnu

    # ==> Tab 3
    $TlSettings = New-Label -Text "Settings" -Width $LayoutT2.TotalWidth -Height $LayoutT2.TitleLabelHeight -LocationX 0 -LocationY $TitleLabelY -FontSize $LayoutT2.Heading[0] -FontStyle "Bold" -ForeColor $Colors.Cyan
    $T3PanelPackageManagersSettings = New-Panel -Width $LayoutT2.TotalWidth -Height ($LayoutT2.ButtonHeight * 7) -ElementBefore $TlSettings

    $ClWingetSettings = New-Label -Text "Winget Settings" -Width $LayoutT2.TotalWidth -Height $LayoutT2.CaptionLabelHeight -LocationX 0 -FontSize $LayoutT1.Heading[1] -LocationY 0 -MarginTop $LayoutT2.DistanceBetweenElements -ForeColor $Colors.White
    $InstallWinget = New-Button -Text "Install Winget" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.ButtonHeight -LocationX (($LayoutT2.PanelWidth * 0) + $LayoutT2.PanelElementX) -ElementBefore $ClWingetSettings -FontSize $LayoutT2.Heading[3] -FontStyle 'Bold' -ForeColor $Colors.Cyan
    $EnableWingetDailyUpgrade = New-Button -Text "Enable Winget Daily Upgrade" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.ButtonHeight -LocationX (($LayoutT2.PanelWidth * 2) + $LayoutT2.PanelElementX) -ElementBefore $ClWingetSettings -FontSize $LayoutT2.Heading[3] -FontStyle 'Bold' -ForeColor $Colors.Cyan
    $RemoveWingetDailyUpgrade = New-Button -Text "Remove Winget Daily Upgrade" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.ButtonHeight -LocationX (($LayoutT2.PanelWidth * 3) + $LayoutT2.PanelElementX) -ElementBefore $ClWingetSettings -FontSize $LayoutT2.Heading[3] -FontStyle 'Bold' -ForeColor $Colors.Cyan

    $ClChocolateySettings = New-Label -Text "Chocolatey Settings" -Width $LayoutT2.TotalWidth -Height $LayoutT2.CaptionLabelHeight -LocationX 0 -FontSize $LayoutT1.Heading[1] -ElementBefore $InstallWinget -MarginTop $LayoutT2.DistanceBetweenElements -ForeColor $Colors.White
    $InstallChocolatey = New-Button -Text "Install Chocolatey" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.ButtonHeight -LocationX (($LayoutT2.PanelWidth * 0) + $LayoutT2.PanelElementX) -ElementBefore $ClChocolateySettings -FontSize $LayoutT2.Heading[3] -FontStyle 'Bold' -ForeColor $Colors.Cyan
    $UninstallChocolatey = New-Button -Text "Uninstall Chocolatey" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.ButtonHeight -LocationX (($LayoutT2.PanelWidth * 1) + $LayoutT2.PanelElementX) -ElementBefore $ClChocolateySettings -FontSize $LayoutT2.Heading[3] -FontStyle 'Bold' -ForeColor $Colors.Cyan
    $EnableChocolateyDailyUpgrade = New-Button -Text "Enable Chocolatey Daily Upgrade" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.ButtonHeight -LocationX (($LayoutT2.PanelWidth * 2) + $LayoutT2.PanelElementX) -ElementBefore $ClChocolateySettings -FontSize $LayoutT2.Heading[3] -FontStyle 'Bold' -ForeColor $Colors.Cyan
    $RemoveChocolateyDailyUpgrade = New-Button -Text "Remove Chocolatey Daily Upgrade" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.ButtonHeight -LocationX (($LayoutT2.PanelWidth * 3) + $LayoutT2.PanelElementX) -ElementBefore $ClChocolateySettings -FontSize $LayoutT2.Heading[3] -FontStyle 'Bold' -ForeColor $Colors.Cyan
    $RemoveAllChocolateyPackages = New-Button -Text "Remove All Chocolatey Packages" -Width $LayoutT2.PanelElementWidth -Height $LayoutT2.ButtonHeight -LocationX (($LayoutT2.PanelWidth * 0) + $LayoutT2.PanelElementX) -ElementBefore $InstallChocolatey -MarginTop $LayoutT2.DistanceBetweenElements -FontSize $LayoutT2.Heading[3] -FontStyle 'Bold' -ForeColor $Colors.WarningYellow

    # Add TabControl to the Form
    $Form.Controls.AddRange(@($FormTabControl))
    # Tabs
    $FormTabControl.Controls.AddRange(@($TabSystemTweaks, $TabSoftwareInstall, $TabSettings))
    $TabSystemTweaks.Controls.AddRange(@($TlSystemTweaks, $ClSystemTweaks, $T1Panel1, $T1Panel2, $T1Panel3))
    $TabSoftwareInstall.Controls.AddRange(@($TlSoftwareInstall, $ClSoftwareInstall, $T2Panel1, $T2Panel2, $T2Panel3, $T2Panel4))
    $TabSettings.Controls.AddRange(@($TlSettings, $T3PanelPackageManagersSettings))
    # Add Elements to each Tab Panel
    $T1Panel1.Controls.AddRange(@($ClCustomizeFeatures, $CbDarkTheme, $CbActivityHistory, $CbBackgroundsApps, $CbClipboardHistory, $CbClipboardSyncAcrossDevice, $CbCortana, $CbHibernate, $CbLegacyContextMenu, $CbLocationTracking, $CbNewsAndInterest, $CbOldVolumeControl, $CbOnlineSpeechRecognition, $CbPhoneLink, $CbPhotoViewer, $CbSearchAppForUnknownExt, $CbTelemetry, $CbWindowsSpotlight, $CbXboxGameBarDVRandMode))
    $T1Panel2.Controls.AddRange(@($ClDebloatTools, $ApplyTweaks, $UndoTweaks, $DiskCleanUp, $RemoveTemporaryFiles, $RemoveWindowsOld, $RemoveMSEdge, $RemoveOneDrive, $RemoveXbox, $PictureBox1))
    $T1Panel2.Controls.AddRange(@($ClInstallSystemApps, $InstallDolbyAudio, $InstallMicrosoftEdge, $InstallOneDrive, $InstallPaintPaint3D, $InstallPhoneLink, $InstallQuickAssist, $InstallSoundRecorder, $InstallTaskbarWidgets, $InstallUWPWMediaPlayer, $InstallXbox))
    $T1Panel2.Controls.AddRange(@($ClOtherTools, $RandomizeSystemColor, $ReinstallBloatApps, $RepairWindows, $ShowDebloatInfo))
    $T1Panel3.Controls.AddRange(@($ClWindowsUpdate, $CbAutomaticWindowsUpdate))
    $T1Panel3.Controls.AddRange(@($ClOptionalFeatures, $CbHyperV, $CbInternetExplorer, $CbPrintToPDFServices, $CbPrintingXPSServices, $CbWindowsMediaPlayer, $CbWindowsSandbox))
    $T1Panel3.Controls.AddRange(@($ClTaskScheduler, $CbFamilySafety))
    $T1Panel3.Controls.AddRange(@($ClServices, $CbWindowsSearch))
    $T1Panel3.Controls.AddRange(@($ClWindowsCapabilities, $CbPowerShellISE))
    $T1Panel3.Controls.AddRange(@($ClMiscFeatures, $CbEncryptedDNS, $CbGodMode, $CbMouseAcceleration, $CbMouseNaturalScroll, $CbTakeOwnership, $CbFastShutdownPCShortcut))

    $T2Panel1.Controls.AddRange(@($UpgradeAll))
    $T2Panel1.Controls.AddRange(@($ClCpuGpuDrivers, $InstallAmdRyzenChipsetDriver, $InstallIntelDSA, $InstallNvidiaGeForceExperience, $InstallDDU, $InstallNVCleanstall))
    $T2Panel1.Controls.AddRange(@($ClApplicationRequirements, $InstallDirectX, $InstallMsDotNetFramework, $InstallMsVCppX64, $InstallMsVCppX86))
    $T2Panel1.Controls.AddRange(@($ClFileCompression, $Install7Zip, $InstallWinRar))
    $T2Panel1.Controls.AddRange(@($ClDocuments, $InstallAdobeReaderDC, $InstallLibreOffice, $InstallOnlyOffice, $InstallPDFCreator, $InstallPowerBi, $InstallSumatraPDF))
    $T2Panel1.Controls.AddRange(@($ClTorrent, $InstallqBittorrent))
    $T2Panel1.Controls.AddRange(@($ClAcademicResearch, $InstallZotero))
    $T2Panel1.Controls.AddRange(@($Cl2fa, $InstallTwilioAuthy))
    $T2Panel1.Controls.AddRange(@($ClBootableUsb, $InstallBalenaEtcher, $InstallRufus, $InstallVentoy))
    $T2Panel1.Controls.AddRange(@($ClVirtualMachines, $InstallOracleVirtualBox, $InstallQemu, $InstallVmWarePlayer))
    $T2Panel1.Controls.AddRange(@($ClCloudStorage, $InstallDropbox, $InstallGoogleDrive))
    $T2Panel1.Controls.AddRange(@($ClUICustomization, $InstallRoundedTB, $InstallTranslucentTB))
    $T2Panel2.Controls.AddRange(@($InstallSelected))
    $T2Panel2.Controls.AddRange(@($ClWebBrowsers, $InstallBraveBrowser, $InstallGoogleChrome, $InstallMozillaFirefox))
    $T2Panel2.Controls.AddRange(@($ClAudioVideoTools, $InstallAudacity, $InstallMpcHc, $InstallVlc))
    $T2Panel2.Controls.AddRange(@($ClImageTools, $InstallGimp, $InstallInkscape, $InstallIrfanView, $InstallKrita, $InstallPaintNet, $InstallShareX))
    $T2Panel2.Controls.AddRange(@($ClStreamingServices, $InstallAmazonPrimeVideo, $InstallDisneyPlus, $InstallNetflix, $InstallSpotify))
    $T2Panel2.Controls.AddRange(@($ClPlanningProductivity, $InstallNotion, $InstallObsidian))
    $T2Panel2.Controls.AddRange(@($ClUtilities, $InstallCpuZ, $InstallCrystalDiskInfo, $InstallCrystalDiskMark, $InstallGeekbench6, $InstallGpuZ, $InstallHwInfo, $InstallInternetDownloadManager, $InstallMsiAfterburner, $InstallRtxVoice, $InstallVoicemod, $InstallVoiceMeeter, $InstallWizTree))
    $T2Panel2.Controls.AddRange(@($ClNetworkManagement, $InstallHamachi, $InstallPuTty, $InstallRadminVpn, $InstallWinScp, $InstallWireshark))
    $T2Panel3.Controls.AddRange(@($UninstallMode))
    $T2Panel3.Controls.AddRange(@($ClCommunication, $InstallDiscord, $InstallMSTeams, $InstallRocketChat, $InstallSignal, $InstallSkype, $InstallSlack, $InstallTelegramDesktop, $InstallWhatsAppDesktop, $InstallZoom))
    $T2Panel3.Controls.AddRange(@($ClGaming, $InstallBorderlessGaming, $InstallEADesktop, $InstallEpicGamesLauncher, $InstallGogGalaxy, $InstallSteam, $InstallUbisoftConnect))
    $T2Panel3.Controls.AddRange(@($ClRemoteConnection, $InstallAnyDesk, $InstallParsec, $InstallScrCpy, $InstallTeamViewer))
    $T2Panel3.Controls.AddRange(@($ClRecordingAndStreaming, $InstallElgatoStreamDeck, $InstallHandBrake, $InstallObsStudio, $InstallStreamlabs))
    $T2Panel3.Controls.AddRange(@($ClEmulation, $InstallCemu, $InstallDolphin, $InstallDuckstation, $InstallKegaFusion, $InstallMGba, $InstallPPSSPP, $InstallRetroArch, $InstallRyujinx, $InstallSnes9x))
    $T2Panel4.Controls.AddRange(@($ClTextEditors, $InstallJetBrainsToolbox, $InstallNotepadPlusPlus, $InstallVisualStudioCommunity, $InstallVSCode, $InstallVSCodium))
    $T2Panel4.Controls.AddRange(@($ClWsl, $InstallWSL, $InstallArchWSL, $InstallDebian, $InstallKaliLinux, $InstallUbuntu))
    $T2Panel4.Controls.AddRange(@($ClDevelopment, $InstallWindowsTerminal, $InstallNerdFonts, $InstallGitGnupgSshSetup, $InstallAdb, $InstallAndroidStudio, $InstallDockerDesktop, $InstallInsomnia, $InstallJavaJdks, $InstallJavaJre, $InstallMySql, $InstallNodeJs, $InstallNodeJsLts, $InstallPostgreSql, $InstallPython3, $InstallPythonAnaconda3, $InstallRuby, $InstallRubyMsys, $InstallRustGnu, $InstallRustMsvc))

    $T3PanelPackageManagersSettings.Controls.AddRange(@($ClWingetSettings, $InstallWinget, $EnableWingetDailyUpgrade, $RemoveWingetDailyUpgrade))
    $T3PanelPackageManagersSettings.Controls.AddRange(@($ClChocolateySettings, $InstallChocolatey, $UninstallChocolatey, $EnableChocolateyDailyUpgrade, $RemoveChocolateyDailyUpgrade, $RemoveAllChocolateyPackages))

    # <===== CLICK EVENTS =====>

    $ApplyTweaks.Add_Click( {
            Set-RevertStatus -Revert $false
            Open-DebloatScript
            $PictureBox1.ImageLocation = "$PSScriptRoot\src\assets\script-image2.png"
            $Form.Update()
        })

    $UndoTweaks.Add_Click( {
            Set-RevertStatus -Revert $true
            $Scripts = @(
                "Invoke-DebloatSoftware.ps1",
                "Optimize-TaskScheduler.ps1",
                "Optimize-ServicesRunning.ps1",
                "Optimize-Privacy.ps1",
                "Optimize-Performance.ps1",
                "Register-PersonalTweaksList.ps1",
                "Remove-CapabilitiesList.ps1",
                "Optimize-WindowsFeaturesList.ps1",
                "Install-DefaultAppsList.ps1"
            )
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts $Scripts -DoneTitle $DoneTitle -DoneMessage $DoneMessage
            Set-RevertStatus -Revert $false
            $PictureBox1.ImageLocation = "$PSScriptRoot\src\assets\peepo-leaving.gif"
            $PictureBox1.SizeMode = 'StretchImage'
            $Form.Update()
        })

    $DiskCleanUp.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("Start-DiskCleanUp.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $RemoveTemporaryFiles.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("Remove-TemporaryFiles.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $RemoveWindowsOld.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("Remove-WindowsOld.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $RemoveMSEdge.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("Remove-MSEdge.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $RemoveOneDrive.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("Remove-OneDrive.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
            $PictureBox1.ImageLocation = "$PSScriptRoot\src\assets\script-image2.png"
            $Form.Update()
        })

    $RemoveXbox.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("Remove-Xbox.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
            $PictureBox1.ImageLocation = "$PSScriptRoot\src\assets\script-image2.png"
            $Form.Update()
        })

    $RepairWindows.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("Backup-System.ps1", "Repair-WindowsSystem.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $InstallDolbyAudio.Add_Click( {
            Install-DolbyAudio
        })

    $InstallMicrosoftEdge.Add_Click( {
            Install-MicrosoftEdge
        })

    $InstallOneDrive.Add_Click( {
            Install-OneDrive
        })

    $InstallPaintPaint3D.Add_Click( {
            Install-PaintPaint3D
        })

    $InstallPhoneLink.Add_Click( {
            Install-PhoneLink
        })

    $InstallQuickAssist.Add_Click( {
            Install-QuickAssist
        })

    $InstallSoundRecorder.Add_Click( {
            Install-SoundRecorder
        })

    $InstallTaskbarWidgets.Add_Click( {
            Install-TaskbarWidgetsApp
        })

    $InstallUWPWMediaPlayer.Add_Click( {
            Install-UWPWindowsMediaPlayer
        })

    $InstallXbox.Add_Click( {
            Install-Xbox
        })

    $RandomizeSystemColor.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("New-SystemColor.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $ReinstallBloatApps.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("Install-DefaultAppsList.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $ShowDebloatInfo.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("Show-DebloatInfo.ps1") -NoDialog
        })

    $CbAutomaticWindowsUpdate.Add_Click( {
            If ($CbAutomaticWindowsUpdate.CheckState -eq "Checked") {
                Enable-AutomaticWindowsUpdate
                $CbAutomaticWindowsUpdate.Text = "[ON]  Automatic Windows Update *"
            } Else {
                Disable-AutomaticWindowsUpdate
                $CbAutomaticWindowsUpdate.Text = "[OFF] Automatic Windows Update"
            }
        })

    $CbDarkTheme.Add_Click( {
            If ($CbDarkTheme.CheckState -eq "Checked") {
                Enable-DarkTheme
                $CbDarkTheme.Text = "[ON]  Dark Theme"
            } Else {
                Disable-DarkTheme
                $CbDarkTheme.Text = "[OFF] Dark Theme *"
            }
        })

    $CbActivityHistory.Add_Click( {
            If ($CbActivityHistory.CheckState -eq "Checked") {
                Enable-ActivityHistory
                $CbActivityHistory.Text = "[ON]  Activity History *"
            } Else {
                Disable-ActivityHistory
                $CbActivityHistory.Text = "[OFF] Activity History"
            }
        })

    $CbBackgroundsApps.Add_Click( {
            If ($CbBackgroundsApps.CheckState -eq "Checked") {
                Enable-BackgroundAppsToogle
                $CbBackgroundsApps.Text = "[ON]  Background Apps *"
            } Else {
                Disable-BackgroundAppsToogle
                $CbBackgroundsApps.Text = "[OFF] Background Apps"
            }
        })

    $CbClipboardHistory.Add_Click( {
            If ($CbClipboardHistory.CheckState -eq "Checked") {
                Enable-ClipboardHistory
                $CbClipboardHistory.Text = "[ON]  Clipboard History *"
            } Else {
                Disable-ClipboardHistory
                $CbClipboardHistory.Text = "[OFF] Clipboard History"
            }
        })

    $CbClipboardSyncAcrossDevice.Add_Click( {
            If ($CbClipboardSyncAcrossDevice.CheckState -eq "Checked") {
                Enable-ClipboardSyncAcrossDevice
                $CbClipboardSyncAcrossDevice.Text = "[ON]  Clipboard Sync Across Devices *"
            } Else {
                Disable-ClipboardSyncAcrossDevice
                $CbClipboardSyncAcrossDevice.Text = "[OFF] Clipboard Sync Across Devices"
            }
        })

    $CbCortana.Add_Click( {
            If ($CbCortana.CheckState -eq "Checked") {
                Enable-Cortana
                $CbCortana.Text = "[ON]  Cortana *"
            } Else {
                Disable-Cortana
                $CbCortana.Text = "[OFF] Cortana"
            }
        })

    $CbHibernate.Add_Click( {
            If ($CbHibernate.CheckState -eq "Checked") {
                Enable-Hibernate
                $CbHibernate.Text = "[ON]  Hibernate *"
            } Else {
                Disable-Hibernate
                $CbHibernate.Text = "[OFF] Hibernate"
            }
        })

    $CbLegacyContextMenu.Add_Click( {
            If ($CbLegacyContextMenu.CheckState -eq "Checked") {
                Enable-LegacyContextMenu
                $CbLegacyContextMenu.Text = "[ON]  Legacy Context Menu"
            } Else {
                Disable-LegacyContextMenu
                $CbLegacyContextMenu.Text = "[OFF] Legacy Context Menu *"
            }
        })

    $CbLocationTracking.Add_Click( {
            If ($CbLocationTracking.CheckState -eq "Checked") {
                Enable-LocationTracking
                $CbLocationTracking.Text = "[ON]  Location Tracking *"
            } Else {
                Disable-LocationTracking
                $CbLocationTracking.Text = "[OFF] Location Tracking"
            }
        })

    $CbNewsAndInterest.Add_Click( {
            If ($CbNewsAndInterest.CheckState -eq "Checked") {
                Enable-NewsAndInterest
                $CbNewsAndInterest.Text = "[ON]  News And Interest *"
            } Else {
                Disable-NewsAndInterest
                $CbNewsAndInterest.Text = "[OFF] News And Interest"
            }
        })

    $CbOldVolumeControl.Add_Click( {
            If ($CbOldVolumeControl.CheckState -eq "Checked") {
                Enable-OldVolumeControl
                $CbOldVolumeControl.Text = "[ON]  Old Volume Control"
            } Else {
                Disable-OldVolumeControl
                $CbOldVolumeControl.Text = "[OFF] Old Volume Control *"
            }
        })

    $CbOnlineSpeechRecognition.Add_Click( {
            If ($CbOnlineSpeechRecognition.CheckState -eq "Checked") {
                Enable-OnlineSpeechRecognition
                $CbOnlineSpeechRecognition.Text = "[ON]  Online Speech Recognition *"
            } Else {
                Disable-OnlineSpeechRecognition
                $CbOnlineSpeechRecognition.Text = "[OFF] Online Speech Recognition"
            }
        })

    $CbPhoneLink.Add_Click( {
            If ($CbPhoneLink.CheckState -eq "Checked") {
                Enable-PhoneLink
                $CbPhoneLink.Text = "[ON]  Phone Link *"
            } Else {
                Disable-PhoneLink
                $CbPhoneLink.Text = "[OFF] Phone Link"
            }
        })

    $CbPhotoViewer.Add_Click( {
            If ($CbPhotoViewer.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-photo-viewer.reg") -NoDialog
                $CbPhotoViewer.Text = "[ON]  Photo Viewer"
            } Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-photo-viewer.reg") -NoDialog
                $CbPhotoViewer.Text = "[OFF] Photo Viewer *"
            }
        })

    $CbSearchAppForUnknownExt.Add_Click( {
            If ($CbSearchAppForUnknownExt.CheckState -eq "Checked") {
                Enable-SearchAppForUnknownExt
                $CbSearchAppForUnknownExt.Text = "[ON]  Search App for Unknown Ext. *"
            } Else {
                Disable-SearchAppForUnknownExt
                $CbSearchAppForUnknownExt.Text = "[OFF] Search App for Unknown Ext."
            }
        })

    $CbTelemetry.Add_Click( {
            If ($CbTelemetry.CheckState -eq "Checked") {
                Enable-Telemetry
                $CbTelemetry.Text = "[ON]  Telemetry *"
            } Else {
                Disable-Telemetry
                $CbTelemetry.Text = "[OFF] Telemetry"
            }
        })

    $CbWindowsSpotlight.Add_Click( {
            If ($CbWindowsSpotlight.CheckState -eq "Checked") {
                Enable-WindowsSpotlight
                $CbWindowsSpotlight.Text = "[ON]  Windows Spotlight *"
            } Else {
                Disable-WindowsSpotlight
                $CbWindowsSpotlight.Text = "[OFF] Windows Spotlight"
            }
        })

    $CbXboxGameBarDVRandMode.Add_Click( {
            If ($CbXboxGameBarDVRandMode.CheckState -eq "Checked") {
                Enable-XboxGameBarDVRandMode
                $CbXboxGameBarDVRandMode.Text = "[ON]  Xbox Game Bar/DVR/Mode *"
            } Else {
                Disable-XboxGameBarDVRandMode
                $CbXboxGameBarDVRandMode.Text = "[OFF] Xbox Game Bar/DVR/Mode"
            }
        })

    $CbHyperV.Add_Click( {
            If ($CbHyperV.CheckState -eq "Checked") {
                Enable-HyperV
                $CbHyperV.Text = "[ON]  Hyper-V"
            } Else {
                Disable-HyperV
                $CbHyperV.Text = "[OFF] Hyper-V *"
            }
        })

    $CbInternetExplorer.Add_Click( {
            If ($CbInternetExplorer.CheckState -eq "Checked") {
                Enable-InternetExplorer
                $CbInternetExplorer.Text = "[ON]  Internet Explorer"
            } Else {
                Disable-InternetExplorer
                $CbInternetExplorer.Text = "[OFF] Internet Explorer *"
            }
        })

    $CbPrintToPDFServices.Add_Click( {
            If ($CbPrintToPDFServices.CheckState -eq "Checked") {
                Enable-PrintToPDFServicesToogle
                $CbPrintToPDFServices.Text = "[ON]  Print To PDF Services *"
            } Else {
                Disable-PrintToPDFServicesToogle
                $CbPrintToPDFServices.Text = "[OFF] Print To PDF Services"
            }
        })

    $CbPrintingXPSServices.Add_Click( {
            If ($CbPrintingXPSServices.CheckState -eq "Checked") {
                Enable-PrintingXPSServicesToogle
                $CbPrintingXPSServices.Text = "[ON]  Printing XPS Services *"
            } Else {
                Disable-PrintingXPSServicesToogle
                $CbPrintingXPSServices.Text = "[OFF] Printing XPS Services"
            }
        })

    $CbWindowsMediaPlayer.Add_Click( {
            If ($CbWindowsMediaPlayer.CheckState -eq "Checked") {
                Enable-WindowsMediaPlayer
                $CbWindowsMediaPlayer.Text = "[ON]  Windows Media Player *"
            } Else {
                Disable-WindowsMediaPlayer
                $CbWindowsMediaPlayer.Text = "[OFF] Windows Media Player"
            }
        })

    $CbWindowsSandbox.Add_Click( {
            If ($CbWindowsSandbox.CheckState -eq "Checked") {
                Enable-WindowsSandbox
                $CbWindowsSandbox.Text = "[ON]  Windows Sandbox"
            } Else {
                Disable-WindowsSandbox
                $CbWindowsSandbox.Text = "[OFF] Windows Sandbox *"
            }
        })

    $CbFamilySafety.Add_Click( {
            If ($CbFamilySafety.CheckState -eq "Checked") {
                Enable-FamilySafety
                $CbFamilySafety.Text = "[ON]  Family Safety Features *"
            } Else {
                Disable-FamilySafety
                $CbFamilySafety.Text = "[OFF] Family Safety Features"
            }
        })

    $CbWindowsSearch.Add_Click( {
            If ($CbWindowsSearch.CheckState -eq "Checked") {
                Enable-WindowsSearch
                $CbWindowsSearch.Text = "[ON]  Windows Search Indexing *"
            } Else {
                Disable-WindowsSearch
                $CbWindowsSearch.Text = "[OFF] Windows Search Indexing"
            }
        })

    $CbPowerShellISE.Add_Click( {
            If ($CbPowerShellISE.CheckState -eq "Checked") {
                Enable-PowerShellISE
                $CbPowerShellISE.Text = "[ON]  PowerShell ISE *"
            } Else {
                Disable-PowerShellISE
                $CbPowerShellISE.Text = "[OFF] PowerShell ISE"
            }
        })

    $CbEncryptedDNS.Add_Click( {
            If ($CbEncryptedDNS.CheckState -eq "Checked") {
                Enable-EncryptedDNS
                $CbEncryptedDNS.Text = "[ON]  Encrypted DNS"
            } Else {
                Disable-EncryptedDNS
                $CbEncryptedDNS.Text = "[OFF] Encrypted DNS *"
            }
        })

    $CbGodMode.Add_Click( {
            If ($CbGodMode.CheckState -eq "Checked") {
                Enable-GodMode
                $CbGodMode.Text = "[ON]  God Mode"
            } Else {
                Disable-GodMode
                $CbGodMode.Text = "[OFF] God Mode *"
            }
        })

    $CbMouseAcceleration.Add_Click( {
            If ($CbMouseAcceleration.CheckState -eq "Checked") {
                Enable-MouseAcceleration
                $CbMouseAcceleration.Text = "[ON]  Mouse Acceleration *"
            } Else {
                Disable-MouseAcceleration
                $CbMouseAcceleration.Text = "[OFF] Mouse Acceleration"
            }
        })

    $CbMouseNaturalScroll.Add_Click( {
            If ($CbMouseNaturalScroll.CheckState -eq "Checked") {
                Enable-MouseNaturalScroll
                $CbMouseNaturalScroll.Text = "[ON]  Mouse Natural Scroll"
            } Else {
                Disable-MouseNaturalScroll
                $CbMouseNaturalScroll.Text = "[OFF] Mouse Natural Scroll *"
            }
        })

    $CbTakeOwnership.Add_Click( {
            If ($CbTakeOwnership.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-take-ownership-context-menu.reg") -NoDialog
                $CbTakeOwnership.Text = "[ON]  Take Ownership menu"
            } Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-take-ownership-context-menu.reg") -NoDialog
                $CbTakeOwnership.Text = "[OFF] Take Ownership... *"
            }
        })

    $CbFastShutdownPCShortcut.Add_Click( {
            If ($CbFastShutdownPCShortcut.CheckState -eq "Checked") {
                Enable-FastShutdownShortcut
                $CbFastShutdownPCShortcut.Text = "[ON]  Fast Shutdown shortcut"
            } Else {
                Disable-FastShutdownShortcut
                $CbFastShutdownPCShortcut.Text = "[OFF] Fast Shutdown shortcut *"
            }
        })

    $UpgradeAll.Add_Click( {
            Update-AllPackage
        })

    $InstallSelected.Add_Click( {
            $AppsSelected = @{
                WingetApps     = [System.Collections.ArrayList]@()
                MSStoreApps    = [System.Collections.ArrayList]@()
                ChocolateyApps = [System.Collections.ArrayList]@()
                WSLDistros     = [System.Collections.ArrayList]@()
            }

            $SoftwareList = ""

            If ($InstallAmdRyzenChipsetDriver.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("amd-ryzen-chipset")
                $InstallAmdRyzenChipsetDriver.CheckState = "Unchecked"
            }

            If ($InstallIntelDSA.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Intel.IntelDriverAndSupportAssistant")
                $InstallIntelDSA.CheckState = "Unchecked"
            }

            If ($InstallNvidiaGeForceExperience.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Nvidia.GeForceExperience")
                $InstallNvidiaGeForceExperience.CheckState = "Unchecked"
            }

            If ($InstallDDU.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Wagnardsoft.DisplayDriverUninstaller")
                $InstallDDU.CheckState = "Unchecked"
            }

            If ($InstallNVCleanstall.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("TechPowerUp.NVCleanstall")
                $InstallNVCleanstall.CheckState = "Unchecked"
            }

            If ($InstallDirectX.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("directx")
                $InstallDirectX.CheckState = "Unchecked"
            }

            If ($InstallMsDotNetFramework.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.DotNet.Framework.DeveloperPack_4")
                $InstallMsDotNetFramework.CheckState = "Unchecked"
            }

            If ($InstallMsVCppX64.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.AddRange(
                    @(
                        "Microsoft.VCRedist.2005.x64", "Microsoft.VCRedist.2008.x64", "Microsoft.VCRedist.2010.x64",
                        "Microsoft.VCRedist.2012.x64", "Microsoft.VCRedist.2013.x64", "Microsoft.VCRedist.2015+.x64"
                    )
                )
                $InstallMsVCppX64.CheckState = "Unchecked"
            }

            If ($InstallMsVCppX86.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.AddRange(
                    @(
                        "Microsoft.VCRedist.2005.x86", "Microsoft.VCRedist.2008.x86", "Microsoft.VCRedist.2010.x86",
                        "Microsoft.VCRedist.2012.x86", "Microsoft.VCRedist.2013.x86", "Microsoft.VCRedist.2015+.x86"
                    )
                )
                $InstallMsVCppX86.CheckState = "Unchecked"
            }

            If ($Install7Zip.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("7zip.7zip")
                $Install7Zip.CheckState = "Unchecked"
            }

            If ($InstallWinRar.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("RARLab.WinRAR")
                $InstallWinRar.CheckState = "Unchecked"
            }

            If ($InstallAdobeReaderDC.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Adobe.Acrobat.Reader.64-bit")
                $InstallAdobeReaderDC.CheckState = "Unchecked"
            }

            If ($InstallLibreOffice.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("TheDocumentFoundation.LibreOffice")
                $InstallLibreOffice.CheckState = "Unchecked"
            }

            If ($InstallOnlyOffice.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("ONLYOFFICE.DesktopEditors")
                $InstallOnlyOffice.CheckState = "Unchecked"
            }

            If ($InstallSumatraPDF.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("SumatraPDF.SumatraPDF")
                $InstallSumatraPDF.CheckState = "Unchecked"
            }

            If ($InstallPDFCreator.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("PDFCreator")
                $InstallPDFCreator.CheckState = "Unchecked"
            }

            If ($InstallPowerBi.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.PowerBI")
                $InstallPowerBi.CheckState = "Unchecked"
            }

            If ($InstallqBittorrent.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("qBittorrent.qBittorrent")
                $InstallqBittorrent.CheckState = "Unchecked"
            }

            If ($InstallZotero.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Zotero.Zotero")
                $InstallZotero.CheckState = "Unchecked"
            }

            If ($InstallTwilioAuthy.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Twilio.Authy")
                $InstallTwilioAuthy.CheckState = "Unchecked"
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

            If ($InstallOracleVirtualBox.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Oracle.VirtualBox")
                $InstallOracleVirtualBox.CheckState = "Unchecked"
            }

            If ($InstallQemu.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("SoftwareFreedomConservancy.QEMU")
                $InstallQemu.CheckState = "Unchecked"
            }

            If ($InstallVmWarePlayer.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("VMware.WorkstationPlayer")
                $InstallVmWarePlayer.CheckState = "Unchecked"
            }

            If ($InstallDropbox.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Dropbox.Dropbox")
                $InstallDropbox.CheckState = "Unchecked"
            }

            If ($InstallRoundedTB.CheckState -eq "Checked") {
                $AppsSelected.MSStoreApps.Add("9MTFTXSJ9M7F")
                $InstallRoundedTB.CheckState = "Unchecked"
            }

            If ($InstallTranslucentTB.CheckState -eq "Checked") {
                $AppsSelected.MSStoreApps.Add("9PF4KZ2VN4W9")
                $InstallTranslucentTB.CheckState = "Unchecked"
            }

            If ($InstallGoogleDrive.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Google.Drive")
                $InstallGoogleDrive.CheckState = "Unchecked"
            }

            If ($InstallBraveBrowser.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Brave.Brave")
                $InstallBraveBrowser.CheckState = "Unchecked"
            }

            If ($InstallGoogleChrome.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Google.Chrome")
                $InstallGoogleChrome.CheckState = "Unchecked"
            }

            If ($InstallMozillaFirefox.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("firefox")
                $InstallMozillaFirefox.CheckState = "Unchecked"
            }

            If ($InstallAudacity.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Audacity.Audacity")
                $InstallAudacity.CheckState = "Unchecked"
            }

            If ($InstallMpcHc.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("clsid2.mpc-hc")
                $InstallMpcHc.CheckState = "Unchecked"
            }

            If ($InstallVlc.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("VideoLAN.VLC")
                $InstallVlc.CheckState = "Unchecked"
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

            If ($InstallAmazonPrimeVideo.CheckState -eq "Checked") {
                $AppsSelected.MSStoreApps.Add("9P6RC76MSMMJ")
                $InstallAmazonPrimeVideo.CheckState = "Unchecked"
            }

            If ($InstallDisneyPlus.CheckState -eq "Checked") {
                $AppsSelected.MSStoreApps.Add("9NXQXXLFST89")
                $InstallDisneyPlus.CheckState = "Unchecked"
            }

            If ($InstallNetflix.CheckState -eq "Checked") {
                $AppsSelected.MSStoreApps.Add("9WZDNCRFJ3TJ")
                $InstallNetflix.CheckState = "Unchecked"
            }

            If ($InstallSpotify.CheckState -eq "Checked") {
                $AppsSelected.MSStoreApps.Add("9NCBCSZSJRSB")
                $InstallSpotify.CheckState = "Unchecked"
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

            If ($InstallGeekbench6.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("PrimateLabs.Geekbench.6")
                $InstallGeekbench6.CheckState = "Unchecked"
            }

            If ($InstallGpuZ.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("TechPowerUp.GPU-Z")
                $InstallGpuZ.CheckState = "Unchecked"
            }

            If ($InstallHwInfo.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("REALiX.HWiNFO")
                $InstallHwInfo.CheckState = "Unchecked"
            }

            If ($InstallInternetDownloadManager.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Tonec.InternetDownloadManager")
                $InstallInternetDownloadManager.CheckState = "Unchecked"
            }

            If ($InstallMsiAfterburner.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("msiafterburner")
                $InstallMsiAfterburner.CheckState = "Unchecked"
            }

            If ($InstallRtxVoice.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Nvidia.RTXVoice")
                $InstallRtxVoice.CheckState = "Unchecked"
            }

            If ($InstallVoicemod.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Voicemod.Voicemod")
                $InstallVoicemod.CheckState = "Unchecked"
            }

            If ($InstallVoiceMeeter.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("VB-Audio.Voicemeeter.Potato")
                $InstallVoiceMeeter.CheckState = "Unchecked"
            }

            If ($InstallWizTree.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("AntibodySoftware.WizTree")
                $InstallWizTree.CheckState = "Unchecked"
            }

            If ($InstallHamachi.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("LogMeIn.Hamachi")
                $InstallHamachi.CheckState = "Unchecked"
            }

            If ($InstallPuTty.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("PuTTY.PuTTY")
                $InstallPuTty.CheckState = "Unchecked"
            }

            If ($InstallRadminVpn.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Radmin.VPN")
                $InstallRadminVpn.CheckState = "Unchecked"
            }

            If ($InstallWinScp.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("WinSCP.WinSCP")
                $InstallWinScp.CheckState = "Unchecked"
            }

            If ($InstallWireshark.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("WiresharkFoundation.Wireshark")
                $InstallWireshark.CheckState = "Unchecked"
            }

            If ($InstallDiscord.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Discord.Discord")
                $InstallDiscord.CheckState = "Unchecked"
            }

            If ($InstallMSTeams.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.Teams")
                $InstallMSTeams.CheckState = "Unchecked"
            }

            If ($InstallRocketChat.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("RocketChat.RocketChat")
                $InstallRocketChat.CheckState = "Unchecked"
            }

            If ($InstallSignal.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("OpenWhisperSystems.Signal")
                $InstallSignal.CheckState = "Unchecked"
            }

            If ($InstallSkype.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.Skype")
                $InstallSkype.CheckState = "Unchecked"
            }

            If ($InstallSlack.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("SlackTechnologies.Slack")
                $InstallSlack.CheckState = "Unchecked"
            }

            If ($InstallTelegramDesktop.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Telegram.TelegramDesktop")
                $InstallTelegramDesktop.CheckState = "Unchecked"
            }

            If ($InstallWhatsAppDesktop.CheckState -eq "Checked") {
                $AppsSelected.MSStoreApps.Add("9NKSQGP7F2NH")
                $InstallWhatsAppDesktop.CheckState = "Unchecked"
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

            If ($InstallElgatoStreamDeck.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Elgato.StreamDeck")
                $InstallElgatoStreamDeck.CheckState = "Unchecked"
            }

            If ($InstallHandBrake.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("HandBrake.HandBrake")
                $InstallHandBrake.CheckState = "Unchecked"
            }

            If ($InstallObsStudio.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("OBSProject.OBSStudio")
                $InstallObsStudio.CheckState = "Unchecked"
            }

            If ($InstallStreamlabs.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Streamlabs.Streamlabs")
                $InstallStreamlabs.CheckState = "Unchecked"
            }

            If ($InstallCemu.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("cemu")
                $InstallCemu.CheckState = "Unchecked"
            }

            If ($InstallDolphin.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("DolphinEmulator.Dolphin")
                $InstallDolphin.CheckState = "Unchecked"
            }

            If ($InstallDuckstation.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Stenzek.DuckStation")
                $InstallDuckstation.CheckState = "Unchecked"
            }

            If ($InstallKegaFusion.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("kega-fusion")
                $InstallKegaFusion.CheckState = "Unchecked"
            }

            If ($InstallMGba.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("JeffreyPfau.mGBA")
                $InstallMGba.CheckState = "Unchecked"
            }

            If ($InstallPPSSPP.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("ppsspp")
                $InstallPPSSPP.CheckState = "Unchecked"
            }

            If ($InstallRetroArch.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Libretro.RetroArch")
                $InstallRetroArch.CheckState = "Unchecked"
            }

            If ($InstallRyujinx.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("ryujinx")
                $InstallRyujinx.CheckState = "Unchecked"
            }

            If ($InstallSnes9x.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("snes9x")
                $InstallSnes9x.CheckState = "Unchecked"
            }

            If ($InstallJetBrainsToolbox.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("JetBrains.Toolbox")
                $InstallJetBrainsToolbox.CheckState = "Unchecked"
            }

            If ($InstallNotepadPlusPlus.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Notepad++.Notepad++")
                $InstallNotepadPlusPlus.CheckState = "Unchecked"
            }

            If ($InstallVisualStudioCommunity.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.VisualStudio.2022.Community")
                $InstallVisualStudioCommunity.CheckState = "Unchecked"
            }

            If ($InstallVSCode.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.VisualStudioCode")
                $InstallVSCode.CheckState = "Unchecked"
            }

            If ($InstallVSCodium.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("VSCodium.VSCodium")
                $InstallVSCodium.CheckState = "Unchecked"
            }

            If ($InstallWSL.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("Install-WSL.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
                } Else {
                    $AppsSelected.MSStoreApps.Add("9P9TQF7MRM4R")
                    Set-OptionalFeatureState -State 'Disabled' -OptionalFeatures @("Microsoft-Windows-Subsystem-Linux")
                }
                $InstallWSL.CheckState = "Unchecked"
            }

            If ($InstallArchWSL.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("Install-ArchWSL.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
                } Else {
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

            If ($InstallUbuntu.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu")
                $InstallUbuntu.CheckState = "Unchecked"
            }

            If ($InstallWindowsTerminal.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.WindowsTerminal")
                $InstallWindowsTerminal.CheckState = "Unchecked"
            }

            If ($InstallNerdFonts.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("Install-NerdFont.ps1")
                }
                $InstallNerdFonts.CheckState = "Unchecked"
            }

            If ($InstallGitGnupgSshSetup.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Stop-Logging # Don't log any credential info after this point
                    Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("Git-GnupgSshKeysSetup.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
                    Start-Logging -File "$CurrentFileName-$(Get-Date -Format "yyyy-MM")"
                } Else {
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
                $AppsSelected.WingetApps.AddRange(@("EclipseAdoptium.Temurin.8.JDK", "EclipseAdoptium.Temurin.11.JDK", "EclipseAdoptium.Temurin.18.JDK"))
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
                $AppsSelected.WingetApps.Add("OpenJS.NodeJS.LTS")
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

            If (!($Script:UninstallSwitch)) {
                If ($AppsSelected.WingetApps) {
                    $SoftwareList += Install-Software -Name "Apps from selection" -Packages $AppsSelected.WingetApps -NoDialog
                }
                If ($AppsSelected.MSStoreApps) {
                    $SoftwareList += "`n" + (Install-Software -Name "Apps from selection" -Packages $AppsSelected.MSStoreApps -PackageProvider 'MsStore' -NoDialog)
                }
                If ($AppsSelected.ChocolateyApps) {
                    $SoftwareList += "`n" + (Install-Software -Name "Apps from selection" -Packages $AppsSelected.ChocolateyApps -PackageProvider 'Chocolatey' -NoDialog)
                }
                If ($AppsSelected.WSLDistros) {
                    $SoftwareList += "`n" + (Install-Software -Name "Apps from selection" -Packages $AppsSelected.WSLDistros -PackageProvider 'WSL' -NoDialog)
                }
            } Else {
                If ($AppsSelected.WingetApps) {
                    $SoftwareList += Uninstall-Software -Name "Apps from selection" -Packages $AppsSelected.WingetApps -NoDialog
                }
                If ($AppsSelected.MSStoreApps) {
                    $SoftwareList += "`n" + (Uninstall-Software -Name "Apps from selection" -Packages $AppsSelected.MSStoreApps -PackageProvider 'MsStore' -NoDialog)
                }
                If ($AppsSelected.ChocolateyApps) {
                    $SoftwareList += "`n" + (Uninstall-Software -Name "Apps from selection" -Packages $AppsSelected.ChocolateyApps -PackageProvider 'Chocolatey' -NoDialog)
                }
                If ($AppsSelected.WSLDistros) {
                    $SoftwareList += "`n" + (Uninstall-Software -Name "Apps from selection" -Packages $AppsSelected.WSLDistros -PackageProvider 'WSL' -NoDialog)
                }
            }

            If (($AppsSelected.WingetApps.Count -ge 1) -or ($AppsSelected.MSStoreApps.Count -ge 1) -or ($AppsSelected.ChocolateyApps.Count -ge 1) -or ($AppsSelected.WSLDistros.Count -ge 1)) {
                Show-MessageDialog -Title "$DoneTitle" -Message "$SoftwareList"
            }
            $SoftwareList = ""
        })

    $UninstallMode.Add_Click( {
            If ($UninstallSwitch) {
                $Script:UninstallSwitch = $false
                $InstallSelected.Text = "Install Selected"
                $UninstallMode.Text = "[OFF] Uninstall Mode"
                $UninstallMode.ForeColor = $Colors.White
            } Else {
                $Script:UninstallSwitch = $true
                $InstallSelected.Text = "Uninstall Selected"
                $UninstallMode.Text = "[ON]  Uninstall Mode"
                $UninstallMode.ForeColor = $Colors.WarningYellow
            }
        })

    $InstallWinget.Add_Click( {
            Install-Winget
        })

    $EnableWingetDailyUpgrade.Add_Click( {
            Register-WingetDailyUpgrade
        })

    $RemoveWingetDailyUpgrade.Add_Click( {
            Unregister-WingetDailyUpgrade
        })

    $InstallChocolatey.Add_Click( {
            Install-Chocolatey
        })

    $UninstallChocolatey.Add_Click( {
            Uninstall-Chocolatey
        })

    $EnableChocolateyDailyUpgrade.Add_Click( {
            Register-ChocolateyDailyUpgrade
        })

    $RemoveChocolateyDailyUpgrade.Add_Click( {
            Unregister-ChocolateyDailyUpgrade
        })

    $RemoveAllChocolateyPackages.Add_Click( {
            Remove-AllChocolateyPackage
        })

    [void] $Form.ShowDialog() # Show the Window
    $Form.Dispose() # When done, dispose of the GUI
}

$Script:ArgsList = $args
If ($args) {
    Main -Mode $args[0]
} Else {
    Main
}
