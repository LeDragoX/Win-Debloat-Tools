Function QuickPrivilegesElevation {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}
# Your script here

Function LoadLibs {

    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Current Folder $PSScriptRoot"
    Write-Host ""
    Push-Location -Path "$PSScriptRoot"
	
    Push-Location -Path "..\lib\"
    Get-ChildItem -Recurse *.ps*1 | Unblock-File

    #Import-Module -DisableNameChecking .\"count-n-seconds.psm1"    # Not Used
    Import-Module -DisableNameChecking .\"check-os-info.psm1"
    Import-Module -DisableNameChecking .\"setup-console-style.psm1" # Make the Console look how i want
    Import-Module -DisableNameChecking .\"simple-message-box.psm1"
    Import-Module -DisableNameChecking .\"title-templates.psm1"
    Pop-Location

}

Function InstallChocolatey {

    # This function will use Windows package manager to bootstrap Chocolatey and install a list of packages.

    # Adapted From https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/utils/install-basic-software.ps1
    Write-Host "Setting up Chocolatey software package manager"
    Get-PackageProvider -Name chocolatey -Force
    
    Write-Host "Setting up Full Chocolatey Install"
    Install-Package -Name Chocolatey -Force -ProviderName chocolatey
    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco upgrade all -y
    choco install chocolatey-core.extension -y #--force
    
    Write-Host "Creating a daily task to automatically upgrade Chocolatey packages"
    # adapted from https://blogs.technet.microsoft.com/heyscriptingguy/2013/11/23/using-scheduled-tasks-and-scheduled-jobs-in-powershell/
    # Find it on "Microsoft\Windows\PowerShell\ScheduledJobs\Chocolatey Daily Upgrade"
    $JobName = "Chocolatey Daily Upgrade"
    $ScheduledJob = @{
        Name               = $JobName
        ScriptBlock        = { choco upgrade all -y }
        Trigger            = New-JobTrigger -Daily -At 12:00
        ScheduledJobOption = New-ScheduledJobOption -RunElevated -MultipleInstancePolicy StopExisting -RequireNetwork
    }
    
    # If the Sched. Job already exists, delete
    If (Get-ScheduledJob -Name $JobName -ErrorAction SilentlyContinue) {
        Write-Host "ScheduledJob: $JobName FOUND! Deleting..."
        Unregister-ScheduledJob -Name $JobName
    }
    # Then register it again
    Register-ScheduledJob @ScheduledJob
    
}

Function InstallPackages {

    # Install CPU drivers first
    If ($CPU.contains("AMD")) {
        
        Section1 -Text "Installing AMD chipset drivers!"
        If ($CPU.contains("Ryzen")) {
            Section1 -Text "You have a Ryzen CPU, installing Chipset driver for Ryzen processors!"
            choco install "amd-ryzen-chipset" -y                # AMD Ryzen Chipset Drivers
        }
        
    }
    ElseIf ($CPU.contains("Intel")) {

        Section1 -Text "Installing Intel chipset drivers!"
        choco install "chocolatey-misc-helpers.extension" -y    # Chocolatey Misc Helpers Extension ('intel-dsa' Dependency)
        choco install "dotnet4.7" -y                            # Microsoft .NET Framework 4.7 ('intel-dsa' Dependency)
        choco install "intel-dsa" -y                            # Intel® Driver & Support Assistant (Intel® DSA)

    }
    
    # Install GPU drivers then
    If ($GPU.contains("AMD") -or $GPU.contains("Radeon")) {
        Title1 -Text "AMD GPU, yay! (Skipping...)"
    }
    
    If ($GPU.contains("Intel")) {
        Section1 -Text "Installing Intel Graphics driver!"
        choco install "intel-graphics-driver" -y                # Intel Graphics Driver (latest)
    }

    If ($GPU.contains("NVIDIA")) {

        Section1 -Text "Installing NVIDIA Graphics driver!"
        choco install "geforce-experience" -y                   # GeForce Experience (latest)
        choco feature enable -n=useRememberedArgumentsForUpgrades
        cinst geforce-game-ready-driver --package-parameters="'/dch'"
        choco install "geforce-game-ready-driver" -y            # GeForce Game Ready Driver (latest)

    }

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

        # [DIY] Remove the # if you want to install something.

        #"audacity"                 # Audacity
        #"brave"                    # Brave Browser
        #"firefox"                  # The person may likes Chrome
        #"imgburn"                  # Img Burn
        #"obs-studio"               # OBS Studio
        #"paint.net"                # Paint.NET
        #"python"                   # Python (Programming Language)
        #"radmin-vpn"               # Radmin VPN
        #"sysinternals"             # Sys Internals Suite
        #"wireshark"                # Wire Shark
    )
    $TotalPackagesLenght = $EssentialPackages.Length
    $TotalPackagesLenght += 1

    Title1 -Text "Installing Packages"
    ForEach ($Package in $EssentialPackages) {
        Title2Counter -Text "Installing: $Package" -MaxNum $TotalPackagesLenght
        # Avoiding a softlock that occurs if the APP is already installed on Microsoft Store (Blame Spotify)
        If ((Get-AppxPackage).Name -ilike "*$Package*") {
            Caption1 -Text "$Package already installed on MS Store! Skipping..."
        }
        Else {
            choco install $Package -y # --force
        }
    }

    # For Java (JRE) correct installation
    If ($Architecture.contains("32-bits")) {
        Title2Counter -Text "Installing: jre8 (32-bits)"
        choco install "jre8" --params="'/exclude:64'" -y
    } 
    ElseIf ($Architecture.contains("64-bits")) {
        Title2Counter -Text "Installing: jre8 (64-bits)"
        choco install "jre8" --params="'/exclude:32'" -y
    }
    
}

Function InstallGamingPackages {
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
                
                # [DIY] Remove the # if you want to install something.

                #"origin"               # [DIY] I don't like Origin
            )
        
            Title1 -Text "Installing Packages"

            Caption1 -Text "Closing ONLY Discord, avoid future reinstalling"
            taskkill.exe /F /IM "Discord.exe"
            ForEach ($Package in $GamingPackages) {
                Title2Counter -Text "Installing: $Package" -MaxNum $GamingPackages.Length
                choco install $Package -y # --force # to reinstall
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

QuickPrivilegesElevation                # Check admin rights
LoadLibs                                # Import modules from lib folder
SetupConsoleStyle                       # Make the Console looks how i want
$Architecture = CheckOSArchitecture     # Checks if the System is 32-bits or 64-bits or Something Else
$CPU = DetectCPU                        # Detects the current CPU
$GPU = DetectGPU                        # Detects the current GPU
InstallChocolatey                       # Install Chocolatey on Powershell
InstallPackages                         # Install the Showed Softwares
InstallGamingPackages                   # Install the most important Gaming Clients and Required Softwares to Run Games
Taskkill /F /IM $PID                    # Kill this task by PID because it won't exit with the command 'exit'