Import-Module -DisableNameChecking "$PSScriptRoot\..\lib\Title-Templates.psm1"

function Start-DiskCleanUp() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [Switch] $Silent
    )

    $CleanOptions = @(
        "Active Setup Temp Folders"
        "BranchCache"
        "D3D Shader Cache"
        "Delivery Optimization Files"
        "Diagnostic Data Viewer database files"
        "Downloaded Program Files"
        "Feedback Hub Archive log files"
        "Internet Cache Files"
        "Language Pack"
        "Old ChkDsk Files"
        "Recycle Bin"
        "RetailDemo Offline Content"
        "Setup Log Files"
        "System error memory dump files"
        "System error minidump files"
        "Temporary Files"
        "Temporary Setup Files"
        "Thumbnail Cache"
        "Update Cleanup"
        "User file versions"
        "Windows Defender"
        "Windows Error Reporting Files"
        "Windows Upgrade Log Files"
    )
    $PathToLMCleangmrSettings = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
    $TweakType = "Disk"

    Write-Status -Types "+", $TweakType -Status "Cleaning the $env:SystemRoot\WinSxS folder..."
    DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Host

    Write-Status -Types "+", $TweakType -Status "Cleaning up more system folders..."
    If (!$Silent) {
        Start-Process cleanmgr.exe -ArgumentList "/d $env:SystemDrive", "/VERYLOWDISK" -Wait
    } Else {
        ForEach ($Key in $CleanOptions) {
            Set-ItemPropertyVerified -Path "$PathToLMCleangmrSettings\$Key" -Name "StateFlags0777" -Type DWord -Value 2
        }

        Start-Process cleanmgr.exe -ArgumentList "/d $env:SystemDrive", "/SAGERUN:777" -Wait
    }
}

Start-DiskCleanUp -Silent
