Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Main() {
    Write-Status -Types "@" -Status "Disabling God Mode hidden folder..." -Warning
    Write-Host @"
###############################################################################
#       _______  _______  ______     __   __  _______  ______   _______       #
#      |       ||       ||      |   |  |_|  ||       ||      | |       |      #
#      |    ___||   _   ||  _    |  |       ||   _   ||  _    ||    ___|      #
#      |   | __ |  | |  || | |   |  |       ||  | |  || | |   ||   |___       #
#      |   ||  ||  |_|  || |_|   |  |       ||  |_|  || |_|   ||    ___|      #
#      |   |_| ||       ||       |  | ||_|| ||       ||       ||   |___       #
#      |_______||_______||______|   |_|   |_||_______||______| |_______|      #
#                                                                             #
#         God Mode has been disabled, link removed from your Desktop          #
#                                                                             #
###############################################################################
"@ -ForegroundColor Cyan

    $DesktopPath = [Environment]::GetFolderPath("Desktop");
    Remove-Item -Path "$DesktopPath\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
}

Main