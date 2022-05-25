# Learned from: https://docs.microsoft.com/en-us/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.1
# Adapted majorly from https://github.com/ChrisTitusTech/win10script and https://github.com/Sycnex/Windows10Debloater
# Take Ownership tweak from: https://www.howtogeek.com/howto/windows-vista/add-take-ownership-to-explorer-right-click-menu-in-vista/

function Request-AdminPrivilege() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function Show-GUI() {
    Write-Status -Symbol "@" -Status "Loading GUI Layout..."
    # Loading System Libs
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles() # Rounded Buttons :3

    Set-UIFont # Load the Layout Font
    $ScreenWidth, $ScreenHeight = Get-CurrentResolution # Get the Screen Size

    $Script:NeedRestart = $false
    $DoneTitle = "Information"
    $DoneMessage = "Process Completed!"

    # <===== PERSONAL LAYOUT =====>

    # To Scroll
    $VerticalScrollWidth = 17

    # To Forms
    If ($ScreenWidth -gt 1024) {
        $FormWidth = ($ScreenWidth * 0.85) + $VerticalScrollWidth # Scaled Resolution Width + Scroll Width
        $FormHeight = $ScreenHeight * 0.85
    } Else {
        $FormWidth = ($ScreenWidth * 0.99) + $VerticalScrollWidth # ~ 870.4 + Scroll Width
        $FormHeight = $ScreenHeight * 0.85
    }

    # To Panels
    $NumOfPanels = 4
    $PanelWidth = ($FormWidth / $NumOfPanels) - (2 * ($VerticalScrollWidth / $NumOfPanels)) # - Scroll Width per Panel
    $TotalWidth = $PanelWidth * $NumOfPanels
    $PanelElementMarginWidth = 0.025
    $PanelElementWidth = $PanelWidth - ($PanelWidth * (2 * $PanelElementMarginWidth))
    $PanelElementX = $PanelWidth * $PanelElementMarginWidth
    # To Labels
    $TitleLabelHeight = 45
    $CaptionLabelHeight = 30
    # To Buttons
    $ButtonHeight = 30
    $DistanceBetweenButtons = 5
    # To Fonts
    $Header1 = 20
    $Header3 = 14

    $TitleLabelY = 0

    $BBHeight = ($ButtonHeight * 2) + $DistanceBetweenButtons

    $WarningYellow = "#EED202"
    $White = "#FFFFFF"
    $WinBlue = "#08ABF7"
    $WinDark = "#252525"

    # Miscellaneous colors

    $AmdRyzenPrimaryColor = "#E4700D"
    $IntelPrimaryColor = "#0071C5"
    $NVIDIAPrimaryColor = "#76B900"

    # <===== Specific Layout =====>

    $SystemTweaksHeight = 550
    $SoftwareInstallHeight = 1500

    # <===== UI =====>

    # Main Window:
    $Form = New-Form -Width $FormWidth -Height $FormHeight -Text "Win 10+ S. D. Tools (LeDragoX) | $(Get-SystemSpec)" -BackColor "$WinDark" -Maximize $false # Loading the specs takes longer time to load the GUI

    $Form = New-FormIcon -Form $Form -ImageLocation "$PSScriptRoot\src\assets\windows-11-logo.png"

    $FormTabControl = New-TabControl -Width ($FormWidth - 8) -Height ($FormHeight - 35) -LocationX -4 -LocationY 0
    $TabSystemTweaks = New-TabPage -Name "Tab1" -Text "System Tweaks"
    $TabSoftwareInstall = New-TabPage -Name "Tab2" -Text "Software Install"

    $TlSystemTweaks = New-Label -Text "System Tweaks" -Width $TotalWidth -Height $TitleLabelHeight -LocationX 0 -LocationY $TitleLabelY -FontSize $Header1 -FontStyle "Bold" -ForeColor $WinBlue

    $NextYLocation = $TlSystemTweaks.Location.Y + $TlSystemTweaks.Height + $DistanceBetweenButtons
    $ClSystemTweaks = New-Label -Text "($((Split-Path -Path $PSCommandPath -Leaf).Split('.')[0]) v$((Get-Item "$(Split-Path -Path $PSCommandPath -Leaf)").LastWriteTimeUtc | Get-Date -Format "yyyy-MM-dd"))" -Width $TotalWidth -Height $CaptionLabelHeight -LocationX 0 -LocationY $NextYLocation -ForeColor $White

    $CurrentPanelIndex = 0
    $NextYLocation = $ClSystemTweaks.Location.Y + $ClSystemTweaks.Height + $DistanceBetweenButtons
    $T1Panel1 = New-Panel -Width $PanelWidth -Height $SystemTweaksHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY $NextYLocation

    $CurrentPanelIndex++
    $NextYLocation = $ClSystemTweaks.Location.Y + $ClSystemTweaks.Height + $DistanceBetweenButtons
    $T1Panel2 = New-Panel -Width $PanelWidth -Height $SystemTweaksHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY $NextYLocation

    # ==> T1 Panel 1
    $NextYLocation = $ClSystemTweaks.Location.Y + $ClSystemTweaks.Height + $DistanceBetweenButtons
    $ClDebloatTools = New-Label -Text "System Debloat Tools" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY 0

    $NextYLocation = $ClDebloatTools.Location.Y + $ClDebloatTools.Height + $DistanceBetweenButtons
    $ApplyTweaks = New-Button -Text "✔ Apply Tweaks" -Width $PanelElementWidth -Height $BBHeight -LocationX $PanelElementX -LocationY $NextYLocation -FontSize $Header3 -ForeColor $WinBlue

    $NextYLocation = $ApplyTweaks.Location.Y + $ApplyTweaks.Height + $DistanceBetweenButtons
    $UndoTweaks = New-Button -Text "❌ Undo Tweaks" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation -ForeColor $WarningYellow

    $NextYLocation = $UndoTweaks.Location.Y + $UndoTweaks.Height + $DistanceBetweenButtons
    $RemoveXbox = New-Button -Text "Remove Xbox" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation -ForeColor $WarningYellow

    $NextYLocation = $RemoveXbox.Location.Y + $RemoveXbox.Height + $DistanceBetweenButtons

    $PictureBox1 = New-PictureBox -ImageLocation "$PSScriptRoot\src\assets\script-logo.png" -Width $PanelElementWidth -Height (($BBHeight * 2) + $DistanceBetweenButtons) -LocationX $PanelElementX -LocationY $NextYLocation -SizeMode 'Zoom'

    $NextYLocation = $PictureBox1.Location.Y + $PictureBox1.Height + $DistanceBetweenButtons
    $InstallOneDrive = New-Button -Text "Install OneDrive" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallOneDrive.Location.Y + $InstallOneDrive.Height + $DistanceBetweenButtons
    $ReinstallBloatApps = New-Button -Text "Reinstall Pre-Installed Apps" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ReinstallBloatApps.Location.Y + $ReinstallBloatApps.Height + $DistanceBetweenButtons
    $RepairWindows = New-Button -Text "Repair Windows" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $RepairWindows.Location.Y + $RepairWindows.Height + $DistanceBetweenButtons
    $ShowDebloatInfo = New-Button -Text "Show Debloat Info" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    # ==> T1 Panel 2
    $ClCustomizeFeatures = New-Label -Text "Customize System Features" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY 0

    $NextYLocation = $ClCustomizeFeatures.Location.Y + $ClCustomizeFeatures.Height + $DistanceBetweenButtons
    $CbDarkTheme = New-CheckBox -Text "Use Dark Theme" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $CbDarkTheme.Location.Y + $CbDarkTheme.Height + $DistanceBetweenButtons
    $CbActivityHistory = New-CheckBox -Text "Enable Activity History" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $CbActivityHistory.Location.Y + $CbActivityHistory.Height + $DistanceBetweenButtons
    $CbBackgroundsApps = New-CheckBox -Text "Enable Background Apps" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $CbBackgroundsApps.Location.Y + $CbBackgroundsApps.Height + $DistanceBetweenButtons
    $CbClipboardHistory = New-CheckBox -Text "Enable Clipboard History" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $CbClipboardHistory.Location.Y + $CbClipboardHistory.Height + $DistanceBetweenButtons
    $CbCortana = New-CheckBox -Text "Enable Cortana" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $CbCortana.Location.Y + $CbCortana.Height + $DistanceBetweenButtons
    $CbOldVolumeControl = New-CheckBox -Text "Enable Old Volume Control" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $CbOldVolumeControl.Location.Y + $CbOldVolumeControl.Height + $DistanceBetweenButtons
    $CbPhotoViewer = New-CheckBox -Text "Enable Photo Viewer" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $CbPhotoViewer.Location.Y + $CbPhotoViewer.Height + $DistanceBetweenButtons
    $CbSearchIdx = New-CheckBox -Text "Enable Search Indexing" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $CbSearchIdx.Location.Y + $CbSearchIdx.Height + $DistanceBetweenButtons
    $CbTelemetry = New-CheckBox -Text "Enable Telemetry" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $CbTelemetry.Location.Y + $CbTelemetry.Height + $DistanceBetweenButtons
    $CbXboxGameBarAndDVR = New-CheckBox -Text "Enable Xbox GameBar/DVR" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $CbXboxGameBarAndDVR.Location.Y + $CbXboxGameBarAndDVR.Height + $DistanceBetweenButtons
    $ClMiscFeatures = New-Label -Text "Miscellaneous Features" -Width $PanelWidth -Height $CaptionLabelHeight -LocationX 0 -LocationY $NextYLocation

    $NextYLocation = $ClMiscFeatures.Location.Y + $ClMiscFeatures.Height + $DistanceBetweenButtons
    $CbGodMode = New-CheckBox -Text "Enable God Mode" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $CbGodMode.Location.Y + $CbGodMode.Height + $DistanceBetweenButtons
    $CbTakeOwnership = New-CheckBox -Text "Enable Take Ownership menu" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $CbTakeOwnership.Location.Y + $CbTakeOwnership.Height + $DistanceBetweenButtons
    $CbShutdownPCShortcut = New-CheckBox -Text "Enable Shutdown PC shortcut" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    # ==> T2 Panel 1
    $CurrentPanelIndex = 0
    $T2Panel1 = New-Panel -Width $PanelWidth -Height $SoftwareInstallHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $CurrentPanelIndex++
    $T2Panel2 = New-Panel -Width $PanelWidth -Height $SoftwareInstallHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $CurrentPanelIndex++
    $T2Panel3 = New-Panel -Width $PanelWidth -Height $SoftwareInstallHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0
    $CurrentPanelIndex++
    $T2Panel4 = New-Panel -Width $PanelWidth -Height $SoftwareInstallHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -LocationY 0

    $TlSoftwareInstall = New-Label -Text "Software Install" -Width $TotalWidth -Height $TitleLabelHeight -LocationX 0 -LocationY $TitleLabelY -FontSize $Header1 -FontStyle "Bold" -ForeColor $WinBlue

    $NextYLocation = $TlSoftwareInstall.Location.Y + $TlSoftwareInstall.Height + $DistanceBetweenButtons
    $ClSoftwareInstall = New-Label -Text "Package Managers: Winget and Chocolatey" -Width $TotalWidth -Height $CaptionLabelHeight -LocationX 0 -LocationY $NextYLocation -ForeColor $White

    $NextYLocation = $ClSoftwareInstall.Location.Y + $ClSoftwareInstall.Height + $DistanceBetweenButtons
    $ClCpuGpuDrivers = New-Label -Text "CPU/GPU Drivers" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClCpuGpuDrivers.Location.Y + $ClCpuGpuDrivers.Height + $DistanceBetweenButtons
    $InstallAmdRyzenChipsetDriver = New-CheckBox -Text "AMD Ryzen Chipset Driver" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation -ForeColor $AmdRyzenPrimaryColor

    $NextYLocation = $InstallAmdRyzenChipsetDriver.Location.Y + $InstallAmdRyzenChipsetDriver.Height + $DistanceBetweenButtons
    $InstallIntelDSA = New-CheckBox -Text "Intel® DSA" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation -ForeColor $IntelPrimaryColor

    $NextYLocation = $InstallIntelDSA.Location.Y + $InstallIntelDSA.Height + $DistanceBetweenButtons
    $InstallNvidiaGeForceExperience = New-CheckBox -Text "NVIDIA GeForce Experience" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation -ForeColor $NVIDIAPrimaryColor

    $NextYLocation = $InstallNvidiaGeForceExperience.Location.Y + $InstallNvidiaGeForceExperience.Height + $DistanceBetweenButtons
    $InstallNVCleanstall = New-CheckBox -Text "NVCleanstall" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallNVCleanstall.Location.Y + $InstallNVCleanstall.Height + $DistanceBetweenButtons
    $ClApplicationRequirements = New-Label -Text "Application Requirements" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClApplicationRequirements.Location.Y + $ClApplicationRequirements.Height + $DistanceBetweenButtons
    $InstallDirectX = New-CheckBox -Text "DirectX End-User Runtime" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallDirectX.Location.Y + $InstallDirectX.Height + $DistanceBetweenButtons
    $InstallMsDotNetFramework = New-CheckBox -Text "Microsoft .NET Framework" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallMsDotNetFramework.Location.Y + $InstallMsDotNetFramework.Height + $DistanceBetweenButtons
    $InstallMsVCppX64 = New-CheckBox -Text "MSVC++ 2005-2022 Redist (x64)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallMsVCppX64.Location.Y + $InstallMsVCppX64.Height + $DistanceBetweenButtons
    $InstallMsVCppX86 = New-CheckBox -Text "MSVC++ 2005-2022 Redist (x86)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallMsVCppX86.Location.Y + $InstallMsVCppX86.Height + $DistanceBetweenButtons
    $ClFileCompression = New-Label -Text "File Compression" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClFileCompression.Location.Y + $ClFileCompression.Height + $DistanceBetweenButtons
    $Install7Zip = New-CheckBox -Text "7-Zip" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $Install7Zip.Location.Y + $Install7Zip.Height + $DistanceBetweenButtons
    $InstallWinRar = New-CheckBox -Text "WinRAR (Trial)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallWinRar.Location.Y + $InstallWinRar.Height + $DistanceBetweenButtons
    $ClDocuments = New-Label -Text "Document Editors/Readers" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClDocuments.Location.Y + $ClDocuments.Height + $DistanceBetweenButtons
    $InstallAdobeReaderDC = New-CheckBox -Text "Adobe Reader DC (x64)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallAdobeReaderDC.Location.Y + $InstallAdobeReaderDC.Height + $DistanceBetweenButtons
    $InstallLibreOffice = New-CheckBox -Text "LibreOffice" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallLibreOffice.Location.Y + $InstallLibreOffice.Height + $DistanceBetweenButtons
    $InstallOnlyOffice = New-CheckBox -Text "ONLYOFFICE DesktopEditors" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallOnlyOffice.Location.Y + $InstallOnlyOffice.Height + $DistanceBetweenButtons
    $InstallPowerBi = New-CheckBox -Text "Power BI" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallPowerBi.Location.Y + $InstallPowerBi.Height + $DistanceBetweenButtons
    $InstallSumatraPDF = New-CheckBox -Text "Sumatra PDF" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallSumatraPDF.Location.Y + $InstallSumatraPDF.Height + $DistanceBetweenButtons
    $ClTorrent = New-Label -Text "Torrent" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClTorrent.Location.Y + $ClTorrent.Height + $DistanceBetweenButtons
    $InstallqBittorrent = New-CheckBox -Text "qBittorrent" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallqBittorrent.Location.Y + $InstallqBittorrent.Height + $DistanceBetweenButtons
    $ClAcademicResearch = New-Label -Text "Academic Research" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClAcademicResearch.Location.Y + $ClAcademicResearch.Height + $DistanceBetweenButtons
    $InstallZotero = New-CheckBox -Text "Zotero" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallZotero.Location.Y + $InstallZotero.Height + $DistanceBetweenButtons
    $Cl2fa = New-Label -Text "2-Factor Authentication" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $Cl2fa.Location.Y + $Cl2fa.Height + $DistanceBetweenButtons
    $InstallTwilioAuthy = New-CheckBox -Text "Twilio Authy" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallTwilioAuthy.Location.Y + $InstallTwilioAuthy.Height + $DistanceBetweenButtons
    $ClBootableUsb = New-Label -Text "Bootable USB" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClBootableUsb.Location.Y + $ClBootableUsb.Height + $DistanceBetweenButtons
    $InstallBalenaEtcher = New-CheckBox -Text "Etcher" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallBalenaEtcher.Location.Y + $InstallBalenaEtcher.Height + $DistanceBetweenButtons
    $InstallRufus = New-CheckBox -Text "Rufus" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallRufus.Location.Y + $InstallRufus.Height + $DistanceBetweenButtons
    $InstallVentoy = New-CheckBox -Text "Ventoy" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallVentoy.Location.Y + $InstallVentoy.Height + $DistanceBetweenButtons
    $ClVirtualMachines = New-Label -Text "Virtual Machines" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClVirtualMachines.Location.Y + $ClVirtualMachines.Height + $DistanceBetweenButtons
    $InstallOracleVirtualBox = New-CheckBox -Text "Oracle VM VirtualBox" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallOracleVirtualBox.Location.Y + $InstallOracleVirtualBox.Height + $DistanceBetweenButtons
    $InstallQemu = New-CheckBox -Text "QEMU" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallQemu.Location.Y + $InstallQemu.Height + $DistanceBetweenButtons
    $InstallVmWarePlayer = New-CheckBox -Text "VMware Workstation Player" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallVmWarePlayer.Location.Y + $InstallVmWarePlayer.Height + $DistanceBetweenButtons
    $ClCloudStorage = New-Label -Text "Cloud Storage" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClCloudStorage.Location.Y + $ClCloudStorage.Height + $DistanceBetweenButtons
    $InstallDropbox = New-CheckBox -Text "Dropbox" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallDropbox.Location.Y + $InstallDropbox.Height + $DistanceBetweenButtons
    $InstallGoogleDrive = New-CheckBox -Text "Google Drive" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    # ==> T2 Panel 2
    $NextYLocation = $ClSoftwareInstall.Location.Y + $ClSoftwareInstall.Height + $DistanceBetweenButtons
    $InstallSelected = New-Button -Text "Install Selected" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation -FontStyle "Bold"

    $NextYLocation = $InstallSelected.Location.Y + $InstallSelected.Height + $DistanceBetweenButtons
    $ClWebBrowsers = New-Label -Text "Web Browsers" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClWebBrowsers.Location.Y + $ClWebBrowsers.Height + $DistanceBetweenButtons
    $InstallBraveBrowser = New-CheckBox -Text "Brave Browser" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallBraveBrowser.Location.Y + $InstallBraveBrowser.Height + $DistanceBetweenButtons
    $InstallGoogleChrome = New-CheckBox -Text "Google Chrome" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallGoogleChrome.Location.Y + $InstallGoogleChrome.Height + $DistanceBetweenButtons
    $InstallMozillaFirefox = New-CheckBox -Text "Mozilla Firefox" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallMozillaFirefox.Location.Y + $InstallMozillaFirefox.Height + $DistanceBetweenButtons
    $ClAudioVideoTools = New-Label -Text "Audio/Video Tools" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClAudioVideoTools.Location.Y + $ClAudioVideoTools.Height + $DistanceBetweenButtons
    $InstallAudacity = New-CheckBox -Text "Audacity (Editor)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallAudacity.Location.Y + $InstallAudacity.Height + $DistanceBetweenButtons
    $InstallMpcHc = New-CheckBox -Text "MPC-HC from clsid2 (Player)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallMpcHc.Location.Y + $InstallMpcHc.Height + $DistanceBetweenButtons
    $InstallVlc = New-CheckBox -Text "VLC (Player)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallVlc.Location.Y + $InstallVlc.Height + $DistanceBetweenButtons
    $ClImageTools = New-Label -Text "Image Tools" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClImageTools.Location.Y + $ClImageTools.Height + $DistanceBetweenButtons
    $InstallGimp = New-CheckBox -Text "GIMP" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallGimp.Location.Y + $InstallGimp.Height + $DistanceBetweenButtons
    $InstallInkscape = New-CheckBox -Text "Inkscape" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallInkscape.Location.Y + $InstallInkscape.Height + $DistanceBetweenButtons
    $InstallIrfanView = New-CheckBox -Text "IrfanView" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallIrfanView.Location.Y + $InstallIrfanView.Height + $DistanceBetweenButtons
    $InstallKrita = New-CheckBox -Text "Krita" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallKrita.Location.Y + $InstallKrita.Height + $DistanceBetweenButtons
    $InstallPaintNet = New-CheckBox -Text "Paint.NET" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallPaintNet.Location.Y + $InstallPaintNet.Height + $DistanceBetweenButtons
    $InstallShareX = New-CheckBox -Text "ShareX (Screenshots/GIFs)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallShareX.Location.Y + $InstallShareX.Height + $DistanceBetweenButtons
    $ClStreamingServices = New-Label -Text "Streaming Services" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClStreamingServices.Location.Y + $ClStreamingServices.Height + $DistanceBetweenButtons
    $InstallAmazonPrimeVideo = New-CheckBox -Text "Amazon Prime Video" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallAmazonPrimeVideo.Location.Y + $InstallAmazonPrimeVideo.Height + $DistanceBetweenButtons
    $InstallDisneyPlus = New-CheckBox -Text "Disney+" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallDisneyPlus.Location.Y + $InstallDisneyPlus.Height + $DistanceBetweenButtons
    $InstallNetflix = New-CheckBox -Text "Netflix" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallNetflix.Location.Y + $InstallNetflix.Height + $DistanceBetweenButtons
    $InstallSpotify = New-CheckBox -Text "Spotify" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallSpotify.Location.Y + $InstallSpotify.Height + $DistanceBetweenButtons
    $ClPlanningProductivity = New-Label -Text "Planning/Productivity" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClPlanningProductivity.Location.Y + $ClPlanningProductivity.Height + $DistanceBetweenButtons
    $InstallNotion = New-CheckBox -Text "Notion" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallNotion.Location.Y + $InstallNotion.Height + $DistanceBetweenButtons
    $InstallObsidian = New-CheckBox -Text "Obsidian" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallObsidian.Location.Y + $InstallObsidian.Height + $DistanceBetweenButtons
    $ClUtilities = New-Label -Text "⚒ Utilities" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClUtilities.Location.Y + $ClUtilities.Height + $DistanceBetweenButtons
    $InstallCpuZ = New-CheckBox -Text "CPU-Z" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallCpuZ.Location.Y + $InstallCpuZ.Height + $DistanceBetweenButtons
    $InstallCrystalDiskInfo = New-CheckBox -Text "Crystal Disk Info" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallCrystalDiskInfo.Location.Y + $InstallCrystalDiskInfo.Height + $DistanceBetweenButtons
    $InstallCrystalDiskMark = New-CheckBox -Text "Crystal Disk Mark" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallCrystalDiskMark.Location.Y + $InstallCrystalDiskMark.Height + $DistanceBetweenButtons
    $InstallGpuZ = New-CheckBox -Text "GPU-Z" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallGpuZ.Location.Y + $InstallGpuZ.Height + $DistanceBetweenButtons
    $InstallHwInfo = New-CheckBox -Text "HWiNFO" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallHwInfo.Location.Y + $InstallHwInfo.Height + $DistanceBetweenButtons
    $ClNetworkManagement = New-Label -Text "Network Management" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClNetworkManagement.Location.Y + $ClNetworkManagement.Height + $DistanceBetweenButtons
    $InstallHamachi = New-CheckBox -Text "Hamachi (LAN)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallHamachi.Location.Y + $InstallHamachi.Height + $DistanceBetweenButtons
    $InstallPuTty = New-CheckBox -Text "PuTTY" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallPuTty.Location.Y + $InstallPuTty.Height + $DistanceBetweenButtons
    $InstallRadminVpn = New-CheckBox -Text "Radmin VPN (LAN)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallRadminVpn.Location.Y + $InstallRadminVpn.Height + $DistanceBetweenButtons
    $InstallWinScp = New-CheckBox -Text "WinSCP" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallWinScp.Location.Y + $InstallWinScp.Height + $DistanceBetweenButtons
    $InstallWireshark = New-CheckBox -Text "Wireshark" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    # ==> T2 Panel 3
    $NextYLocation = $ClSoftwareInstall.Location.Y + $ClSoftwareInstall.Height + $DistanceBetweenButtons
    $UninstallMode = New-Button -Text "[OFF] Uninstall Mode" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation -FontStyle "Bold"

    $NextYLocation = $UninstallMode.Location.Y + $UninstallMode.Height + $DistanceBetweenButtons
    $ClCommunication = New-Label -Text "Communication" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClCommunication.Location.Y + $ClCommunication.Height + $DistanceBetweenButtons
    $InstallDiscord = New-CheckBox -Text "Discord" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallDiscord.Location.Y + $InstallDiscord.Height + $DistanceBetweenButtons
    $InstallMSTeams = New-CheckBox -Text "Microsoft Teams" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallMSTeams.Location.Y + $InstallMSTeams.Height + $DistanceBetweenButtons
    $InstallRocketChat = New-CheckBox -Text "Rocket Chat" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallRocketChat.Location.Y + $InstallRocketChat.Height + $DistanceBetweenButtons
    $InstallSignal = New-CheckBox -Text "Signal" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallSignal.Location.Y + $InstallSignal.Height + $DistanceBetweenButtons
    $InstallSkype = New-CheckBox -Text "Skype" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallSkype.Location.Y + $InstallSkype.Height + $DistanceBetweenButtons
    $InstallSlack = New-CheckBox -Text "Slack" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallSlack.Location.Y + $InstallSlack.Height + $DistanceBetweenButtons
    $InstallTelegramDesktop = New-CheckBox -Text "Telegram Desktop" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallTelegramDesktop.Location.Y + $InstallTelegramDesktop.Height + $DistanceBetweenButtons
    $InstallWhatsAppDesktop = New-CheckBox -Text "WhatsApp Desktop" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallWhatsAppDesktop.Location.Y + $InstallWhatsAppDesktop.Height + $DistanceBetweenButtons
    $InstallZoom = New-CheckBox -Text "Zoom" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallZoom.Location.Y + $InstallZoom.Height + $DistanceBetweenButtons
    $ClGaming = New-Label -Text "Gaming" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClGaming.Location.Y + $ClGaming.Height + $DistanceBetweenButtons
    $InstallBorderlessGaming = New-CheckBox -Text "Borderless Gaming" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallBorderlessGaming.Location.Y + $InstallBorderlessGaming.Height + $DistanceBetweenButtons
    $InstallEADesktop = New-CheckBox -Text "EA Desktop" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallEADesktop.Location.Y + $InstallEADesktop.Height + $DistanceBetweenButtons
    $InstallEpicGamesLauncher = New-CheckBox -Text "Epic Games Launcher" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallEpicGamesLauncher.Location.Y + $InstallEpicGamesLauncher.Height + $DistanceBetweenButtons
    $InstallGogGalaxy = New-CheckBox -Text "GOG Galaxy" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallGogGalaxy.Location.Y + $InstallGogGalaxy.Height + $DistanceBetweenButtons
    $InstallSteam = New-CheckBox -Text "Steam" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallSteam.Location.Y + $InstallSteam.Height + $DistanceBetweenButtons
    $InstallUbisoftConnect = New-CheckBox -Text "Ubisoft Connect" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallUbisoftConnect.Location.Y + $InstallUbisoftConnect.Height + $DistanceBetweenButtons
    $ClRemoteConnection = New-Label -Text "Remote Connection" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClRemoteConnection.Location.Y + $ClRemoteConnection.Height + $DistanceBetweenButtons
    $InstallAnyDesk = New-CheckBox -Text "AnyDesk" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallAnyDesk.Location.Y + $InstallAnyDesk.Height + $DistanceBetweenButtons
    $InstallParsec = New-CheckBox -Text "Parsec" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallParsec.Location.Y + $InstallParsec.Height + $DistanceBetweenButtons
    $InstallScrCpy = New-CheckBox -Text "ScrCpy (Android)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallScrCpy.Location.Y + $InstallScrCpy.Height + $DistanceBetweenButtons
    $InstallTeamViewer = New-CheckBox -Text "Team Viewer" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallTeamViewer.Location.Y + $InstallTeamViewer.Height + $DistanceBetweenButtons
    $ClRecordingAndStreaming = New-Label -Text "Recording and Streaming" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClRecordingAndStreaming.Location.Y + $ClRecordingAndStreaming.Height + $DistanceBetweenButtons
    $InstallElgatoStreamDeck = New-CheckBox -Text "Elgato Stream Deck" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallElgatoStreamDeck.Location.Y + $InstallElgatoStreamDeck.Height + $DistanceBetweenButtons
    $InstallHandBrake = New-CheckBox -Text "HandBrake (Transcode)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallHandBrake.Location.Y + $InstallHandBrake.Height + $DistanceBetweenButtons
    $InstallObsStudio = New-CheckBox -Text "OBS Studio" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallObsStudio.Location.Y + $InstallObsStudio.Height + $DistanceBetweenButtons
    $InstallStreamlabs = New-CheckBox -Text "Streamlabs" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallStreamlabs.Location.Y + $InstallStreamlabs.Height + $DistanceBetweenButtons
    $InstallVoicemod = New-CheckBox -Text "Voicemod" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallVoicemod.Location.Y + $InstallVoicemod.Height + $DistanceBetweenButtons
    $ClEmulation = New-Label -Text "Emulation" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClEmulation.Location.Y + $ClEmulation.Height + $DistanceBetweenButtons
    $InstallBSnesHd = New-CheckBox -Text "BSnes HD (SNES)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallBSnesHd.Location.Y + $InstallBSnesHd.Height + $DistanceBetweenButtons
    $InstallCemu = New-CheckBox -Text "Cemu (Wii U)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallCemu.Location.Y + $InstallCemu.Height + $DistanceBetweenButtons
    $InstallDolphin = New-CheckBox -Text "Dolphin Stable (GC/Wii)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallDolphin.Location.Y + $InstallDolphin.Height + $DistanceBetweenButtons
    $InstallKegaFusion = New-CheckBox -Text "Kega Fusion (Sega Genesis)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallKegaFusion.Location.Y + $InstallKegaFusion.Height + $DistanceBetweenButtons
    $InstallMGba = New-CheckBox -Text "mGBA (GBA)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallMGba.Location.Y + $InstallMGba.Height + $DistanceBetweenButtons
    $InstallPCSX2 = New-CheckBox -Text "PCSX2 Stable (PS2 | Portable)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallPCSX2.Location.Y + $InstallPCSX2.Height + $DistanceBetweenButtons
    $InstallPPSSPP = New-CheckBox -Text "PPSSPP (PSP)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallPPSSPP.Location.Y + $InstallPPSSPP.Height + $DistanceBetweenButtons
    $InstallProject64 = New-CheckBox -Text "Project64 Dev (N64)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallProject64.Location.Y + $InstallProject64.Height + $DistanceBetweenButtons
    $InstallRetroArch = New-CheckBox -Text "RetroArch (All In One)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallRetroArch.Location.Y + $InstallRetroArch.Height + $DistanceBetweenButtons
    $InstallSnes9x = New-CheckBox -Text "Snes9x (SNES)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    # ==> T2 Panel 4
    $NextYLocation = $ClSoftwareInstall.Location.Y + $ClSoftwareInstall.Height + $DistanceBetweenButtons
    $ClTextEditors = New-Label -Text "Text Editors/IDEs" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClTextEditors.Location.Y + $ClTextEditors.Height + $DistanceBetweenButtons
    $InstallAtom = New-CheckBox -Text "Atom" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallAtom.Location.Y + $InstallAtom.Height + $DistanceBetweenButtons
    $InstallJetBrainsToolbox = New-CheckBox -Text "JetBrains Toolbox" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallJetBrainsToolbox.Location.Y + $InstallJetBrainsToolbox.Height + $DistanceBetweenButtons
    $InstallNotepadPlusPlus = New-CheckBox -Text "Notepad++" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallNotepadPlusPlus.Location.Y + $InstallNotepadPlusPlus.Height + $DistanceBetweenButtons
    $InstallVisualStudioCommunity = New-CheckBox -Text "Visual Studio 2022 Community" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallVisualStudioCommunity.Location.Y + $InstallVisualStudioCommunity.Height + $DistanceBetweenButtons
    $InstallVSCode = New-CheckBox -Text "VS Code" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallVSCode.Location.Y + $InstallVSCode.Height + $DistanceBetweenButtons
    $InstallVSCodium = New-CheckBox -Text "VS Codium" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallVSCodium.Location.Y + $InstallVSCodium.Height + $DistanceBetweenButtons
    $ClWsl = New-Label -Text "Windows Subsystem For Linux" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClWsl.Location.Y + $ClWsl.Height + $DistanceBetweenButtons
    $InstallWSLgOrPreview = New-CheckBox -Text "Install WSLg/Preview" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation -ForeColor $WinBlue

    $NextYLocation = $InstallWSLgOrPreview.Location.Y + $InstallWSLgOrPreview.Height + $DistanceBetweenButtons
    $InstallArchWSL = New-CheckBox -Text "ArchWSL (x64)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation -ForeColor $WinBlue

    $NextYLocation = $InstallArchWSL.Location.Y + $InstallArchWSL.Height + $DistanceBetweenButtons
    $InstallDebian = New-CheckBox -Text "Debian GNU/Linux" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallDebian.Location.Y + $InstallDebian.Height + $DistanceBetweenButtons
    $InstallKaliLinux = New-CheckBox -Text "Kali Linux Rolling" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallKaliLinux.Location.Y + $InstallKaliLinux.Height + $DistanceBetweenButtons
    $InstallOpenSuse = New-CheckBox -Text "Open SUSE 42" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallOpenSuse.Location.Y + $InstallOpenSuse.Height + $DistanceBetweenButtons
    $InstallSles = New-CheckBox -Text "SLES v12" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallSles.Location.Y + $InstallSles.Height + $DistanceBetweenButtons
    $InstallUbuntu = New-CheckBox -Text "Ubuntu" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallUbuntu.Location.Y + $InstallUbuntu.Height + $DistanceBetweenButtons
    $InstallUbuntu16Lts = New-CheckBox -Text "Ubuntu 16.04 LTS" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallUbuntu16Lts.Location.Y + $InstallUbuntu16Lts.Height + $DistanceBetweenButtons
    $InstallUbuntu18Lts = New-CheckBox -Text "Ubuntu 18.04 LTS" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallUbuntu18Lts.Location.Y + $InstallUbuntu18Lts.Height + $DistanceBetweenButtons
    $InstallUbuntu20Lts = New-CheckBox -Text "Ubuntu 20.04 LTS" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallUbuntu20Lts.Location.Y + $InstallUbuntu20Lts.Height + $DistanceBetweenButtons
    $ClDevelopment = New-Label -Text "⌨ Development on Windows" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $ClDevelopment.Location.Y + $ClDevelopment.Height + $DistanceBetweenButtons
    $InstallWindowsTerminal = New-CheckBox -Text "Windows Terminal" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallWindowsTerminal.Location.Y + $InstallWindowsTerminal.Height + $DistanceBetweenButtons
    $InstallNerdFonts = New-CheckBox -Text "Install Nerd Fonts" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation -ForeColor $WinBlue

    $NextYLocation = $InstallNerdFonts.Location.Y + $InstallNerdFonts.Height + $DistanceBetweenButtons
    $InstallGitGnupgSshSetup = New-CheckBox -Text "Git + GnuPG + SSH (Setup)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation -ForeColor $WinBlue

    $NextYLocation = $InstallGitGnupgSshSetup.Location.Y + $InstallGitGnupgSshSetup.Height + $DistanceBetweenButtons
    $InstallAdb = New-CheckBox -Text "Android Debug Bridge (ADB)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallAdb.Location.Y + $InstallAdb.Height + $DistanceBetweenButtons
    $InstallAndroidStudio = New-CheckBox -Text "Android Studio" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallAndroidStudio.Location.Y + $InstallAndroidStudio.Height + $DistanceBetweenButtons
    $InstallDockerDesktop = New-CheckBox -Text "Docker Desktop" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallDockerDesktop.Location.Y + $InstallDockerDesktop.Height + $DistanceBetweenButtons
    $InstallInsomnia = New-CheckBox -Text "Insomnia" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallInsomnia.Location.Y + $InstallInsomnia.Height + $DistanceBetweenButtons
    $InstallJavaJdks = New-CheckBox -Text "Java - Adoptium JDK 8/11/18" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallJavaJdks.Location.Y + $InstallJavaJdks.Height + $DistanceBetweenButtons
    $InstallJavaJre = New-CheckBox -Text "Java - Oracle JRE" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallJavaJre.Location.Y + $InstallJavaJre.Height + $DistanceBetweenButtons
    $InstallMySql = New-CheckBox -Text "MySQL" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallMySql.Location.Y + $InstallMySql.Height + $DistanceBetweenButtons
    $InstallNodeJs = New-CheckBox -Text "NodeJS" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallNodeJs.Location.Y + $InstallNodeJs.Height + $DistanceBetweenButtons
    $InstallNodeJsLts = New-CheckBox -Text "NodeJS LTS" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallNodeJsLts.Location.Y + $InstallNodeJsLts.Height + $DistanceBetweenButtons
    $InstallPostgreSql = New-CheckBox -Text "PostgreSQL" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallPostgreSql.Location.Y + $InstallPostgreSql.Height + $DistanceBetweenButtons
    $InstallPython3 = New-CheckBox -Text "Python 3" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallPython3.Location.Y + $InstallPython3.Height + $DistanceBetweenButtons
    $InstallPythonAnaconda3 = New-CheckBox -Text "Python - Anaconda3" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallPythonAnaconda3.Location.Y + $InstallPythonAnaconda3.Height + $DistanceBetweenButtons
    $InstallRuby = New-CheckBox -Text "Ruby" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallRuby.Location.Y + $InstallRuby.Height + $DistanceBetweenButtons
    $InstallRubyMsys = New-CheckBox -Text "Ruby (MSYS2)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallRubyMsys.Location.Y + $InstallRubyMsys.Height + $DistanceBetweenButtons
    $InstallRustGnu = New-CheckBox -Text "Rust (GNU)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    $NextYLocation = $InstallRustGnu.Location.Y + $InstallRustGnu.Height + $DistanceBetweenButtons
    $InstallRustMsvc = New-CheckBox -Text "Rust (MSVC)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY $NextYLocation

    # Add all Panels to the Form (Screen)
    $Form.Controls.AddRange(@($FormTabControl))
    # Tabs
    $FormTabControl.Controls.AddRange(@($TabSystemTweaks, $TabSoftwareInstall))
    $TabSystemTweaks.Controls.AddRange(@($TlSystemTweaks, $ClSystemTweaks, $T1Panel1, $T1Panel2))
    $TabSoftwareInstall.Controls.AddRange(@($TlSoftwareInstall, $ClSoftwareInstall, $T2Panel1, $T2Panel2, $T2Panel3, $T2Panel4))
    # Add Elements to each Panel
    $T1Panel1.Controls.AddRange(@($ClDebloatTools, $ApplyTweaks, $UndoTweaks, $RemoveXbox, $InstallOneDrive, $ReinstallBloatApps, $RepairWindows, $ShowDebloatInfo, $PictureBox1))
    $T1Panel2.Controls.AddRange(@($ClCustomizeFeatures))
    $T1Panel2.Controls.AddRange(@($CbDarkTheme, $CbActivityHistory, $CbBackgroundsApps, $CbClipboardHistory, $CbCortana, $CbOldVolumeControl, $CbPhotoViewer, $CbSearchIdx, $CbTelemetry, $CbXboxGameBarAndDVR))
    $T1Panel2.Controls.AddRange(@($ClMiscFeatures, $CbGodMode, $CbTakeOwnership, $CbShutdownPCShortcut))

    $T2Panel1.Controls.AddRange(@($ClCpuGpuDrivers, $InstallAmdRyzenChipsetDriver, $InstallIntelDSA, $InstallNvidiaGeForceExperience, $InstallNVCleanstall))
    $T2Panel1.Controls.AddRange(@($ClApplicationRequirements, $InstallDirectX, $InstallMsDotNetFramework, $InstallMsVCppX64, $InstallMsVCppX86))
    $T2Panel1.Controls.AddRange(@($ClFileCompression, $Install7Zip, $InstallWinRar))
    $T2Panel1.Controls.AddRange(@($ClDocuments, $InstallAdobeReaderDC, $InstallLibreOffice, $InstallOnlyOffice, $InstallPowerBi, $InstallSumatraPDF))
    $T2Panel1.Controls.AddRange(@($ClTorrent, $InstallqBittorrent))
    $T2Panel1.Controls.AddRange(@($ClAcademicResearch, $InstallZotero))
    $T2Panel1.Controls.AddRange(@($Cl2fa, $InstallTwilioAuthy))
    $T2Panel1.Controls.AddRange(@($ClBootableUsb, $InstallBalenaEtcher, $InstallRufus, $InstallVentoy))
    $T2Panel1.Controls.AddRange(@($ClVirtualMachines, $InstallOracleVirtualBox, $InstallQemu, $InstallVmWarePlayer))
    $T2Panel1.Controls.AddRange(@($ClCloudStorage, $InstallDropbox, $InstallGoogleDrive))
    $T2Panel2.Controls.AddRange(@($InstallSelected))
    $T2Panel2.Controls.AddRange(@($ClWebBrowsers, $InstallBraveBrowser, $InstallGoogleChrome, $InstallMozillaFirefox))
    $T2Panel2.Controls.AddRange(@($ClAudioVideoTools, $InstallAudacity, $InstallMpcHc, $InstallVlc))
    $T2Panel2.Controls.AddRange(@($ClImageTools, $InstallGimp, $InstallInkscape, $InstallIrfanView, $InstallKrita, $InstallPaintNet, $InstallShareX))
    $T2Panel2.Controls.AddRange(@($ClStreamingServices, $InstallAmazonPrimeVideo, $InstallDisneyPlus, $InstallNetflix, $InstallSpotify))
    $T2Panel2.Controls.AddRange(@($ClPlanningProductivity, $InstallNotion, $InstallObsidian))
    $T2Panel2.Controls.AddRange(@($ClUtilities, $InstallCpuZ, $InstallCrystalDiskInfo, $InstallCrystalDiskMark, $InstallGpuZ, $InstallHwInfo))
    $T2Panel2.Controls.AddRange(@($ClNetworkManagement, $InstallHamachi, $InstallPuTty, $InstallRadminVpn, $InstallWinScp, $InstallWireshark))
    $T2Panel3.Controls.AddRange(@($UninstallMode))
    $T2Panel3.Controls.AddRange(@($ClCommunication, $InstallDiscord, $InstallMSTeams, $InstallRocketChat, $InstallSignal, $InstallSkype, $InstallSlack, $InstallTelegramDesktop, $InstallWhatsAppDesktop, $InstallZoom))
    $T2Panel3.Controls.AddRange(@($ClGaming, $InstallBorderlessGaming, $InstallEADesktop, $InstallEpicGamesLauncher, $InstallGogGalaxy, $InstallSteam, $InstallUbisoftConnect))
    $T2Panel3.Controls.AddRange(@($ClRemoteConnection, $InstallAnyDesk, $InstallParsec, $InstallScrCpy, $InstallTeamViewer))
    $T2Panel3.Controls.AddRange(@($ClRecordingAndStreaming, $InstallElgatoStreamDeck, $InstallHandBrake, $InstallObsStudio, $InstallStreamlabs, $InstallVoicemod))
    $T2Panel3.Controls.AddRange(@($ClEmulation, $InstallBSnesHd, $InstallCemu, $InstallDolphin, $InstallKegaFusion, $InstallMGba, $InstallPCSX2, $InstallPPSSPP, $InstallProject64, $InstallRetroArch, $InstallSnes9x))
    $T2Panel4.Controls.AddRange(@($ClTextEditors, $InstallAtom, $InstallJetBrainsToolbox, $InstallNotepadPlusPlus, $InstallVisualStudioCommunity, $InstallVSCode, $InstallVSCodium))
    $T2Panel4.Controls.AddRange(@($ClWsl, $InstallWSLgOrPreview, $InstallArchWSL, $InstallDebian, $InstallKaliLinux, $InstallOpenSuse, $InstallSles, $InstallUbuntu, $InstallUbuntu16Lts, $InstallUbuntu18Lts, $InstallUbuntu20Lts))
    $T2Panel4.Controls.AddRange(@($ClDevelopment, $InstallWindowsTerminal, $InstallNerdFonts, $InstallGitGnupgSshSetup, $InstallAdb, $InstallAndroidStudio, $InstallDockerDesktop, $InstallInsomnia, $InstallJavaJdks, $InstallJavaJre, $InstallMySql, $InstallNodeJs, $InstallNodeJsLts, $InstallPostgreSql, $InstallPython3, $InstallPythonAnaconda3, $InstallRuby, $InstallRubyMsys, $InstallRustGnu, $InstallRustMsvc))

    # <===== CLICK EVENTS =====>

    $ApplyTweaks.Add_Click( {
            $Scripts = @(
                # [Recommended order]
                "backup-system.ps1",
                "silent-debloat-softwares.ps1",
                "optimize-task-scheduler.ps1",
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
            $Form.Update()
            $Script:NeedRestart = $true
        })

    $UndoTweaks.Add_Click( {
            $Global:Revert = $true
            $Scripts = @(
                "optimize-task-scheduler.ps1",
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
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("remove-xbox.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
            $PictureBox1.imageLocation = "$PSScriptRoot\src\assets\script-logo2.png"
            $Form.Update()
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

    $CbDarkTheme.Add_Click( {
            If ($CbDarkTheme.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("use-dark-theme.reg") -NoDialog
                $CbDarkTheme.Text = "[ON]  ⚫ Use Dark Theme"
            } Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("use-light-theme.reg") -NoDialog
                $CbDarkTheme.Text = "[OFF] ☀ Use Dark Theme (D.)"
            }
        })

    $CbActivityHistory.Add_Click( {
            If ($CbActivityHistory.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-activity-history.reg") -NoDialog
                $CbActivityHistory.Text = "[ON]  Activity History (Default)"
            } Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-activity-history.reg") -NoDialog
                $CbActivityHistory.Text = "[OFF] Activity History"
            }
        })

    $CbBackgroundsApps.Add_Click( {
            If ($CbBackgroundsApps.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-bg-apps.reg") -NoDialog
                $CbBackgroundsApps.Text = "[ON]  Background Apps (D.)"
            } Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-bg-apps.reg") -NoDialog
                $CbBackgroundsApps.Text = "[OFF] Background Apps"
            }
        })

    $CbClipboardHistory.Add_Click( {
            If ($CbClipboardHistory.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-clipboard-history.reg") -NoDialog
                $CbClipboardHistory.Text = "[ON]  Clipboard History (D.)"
            } Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-clipboard-history.reg") -NoDialog
                $CbClipboardHistory.Text = "[OFF] Clipboard History"
            }
        })

    $CbCortana.Add_Click( {
            If ($CbCortana.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-cortana.reg") -NoDialog
                $CbCortana.Text = "[ON]  Cortana (Default)"
            } Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-cortana.reg") -NoDialog
                $CbCortana.Text = "[OFF] Cortana"
            }
        })

    $CbOldVolumeControl.Add_Click( {
            If ($CbOldVolumeControl.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-old-volume-control.reg") -NoDialog
                $CbOldVolumeControl.Text = "[ON]  Old Volume Control"
            } Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-old-volume-control.reg") -NoDialog
                $CbOldVolumeControl.Text = "[OFF] Old Volume Control (D.)"
            }
        })

    $CbPhotoViewer.Add_Click( {
            If ($CbPhotoViewer.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-photo-viewer.reg") -NoDialog
                $CbPhotoViewer.Text = "[ON]  Photo Viewer"
            } Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-photo-viewer.reg") -NoDialog
                $CbPhotoViewer.Text = "[OFF] Photo Viewer (D.)"
            }
        })

    $CbSearchIdx.Add_Click( {
            If ($CbSearchIdx.CheckState -eq "Checked") {
                Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-search-idx-service.ps1") -NoDialog
                $CbSearchIdx.Text = "[ON]  Search Indexing (Default)"
            } Else {
                Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-search-idx-service.ps1") -NoDialog
                $CbSearchIdx.Text = "[OFF] Search Indexing"
            }
        })

    $CbTelemetry.Add_Click( {
            If ($CbTelemetry.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-telemetry.reg") -NoDialog
                $CbTelemetry.Text = "[ON]  Telemetry (Default)"
            } Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-telemetry.reg") -NoDialog
                $CbTelemetry.Text = "[OFF] Telemetry"
            }
        })

    $CbXboxGameBarAndDVR.Add_Click( {
            If ($CbXboxGameBarAndDVR.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-game-bar-dvr.reg") -NoDialog
                $CbXboxGameBarAndDVR.Text = "[ON]  Xbox GameBar/DVR (D.)"
            } Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-game-bar-dvr.reg") -NoDialog
                $CbXboxGameBarAndDVR.Text = "[OFF] Xbox GameBar/DVR"
            }
        })

    $CbGodMode.Add_Click( {
            If ($CbGodMode.CheckState -eq "Checked") {
                Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-god-mode.ps1") -NoDialog
                $CbGodMode.Text = "[ON]  God Mode"
            } Else {
                Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-god-mode.ps1") -NoDialog
                $CbGodMode.Text = "[OFF] God Mode (Default)"
            }
        })

    $CbTakeOwnership.Add_Click( {
            If ($CbTakeOwnership.CheckState -eq "Checked") {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-take-ownership-context-menu.reg") -NoDialog
                $CbTakeOwnership.Text = "[ON]  Take Ownership menu"
            } Else {
                Open-RegFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-take-ownership-context-menu.reg") -NoDialog
                $CbTakeOwnership.Text = "[OFF] Take Ownership... (D.)"
            }
        })

    $CbShutdownPCShortcut.Add_Click( {
            If ($CbShutdownPCShortcut.CheckState -eq "Checked") {
                Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("enable-shutdown-pc-shortcut.ps1") -NoDialog
                $CbShutdownPCShortcut.Text = "[ON]  Shutdown PC shortcut"
            } Else {
                Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("disable-shutdown-pc-shortcut.ps1") -NoDialog
                $CbShutdownPCShortcut.Text = "[OFF] Shutdown PC... (Default)"
            }
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

            If ($InstallNVCleanstall.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("TechPowerUp.NVCleanstall")
                $InstallNVCleanstall.CheckState = "Unchecked"
            }

            If ($InstallDirectX.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("directx")
                $InstallDirectX.CheckState = "Unchecked"
            }

            If ($InstallMsDotNetFramework.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.dotNetFramework")
                $InstallMsDotNetFramework.CheckState = "Unchecked"
            }

            If ($InstallMsVCppX64.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.AddRange(
                    @(
                        "Microsoft.VC++2005Redist-x64", "Microsoft.VC++2008Redist-x64", "Microsoft.VC++2010Redist-x64",
                        "Microsoft.VC++2012Redist-x64", "Microsoft.VC++2013Redist-x64", "Microsoft.VC++2015-2022Redist-x64"
                    )
                )
                $InstallMsVCppX64.CheckState = "Unchecked"
            }

            If ($InstallMsVCppX86.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.AddRange(
                    @(
                        "Microsoft.VC++2005Redist-x86", "Microsoft.VC++2008Redist-x86", "Microsoft.VC++2010Redist-x86",
                        "Microsoft.VC++2012Redist-x86", "Microsoft.VC++2013Redist-x86", "Microsoft.VC++2015-2022Redist-x86"
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
                $AppsSelected.WingetApps.Add("LibreOffice.LibreOffice")
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

            If ($InstallGoogleDrive.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Google.Drive")
                $InstallGoogleDrive.CheckState = "Unchecked"
            }

            If ($InstallBraveBrowser.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("BraveSoftware.BraveBrowser")
                $InstallBraveBrowser.CheckState = "Unchecked"
            }

            If ($InstallGoogleChrome.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Google.Chrome")
                $InstallGoogleChrome.CheckState = "Unchecked"
            }

            If ($InstallMozillaFirefox.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Mozilla.Firefox")
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

            If ($InstallGpuZ.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("TechPowerUp.GPU-Z")
                $InstallGpuZ.CheckState = "Unchecked"
            }

            If ($InstallHwInfo.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("REALiX.HWiNFO")
                $InstallHwInfo.CheckState = "Unchecked"
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

            If ($InstallVoicemod.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Voicemod.Voicemod")
                $InstallVoicemod.CheckState = "Unchecked"
            }

            If ($InstallBSnesHd.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("bsnes-hd")
                $InstallBSnesHd.CheckState = "Unchecked"
            }

            If ($InstallCemu.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("cemu")
                $InstallCemu.CheckState = "Unchecked"
            }

            If ($InstallDolphin.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("DolphinEmulator.Dolphin")
                $InstallDolphin.CheckState = "Unchecked"
            }

            If ($InstallKegaFusion.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("kega-fusion")
                $InstallKegaFusion.CheckState = "Unchecked"
            }

            If ($InstallMGba.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("JeffreyPfau.mGBA")
                $InstallMGba.CheckState = "Unchecked"
            }

            If ($InstallPCSX2.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("pcsx2.portable")
                $InstallPCSX2.CheckState = "Unchecked"
            }

            If ($InstallPPSSPP.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("PPSSPPTeam.PPSSPP")
                $InstallPPSSPP.CheckState = "Unchecked"
            }

            If ($InstallProject64.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Project64.Project64.Dev")
                $InstallProject64.CheckState = "Unchecked"
            }

            If ($InstallRetroArch.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("retroarch")
                $InstallRetroArch.CheckState = "Unchecked"
            }

            If ($InstallSnes9x.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("snes9x")
                $InstallSnes9x.CheckState = "Unchecked"
            }

            If ($InstallAtom.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("GitHub.Atom")
                $InstallAtom.CheckState = "Unchecked"
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

            If ($InstallWSLgOrPreview.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("install-wslg-or-preview.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
                } Else {
                    $AppsSelected.MSStoreApps.Add("9P9TQF7MRM4R")
                }
                $InstallWSLgOrPreview.CheckState = "Unchecked"
            }

            If ($InstallArchWSL.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("install-archwsl.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
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

            If ($InstallOpenSuse.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("openSUSE-42")
                $InstallOpenSuse.CheckState = "Unchecked"
            }

            If ($InstallSles.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("SLES-12")
                $InstallSles.CheckState = "Unchecked"
            }

            If ($InstallUbuntu.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu")
                $InstallUbuntu.CheckState = "Unchecked"
            }

            If ($InstallUbuntu16Lts.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu-16.04")
                $InstallUbuntu16Lts.CheckState = "Unchecked"
            }

            If ($InstallUbuntu18Lts.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu-18.04")
                $InstallUbuntu18Lts.CheckState = "Unchecked"
            }

            If ($InstallUbuntu20Lts.CheckState -eq "Checked") {
                $AppsSelected.WSLDistros.Add("Ubuntu-20.04")
                $InstallUbuntu20Lts.CheckState = "Unchecked"
            }

            If ($InstallWindowsTerminal.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("Microsoft.WindowsTerminal")
                $InstallWindowsTerminal.CheckState = "Unchecked"
            }

            If ($InstallNerdFonts.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("install-nerd-fonts.ps1")
                }
                $InstallNerdFonts.CheckState = "Unchecked"
            }

            If ($InstallGitGnupgSshSetup.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\utils" -Scripts @("git-gnupg-ssh-keys-setup.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
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
                $AppsSelected.WingetApps.AddRange(@("EclipseAdoptium.Temurin.8", "EclipseAdoptium.Temurin.11", "EclipseAdoptium.Temurin.18"))
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
                $AppsSelected.WingetApps.Add("OpenJS.NodeJSLTS")
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
                    $SoftwareList += "`n" + (Install-Software -Name "Apps from selection" -Packages $AppsSelected.MSStoreApps -ViaMSStore -NoDialog)
                }
                If ($AppsSelected.ChocolateyApps) {
                    $SoftwareList += "`n" + (Install-Software -Name "Apps from selection" -Packages $AppsSelected.ChocolateyApps -ViaChocolatey -NoDialog)
                }
                If ($AppsSelected.WSLDistros) {
                    $SoftwareList += "`n" + (Install-Software -Name "Apps from selection" -Packages $AppsSelected.WSLDistros -ViaWSL -NoDialog)
                }
            } Else {
                If ($AppsSelected.WingetApps) {
                    $SoftwareList += Uninstall-Software -Name "Apps from selection" -Packages $AppsSelected.WingetApps -NoDialog
                }
                If ($AppsSelected.MSStoreApps) {
                    $SoftwareList += "`n" + (Uninstall-Software -Name "Apps from selection" -Packages $AppsSelected.MSStoreApps -ViaMSStore -NoDialog)
                }
                If ($AppsSelected.ChocolateyApps) {
                    $SoftwareList += "`n" + (Uninstall-Software -Name "Apps from selection" -Packages $AppsSelected.ChocolateyApps -ViaChocolatey -NoDialog)
                }
                If ($AppsSelected.WSLDistros) {
                    $SoftwareList += "`n" + (Uninstall-Software -Name "Apps from selection" -Packages $AppsSelected.WSLDistros -ViaWSL -NoDialog)
                }
            }

            Show-Message -Title "$DoneTitle" -Message "$SoftwareList"
            $SoftwareList = ""
        })

    $UninstallMode.Add_Click( {
            If ($UninstallSwitch) {
                $Script:UninstallSwitch = $false
                $InstallSelected.Text = "Install Selected"
                $UninstallMode.Text = "[OFF] Uninstall Mode"
            } Else {
                $Script:UninstallSwitch = $true
                $InstallSelected.Text = "Uninstall Selected"
                $UninstallMode.Text = "[ON]  Uninstall Mode"
            }
        })

    [void] $Form.ShowDialog() # Show the Window
    $Form.Dispose() # When done, dispose of the GUI
}

function Main() {
    Clear-Host
    Request-AdminPrivilege # Check admin rights
    Get-ChildItem -Recurse $PSScriptRoot\*.ps*1 | Unblock-File

    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"download-web-file.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"get-hardware-info.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"ui-helper.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"open-file.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"manage-software.psm1" -Force
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