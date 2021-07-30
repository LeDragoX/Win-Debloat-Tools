<h1 align="center">
    <img width=30px src="./../images/windows-11-logo.png"> Install Softwares 
    <img width=30px src="./../images/powershell-icon.png">
</h1>

## Resume

This was made to install all needed softwares on a Post-Install Windows.
You can modify it as you want.

The best part is, if a Software was installed with Chocolatey,
in this specific case, they'll upgrade automatically.

<hr>

## Usage Requirements

The `install-softwares.ps1` do not make everything automatically, follow these steps.

- Open `OpenPowershellHere.cmd` (For beginners) or the Powershell as admin on its folder.
- Enable execution of PowerShell scripts and Unblock PowerShell scripts and modules within this directory.
- Copy and Paste this entire line below on **Powershell**:

```Powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; ls -Recurse .ps1 | Unblock-File; .\src\scripts\"install-softwares.ps1"
```

<hr>

## Softwares that'll be Installed:

- [7-Zip](https://community.chocolatey.org/packages/7zip);
- [Google Chrome](https://community.chocolatey.org/packages/GoogleChrome);
- [Gimp](https://community.chocolatey.org/packages/gimp);
- [Notepad++](https://community.chocolatey.org/packages/notepadplusplus.install);
- [ONLYOffice Editors](https://community.chocolatey.org/packages/onlyoffice);
- [qBitTorrent](https://community.chocolatey.org/packages/qbittorrent);
- [Spotify](https://community.chocolatey.org/packages/spotify);
- [uBlock Origin for Chrome](https://community.chocolatey.org/packages/ublockorigin-chrome);
- [WinRAR](https://community.chocolatey.org/packages/winrar);
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
