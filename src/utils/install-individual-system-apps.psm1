Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"Manage-Software.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"Title-Templates.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\debloat-helper\"Set-ItemPropertyVerified.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\utils\"Individual-Tweaks.psm1"

$Script:TweakType = "App"

function Install-Cortana() {
    $Apps = @("9NFFX4SZZ23L")

    Write-Status -Types "*", $TweakType -Status "Installing Cortana..."
    Install-Software -Name "Cortana" -Packages $Apps -PackageProvider 'MsStore'
}

function Install-DolbyAudio() {
    $Apps = @("9NJZD5S7QN99")

    Write-Status -Types "*", $TweakType -Status "Installing Dolby Audio..."
    Install-Software -Name "Dolby Audio" -Packages $Apps -PackageProvider 'MsStore'
}

function Install-MicrosoftEdge() {
    Write-Status -Types "*", $TweakType -Status "Installing Microsoft Edge..."
    Install-Software -Name "Microsoft Edge" -Packages "Microsoft.Edge"
}

function Install-OneDrive() {
    Write-Status -Types "*" -Status "Installing OneDrive..."
    Set-ItemPropertyVerified -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 0
    Start-Process -FilePath "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
}

function Install-PaintPaint3D() {
    $Apps = @("9PCFS5B6T72H", "9NBLGGH5FV99")

    Write-Status -Types "*", $TweakType -Status "Installing Paint + Paint 3D..."
    Install-Software -Name "Paint + Paint 3D" -Packages $Apps -PackageProvider 'MsStore'
}

function Install-PhoneLink() {
    $Apps = @("9NMPJ99VJBWV")

    Write-Status -Types "*", $TweakType -Status "Installing Phone Link (Your Phone)..."
    Install-Software -Name "Phone Link (Your Phone)" -Packages $Apps -PackageProvider 'MsStore'
    Enable-PhoneLink
}

function Install-SoundRecorder() {
    $Apps = @("9WZDNCRFHWKN")

    Write-Status -Types "*", $TweakType -Status "Installing Sound Recorder..."
    Install-Software -Name "Sound Recorder" -Packages $Apps -PackageProvider 'MsStore'
}

function Install-TaskbarWidgetsApp() {
    $Apps = @("9MSSGKG348SP")

    Write-Status -Types "*", $TweakType -Status "Installing Taskbar Widgets..."
    Install-Software -Name "Taskbar Widgets" -Packages $Apps -PackageProvider 'MsStore'
}

function Install-UWPWindowsMediaPlayer() {
    Write-Status -Types "*", $TweakType -Status "Installing Windows Media Player (UWP)..."
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

    Write-Status -Types "*", $TweakType -Status "Installing Xbox Apps again..."
    Install-Software -Name "Missing Xbox Apps" -Packages $XboxApps -PackageProvider 'MsStore' -NoDialog

    Write-Status -Types "*", $TweakType -Status "Enabling Xbox Game Monitoring..."
    Set-ItemPropertyVerified -Path "$PathToLMServicesXbgm" -Name "Start" -Type DWord -Value 3

    Enable-XboxGameBarDVRandMode
}
