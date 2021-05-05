<h1>
    <img width=30px src="./lib/images/Windows-10-logo.png"> Win10 Smart Debloat 
    <img width=30px src="./lib/images/PowerShell-icon.png">
</h1>

## Adapted from [W4RH4WK's Project](https://github.com/W4RH4WK/Debloat-Windows-10)

## Download Latest Version

Code located in the `master` branch is always considered under development,
but you'll probably want the most recent version anyway.

|    Download    | Should work on |   Build   |      Editions     | Script version |
|:--------------:|:--------------:|:---------:|:-----------------:|:--------------:|
| [Download [Zip]](https://github.com/LeDragoX/Win10SmartDebloat/archive/master.zip) | 20H2 and Older | 19042.xxx |Home/Pro/Enterprise| **Always Latest** |

## Resume

This is a improved version from [another project](https://github.com/W4RH4WK/Debloat-Windows-10). 
These scripts will Customize, Debloat and Improve Security/Performance on Windows 10.

## Roll-Back

**There is a undo (if works)**, because i did a restoration point script before
doing everything.

**Use on a fresh windows install to note the differences, and if something breaks,**
**you can rely on a pre-made restoration point and the** [`repair-windows.ps1`](./scripts/repair-windows.ps1) file.

## Usage Requirements

The `Script-Win10.ps1` do not make everything automatically, follow these steps.

- Open `OpenPowershellHere.cmd` (For beginners) or the Powershell as admin on its folder.
- Enable execution of PowerShell scripts and Unblock PowerShell scripts and modules within this directory.

### Easy way (Prepare and Run once):

#### GUI (Advice - Some of the output still missing from the console, not something to worry about, just the % and ETA from some commands)

- Copy and Paste this entire line below on **Powershell**:
```Powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; ls -Recurse *.ps*1 | Unblock-File; .\"Win10ScriptGUI.ps1"
```
![Script GUI](./lib/images/Script-GUI.png)
*The `Automated Tweaks` button is the main one.*

#### CLI

- Copy and Paste this entire line below on **Powershell**:
```Powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; ls -Recurse *.ps*1 | Unblock-File; .\"Win10Script.ps1"
```

**[Scripts](/scripts) can be run individually, pick what you need.**

## GUI Script Features

- Run every Automated Tweaks scripts; (without interaction)
- Run WinAero Tweaker to apply my profile and other "Manual" softwares; ([`manual-debloat-softwares.ps1`](./scripts/manual-debloat-softwares.ps1))
- [Optional] Try to Completely fix the Windows worst problems via Command Line; ([`backup-system.ps1`](./scripts/backup-system.ps1) and ([`repair-windows.ps1`](./scripts/repair-windows.ps1))
- Apply Dark Mode or Light Mode exclusively from GUI; ([Dark](./utils/dark-theme.reg) and [Light](./utils/light-theme.reg))
- Install Chocolatey and install Basic Softwares from my selection. ([`choco-sw-installer.ps1`](./scripts/choco-sw-installer.ps1) See Doc: [Chocolatey-SW-Installer.md](./lib/docs/Chocolatey-SW-Installer.md))

## Script Features

- Import all necessary Modules before Executing everything; ([lib folder](lib/))
- Make a Restore Point and Backup the Hosts file; ([`backup-system.ps1`](./scripts/backup-system.ps1))
- Download OOShutUp10 and import my Configuration file; ([`all-in-one-tweaks.ps1`](./scripts/all-in-one-tweaks.ps1))
- Download AdwCleaner and Run the latest version of for Virus/Adware scan;
- Disable Telemetry from Scheduled Tasks and Optimize it;
- Re-Enable useful Services & Disable the Heavy ones;
- Disable Telemetry and Data Collection via Registry;
- Help improve the Security of Windows by a little;
- Apply my Performance & UI Personalization tweaks via Registry and Powershell commands;
- Remove Bloatware Apps that comes with Windows 10, except from my choice;
- Enable Optional Features especially for Gaming/Work (including WSL 2);
- [Default] Fix more Privacy problems via Registry and Commands; ([`fix-privacy-settings.ps1`](./scripts/fix-privacy-settings.ps1))
- Optimize the Default Windows UI to look more Clean, and fixes the Mouse; ([`optimize-user-interface.ps1`](./scripts/optimize-user-interface.ps1))
- [Default] Remove OneDrive completely from the System, re-install is possible via Win Store; ([`remove-onedrive.ps1`](./scripts/remove-onedrive.ps1))
- Run WinAero Tweaker for Extra UI Customization and tell how to import my Profile; ([`manual-debloat-softwares.ps1`](./scripts/manual-debloat-softwares.ps1))
- [Optional] Try to Completely fix the Windows worst problems via Command Line; ([`repair-windows.ps1`](./scripts/repair-windows.ps1))
- In the End it Locks Script's Usage Permission. ([`Win10Script.ps1`](./Win10Script.ps1))

***Default**:  That means i didn't Modified the File.

***Optional**: Means that you decide what to do.

## Known Issues 

- Start menu Search (`WSearch` indexing service will be disabled)
- ~Sysprep will hang~ ...? (Don't know what's that)
- [~Xbox Wireless Adapter~](https://github.com/W4RH4WK/Debloat-Windows-10/issues/78) (Fixed by not disabling the `XboxGipSvc` service)
- [Issues with Skype](https://github.com/W4RH4WK/Debloat-Windows-10/issues/79) (`Microsoft.SkypeApp` app will be uninstalled)
- [Fingerprint Reader / Facial Detection not Working](https://github.com/W4RH4WK/Debloat-Windows-10/issues/189) (`WbioSrvc` service will be disabled)

## Contribute

I would be happy to extend the collection of scripts. 
Just open an issue or send me a pull request. (Yes, if its useful, you can).

### Thanks To

- [W4RH4WK](https://github.com/W4RH4WK) (For his project ^^)
- [Sergey Tkachenko](https://winaero.com/) (*WinAero Tweaker Dev.*)
- [O&O Software GmbH](https://www.oo-software.com/en/company) (*ShutUp10 Dev. Company*)
- [MalwareBytes](https://br.malwarebytes.com/company/) (*AdwCleaner Dev. Company*)
- [10se1ucgo](https://github.com/10se1ucgo)
- [Plumebit](https://github.com/Plumebit)
- [aramboi](https://github.com/aramboi)
- [maci0](https://github.com/maci0)
- [narutards](https://github.com/narutards)
- [tumpio](https://github.com/tumpio)

### Who inspired me to improve more:

- Special thanks to the [LowSpecGamer](https://youtu.be/IU5F01oOzQQ?t=324), he is the reason i've updated this script.

- [Adamx's channel](https://www.youtube.com/channel/UCjidjWX76LR1g5yx18NSrLA) - by [this video](https://youtu.be/hQSkPmZRCjc) 
- [Baboo's channel](https://www.youtube.com/user/baboo) - by [this video](https://youtu.be/qWESrvP_uU8)
- [ChrisTitusTech](https://www.youtube.com/channel/UCg6gPGh8HU2U01vaFCAsvmQ) - gave me more confidence to mess with PowerShell after [this video](https://youtu.be/ER27pGt5wH0)
- [Daniel Persson](https://www.youtube.com/channel/UCnG-TN23lswO6QbvWhMtxpA) - by [this video](https://youtu.be/EfrT_Bvgles)
- [matthewjberger](https://gist.github.com/matthewjberger) - by [this script](https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f)

## More Debloat Scripts (Community)

The scripts are designed to run With/Without (GUI/CLI) any user interaction. Modify them
beforehand. If you want a more interactive approach check out:

### Powershell (Sorted by complexity - Less to More)
- [windows-debloat](https://github.com/kalaspuffar/windows-debloat) from [kalaspuffar](https://github.com/kalaspuffar)
- [Windows10Debloater](https://github.com/Sycnex/Windows10Debloater) from [Sycnex](https://github.com/Sycnex).
- [win10script](https://github.com/ChrisTitusTech/win10script) from [ChrisTitusTech](https://github.com/ChrisTitusTech).
- [Windows 10 Sophia Script](https://github.com/farag2/Windows-10-Sophia-Script) from [farag2](https://github.com/farag2)

### Python
- [DisableWinTracking](https://github.com/10se1ucgo/DisableWinTracking) from [10se1ucgo](https://github.com/10se1ucgo).

## How did i find specific Tweaks?
<details>
    <summary>How To (Advanced Users)</summary>

By using [SysInternal Suite](https://docs.microsoft.com/pt-br/sysinternals/downloads/sysinternals-suite) `Procmon(64).exe`
i could track the `SystemSettings.exe` by filtering it per Process Name, then `Clearing the list (Ctrl + X)`
(But make sure it is `Capturing the Events (Ctrl + E)`) and finally, applying an option of the Windows Configurations
and searching the Registry Key inside `Procmon(64).exe`.

![Grab the current tweak on registry with Procmon64.exe](./lib/images/Grab-the-current-tweak-on-registry-with-Procmon64.png)

After finding the right register Key, you just need to Right-Click and select `Jump To... (Ctrl + J)` to get on its directory.

![Showing on regedit](./lib/images/Showing-on-regedit.png)

</details>

## License

    MIT License

    Copyright (c) 2021 Plínio Larrubia

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.