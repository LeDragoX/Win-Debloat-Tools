# Learned from: https://docs.microsoft.com/en-us/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.1
# Adapted majorly from https://github.com/ChrisTitusTech/win10script and https://github.com/Sycnex/Windows10Debloater
# Take Ownership tweak from: https://www.howtogeek.com/howto/windows-vista/add-take-ownership-to-explorer-right-click-menu-in-vista/

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
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"show-dialog-window.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"start-logging.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\lib\"title-templates.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\utils\"individual-tweaks.psm1" -Force
    Import-Module -DisableNameChecking $PSScriptRoot\src\utils\"install-individual-system-apps.psm1" -Force

    Set-ConsoleStyle            # Makes the console look cooler
    $CurrentFileName = (Split-Path -Path $PSCommandPath -Leaf).Split('.')[0]
    $CurrentFileLastModified = (Get-Item "$(Split-Path -Path $PSCommandPath -Leaf)").LastWriteTimeUtc | Get-Date -Format "yyyy-MM-dd"
    (Get-Item "$(Split-Path -Path $PSCommandPath -Leaf)").LastWriteTimeUtc | Get-Date -Format "yyyy-MM-dd"
    Start-Logging -File $CurrentFileName
    Write-Caption "$CurrentFileName v$CurrentFileLastModified"
    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Root Folder $PSScriptRoot"
    Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts "install-package-managers.ps1" -NoDialog # Install Winget and Chocolatey at the beginning
    Write-ScriptLogo            # Thanks Figlet
    Show-GUI                    # Load the GUI

    Write-Verbose "Restart: $Script:NeedRestart"
    If ($Script:NeedRestart) {
        Request-PcRestart       # Prompt options to Restart the PC
    }
    Stop-Logging
}

function Request-AdminPrivilege() {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

function Show-GUI() {
    Write-Status -Types "@" -Status "Loading GUI Layout..."
    # Loading System Libs
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles() # Rounded Buttons :3

    Set-UIFont # Load the Layout Font
    $ScreenWidth, $ScreenHeight = Get-CurrentResolution # Get the Screen Size
    $ScreenProportion = $ScreenWidth / $ScreenHeight # 16:9 ~1.777...

    $Script:NeedRestart = $false
    $DoneTitle = "Information"
    $DoneMessage = "Process Completed!"

    # <===== PERSONAL LAYOUT =====>

    # To Scroll
    $VerticalScrollWidth = 17

    # To Forms
    If ($ScreenProportion -lt 1.5) {
        $FormWidth = ($ScreenWidth * 0.99) + $VerticalScrollWidth # Small Resolution Width + Scroll Width
        $FormHeight = $ScreenHeight * 0.85
    } ElseIf ($ScreenProportion -lt 2.0) {
        $FormWidth = ($ScreenWidth * 0.85) + $VerticalScrollWidth # Scaled Resolution Width + Scroll Width
        $FormHeight = $ScreenHeight * 0.85
    } ElseIf ($ScreenProportion -ge 2.0) {
        $FormWidth = ($ScreenWidth * 0.65) + $VerticalScrollWidth # Scaled Resolution Width + Scroll Width
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
    $CaptionLabelHeight = 40
    # To Buttons
    $ButtonHeight = 30
    $DistanceBetweenElements = 5
    # To CheckBox
    $CheckBoxHeight = 35
    # To Fonts
    $Header1 = 20
    $Header3 = 14

    $TitleLabelY = 0

    $BBHeight = ($ButtonHeight * 2) + $DistanceBetweenElements

    $WarningYellow = "#EED202"
    $White = "#FFFFFF"
    $WinBlue = "#08ABF7"
    $WinDark = "#252525"

    # Miscellaneous colors

    $AmdRyzenPrimaryColor = "#E4700D"
    $IntelPrimaryColor = "#0071C5"
    $NVIDIAPrimaryColor = "#76B900"

    # <===== Specific Layout =====>

    $SystemTweaksHeight = 1050
    $SoftwareInstallHeight = 1700

    # <===== UI =====>

    # Main Window:
    $Form = New-Form -Width $FormWidth -Height $FormHeight -Text "Win Debloat Tools (LeDragoX) | $(Get-SystemSpec)" -BackColor "$WinDark" -Maximize $false # Loading the specs takes longer time to load the GUI

    $Form = New-FormIcon -Form $Form -ImageLocation "$PSScriptRoot\src\assets\windows-11-logo.png"

    $FormTabControl = New-TabControl -Width ($FormWidth - 8) -Height ($FormHeight - 35) -LocationX -4 -LocationY 0
    $TabSystemTweaks = New-TabPage -Name "Tab1" -Text "System Tweaks"
    $TabSoftwareInstall = New-TabPage -Name "Tab2" -Text "Software Install"

    $TlSystemTweaks = New-Label -Text "System Tweaks" -Width $TotalWidth -Height $TitleLabelHeight -LocationX 0 -LocationY $TitleLabelY -FontSize $Header1 -FontStyle "Bold" -ForeColor $WinBlue
    $ClSystemTweaks = New-Label -Text "$CurrentFileName v$CurrentFileLastModified" -Width $TotalWidth -Height $CaptionLabelHeight -LocationX 0 -ElementBefore $TlSystemTweaks -MarginTop $DistanceBetweenElements -ForeColor $White

    # ==> Tab 1
    $CurrentPanelIndex = 1
    $T1Panel1 = New-Panel -Width $PanelWidth -Height $SystemTweaksHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSystemTweaks
    $CurrentPanelIndex++
    $T1Panel2 = New-Panel -Width $PanelWidth -Height $SystemTweaksHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSystemTweaks

    # ==> T1 Panel 1
    $ClDebloatTools = New-Label -Text "System Debloat Tools" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY 0
    $ApplyTweaks = New-Button -Text "✔ Apply Tweaks" -Width $PanelElementWidth -Height $BBHeight -LocationX $PanelElementX -ElementBefore $ClDebloatTools -FontSize $Header3 -ForeColor $WinBlue
    $UndoTweaks = New-Button -Text "❌ Undo Tweaks" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $ApplyTweaks -MarginTop $DistanceBetweenElements -ForeColor $WarningYellow
    $RemoveMSEdge = New-Button -Text "Remove Microsoft Edge" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $UndoTweaks -MarginTop $DistanceBetweenElements -ForeColor $WarningYellow
    $RemoveOneDrive = New-Button -Text "Remove OneDrive" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $RemoveMSEdge -MarginTop $DistanceBetweenElements -ForeColor $WarningYellow
    $RemoveXbox = New-Button -Text "Remove Xbox" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $RemoveOneDrive -MarginTop $DistanceBetweenElements -ForeColor $WarningYellow
    $PictureBox1 = New-PictureBox -ImageLocation "$PSScriptRoot\src\assets\script-logo.png" -Width $PanelElementWidth -Height (($BBHeight * 2) + $DistanceBetweenElements) -LocationX $PanelElementX -ElementBefore $RemoveXbox -MarginTop $DistanceBetweenElements -SizeMode 'Zoom'

    $ClInstallSystemApps = New-Label -Text "Install System Apps" -Width $PanelWidth -Height $CaptionLabelHeight -LocationX 0 -ElementBefore $PictureBox1
    $EnableHEVCSupport = New-Button -Text "Get H.265 video codec" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClInstallSystemApps
    $InstallCortana = New-Button -Text "Cortana" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $EnableHEVCSupport -MarginTop $DistanceBetweenElements
    $InstallDolbyAudio = New-Button -Text "Dolby Audio" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $InstallCortana -MarginTop $DistanceBetweenElements
    $InstallMicrosoftEdge = New-Button -Text "Microsoft Edge" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $InstallDolbyAudio -MarginTop $DistanceBetweenElements
    $InstallOneDrive = New-Button -Text "OneDrive" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $InstallMicrosoftEdge -MarginTop $DistanceBetweenElements
    $InstallPaintPaint3D = New-Button -Text "Paint + Paint 3D" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallOneDrive
    $InstallPhoneLink = New-Button -Text "Phone Link" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallPaintPaint3D
    $InstallSoundRecorder = New-Button -Text "Sound Recorder" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallPhoneLink
    $InstallTaskbarWidgets = New-Button -Text "Taskbar Widgets" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallSoundRecorder
    $InstallUWPWMediaPlayer = New-Button -Text "Windows Media Player (UWP)" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $InstallTaskbarWidgets -MarginTop $DistanceBetweenElements
    $InstallXbox = New-Button -Text "Xbox" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $InstallUWPWMediaPlayer -MarginTop $DistanceBetweenElements

    $ClOtherTools = New-Label -Text "Other Tools" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY 0 -ElementBefore $InstallXbox
    $RandomizeSystemColor = New-Button -Text "Randomize System Color" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $ClOtherTools -MarginTop $DistanceBetweenElements
    $ReinstallBloatApps = New-Button -Text "Reinstall Pre-Installed Apps" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $RandomizeSystemColor -MarginTop $DistanceBetweenElements
    $RepairWindows = New-Button -Text "Repair Windows" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $ReinstallBloatApps -MarginTop $DistanceBetweenElements
    $ShowDebloatInfo = New-Button -Text "Show Debloat Info" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -ElementBefore $RepairWindows -MarginTop $DistanceBetweenElements

    # ==> T1 Panel 2
    $ClCustomizeFeatures = New-Label -Text "Customize System Features" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY 0
    $CbDarkTheme = New-CheckBox -Text "Enable Dark Theme" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClCustomizeFeatures -MarginTop $DistanceBetweenElements
    $CbActivityHistory = New-CheckBox -Text "Enable Activity History" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbDarkTheme
    $CbBackgroundsApps = New-CheckBox -Text "Enable Background Apps" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbActivityHistory
    $CbClipboardHistory = New-CheckBox -Text "Enable Clipboard History" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbBackgroundsApps
    $CbClipboardSyncAcrossDevice = New-CheckBox -Text "Enable Clipboard Sync Across Devices" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbClipboardHistory
    $CbCortana = New-CheckBox -Text "Enable Cortana" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbClipboardSyncAcrossDevice
    $CbOldVolumeControl = New-CheckBox -Text "Enable Old Volume Control" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbCortana
    $CbOnlineSpeechRecognition = New-CheckBox -Text "Enable Online Speech Recognition" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbOldVolumeControl
    $CbPhoneLink = New-CheckBox -Text "Enable Phone Link" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbOnlineSpeechRecognition
    $CbPhotoViewer = New-CheckBox -Text "Enable Photo Viewer" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbPhoneLink
    $CbSearchAppForUnknownExt = New-CheckBox -Text "Enable Search App for Unknown Ext." -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbPhotoViewer
    $CbTelemetry = New-CheckBox -Text "Enable Telemetry" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbSearchAppForUnknownExt
    $CbWSearchService = New-CheckBox -Text "Enable WSearch Service" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbTelemetry
    $CbXboxGameBarDVRandMode = New-CheckBox -Text "Enable Xbox Game Bar/DVR/Mode" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbWSearchService

    $ClOptionalFeatures = New-Label -Text "Optional Features" -Width $PanelWidth -Height $CaptionLabelHeight -LocationX 0 -ElementBefore $CbXboxGameBarDVRandMode
    $CbInternetExplorer = New-CheckBox -Text "Internet Explorer" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClOptionalFeatures
    $CbPrintToPDFServices = New-CheckBox -Text "Printing-PrintToPDFServices-Features" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbInternetExplorer
    $CbPrintingXPSServices = New-CheckBox -Text "Printing-XPSServices-Features" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbPrintToPDFServices
    $CbWindowsMediaPlayer = New-CheckBox -Text "Windows Media Player" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbPrintingXPSServices

    $ClMiscFeatures = New-Label -Text "Miscellaneous Features" -Width $PanelWidth -Height $CaptionLabelHeight -LocationX 0 -ElementBefore $CbWindowsMediaPlayer
    $CbEncryptedDNS = New-CheckBox -Text "Enable Encrypted DNS" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClMiscFeatures
    $CbGodMode = New-CheckBox -Text "Enable God Mode" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbEncryptedDNS
    $CbMouseNaturalScroll = New-CheckBox -Text "Enable Mouse Natural Scroll" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbGodMode
    $CbTakeOwnership = New-CheckBox -Text "Enable Take Ownership menu" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbMouseNaturalScroll
    $CbFastShutdownPCShortcut = New-CheckBox -Text "Enable Fast Shutdown shortcut" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $CbTakeOwnership

    # ==> Tab 2
    $TlSoftwareInstall = New-Label -Text "Software Install" -Width $TotalWidth -Height $TitleLabelHeight -LocationX 0 -LocationY $TitleLabelY -FontSize $Header1 -FontStyle "Bold" -ForeColor $WinBlue
    $ClSoftwareInstall = New-Label -Text "Package Managers: Winget and Chocolatey" -Width $TotalWidth -Height $CaptionLabelHeight -LocationX 0 -ElementBefore $TlSoftwareInstall -MarginTop $DistanceBetweenElements -ForeColor $White

    $CurrentPanelIndex = 0
    $T2Panel1 = New-Panel -Width $PanelWidth -Height $SoftwareInstallHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSoftwareInstall
    $CurrentPanelIndex++
    $T2Panel2 = New-Panel -Width $PanelWidth -Height $SoftwareInstallHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSoftwareInstall
    $CurrentPanelIndex++
    $T2Panel3 = New-Panel -Width $PanelWidth -Height $SoftwareInstallHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSoftwareInstall
    $CurrentPanelIndex++
    $T2Panel4 = New-Panel -Width $PanelWidth -Height $SoftwareInstallHeight -LocationX ($PanelWidth * $CurrentPanelIndex) -ElementBefore $ClSoftwareInstall

    # ==> T2 Panel 1
    $UpgradeAll = New-Button -Text "Upgrade All Softwares" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY 0

    $ClCpuGpuDrivers = New-Label -Text "CPU/GPU Drivers" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $UpgradeAll
    $InstallAmdRyzenChipsetDriver = New-CheckBox -Text "AMD Ryzen Chipset Driver" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClCpuGpuDrivers -ForeColor $AmdRyzenPrimaryColor
    $InstallIntelDSA = New-CheckBox -Text "Intel® DSA" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallAmdRyzenChipsetDriver -ForeColor $IntelPrimaryColor
    $InstallNvidiaGeForceExperience = New-CheckBox -Text "NVIDIA GeForce Experience" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallIntelDSA -ForeColor $NVIDIAPrimaryColor
    $InstallNVCleanstall = New-CheckBox -Text "NVCleanstall" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallNvidiaGeForceExperience

    $ClApplicationRequirements = New-Label -Text "Application Requirements" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallNVCleanstall
    $InstallDirectX = New-CheckBox -Text "DirectX End-User Runtime" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClApplicationRequirements
    $InstallMsDotNetFramework = New-CheckBox -Text "Microsoft .NET Framework" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallDirectX
    $InstallMsVCppX64 = New-CheckBox -Text "MSVC Redist 2005-2022 (x64)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallMsDotNetFramework
    $InstallMsVCppX86 = New-CheckBox -Text "MSVC Redist 2005-2022 (x86)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallMsVCppX64

    $ClFileCompression = New-Label -Text "File Compression" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallMsVCppX86
    $Install7Zip = New-CheckBox -Text "7-Zip" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClFileCompression
    $InstallWinRar = New-CheckBox -Text "WinRAR (Trial)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $Install7Zip

    $ClDocuments = New-Label -Text "Document Editors/Readers" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallWinRar
    $InstallAdobeReaderDC = New-CheckBox -Text "Adobe Reader DC (x64)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClDocuments
    $InstallLibreOffice = New-CheckBox -Text "LibreOffice" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallAdobeReaderDC
    $InstallOnlyOffice = New-CheckBox -Text "ONLYOFFICE DesktopEditors" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallLibreOffice
    $InstallPDFCreator = New-CheckBox -Text "PDFCreator (PDF Converter)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallOnlyOffice
    $InstallPowerBi = New-CheckBox -Text "Power BI" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallPDFCreator
    $InstallSumatraPDF = New-CheckBox -Text "Sumatra PDF" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallPowerBi

    $ClTorrent = New-Label -Text "Torrent" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallSumatraPDF
    $InstallqBittorrent = New-CheckBox -Text "qBittorrent" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClTorrent

    $ClAcademicResearch = New-Label -Text "Academic Research" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallqBittorrent
    $InstallZotero = New-CheckBox -Text "Zotero" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClAcademicResearch

    $Cl2fa = New-Label -Text "2-Factor Authentication" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallZotero
    $InstallTwilioAuthy = New-CheckBox -Text "Twilio Authy" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $Cl2fa

    $ClBootableUsb = New-Label -Text "Bootable USB" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallTwilioAuthy
    $InstallBalenaEtcher = New-CheckBox -Text "Etcher" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClBootableUsb
    $InstallRufus = New-CheckBox -Text "Rufus" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallBalenaEtcher
    $InstallVentoy = New-CheckBox -Text "Ventoy" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallRufus

    $ClVirtualMachines = New-Label -Text "Virtual Machines" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallVentoy
    $InstallOracleVirtualBox = New-CheckBox -Text "Oracle VM VirtualBox" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClVirtualMachines
    $InstallQemu = New-CheckBox -Text "QEMU" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallOracleVirtualBox
    $InstallVmWarePlayer = New-CheckBox -Text "VMware Workstation Player" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallQemu

    $ClCloudStorage = New-Label -Text "Cloud Storage" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallVmWarePlayer
    $InstallDropbox = New-CheckBox -Text "Dropbox" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClCloudStorage
    $InstallGoogleDrive = New-CheckBox -Text "Google Drive" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallDropbox

    $ClUICustomization = New-Label -Text "UI Customization" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallGoogleDrive
    $InstallRoundedTB = New-CheckBox -Text "RoundedTB" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClUICustomization
    $InstallTranslucentTB = New-CheckBox -Text "TranslucentTB" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallRoundedTB

    # ==> T2 Panel 2
    $InstallSelected = New-Button -Text "Install Selected" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY 0 -FontStyle "Bold"

    $ClWebBrowsers = New-Label -Text "Web Browsers" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallSelected
    $InstallBraveBrowser = New-CheckBox -Text "Brave Browser" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClWebBrowsers
    $InstallGoogleChrome = New-CheckBox -Text "Google Chrome" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallBraveBrowser
    $InstallMozillaFirefox = New-CheckBox -Text "Mozilla Firefox" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallGoogleChrome

    $ClAudioVideoTools = New-Label -Text "Audio/Video Tools" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallMozillaFirefox
    $InstallAudacity = New-CheckBox -Text "Audacity (Editor)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClAudioVideoTools
    $InstallMpcHc = New-CheckBox -Text "MPC-HC (Player)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallAudacity
    $InstallVlc = New-CheckBox -Text "VLC (Player)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallMpcHc

    $ClImageTools = New-Label -Text "Image Tools" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallVlc
    $InstallGimp = New-CheckBox -Text "GIMP" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClImageTools
    $InstallInkscape = New-CheckBox -Text "Inkscape" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallGimp
    $InstallIrfanView = New-CheckBox -Text "IrfanView" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallInkscape
    $InstallKrita = New-CheckBox -Text "Krita" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallIrfanView
    $InstallPaintNet = New-CheckBox -Text "Paint.NET" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallKrita
    $InstallShareX = New-CheckBox -Text "ShareX (Screenshots/GIFs)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallPaintNet

    $ClStreamingServices = New-Label -Text "Streaming Services" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallShareX
    $InstallAmazonPrimeVideo = New-CheckBox -Text "Amazon Prime Video" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClStreamingServices
    $InstallDisneyPlus = New-CheckBox -Text "Disney+" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallAmazonPrimeVideo
    $InstallNetflix = New-CheckBox -Text "Netflix" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallDisneyPlus
    $InstallSpotify = New-CheckBox -Text "Spotify" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallNetflix

    $ClPlanningProductivity = New-Label -Text "Planning/Productivity" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallSpotify
    $InstallNotion = New-CheckBox -Text "Notion" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClPlanningProductivity
    $InstallObsidian = New-CheckBox -Text "Obsidian" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallNotion

    $ClUtilities = New-Label -Text "⚒ Utilities" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallObsidian
    $InstallCpuZ = New-CheckBox -Text "CPU-Z" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClUtilities
    $InstallCrystalDiskInfo = New-CheckBox -Text "Crystal Disk Info" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallCpuZ
    $InstallCrystalDiskMark = New-CheckBox -Text "Crystal Disk Mark" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallCrystalDiskInfo
    $InstallGeekbench5 = New-CheckBox -Text "Geekbench 5" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallCrystalDiskMark
    $InstallGpuZ = New-CheckBox -Text "GPU-Z" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallGeekbench5
    $InstallHwInfo = New-CheckBox -Text "HWiNFO" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallGpuZ
    $InstallInternetDownloadManager = New-CheckBox -Text "Internet Download Manager (Trial)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallHwInfo
    $InstallMsiAfterburner = New-CheckBox -Text "MSI Afterburner" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallInternetDownloadManager
    $InstallRtxVoice = New-CheckBox -Text "RTX Voice" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallMsiAfterburner
    $InstallVoicemod = New-CheckBox -Text "Voicemod" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallRtxVoice
    $InstallVoiceMeeter = New-CheckBox -Text "Voicemeeter Potato" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallVoicemod

    $ClNetworkManagement = New-Label -Text "Network Management" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallVoiceMeeter
    $InstallHamachi = New-CheckBox -Text "Hamachi (LAN)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClNetworkManagement
    $InstallPuTty = New-CheckBox -Text "PuTTY" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallHamachi
    $InstallRadminVpn = New-CheckBox -Text "Radmin VPN (LAN)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallPuTty
    $InstallWinScp = New-CheckBox -Text "WinSCP" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallRadminVpn
    $InstallWireshark = New-CheckBox -Text "Wireshark" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallWinScp

    # ==> T2 Panel 3
    $UninstallMode = New-Button -Text "[OFF] Uninstall Mode" -Width $PanelElementWidth -Height $ButtonHeight -LocationX $PanelElementX -LocationY 0 -FontStyle "Bold"

    $ClCommunication = New-Label -Text "Communication" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $UninstallMode
    $InstallDiscord = New-CheckBox -Text "Discord" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClCommunication
    $InstallMSTeams = New-CheckBox -Text "Microsoft Teams" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallDiscord
    $InstallRocketChat = New-CheckBox -Text "Rocket Chat" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallMSTeams
    $InstallSignal = New-CheckBox -Text "Signal" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallRocketChat
    $InstallSkype = New-CheckBox -Text "Skype" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallSignal
    $InstallSlack = New-CheckBox -Text "Slack" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallSkype
    $InstallTelegramDesktop = New-CheckBox -Text "Telegram Desktop" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallSlack
    $InstallWhatsAppDesktop = New-CheckBox -Text "WhatsApp Desktop" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallTelegramDesktop
    $InstallZoom = New-CheckBox -Text "Zoom" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallWhatsAppDesktop

    $ClGaming = New-Label -Text "Gaming" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallZoom
    $InstallBorderlessGaming = New-CheckBox -Text "Borderless Gaming" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClGaming
    $InstallEADesktop = New-CheckBox -Text "EA Desktop" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallBorderlessGaming
    $InstallEpicGamesLauncher = New-CheckBox -Text "Epic Games Launcher" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallEADesktop
    $InstallGogGalaxy = New-CheckBox -Text "GOG Galaxy" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallEpicGamesLauncher
    $InstallSteam = New-CheckBox -Text "Steam" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallGogGalaxy
    $InstallUbisoftConnect = New-CheckBox -Text "Ubisoft Connect" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallSteam

    $ClRemoteConnection = New-Label -Text "Remote Connection" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallUbisoftConnect
    $InstallAnyDesk = New-CheckBox -Text "AnyDesk" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClRemoteConnection
    $InstallParsec = New-CheckBox -Text "Parsec" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallAnyDesk
    $InstallScrCpy = New-CheckBox -Text "ScrCpy (Android)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallParsec
    $InstallTeamViewer = New-CheckBox -Text "Team Viewer" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallScrCpy

    $ClRecordingAndStreaming = New-Label -Text "Recording and Streaming" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallTeamViewer
    $InstallElgatoStreamDeck = New-CheckBox -Text "Elgato Stream Deck" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClRecordingAndStreaming
    $InstallHandBrake = New-CheckBox -Text "HandBrake (Transcode)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallElgatoStreamDeck
    $InstallObsStudio = New-CheckBox -Text "OBS Studio" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallHandBrake
    $InstallStreamlabs = New-CheckBox -Text "Streamlabs" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallObsStudio

    $ClEmulation = New-Label -Text "Emulation" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallStreamlabs
    $InstallBSnesHd = New-CheckBox -Text "BSnes HD (SNES)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClEmulation
    $InstallCemu = New-CheckBox -Text "Cemu (Wii U)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallBSnesHd
    $InstallDolphin = New-CheckBox -Text "Dolphin Stable (GC/Wii)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallCemu
    $InstallKegaFusion = New-CheckBox -Text "Kega Fusion (Sega Genesis)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallDolphin
    $InstallMGba = New-CheckBox -Text "mGBA (GBA)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallKegaFusion
    $InstallPCSX2 = New-CheckBox -Text "PCSX2 Stable (PS2 | Portable)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallMGba
    $InstallPPSSPP = New-CheckBox -Text "PPSSPP (PSP)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallPCSX2
    $InstallProject64 = New-CheckBox -Text "Project64 Dev (N64)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallPPSSPP
    $InstallRetroArch = New-CheckBox -Text "RetroArch (All In One)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallProject64
    $InstallRyujinx = New-CheckBox -Text "Ryujinx (Switch)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallRetroArch
    $InstallSnes9x = New-CheckBox -Text "Snes9x (SNES)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallRyujinx

    # ==> T2 Panel 4
    $ClTextEditors = New-Label -Text "Text Editors/IDEs" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -LocationY ($ButtonHeight + $DistanceBetweenElements)
    $InstallAtom = New-CheckBox -Text "Atom" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClTextEditors
    $InstallJetBrainsToolbox = New-CheckBox -Text "JetBrains Toolbox" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallAtom
    $InstallNotepadPlusPlus = New-CheckBox -Text "Notepad++" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallJetBrainsToolbox
    $InstallVisualStudioCommunity = New-CheckBox -Text "Visual Studio 2022 Community" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallNotepadPlusPlus
    $InstallVSCode = New-CheckBox -Text "VS Code" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallVisualStudioCommunity
    $InstallVSCodium = New-CheckBox -Text "VS Codium" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallVSCode

    $ClWsl = New-Label -Text "Windows Subsystem For Linux" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallVSCodium
    $InstallWSLgOrPreview = New-CheckBox -Text "Install WSLg/Preview" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClWsl -ForeColor $WinBlue
    $InstallArchWSL = New-CheckBox -Text "ArchWSL (x64)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallWSLgOrPreview -ForeColor $WinBlue
    $InstallDebian = New-CheckBox -Text "Debian GNU/Linux" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallArchWSL
    $InstallKaliLinux = New-CheckBox -Text "Kali Linux Rolling" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallDebian
    $InstallOpenSuse = New-CheckBox -Text "Open SUSE 42" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallKaliLinux
    $InstallSles = New-CheckBox -Text "SLES v12" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallOpenSuse
    $InstallUbuntu = New-CheckBox -Text "Ubuntu" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallSles
    $InstallUbuntu16Lts = New-CheckBox -Text "Ubuntu 16.04 LTS" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallUbuntu
    $InstallUbuntu18Lts = New-CheckBox -Text "Ubuntu 18.04 LTS" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallUbuntu16Lts
    $InstallUbuntu20Lts = New-CheckBox -Text "Ubuntu 20.04 LTS" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallUbuntu18Lts

    $ClDevelopment = New-Label -Text "⌨ Development on Windows" -Width $PanelElementWidth -Height $CaptionLabelHeight -LocationX $PanelElementX -ElementBefore $InstallUbuntu20Lts
    $InstallWindowsTerminal = New-CheckBox -Text "Windows Terminal" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $ClDevelopment
    $InstallNerdFonts = New-CheckBox -Text "Install Nerd Fonts" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallWindowsTerminal -ForeColor $WinBlue
    $InstallGitGnupgSshSetup = New-CheckBox -Text "Git + GnuPG + SSH (Setup)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallNerdFonts -ForeColor $WinBlue
    $InstallAdb = New-CheckBox -Text "Android Debug Bridge (ADB)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallGitGnupgSshSetup
    $InstallAndroidStudio = New-CheckBox -Text "Android Studio" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallAdb
    $InstallDockerDesktop = New-CheckBox -Text "Docker Desktop" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallAndroidStudio
    $InstallInsomnia = New-CheckBox -Text "Insomnia" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallDockerDesktop
    $InstallJavaJdks = New-CheckBox -Text "Java - Adoptium JDK 8/11/18" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallInsomnia
    $InstallJavaJre = New-CheckBox -Text "Java - Oracle JRE" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallJavaJdks
    $InstallMySql = New-CheckBox -Text "MySQL" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallJavaJre
    $InstallNodeJs = New-CheckBox -Text "NodeJS" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallMySql
    $InstallNodeJsLts = New-CheckBox -Text "NodeJS LTS" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallNodeJs
    $InstallPostgreSql = New-CheckBox -Text "PostgreSQL" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallNodeJsLts
    $InstallPython3 = New-CheckBox -Text "Python 3" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallPostgreSql
    $InstallPythonAnaconda3 = New-CheckBox -Text "Python - Anaconda3" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallPython3
    $InstallRuby = New-CheckBox -Text "Ruby" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallPythonAnaconda3
    $InstallRubyMsys = New-CheckBox -Text "Ruby (MSYS2)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallRuby
    $InstallRustGnu = New-CheckBox -Text "Rust (GNU)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallRubyMsys
    $InstallRustMsvc = New-CheckBox -Text "Rust (MSVC)" -Width $PanelElementWidth -Height $CheckBoxHeight -LocationX $PanelElementX -ElementBefore $InstallRustGnu

    # Add TabControl to the Form
    $Form.Controls.AddRange(@($FormTabControl))
    # Tabs
    $FormTabControl.Controls.AddRange(@($TabSystemTweaks, $TabSoftwareInstall))
    $TabSystemTweaks.Controls.AddRange(@($TlSystemTweaks, $ClSystemTweaks, $T1Panel1, $T1Panel2))
    $TabSoftwareInstall.Controls.AddRange(@($TlSoftwareInstall, $ClSoftwareInstall, $T2Panel1, $T2Panel2, $T2Panel3, $T2Panel4))
    # Add Elements to each Tab Panel
    $T1Panel1.Controls.AddRange(@($ClDebloatTools, $ApplyTweaks, $UndoTweaks, $RemoveMSEdge, $RemoveOneDrive, $RemoveXbox, $PictureBox1))
    $T1Panel1.Controls.AddRange(@($ClInstallSystemApps, $EnableHEVCSupport, $InstallCortana, $InstallDolbyAudio, $InstallMicrosoftEdge, $InstallOneDrive, $InstallPaintPaint3D, $InstallTaskbarWidgets, $InstallUWPWMediaPlayer, $InstallPhoneLink, $InstallSoundRecorder, $InstallXbox))
    $T1Panel1.Controls.AddRange(@($ClOtherTools, $RandomizeSystemColor, $ReinstallBloatApps, $RepairWindows, $ShowDebloatInfo))
    $T1Panel2.Controls.AddRange(@($ClCustomizeFeatures, $CbDarkTheme, $CbActivityHistory, $CbBackgroundsApps, $CbClipboardHistory, $CbClipboardSyncAcrossDevice, $CbCortana, $CbOldVolumeControl, $CbOnlineSpeechRecognition, $CbPhoneLink, $CbPhotoViewer, $CbSearchAppForUnknownExt, $CbTelemetry, $CbWSearchService, $CbXboxGameBarDVRandMode))
    $T1Panel2.Controls.AddRange(@($ClOptionalFeatures, $CbInternetExplorer, $CbPrintToPDFServices, $CbPrintingXPSServices, $CbWindowsMediaPlayer))
    $T1Panel2.Controls.AddRange(@($ClMiscFeatures, $CbEncryptedDNS, $CbGodMode, $CbMouseNaturalScroll, $CbTakeOwnership, $CbFastShutdownPCShortcut))

    $T2Panel1.Controls.AddRange(@($UpgradeAll))
    $T2Panel1.Controls.AddRange(@($ClCpuGpuDrivers, $InstallAmdRyzenChipsetDriver, $InstallIntelDSA, $InstallNvidiaGeForceExperience, $InstallNVCleanstall))
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
    $T2Panel2.Controls.AddRange(@($ClUtilities, $InstallCpuZ, $InstallCrystalDiskInfo, $InstallCrystalDiskMark, $InstallGeekbench5, $InstallGpuZ, $InstallHwInfo, $InstallInternetDownloadManager, $InstallMsiAfterburner, $InstallRtxVoice, $InstallVoicemod, $InstallVoiceMeeter))
    $T2Panel2.Controls.AddRange(@($ClNetworkManagement, $InstallHamachi, $InstallPuTty, $InstallRadminVpn, $InstallWinScp, $InstallWireshark))
    $T2Panel3.Controls.AddRange(@($UninstallMode))
    $T2Panel3.Controls.AddRange(@($ClCommunication, $InstallDiscord, $InstallMSTeams, $InstallRocketChat, $InstallSignal, $InstallSkype, $InstallSlack, $InstallTelegramDesktop, $InstallWhatsAppDesktop, $InstallZoom))
    $T2Panel3.Controls.AddRange(@($ClGaming, $InstallBorderlessGaming, $InstallEADesktop, $InstallEpicGamesLauncher, $InstallGogGalaxy, $InstallSteam, $InstallUbisoftConnect))
    $T2Panel3.Controls.AddRange(@($ClRemoteConnection, $InstallAnyDesk, $InstallParsec, $InstallScrCpy, $InstallTeamViewer))
    $T2Panel3.Controls.AddRange(@($ClRecordingAndStreaming, $InstallElgatoStreamDeck, $InstallHandBrake, $InstallObsStudio, $InstallStreamlabs))
    $T2Panel3.Controls.AddRange(@($ClEmulation, $InstallBSnesHd, $InstallCemu, $InstallDolphin, $InstallKegaFusion, $InstallMGba, $InstallPCSX2, $InstallPPSSPP, $InstallProject64, $InstallRetroArch, $InstallRyujinx, $InstallSnes9x))
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
                "silent-debloat-softwares.ps1",
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

    $RemoveMSEdge.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("remove-msedge.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $RemoveOneDrive.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("remove-onedrive.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
            $PictureBox1.imageLocation = "$PSScriptRoot\src\assets\script-logo2.png"
            $Form.Update()
        })

    $RemoveXbox.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("remove-xbox.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
            $PictureBox1.imageLocation = "$PSScriptRoot\src\assets\script-logo2.png"
            $Form.Update()
        })

    $RepairWindows.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("backup-system.ps1", "repair-windows.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $EnableHEVCSupport.Add_Click( {
            Install-HEVCSupport
        })

    $InstallCortana.Add_Click( {
            Install-Cortana
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
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("new-system-color.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $ReinstallBloatApps.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts" -Scripts @("reinstall-pre-installed-apps.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
        })

    $ShowDebloatInfo.Add_Click( {
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("show-debloat-info.ps1") -NoDialog
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

    $CbWSearchService.Add_Click( {
            If ($CbWSearchService.CheckState -eq "Checked") {
                Enable-WSearchService
                $CbWSearchService.Text = "[ON]  WSearch Service *"
            } Else {
                Disable-WSearchService
                $CbWSearchService.Text = "[OFF] WSearch Service"
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
            Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("update-all-packages.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
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

            If ($InstallGeekbench5.CheckState -eq "Checked") {
                $AppsSelected.WingetApps.Add("PrimateLabs.Geekbench.5")
                $InstallGeekbench5.CheckState = "Unchecked"
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

            If ($InstallRyujinx.CheckState -eq "Checked") {
                $AppsSelected.ChocolateyApps.Add("ryujinx")
                $InstallRyujinx.CheckState = "Unchecked"
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
                    Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("install-wslg-or-preview.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
                } Else {
                    $AppsSelected.MSStoreApps.Add("9P9TQF7MRM4R")
                }
                $InstallWSLgOrPreview.CheckState = "Unchecked"
            }

            If ($InstallArchWSL.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("install-archwsl.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
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
                    Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("install-nerd-fonts.ps1")
                }
                $InstallNerdFonts.CheckState = "Unchecked"
            }

            If ($InstallGitGnupgSshSetup.CheckState -eq "Checked") {
                If (!($Script:UninstallSwitch)) {
                    Open-PowerShellFilesCollection -RelativeLocation "src\scripts\other-scripts" -Scripts @("git-gnupg-ssh-keys-setup.ps1") -DoneTitle $DoneTitle -DoneMessage $DoneMessage
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

            If (($AppsSelected.WingetApps.Count -ge 1) -or ($AppsSelected.MSStoreApps.Count -ge 1) -or ($AppsSelected.ChocolateyApps.Count -ge 1) -or ($AppsSelected.WSLDistros.Count -ge 1)) {
                Show-Message -Title "$DoneTitle" -Message "$SoftwareList"
            }
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

Main
