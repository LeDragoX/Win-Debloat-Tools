Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"set-service-startup.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"remove-uwp-appx.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\utils\"individual-tweaks.psm1"

function Remove-Xbox() {
    $TweakType = "Xbox"
    $PathToLMPoliciesGameDVR = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"

    $XboxServices = @(
        "XblAuthManager"
        "XblGameSave"
        "XboxGipSvc"
        "XboxNetApiSvc"
    )

    $XboxApps = @(
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
}

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

Main
