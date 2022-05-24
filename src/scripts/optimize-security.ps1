Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"get-hardware-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://youtu.be/xz3oXHleKoM
# Adapted from: https://github.com/ChrisTitusTech/win10script
# Adapted from: https://github.com/kalaspuffar/windows-debloat

function Optimize-Security() {
    $TweakType = "Security"
    # Initialize all Path variables used to Registry Tweaks
    $PathToLMPoliciesEdge = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge"
    $PathToLMPoliciesMRT = "HKLM:\SOFTWARE\Policies\Microsoft\MRT"
    $PathToCUExplorer = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
    $PathToCUExplorerAdvanced = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

    Write-Title -Text "Security Tweaks"

    Write-Section -Text "Windows Firewall"
    Write-Status -Symbol "+" -Type $TweakType -Status "Enabling default firewall profiles..."
    Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True

    Write-Section -Text "Windows Defender"
    Write-Status -Symbol "?" -Type $TweakType -Status "If you already use another antivirus, nothing will happen." -Warning
    Write-Status -Symbol "+" -Type $TweakType -Status "Ensuring your Windows Defender is ENABLED..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWORD -Value 0 -Force
    Set-MpPreference -DisableRealtimeMonitoring $false -Force

    Write-Status -Symbol "+" -Type $TweakType -Status "Enabling Microsoft Defender Exploit Guard network protection..."
    Set-MpPreference -EnableNetworkProtection Enabled -Force

    Write-Status -Symbol "+" -Type $TweakType -Status "Enabling detection for potentially unwanted applications and block them..."
    Set-MpPreference -PUAProtection Enabled -Force

    Write-Section -Text "SmartScreen"
    Write-Status -Symbol "+" -Type $TweakType -Status "Enabling 'SmartScreen' for Microsoft Edge..."
    If (!(Test-Path "$PathToLMPoliciesEdge\PhishingFilter")) {
        New-Item -Path "$PathToLMPoliciesEdge\PhishingFilter" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMPoliciesEdge\PhishingFilter" -Name "EnabledV9" -Type DWord -Value 1

    Write-Status -Symbol "+" -Type $TweakType -Status "Enabling 'SmartScreen' for Store Apps..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 1

    Write-Section -Text "Old SMB Protocol"
    # Details: https://techcommunity.microsoft.com/t5/storage-at-microsoft/stop-using-smb1/ba-p/425858
    Write-Status -Symbol "+" -Type $TweakType -Status "Disabling SMB 1.0 protocol..."
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

    Write-Section -Text "Old .NET cryptography"
    # Enable strong cryptography for .NET Framework (version 4 and above) - https://stackoverflow.com/a/47682111
    Write-Status -Symbol "+" -Type $TweakType -Status "Enabling .NET strong cryptography..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1

    Write-Section -Text "Autoplay and Autorun (Removable Devices)"
    Write-Status -Symbol "-" -Type $TweakType -Status "Disabling Autoplay..."
    Set-ItemProperty -Path "$PathToCUExplorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1

    Write-Status -Symbol "-" -Type $TweakType -Status "Disabling Autorun for all Drives..."
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255

    Write-Section -Text "Microsoft Store"
    Write-Status -Symbol "-" -Type $TweakType -Status "Disabling Search for App in Store for Unknown Extensions..."
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1

    Write-Section -Text "Windows Explorer"
    Write-Status -Symbol "+" -Type $TweakType -Status "Enabling Show file extensions in Explorer..."
    Set-ItemProperty -Path "$PathToCUExplorerAdvanced" -Name "HideFileExt" -Type DWord -Value 0

    Write-Section -Text "User Account Control (UAC)"
    # Details: https://docs.microsoft.com/pt-br/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings
    Write-Status -Symbol "+" -Type $TweakType -Status "Raising UAC level..."
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 5
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 1

    Write-Section -Text "Windows Update"
    # Details: https://forums.malwarebytes.com/topic/246740-new-potentially-unwanted-modification-disablemrt/
    Write-Status -Symbol "+" -Type $TweakType -Status "Enabling offer Malicious Software Removal Tool via Windows Update..."
    If (!(Test-Path "$PathToLMPoliciesMRT")) {
        New-Item -Path "$PathToLMPoliciesMRT" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMPoliciesMRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 0

    Write-Status -Symbol "?" -Type $TweakType -Status "For more tweaks, edit the '$PSCommandPath' file, then uncomment '#SomethingHere' code lines" -Warning
    # Consumes more RAM - Make Windows Defender run in Sandbox Mode (MsMpEngCP.exe and MsMpEng.exe will run on background)
    # Details: https://www.microsoft.com/security/blog/2018/10/26/windows-defender-antivirus-can-now-run-in-a-sandbox/
    #Write-Status -Symbol "+" -Type $TweakType -Status "Enabling Windows Defender Sandbox mode..."
    #setx /M MP_FORCE_USE_SANDBOX 1  # Restart the PC to apply the changes, 0 to Revert

    # Disable Windows Script Host. CAREFUL, this may break stuff, including software uninstall.
    #Write-Status -Symbol "+" -Type $TweakType -Status "Disabling Windows Script Host (execution of *.vbs scripts and alike)..."
    #Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Type DWord -Value 0
}

function Main() {
    Optimize-Security # Improve the Windows Security
}

Main
