#   Description:
# This script disables Windows Defender. Run it once (will throw errors), then
# reboot, run it again (this time no errors should occur) followed by another
# reboot.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\New-FolderForced.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

Write-Output "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

$tasks = @(
    "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance"
    "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup"
    "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan"
    "\Microsoft\Windows\Windows Defender\Windows Defender Verification"
)

foreach ($task in $tasks) {
    $parts = $task.split('\')
    $name = $parts[-1]
    $path = $parts[0..($parts.length-2)] -join '\'

    Write-Output "Trying to disable scheduled task $name"
    Disable-ScheduledTask -TaskName "$name" -TaskPath "$path"
}

Write-Output "Disabling Windows Defender via Group Policies"
New-FolderForced -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender" "DisableAntiSpyware" 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender" "DisableRoutinelyTakingAction" 1
New-FolderForced -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender\Real-Time Protection"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 1

Write-Output "Disabling Windows Defender Services"
Takeown-Registry("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend")
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend" "Start" 4
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend" "AutorunsDisabled" 3
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WdNisSvc" "Start" 4
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WdNisSvc" "AutorunsDisabled" 3
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Sense" "Start" 4
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Sense" "AutorunsDisabled" 3

Write-Output "Removing Windows Defender context menu item"
Set-Item "HKLM:\SOFTWARE\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" ""

Write-Output "Removing Windows Defender GUI / tray from autorun"
Remove-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "WindowsDefender" -ea 0
