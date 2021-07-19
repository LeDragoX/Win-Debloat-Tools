<h1>
    <img width=30px src="./../images/Windows-10-logo.png"> Package Software Installer 
    <img width=30px src="./../images/PowerShell-icon.png">
</h1>

This was made to install all needed softwares on a Post-Install Windows.
You can modify it as you want.

The best part is, if a Software was installed with Chocolatey,
in this specific case, they'll upgrade automatically.

## Usage Requirements

The `pkg-sw-installer.ps1` do not make everything automatically, follow these steps.

- Open `OpenPowershellHere.cmd` (For beginners) or the Powershell as admin on its folder.
- Enable execution of PowerShell scripts and Unblock PowerShell scripts and modules within this directory.

### Easy way (Prepare and Run once):

- Copy and Paste this entire line below on **Powershell**:
```Powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; ls -Recurse .ps1 | Unblock-File; .\scripts\"pkg-sw-installer.ps1"
```

## Softwares that'll be Installed:

- Obviously, [Chocolatey](https://chocolatey.org/why-chocolatey) !!!
- The Latest CPU ([Intel](https://community.chocolatey.org/packages/intel-dsa) and [AMD](https://community.chocolatey.org/packages/amd-ryzen-chipset)) driver installer;
- The Lastest Graphics driver of your GPU (Except AMD. See [Intel](https://community.chocolatey.org/packages/intel-graphics-driver) and [NVIDIA](https://community.chocolatey.org/packages/geforce-game-ready-driver), including [GeForce Experience](https://community.chocolatey.org/packages/geforce-experience));
- [7-Zip](https://community.chocolatey.org/packages/7zip);
- [Google Chrome](https://community.chocolatey.org/packages/GoogleChrome);
- [Gimp](https://community.chocolatey.org/packages/gimp);
- [Notepad++](https://community.chocolatey.org/packages/notepadplusplus.install);
- [ONLYOffice Editors](https://community.chocolatey.org/packages/onlyoffice);
- [qBitTorrent](https://community.chocolatey.org/packages/qbittorrent);
- [Spotify](https://community.chocolatey.org/packages/spotify);
- [uBlock Origin for Chrome](https://community.chocolatey.org/packages/ublockorigin-chrome);
- [WinRAR](https://community.chocolatey.org/packages/winrar) ( English only :/ );
- [VLC](https://community.chocolatey.org/packages/vlc);
- [Java SE Runtime Environment](https://community.chocolatey.org/packages/jre8). (This matches with your OS Architecture and install the XX-bits only)

### [Optional] If you do play Games on PC, you'll want this (probably):

- [DirectX](https://community.chocolatey.org/packages/directx);
- [Discord](https://community.chocolatey.org/packages/discord.install);
- [Microsoft .NET](https://community.chocolatey.org/packages/dotnet/5.0.4);
- [Microsoft .NET Framework](https://community.chocolatey.org/packages/dotnetfx) (Latest); 
- [Parsec](https://community.chocolatey.org/packages/parsec);
- [Steam](https://community.chocolatey.org/packages/steam);
- [Microsoft Visual C++ 2005 SP1 Redistributable Package](https://community.chocolatey.org/packages/vcredist2005);
- [Microsoft Visual C++ 2008 SP1 Redistributable Package](https://community.chocolatey.org/packages/vcredist2008);
- [Microsoft Visual C++ 2010 Redistributable Package](https://community.chocolatey.org/packages/vcredist2010);
- [Microsoft Visual C++ 2012 Redistributable Package](https://community.chocolatey.org/packages/vcredist2012);
- [Visual C++ Redistributable Packages for Visual Studio 2013](https://community.chocolatey.org/packages/vcredist2013)
- [Microsoft Visual C++ Redistributable for Visual Studio 2015-2019](https://community.chocolatey.org/packages/vcredist140);

### These listed below are OPTIONAL, if you want to install them, just remove the # ( DIY ;D ).

- [Audacity](https://community.chocolatey.org/packages/audacity);
- [Brave](https://community.chocolatey.org/packages/brave/1.19.86);
- [Firefox](https://community.chocolatey.org/packages/Firefox);
- [ImgBurn](https://community.chocolatey.org/packages/imgburn);
- [OBS Studio](https://community.chocolatey.org/packages/obs-studio);
- [Paint.NET](https://community.chocolatey.org/packages/paint.net);
- [Python](https://community.chocolatey.org/packages/python/) (Latest);
- [Radmin VPN](https://community.chocolatey.org/packages/radmin-vpn);
- [Sys Internals](https://community.chocolatey.org/packages/sysinternals);
- [Wireshark](https://community.chocolatey.org/packages/wireshark).

#### DIY From the Gaming part:

- [Origin](https://community.chocolatey.org/packages/origin).