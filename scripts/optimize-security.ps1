# Adapted from this Baboo video:                            https://youtu.be/xz3oXHleKoM
# Adapted from this ChrisTitus script:                      https://github.com/ChrisTitusTech/win10script
# Adapted from this kalaspuffar/Daniel Persson script:      https://github.com/kalaspuffar/windows-debloat

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"check-os-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

$CPU = DetectCPU
# Initialize all Path variables used to Registry Tweaks
$Global:PathToExplorer  = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
$Global:PathToEdgeLMPol = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge"

Function TweaksForSecurity {

    Title1 -Text "Security Tweaks"

    Write-Host "[+] Ensure your Windows Defender is ENABLED, if you already use another antivirus, nothing will happen."
    Set-MpPreference -DisableRealtimeMonitoring $false -Force

    Write-Host "[+] Enabling Microsoft Defender Exploit Guard network protection... (if you already use another antivirus, nothing will happen)"
    Set-MpPreference -EnableNetworkProtection Enabled -Force

    Write-Host "[+] Enabling detection for potentially unwanted applications and block them... (if you already use another antivirus, nothing will happen)"
    Set-MpPreference -PUAProtection Enabled -Force

    # Make Windows Defender run in Sandbox Mode (MsMpEngCP.exe and MsMpEng.exe will run on background)
    # Details: https://www.microsoft.com/security/blog/2018/10/26/windows-defender-antivirus-can-now-run-in-a-sandbox/
    Write-Host "[+] Enabling Windows Defender Sandbox mode... (if you already use another antivirus, nothing will happen)"
    setx /M MP_FORCE_USE_SANDBOX 1  # Restart the PC to apply the changes, 0 to Revert

    # Details: https://techcommunity.microsoft.com/t5/storage-at-microsoft/stop-using-smb1/ba-p/425858
    Write-Host "[+] Disabling SMB 1.0 protocol..."
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

    # Enable strong cryptography for .NET Framework (version 4 and above) - https://stackoverflow.com/questions/36265534/invoke-webrequest-ssl-fails
    Write-Host "[+] Enabling .NET strong cryptography..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1

    Write-Host "[-] Disabling Autoplay..."
    Set-ItemProperty -Path "$PathToExplorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1

    Write-Host "[-] Disabling Autorun for all Drives..."
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255

    Write-Host "[-] Disabling Search for App in Store for Unknown Extensions..."
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1

    # Details: https://docs.microsoft.com/pt-br/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings
    Write-Host "[+] Raising UAC level..."
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 5
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 1

    # Details: https://support.microsoft.com/en-us/help/4072699/january-3-2018-windows-security-updates-and-antivirus-software.
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Force | Out-Null
    }
    If ($CPU.contains("Intel" -or "ARM")) {
        Write-Host "[+] Enabling Meltdown (CVE-2017-5754) compatibility flag..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -Type DWord -Value 0
    }
    else {
        Write-Host "[-] Your processor doesn't need Meltdown (CVE-2017-5754) compatibility flag..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -Type DWord -Value 1
    }

    Write-Host "[+] Enabling 'SmartScreen' for Microsoft Edge..."
    If (!(Test-Path "$PathToEdgeLMPol\PhishingFilter")) {
        New-Item -Path "$PathToEdgeLMPol\PhishingFilter" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToEdgeLMPol\PhishingFilter" -Name "EnabledV9" -Type DWord -Value 1

    Write-Host "[+] Enabling 'SmartScreen' for Store Apps..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 1

    # [DIY] The "OpenPowershellHere.cmd" file actually uses .vbs script, so, i'll make this optional
    #Write-Host "[-] Disabling Windows Script Host (execution of *.vbs scripts and alike)..."
    #Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Type DWord -Value 0

}

TweaksForSecurity   # Improve the Windows Security