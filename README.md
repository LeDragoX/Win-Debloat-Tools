<h1>
    <img width=30px src="./lib/images/Windows-10-logo.png"> Win10 Smart Debloat 
    <img width=30px src="./lib/images/PowerShell-icon.png">
</h1>

## Original Project from [W4RH4WK](https://github.com/W4RH4WK/Debloat-Windows-10)

## Warning 

==> __*All scripts are provided as-is and you use them at your own risk.*__ <==

==> __*The last part of `fix-general-problems.ps1` will restart your internet connection for a while.*__ <==

==> __*You were warned.*__ <==

## Download Latest Version

Code located in the `master` branch is always considered under development,
but you'll probably want the most recent version anyway.

- [Download [zip]](https://github.com/LeDragoX/Win10SmartDebloat/archive/master.zip)

## Resume

This project is a modified version of [another project](https://github.com/W4RH4WK/Debloat-Windows-10)
that was made for debloat and tweak Windows 10 for better performance and less issues,
i've done some changes so it won't annoy by unninstalled apps, and keeps stability
for games and daily drive.

**There is a undo (if works)**, because i did a restoration point script before
doing everything.

**Use on a fresh windows install to note the differences, and if something breaks,**
**you can rely on a pre-made restoration point and the** `fix-general-problems.ps1`.

## 1. How to use
### 1.1 - Requirements

If the `Script-Win10.ps1` do not make that automatically, follow these steps.

- Open `RunPowershellHere.cmd` (For beginners) or the Powershell as admin on its folder.
- Enable execution of PowerShell scripts and Unblock PowerShell scripts and modules within this directory.
- Copy and Paste this line on **Powershell**:

#### 1.1.1 - Easy way (Run once):

```Powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; ls -Recurse .ps1 | Unblock-File; .\"Win10Script.ps1"
```
#### 1.1.2 - Old way (For compatibility):

```Powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser; ls -Recurse .ps1 | Unblock-File
```
- Type what matches 'Yes' on your language and hit Enter.

### 1.2 - Running the Script
#### - Method 1
- Run the `Script-Win10.ps1` from the opened powershell.
```Powershell
.\"Win10Script.ps1"
```
- Or follow this method down here.
#### - Method 2
- On the `Script-Win10.ps1` file,
- Right click on it
- Select `Run with Powershell`
- Click `Yes` and there you go.

**[Scripts](/scripts) can be run individually, pick what you need.**

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
- [ChrisTitusTech](https://www.youtube.com/channel/UCg6gPGh8HU2U01vaFCAsvmQ) - gave me more confidence to mess with PowerShell by [this video](https://www.youtube.com/watch?v=ER27pGt5wH0)
- [matthewjberger](https://gist.github.com/matthewjberger) - by [this script](https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f)

## Interactivity

The scripts are designed to run without any user interaction. Modify them
beforehand. If you want a more interactive approach check out:
- [DisableWinTracking](https://github.com/10se1ucgo/DisableWinTracking) from [10se1ucgo](https://github.com/10se1ucgo).
- [Windows10Debloater](https://github.com/Sycnex/Windows10Debloater) from [Sycnex](https://github.com/Sycnex).
- [win10script](https://github.com/ChrisTitusTech/win10script) from [ChrisTitusTech](https://github.com/ChrisTitusTech).

## How did i find specific Tweaks?

By using [SysInternal Suite](https://docs.microsoft.com/pt-br/sysinternals/downloads/sysinternals-suite) `Procmon(64).exe`
i could track the `SystemSettings.exe` by filtering it per Process Name, then Clearing the list (Ctrl + X)
and finally, applying an option of the Windows Configurations and searching the Registry Key inside `Procmon(64).exe`.

### Screenshot

![Grab the current tweak on registry with Procmon64.exe](./lib/images/Grab-the-current-tweak-on-registry-with-Procmon64.png)

After finding the right register Key, you just need to Right-Click and select `Jump To...` to get on its directory.

![Showing on regedit](./lib/images/Showing-on-regedit.png)


## License

    "The Unlicense License"

    This is free and unencumbered software released into the public domain.

    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.

    In jurisdictions that recognize copyright laws, the author or authors
    of this software dedicate any and all copyright interest in the
    software to the public domain. We make this dedication for the benefit
    of the public at large and to the detriment of our heirs and
    successors. We intend this dedication to be an overt act of
    relinquishment in perpetuity of all present and future rights to this
    software under copyright law.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
    OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.

    For more information, please refer to <http://unlicense.org/>