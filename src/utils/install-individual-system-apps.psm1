Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"manage-software.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\utils\"individual-tweaks.psm1"

function Install-Cortana() {
    $Apps = @("9NFFX4SZZ23L")

    Write-Status -Types "*", "Apps" -Status "Installing Cortana..."
    Install-Software -Name "Cortana" -Packages $Apps -ViaMSStore
}

function Install-DolbyAudio() {
    $Apps = @("9NJZD5S7QN99")

    Write-Status -Types "*", "Apps" -Status "Installing Dolby Audio..."
    Install-Software -Name "Dolby Audio" -Packages $Apps -ViaMSStore
}

function Install-HEVCSupport() {
    Write-Status -Types "+", "Apps" -Status "Installing HEVC/H.265 video codec (MUST HAVE)..."
    Install-Software -Name "HEVC Video Extensions from Device Manufacturer" -Packages "9N4WGH0Z6VHQ" -ViaMSStore # Gives error
}

function Install-MicrosoftEdge() {
    Write-Status -Types "*", "Apps" -Status "Installing Microsoft Edge..."
    Install-Software -Name "Microsoft Edge" -Packages "Microsoft.Edge"
}

function Install-OneDrive() {
    Write-Status -Types "*" -Status "Installing OneDrive..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 0
    Start-Process -FilePath "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
}

function Install-PaintPaint3D() {
    $Apps = @("9PCFS5B6T72H", "9NBLGGH5FV99")

    Write-Status -Types "*", "Apps" -Status "Installing Paint + Paint 3D..."
    Install-Software -Name "Paint + Paint 3D" -Packages $Apps -ViaMSStore
}

function Install-PhoneLink() {
    $Apps = @("9NMPJ99VJBWV")

    Write-Status -Types "*", "Apps" -Status "Installing Phone Link (Your Phone)..."
    Install-Software -Name "Phone Link (Your Phone)" -Packages $Apps -ViaMSStore
    Enable-PhoneLink
}

function Install-SoundRecorder() {
    $Apps = @("9WZDNCRFHWKN")

    Write-Status -Types "*", "Apps" -Status "Installing Sound Recorder..."
    Install-Software -Name "Sound Recorder" -Packages $Apps -ViaMSStore
}

function Install-TaskbarWidgetsApp() {
    $Apps = @("9MSSGKG348SP")

    Write-Status -Types "*", "Apps" -Status "Installing Taskbar Widgets..."
    Install-Software -Name "Taskbar Widgets" -Packages $Apps -ViaMSStore
}

function Install-UWPWindowsMediaPlayer() {
    Write-Status -Types "*", "Apps" -Status "Installing Windows Media Player (UWP)..."
    Install-Software -Name "Windows Media Player (UWP)" -Packages @("9WZDNCRFJ3PT") -ViaMSStore
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
    Set-ServiceStartup -Manual -Services $XboxServices

    Write-Status -Types "*", $TweakType -Status "Installing Xbox Apps again..."
    Install-Software -Name "Missing Xbox Apps" -Packages $XboxApps -ViaMSStore -NoDialog

    Write-Status -Types "*", $TweakType -Status "Enabling Xbox Game Monitoring..."
    If (!(Test-Path "$PathToLMServicesXbgm")) {
        New-Item -Path "$PathToLMServicesXbgm" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMServicesXbgm" -Name "Start" -Type DWord -Value 3

    Enable-XboxGameBarDVRandMode
}
