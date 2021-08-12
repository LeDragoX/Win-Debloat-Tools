<h1 align="center">
    <img width=30px src="./src/lib/images/windows-11-logo.png" style="vertical-align: bottom"> Win10 Smart Debloat 
    <img width=30px src="./src/lib/images/powershell-icon.png" style="vertical-align: bottom">
</h1>

<h2 align="center">

Adapted from [W4RH4WK's Project](https://github.com/W4RH4WK/Debloat-Windows-10)

</h2>

## 🚀 Download Latest Version

Code located in the `main` branch is always considered under development,
but you'll probably want the most recent version anyway.

<div align="center">

|                                                Download                                                 | Version Supported | Build | Editions |                                        Powershell version                                         |
| :-----------------------------------------------------------------------------------------------------: | :---------------: | :---: | :------: | :-----------------------------------------------------------------------------------------------: |
| <h3><a href="https://github.com/LeDragoX/Win10SmartDebloat/archive/main.zip">🚀 Download [Zip]</a></h3> |   21H2 or Older   | 22000 | Home/Pro | <img width=20px src="./src/lib/images/powershell-icon.png" style="vertical-align: bottom" /> v5.1 |

</div>

## 📄 Resume

This is an adapted version from [another project](https://github.com/W4RH4WK/Debloat-Windows-10).
These scripts will Customize, Debloat and Improve Security/Performance on Windows 10/+.

_Use on a fresh windows install to note the differences._

⚠️ **Disclaimer:** You're doing this at your own risk, I am not responsible for any data loss or damage that may occur.

## 🔄️ Roll-Back

**If something breaks you can rely on:**.

1.  A restoration point;
2.  The [`repair-windows.ps1`](./src/scripts/repair-windows.ps1) file or button on [`Win10ScriptGUI.ps1`](./Win10ScriptGUI.ps1);
3.  If you want (almost) everything to it's original state, use the `Revert Tweaks` button on [`Win10ScriptGUI.ps1`](./Win10ScriptGUI.ps1).

## ❗ Usage Requirements

The `Script-Win10.ps1` do not make everything automatically, follow these steps.

- Open `OpenPowershellHere.cmd` (For beginners) or the Powershell as admin on its folder.
- Enable execution of PowerShell scripts and Unblock PowerShell scripts and modules within this directory.

### **GUI Version**

- Copy and Paste this entire line below on **Powershell**:

```ps1
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; ls -Recurse *.ps*1 | Unblock-File; .\"Win10ScriptGUI.ps1"
```

![Script GUI](./src/lib/images/script-gui.png)

_The `Apply Tweaks` button is the main one._

### **CLI Version** (Advice - If you want FULL Output to be displayed on the console, use this version)

- Copy and Paste this entire line below on **Powershell**:

```ps1
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; ls -Recurse *.ps*1 | Unblock-File; .\"Win10Script.ps1"
```

**[Scripts](./src/scripts) can be run individually, pick what you need.**

## ✅ GUI Script Features

<details>
    <summary>Click to expand</summary>

- `Apply Tweaks`: Run every 'non-interactive' Tweak scripts;
- `Repair Windows`: Try to Completely fix the Windows worst problems via Command Line; ([`backup-system.ps1`](./src/scripts/backup-system.ps1) and [`repair-windows.ps1`](./src/scripts/repair-windows.ps1))
- `Revert Tweaks`: Re-apply some tweaks and revert all possible ones, covering the `Scheduled Tasks`, `Services`, `Privacy and Performance`, `Personal` and `Optional Features` tweaks;
- `Dark Mode & Light Mode`: Apply [Dark Mode](./src/utils/dark-theme.reg) or [Light Mode](./src/utils/light-theme.reg) exclusively from GUI;
- `Enable Cortana & Disable Cortana`: Let you choose whether the cortana is [enabled](./src/utils/enable-cortana.reg) or [disabled](src/utils/disable-cortana.reg);
- `Enable Full Telemetry & Disable Telemetry`: Let you choose whether the Telemetry is [FULL enabled](./src/utils/enable-telemetry.ps1) (For those who wants to join Windows insider) or [disabled](src/utils/disable-telemetry.ps1);
- `Install CPU/GPU Drivers (Winget/Chocolatey)`: Install CPU and GPU drivers. ([`install-drivers.ps1`](./src/scripts/install-drivers.ps1));
  - The Latest CPU (`Intel (Winget)` and [AMD](https://community.chocolatey.org/packages/amd-ryzen-chipset)) driver installer;
  - The Lastest Graphics driver of your GPU (Except AMD). See `Intel (Winget)` and [NVIDIA](https://community.chocolatey.org/packages/geforce-game-ready-driver), including `GeForce Experience (Winget)`);
- `Install Gaming Dependencies`: Install all Gaming Dependencies required to play games. ([`install-gaming-dependencies.ps1`](./src/scripts/install-gaming-dependencies.ps1));
- Every software installation is explicitly showed;

</details>

## ☑️ Common Script Features

<details>
    <summary>Click to expand</summary>

- Import all necessary Modules before Executing everything; ([lib folder](./src/lib/))
- Make a Restore Point and Backup the Hosts file; ([`backup-system.ps1`](./src/scripts/backup-system.ps1))
- Download OOShutUp10 and import all Recommended settings; ([`silent-debloat-softwares.ps1`](./src/scripts/silent-debloat-softwares.ps1))
- Download AdwCleaner and Run the latest version of for Virus/Adware scan;
- Disable Telemetry from Scheduled Tasks and Optimize it; ([`optimize-scheduled-tasks.ps1`](./src/scripts/optimize-scheduled-tasks.ps1))
- Disable heavy Services; ([`optimize-services.ps1`](./src/scripts/optimize-services.ps1))
- Remove Bloatware Apps that comes with Windows 10, except from my choice; ([`remove-bloatware-apps.ps1`](./src/scripts/remove-bloatware-apps.ps1))
- Optimize Privacy and Performance settings disabling more telemetry stuff and changing GPOs; ([`optimize-privacy-and-performance.ps1`](./src/scripts/optimize-privacy-and-performance.ps1))
- Apply General Personalization tweaks via Registry and Powershell commands; ([`personal-tweaks.ps1`](./src/scripts/personal-tweaks.ps1))
- Help improve the Security of Windows by a little; ([`optimize-security.ps1`](./src/scripts/optimize-security.ps1))
- Disable and Enable Optional Features specially for Gaming/Work (including WSL 2); ([`optimize-optional-features.ps1`](./src/scripts/optimize-optional-features.ps1))
- Remove OneDrive completely from the System, re-install is possible via Win Store; ([`remove-onedrive.ps1`](./src/scripts/remove-onedrive.ps1))
- Install _Chocolatey/Winget_ by default; ([`install-package-managers.ps1`](./src/scripts/install-package-managers.ps1))
- In the End it Locks Script's Usage Permission. (`Win10Script(GUI).ps1`)

</details>

## ⚡ Troubleshooting

> For each issue, expand the problem you're looking for,
> and Open PowerShell as admin to copy paste it's content:

<details>
<summary>Start menu Search (<code>WSearch</code> indexing service will be disabled).</summary>

```Powershell
Get-Service WSearch | Set-Service -StartupType Automatic -PassThru | Start-Service
```

</details>

<details>
<summary><a href="https://github.com/W4RH4WK/Debloat-Windows-10/issues/79">Issues with Skype</a> (<code>Microsoft.SkypeApp</code> app will be uninstalled).</summary>

```Powershell
# Winget required first
winget install --silent "Microsoft.Skype"
```

</details>

<details>
<summary><a href="https://github.com/W4RH4WK/Debloat-Windows-10/issues/189">Fingerprint Reader / Facial Detection not Working</a> (<code>WbioSrvc</code> service will be disabled).</summary>

```Powershell
Get-Service WbioSrvc | Set-Service -StartupType Automatic -PassThru | Start-Service
```

</details>

<details>
<summary>Bluestacks doesn't work with <code>Hyper-V</code> enabled.</summary>

```Powershell
Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName "Microsoft-Hyper-V-All"
Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName "HypervisorPlatform"
Disable-WindowsOptionalFeature -Online -NoRestart -FeatureName "VirtualMachinePlatform"
```

</details>

<details>
<summary>Taskbar Widgets disappeared (Win11).</summary>

```Powershell
# Needs reboot to work properly
Add-AppxPackage -register "$env:ProgramFiles\WindowsApps\*MicrosoftWindows.Client.WebExperience*\AppxManifest.xml" -DisableDevelopmentMode
```

</details>

<details>
<summary>Sysprep will hang (Not Tested).</summary>

> _No solution yet, do a Google search_

</details>

## ➕ Contribute

I would be happy to extend the collection of scripts.
Just open an issue or send me a pull request. (Yes, if its useful, you can).

## 🤍 Credits

- Special thanks to the [LowSpecGamer](https://youtu.be/IU5F01oOzQQ?t=324), he is the reason i've adapted this script.

- [W4RH4WK](https://github.com/W4RH4WK) (For his project ^^);
- [O&O Software GmbH](https://www.oo-software.com/en/company) (_ShutUp10 Company_);
- [MalwareBytes](https://br.malwarebytes.com/company/) (_AdwCleaner Company_);
- [Adamx's channel](https://www.youtube.com/channel/UCjidjWX76LR1g5yx18NSrLA) - by [this video](https://youtu.be/hQSkPmZRCjc);
- [Baboo's channel](https://www.youtube.com/user/baboo) - by [this video](https://youtu.be/qWESrvP_uU8);
- [ChrisTitusTech](https://www.youtube.com/channel/UCg6gPGh8HU2U01vaFCAsvmQ) - gave me more confidence to mess with PowerShell after [this LIVE](https://youtu.be/ER27pGt5wH0)
- [Daniel Persson](https://www.youtube.com/channel/UCnG-TN23lswO6QbvWhMtxpA) - by [this video](https://youtu.be/EfrT_Bvgles);
- [matthewjberger](https://gist.github.com/matthewjberger) - by [this script](https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f).

## 🏅 More Debloat Scripts (Community)

<details>
    <summary>Click to expand</summary>
<p>The scripts are designed to run With/Without (GUI/CLI) any user interaction. Modify them beforehand. If you want a more interactive approach check out:</p>

- [win10script](https://github.com/ChrisTitusTech/win10script) from [ChrisTitusTech](https://github.com/ChrisTitusTech) (Recommended);
- [Windows10Debloater](https://github.com/Sycnex/Windows10Debloater) from [Sycnex](https://github.com/Sycnex);
- [Windows 10 Sophia Script](https://github.com/farag2/Windows-10-Sophia-Script) from [farag2](https://github.com/farag2).
</details>

## 🔎 How did i find specific Tweaks?

<details>
    <summary>Click to expand</summary>
<p>How To (Advanced Users)</p>

By using [SysInternal Suite](https://docs.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite) `Procmon(64).exe`
i could track the `SystemSettings.exe` by filtering it per Process Name, then `Clearing the list (Ctrl + X)`
(But make sure it is `Capturing the Events (Ctrl + E)`) and finally, applying an option of the Windows Configurations
and searching the Registry Key inside `Procmon(64).exe`.

![Grab the current tweak on registry with Procmon64.exe](./src/lib/images/grab-the-current-tweak-on-registry-with-procmon64.png)

After finding the right register Key, you just need to Right-Click and select `Jump To... (Ctrl + J)` to get on its directory.

![Showing on regedit](./src/lib/images/showing-on-regedit.png)

</details>

## 📝 License

Check the License file [here](./LICENSE).
