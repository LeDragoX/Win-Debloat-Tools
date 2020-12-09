#   Description:
# This script remove strang looking stuff which will probably result in a break
# of your system.  It should not be used unless you want to test out a few
# things. It is named `experimental_unfuckery.ps1` for a reason.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

Write-Output "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

Write-Output "Force removing system apps"
$needles = @(
    #"Anytime"
    "BioEnrollment"
    #"Browser"
    "ContactSupport"
    #"Cortana"       # This will disable startmenu search.
    #"Defender"
    "Feedback"
    "Flash"
    "Gaming"
    #"Holo"
    #"InternetExplorer"
    #"Maps"
    #"MiracastView"
    "OneDrive"
    #"SecHealthUI"
    #"Wallet"
    #"Xbox"          # This will result in a bootloop since upgrade 1511
)

foreach ($needle in $needles) {
    Write-Output "Trying to remove all packages containing $needle"

    $pkgs = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages" |
        Where-Object Name -Like "*$needle*")

    foreach ($pkg in $pkgs) {
        $pkgname = $pkg.Name.split('\')[-1]

        Takeown-Registry($pkg.Name)
        Takeown-Registry($pkg.Name + "\Owners")

        Set-ItemProperty -Path ("HKLM:" + $pkg.Name.Substring(18)) -Name Visibility -Value 1
        New-ItemProperty -Path ("HKLM:" + $pkg.Name.Substring(18)) -Name DefVis -PropertyType DWord -Value 2
        Remove-Item      -Path ("HKLM:" + $pkg.Name.Substring(18) + "\Owners")

        dism.exe /Online /Remove-Package /PackageName:$pkgname /NoRestart
    }
}
