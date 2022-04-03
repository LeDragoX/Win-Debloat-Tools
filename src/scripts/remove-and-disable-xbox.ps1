Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"remove-uwp-apps.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"

function Remove-Xbox() {
    [CmdletBinding()] param()

    $PathToLMPoliciesGameDVR = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"

    Write-Host "[-][Services] Disabling Xbox Services (Except from Accessories)..."
    Get-Service -Name "XblAuthManager" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    Get-Service -Name "XblGameSave" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    Get-Service -Name "XboxNetApiSvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    Stop-Service "XblAuthManager" -Force -NoWait
    Stop-Service "XblGameSave" -Force -NoWait
    Stop-Service "XboxNetApiSvc" -Force -NoWait
    # Only disable if you'll not get ANY Xbox Accessory (Xbox Wireless Controller, Xbox Wireless Receiver, Steering Wheel, etc.)
    #Get-Service -Name "XboxGipSvc" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    #Stop-Service "XboxGipSvc" -Force -NoWait

    Write-Host "[-][UWP] Wiping Xbox completely from Windows..."
    $XboxApps = @(
        "Microsoft.XboxApp"                 # Xbox Console Companion (Replaced by new App)
        "Microsoft.XboxGameCallableUI"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.XboxGamingOverlay"       # Xbox Game Bar
        "Microsoft.XboxIdentityProvider"    # Xbox Identity Provider (Xbox Dependency)
        "Microsoft.Xbox.TCUI"               # Xbox Live API communication (Xbox Dependency)
    )

    Remove-UWPAppsList -Apps $XboxApps

    Write-Host "[-][Priv&Perf] Disabling Xbox Game Bar & Game DVR..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
    If (!(Test-Path "$PathToLMPoliciesGameDVR")) {
        New-Item -Path "$PathToLMPoliciesGameDVR" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMPoliciesGameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
}

function Main() {
    $Ask = "This will remove or disable the Xbox:`n  - Apps;`n  - Services (Except from Accessories) and;`n  - GameBar;`n  - GameDVR.`n`nDo you want to proceed?"

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