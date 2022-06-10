Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"set-service-startup.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"remove-uwp-appx.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

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

    Write-Status -Types "-", $TweakType -Status "Disabling Xbox Game Bar & Game DVR..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
    If (!(Test-Path "$PathToLMPoliciesGameDVR")) {
        New-Item -Path "$PathToLMPoliciesGameDVR" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMPoliciesGameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
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
