Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Main() {
    Write-Status -Types "@" -Status "Enabling God Mode hidden folder on Desktop..."
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
#      God Mode has been enabled, check out the new link on your Desktop      #
#                                                                             #
###############################################################################
"@ -ForegroundColor Blue

    $DesktopPath = [Environment]::GetFolderPath("Desktop");
    New-Item -Path "$DesktopPath\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}" -ItemType Directory -Force
}

Main