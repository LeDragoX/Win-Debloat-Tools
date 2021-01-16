<h1>
    <img width=30px src="./lib/images/Windows-10-logo.png"> Win10 Smart Debloat 
    <img width=30px src="./lib/images/PowerShell-icon.png">
</h1>

## Adapted from [W4RH4WK's Project](https://github.com/W4RH4WK/Debloat-Windows-10)

## Download Latest Version

Code located in the `master` branch is always considered under development,
but you'll probably want the most recent version anyway.

- [Download [zip]](https://github.com/LeDragoX/Win10SmartDebloat/archive/master.zip)

## Resume

This project is a modified version of [another project](https://github.com/W4RH4WK/Debloat-Windows-10)
that was made for *Debloat* and *Tweak* Windows 10 for *better performance* and *less issues*.

## Roll-Back

**There is a undo (if works)**, because i did a restoration point script before
doing everything.

**Use on a fresh windows install to note the differences, and if something breaks,**
**you can rely on a pre-made restoration point and the** [`fix-general-problems.ps1`](./scripts/fix-general-problems.ps1) file.

## Usage Requirements

The `Script-Win10.ps1` do not make everything automatically, follow these steps.

- Open `OpenPowershellHere.cmd` (For beginners) or the Powershell as admin on its folder.
- Enable execution of PowerShell scripts and Unblock PowerShell scripts and modules within this directory.

### Easy way (Prepare and Run once):

- Copy and Paste this entire line below on **Powershell**:
```Powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; ls -Recurse .ps1 | Unblock-File; .\"Win10Script.ps1"
```

**[Scripts](/scripts) can be run individually, pick what you need.**

## Script Features

- Import all necessary Modules before Executing everything ([lib folder](lib/))
- Make a Restore Point ([`backup-system.ps1`](./scripts/backup-system.ps1))
- Run WinAero Tweaker for Extra UI Customization and tell how to import my Profile ([`all-in-one-tweaks.ps1`](./scripts/all-in-one-tweaks.ps1))
- Download OOShutUp10 and import my Configuration file
- Disable Telemetry from Scheduled Tasks and Optimize it
- Re-Enable useful Services & Disable the Heavy ones
- Disable Telemetry and Data Collection via Registry
- Apply my UI Personalization tweaks via Registry
- Remove Bloatware Apps that comes with Windows 10, except from my choice
- Enable Optional Features (including WSL 2) especially for Gaming
- [Default] Fix more Privacy problems via Registry and Commands ([`fix-privacy-settings.ps1`](./scripts/fix-privacy-settings.ps1))
- Optimize the Default Windows UI to look more Clean, and fixes the Mouse ([`optimize-user-interface.ps1`](./scripts/optimize-user-interface.ps1))
- [Default] Remove OneDrive completely from the System (Re-installable) ([`remove-onedrive.ps1`](./scripts/remove-onedrive.ps1))
- [Optional] Try to Completely fix the Windows worst problems via Command Line ([`fix-general-problems.ps1`](./scripts/fix-general-problems.ps1))
- In the End it Locks Script's Usage Permission ([`Win10Script.ps1`](./Win10Script.ps1))

* Default:  That means i didn't Modified the File
* Optional: Means that you decide what to do

## Known Issues 

- ~Start menu Search~ (Fixed by enabling `WSearch` service)
- ~Sysprep will hang~ ...? (Don't know what's that)
- [~Xbox Wireless Adapter~](https://github.com/W4RH4WK/Debloat-Windows-10/issues/78) (Fixed by not disabling the `XboxGipSvc` service)
- [Issues with Skype](https://github.com/W4RH4WK/Debloat-Windows-10/issues/79) (`Microsoft.SkypeApp` app will be uninstalled)
- [Fingerprint Reader / Facial Detection not Working](https://github.com/W4RH4WK/Debloat-Windows-10/issues/189) (`WbioSrvc` service will be disabled)

## Contribute

I would be happy to extend the collection of scripts. 
Just open an issue or send me a pull request. (Yes, if its useful, you can).

### Thanks To

- [W4RH4WK](https://github.com/W4RH4WK) (For his project ^^)
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
- [ChrisTitusTech](https://www.youtube.com/channel/UCg6gPGh8HU2U01vaFCAsvmQ) - gave me more confidence to mess with PowerShell after [this video](https://www.youtube.com/watch?v=ER27pGt5wH0)
- [matthewjberger](https://gist.github.com/matthewjberger) - by [this script](https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f)

## Interactivity

The scripts are designed to run without any user interaction. Modify them
beforehand. If you want a more interactive approach check out:
- [DisableWinTracking](https://github.com/10se1ucgo/DisableWinTracking) from [10se1ucgo](https://github.com/10se1ucgo).
- [Windows10Debloater](https://github.com/Sycnex/Windows10Debloater) from [Sycnex](https://github.com/Sycnex).
- [win10script](https://github.com/ChrisTitusTech/win10script) from [ChrisTitusTech](https://github.com/ChrisTitusTech).

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

    "The MIT License"

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