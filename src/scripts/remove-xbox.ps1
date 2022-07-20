Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"set-service-startup.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"remove-uwp-appx.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\utils\"individual-tweaks.psm1"

function Main() {
    $Ask = "This will remove and/or disable all the Xbox:`n  - Apps;`n  - Services and;`n  - GameBar;`n  - GameDVR.`n`nDo you want to proceed?"

    switch (Show-Question -Title "Warning" -Message $Ask -BoxIcon "Warning") {
        'Yes' {
            Remove-Xbox # Remove all Xbox related Apps, services, etc.
        }
        'No' {
            Write-Host "Aborting..."
        }
        'Cancel' {
            Write-Host "Aborting..." # With Yes, No and Cancel, the user can press Esc to exit
        }
    }
}

function Remove-Xbox() {
    $PathToCUXboxGameBar = "HKCU:\Software\Microsoft\GameBar"
    $PathToLMServicesXbgm = "HKLM:\SYSTEM\CurrentControlSet\Services\xbgm"
    $TweakType = "Xbox"

    $XboxServices = @(
        "XblAuthManager"                    # Xbox Live Auth Manager
        "XblGameSave"                       # Xbox Live Game Save
        "XboxGipSvc"                        # Xbox Accessory Management Service
        "XboxNetApiSvc"
    )

    $XboxApps = @(
        "Microsoft.GamingServices"          # Gaming Services
        "Microsoft.XboxApp"                 # Xbox Console Companion (Replaced by new App)
        "Microsoft.XboxGameCallableUI"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.XboxGamingOverlay"       # Xbox Game Bar
        "Microsoft.XboxIdentityProvider"    # Xbox Identity Provider (Xbox Dependency)
        "Microsoft.Xbox.TCUI"               # Xbox Live API communication (Xbox Dependency)
    )

    Write-Status -Types "-", $TweakType -Status "Disabling ALL Xbox Services..."
    Set-ServiceStartup -Disabled -Services $XboxServices

    Write-Status -Types "-", $TweakType -Status "Wiping Xbox Apps completely from Windows..."
    Remove-UWPAppx -AppxPackages $XboxApps

    Disable-XboxGameBarDVR

    # Adapted from: https://docs.microsoft.com/en-us/answers/questions/241800/completely-disable-and-remove-xbox-apps-and-relate.html
    Write-Status -Types "-", $TweakType -Status "Disabling Game mode..."
    Set-ItemProperty -Path "$PathToCUXboxGameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 0
    Write-Status -Types "-", $TweakType -Status "Disabling Game Mode Notifications..."
    Set-ItemProperty -Path "$PathToCUXboxGameBar" -Name "ShowGameModeNotifications" -Type DWord -Value 0
    Write-Status -Types "-", $TweakType -Status "Disabling Game Bar tips..."
    Set-ItemProperty -Path "$PathToCUXboxGameBar" -Name "ShowStartupPanel" -Type DWord -Value 0
    Write-Status -Types "-", $TweakType -Status "Disabling Open Xbox Game Bar using Xbox button on Game Controller..."
    Set-ItemProperty -Path "$PathToCUXboxGameBar" -Name "UseNexusForGameBarEnabled" -Type DWord -Value 0

    Write-Status -Types "-", $TweakType -Status "Disabling GameBar Presence Writer..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter" -Name "ActivationType" -Type DWord -Value 0

    Write-Status -Types "-", $TweakType -Status "Disabling Xbox Game Monitoring..."
    If (!(Test-Path "$PathToLMServicesXbgm")) {
        New-Item -Path "$PathToLMServicesXbgm" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMServicesXbgm" -Name "Start" -Type DWord -Value 4
}

Main