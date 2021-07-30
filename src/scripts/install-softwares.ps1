Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"check-os-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"simple-message-box.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/utils/install-basic-software.ps1

function InstallPackages() {

    $EssentialPackages = @(
        "7zip"                      # 7-Zip
        "googlechrome"              # Google Chrome
        "gimp"                      # Gimp
        "notepadplusplus"           # Notepad++
        "onlyoffice"                # ONLYOffice Editors
        "qbittorrent"               # qBittorrent
        "spotify"                   # Spotify
        "ublockorigin-chrome"       # uBlock Origin extension for Chrome
        "winrar"                    # English only
        "vlc"                       # VLC
    )
    $TotalPackagesLenght = $EssentialPackages.Length + 1

    Title1 -Text "Installing Packages"
    ForEach ($Package in $EssentialPackages) {
        Title2Counter -Text "Installing: $Package" -MaxNum $TotalPackagesLenght
        # Avoiding a softlock that occurs if the APP is already installed on Microsoft Store (Blame Spotify)
        If ((Get-AppxPackage).Name -ilike "*$Package*") {
            Caption1 -Text "$Package already installed on MS Store! Skipping..."
        }
        Else {
            choco install -y $Package # --force
        }
    }

    # For Java (JRE) correct installation
    If ($Architecture.contains("32-bits")) {
        Title2Counter -Text "Installing: jre8 (32-bits)"
        choco install -y "jre8" --params="/exclude:64" 
    } 
    ElseIf ($Architecture.contains("64-bits")) {
        Title2Counter -Text "Installing: jre8 (64-bits)"
        choco install -y "jre8" --params="/exclude:32" 
    }
    
}

function InstallGamingPackages() {

    # You Choose
    $Ask = "Do you plan to play Games on this PC?
    All important Gaming clients and Required Game Softwares to Run Games will be installed.
    + Discord (Will be closed, sorry for the inconvenience)
    + Parsec
    + Steam
    + Microsoft DirectX & .NET & VC++ Packages"

    switch (ShowQuestion -Title "Read carefully" -Message $Ask) {
        'Yes' {

            Write-Host "You choose Yes."
            $GamingPackages = @(
                "discord"               # Discord
                "parsec"                # Parsec
                "steam"                 # Steam
                "directx"               # DirectX End-User Runtime
                "dotnetfx"              # Microsoft .NET Framework (Before v5)
                "dotnet"                # Microsoft .NET (v5 +)
                "dotnet-desktopruntime" # Microsoft .NET Desktop Runtime (v5 +)
                "vcredist2005"          # Microsoft Visual C++ 2005 SP1 Redistributable Package
                "vcredist2008"          # Microsoft Visual C++ 2008 SP1 Redistributable Package
                "vcredist2010"          # Microsoft Visual C++ 2010 Redistributable Package
                "vcredist2012"          # Microsoft Visual C++ 2012 Redistributable Package
                "vcredist2013"          # Visual C++ Redistributable Packages for Visual Studio 2013
                "vcredist140"           # Microsoft Visual C++ Redistributable for Visual Studio 2015-2019
            )
        
            Title1 -Text "Installing Packages"

            Caption1 -Text "Closing ONLY Discord, avoid reinstalling bug"
            taskkill.exe /F /IM "Discord.exe"
            ForEach ($Package in $GamingPackages) {
                Title2Counter -Text "Installing: $Package" -MaxNum $GamingPackages.Length
                choco install -y $Package  # --force # to reinstall
            }

        }
        'No' {
            Write-Host "You choose No. (No = Cancel)"
        }
        'Cancel' {
            # With Yes, No and Cancel, the user can press Esc to exit
            Write-Host "You choose Cancel. (Cancel = No)"
        }
    }

}

function Main() {

    SetupConsoleStyle                   # Make the Console looks how i want
    $Architecture = CheckOSArchitecture # Checks if the System is 32-bits or 64-bits or Something Else
    InstallPackages                     # Install the Showed Softwares
    InstallGamingPackages               # Install the most important Gaming Clients and Required Softwares to Run Games

}

Main