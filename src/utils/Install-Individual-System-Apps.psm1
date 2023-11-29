Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\debloat-helper\Set-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\package-managers\Manage-Software.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\utils\Individual-Tweaks.psm1"

$Script:TweakType = "App"
$OneDriveFolders = @("System32", "SysWOW64") # W11+/W10

function Install-DolbyAudio() {
    $Apps = @("9NJZD5S7QN99")
    Install-Software -Name "Dolby Audio" -Packages $Apps -PackageProvider 'MsStore'
}

function Install-MicrosoftEdge() {
    Install-Software -Name "Microsoft Edge" -Packages "Microsoft.Edge"
}

function Install-OneDrive() {
    Write-Status -Types "*" -Status "Installing OneDrive..."
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 0

    ForEach ($Folder in $OneDriveFolders) {
        If (Test-Path "$env:SystemRoot\$Folder\OneDriveSetup.exe") {
            Start-Process -FilePath "$env:SystemRoot\$Folder\OneDriveSetup.exe"
        } Else {
            Write-Status -Types "?", $TweakType -Status "The path `"$env:SystemRoot\$Folder\OneDriveSetup.exe`" does not exist" -Warning
        }
    }
}

function Install-PaintPaint3D() {
    $Apps = @("9PCFS5B6T72H", "9NBLGGH5FV99")
    Install-Software -Name "Paint + Paint 3D" -Packages $Apps -PackageProvider 'MsStore'
}

function Install-PhoneLink() {
    $Apps = @("9NMPJ99VJBWV")
    Install-Software -Name "Phone Link (Your Phone)" -Packages $Apps -PackageProvider 'MsStore'
    Enable-PhoneLink
}

function Install-QuickAssist() {
    $Apps = @("9P7BP5VNWKX5")
    Install-Software -Name "Quick Assist" -Packages $Apps -PackageProvider 'MsStore'
}

function Install-SoundRecorder() {
    $Apps = @("9WZDNCRFHWKN")
    Install-Software -Name "Sound Recorder" -Packages $Apps -PackageProvider 'MsStore'
}

function Install-TaskbarWidgetsApp() {
    $Apps = @("9MSSGKG348SP")
    Install-Software -Name "Taskbar Widgets" -Packages $Apps -PackageProvider 'MsStore'
}

function Install-UWPWindowsMediaPlayer() {
    Install-Software -Name "Windows Media Player (UWP)" -Packages @("9WZDNCRFJ3PT") -PackageProvider 'MsStore'
}

function Install-Xbox() {
    $PathToLMServicesXbgm = "HKLM:\SYSTEM\CurrentControlSet\Services\xbgm"
    $TweakType = "Xbox"

    $XboxServices = @(
        "XblAuthManager"                    # Xbox Live Auth Manager
        "XblGameSave"                       # Xbox Live Game Save
        "XboxGipSvc"                        # Xbox Accessory Management Service
        "XboxNetApiSvc"
    )

    $XboxApps = @("9MWPM2CQNLHN", "9MV0B5HZVK9Z", "9WZDNCRD1HKW", "9NZKPSTSNW4P")

    Write-Status -Types "*", $TweakType -Status "Enabling ALL Xbox Services..."
    Set-ServiceStartup -State 'Manual' -Services $XboxServices
    Install-Software -Name "Missing Xbox Apps" -Packages $XboxApps -PackageProvider 'MsStore' -NoDialog

    Write-Status -Types "*", $TweakType -Status "Enabling Xbox Game Monitoring..."
    Set-ItemPropertyVerified -Path "$PathToLMServicesXbgm" -Name "Start" -Type DWord -Value 3

    Enable-XboxGameBarDVRandMode
}
