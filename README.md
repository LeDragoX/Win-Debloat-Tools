<!--
Self reminder: If i'm willing to change the repository name (again...why???)
I need to change these files:
- src\lib\start-logging.psm1
- src\lib\title-templates.psm1 (LOGO)
- CONTRIBUTING.md
- README.md
- Win10ScriptGUI.ps1 (Window Title)
-->

<h1 align="center">
  <img width=30px src="src/assets/windows-11-logo.png" style="vertical-align: bottom"> Win Debloat Tools (10+)
  <img width=30px src="src/assets/powershell-icon.png" style="vertical-align: bottom">
</h1>

<h2 align="center"><i>This Project was adapted from <a href="https://github.com/W4RH4WK/Debloat-Windows-10">W4RH4WK's Project</a></i></h2>

These scripts will Customize, Debloat and Improve Privacy/Performance and System Responsiveness on Windows 10+. A collection of scripts to organize the tweaks per category, using different functions to adjust the system settings and make Windows great again! You can also install your favorite softwares through the GUI with just one click after being selected.

> _Use on a fresh windows install to note the differences._

⚠️ **Disclaimer:** You're doing this at your own risk, I am not responsible for any data loss or damage that may occur.

<h1 align="center">

[![PSScriptAnalyzer](https://github.com/LeDragoX/Win-Debloat-Tools/actions/workflows/powershell-linter.yml/badge.svg?style=flat)](https://github.com/LeDragoX/Win-Debloat-Tools/actions/workflows/powershell-linter.yml)
![GitHub issues](https://img.shields.io/github/issues/LeDragoX/Win-Debloat-Tools?label=Issues)
![GitHub license](https://img.shields.io/github/license/LeDragoX/Win-Debloat-Tools?color=blue&label=License)
[![Commit rate](https://img.shields.io/github/commit-activity/m/LeDragoX/Win-Debloat-Tools?label=Commits)](https://github.com/LeDragoX/Win-Debloat-Tools/commits/master)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/LeDragoX/Win-Debloat-Tools/main?label=Last%20commit)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/LeDragoX/Win-Debloat-Tools?label=Code%20size)

</h1>

## 🚀 Download Latest Version

Code located in the `main` branch is considered stable,
the `develop` branch is the most recent version.

<div align="center">
  <table>
    <thead align="center">
      <tr>
        <th>Download</th>
        <th>Version(s) Supported</th>
        <th>Edition(s)</th>
        <th>PowerShell Version</th>
      </tr>
    </thead>
    <tbody align="center">
      <tr>
        <td align="left">
            <h4><a href="https://github.com/LeDragoX/Win-Debloat-Tools/archive/main.zip">⬇️ Main - Stable</a></h4>
        </td>
        <td rowspan="2">21H2 or Older</td>
        <td rowspan="2">Home / Pro</td>
        <td rowspan="2"><img width=20px src="src/assets/powershell-icon.png" style="vertical-align: bottom" /> v5.1+</td>
      </tr>
      <tr>
        <td align="left">
            <h5><a href="https://github.com/LeDragoX/Win-Debloat-Tools/archive/develop.zip">⬇️ Develop - Newer</a></h5>
        </td>
      </tr>
    </tbody>
  </table>
</div>

## 🔄️ Roll-Back

**If something breaks you can rely on:**

1. A restoration point;
2. The [`repair-windows.ps1`](./src/scripts/repair-windows.ps1) file or button on [`Win10ScriptGUI.ps1`](./Win10ScriptGUI.ps1);
3. If you want (almost) everything to it's original state, use the `Undo Tweaks` button on [`Win10ScriptGUI.ps1`](./Win10ScriptGUI.ps1).

## ❗ Usage Requirements

The `Win10Script(CLI/GUI).ps1` do not make everything automatically, follow these steps.

- Extract the `.zip` file.
- Open `OpenTerminalHere.cmd` (For beginners) or the Powershell as admin on it's folder.
- Enable execution of PowerShell scripts and Unblock PowerShell scripts and modules within this directory (Down below).

### **GUI Version**

- Copy and Paste this entire line below on **Powershell**:

```ps1
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; ls -Recurse *.ps*1 | Unblock-File; .\"Win10ScriptGUI.ps1"
```

![Script GUI](./src/assets/script-gui.gif)

_The `Apply Tweaks` button is the main one for debloating._

### **CLI Version** (Minimal, good for automation)

- Copy and Paste this entire line below on **Powershell**:

```ps1
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force; ls -Recurse *.ps*1 | Unblock-File; .\"Win10ScriptCLI.ps1"
```

**[Scripts](./src/scripts) can be run individually, pick what you need.**

## ✅ GUI Script Features

<details>
  <summary>Click to expand</summary>

### System Tweaks

#### System Debloat Tools

- `Apply Tweaks`: Run every Common Tweak scripts;
- `Undo Tweaks`: Re-apply some tweaks and [Revert] all possible ones, covering the `Scheduled Tasks`, `Services`, `Privacy and Performance`, `Personal` and `Optional Features` tweaks, then try to `Reinstall Pre-Installed Apps`;
- `Remove OneDrive`: completely removes OneDrive from the System, re-install is possible via Win Store; ([`remove-onedrive.ps1`](./src/scripts/remove-onedrive.ps1))
- `Remove Xbox`: Wipe Xbox Apps, disable Services related to Xbox and GameBar/GameDVR; ([`remove-xbox.ps1`](./src/scripts/remove-xbox.ps1))
- `Install OneDrive`: Tries to re-install the built-in OneDrive; ([`install-onedrive.ps1`](./src/utils/install-onedrive.ps1))
- `Reinstall Pre-Installed Apps`: Rebloat Windows with all the Pre-Installed Apps; ([`reinstall-pre-installed-apps.ps1`](./src/utils/reinstall-pre-installed-apps.ps1))
- `Repair Windows`: Try to Completely fix the Windows worst problems via Command Line; ([`backup-system.ps1`](./src/scripts/backup-system.ps1) and [`repair-windows.ps1`](./src/scripts/repair-windows.ps1))
- `Show Debloat Info`: Make an overall check-up from disabled and enabled Windows Components (Compare before and after applying tweaks, it's a great difference); ([`show-debloat-info.ps1`](./src/utils/show-debloat-info.ps1))

#### [System Apps](src/utils/install-individual-system-apps.psm1)

- This section contains options to restore the system apps, by downloading them from the **MS Store** (mostly) and doing **Stock configurations** (for some Apps).

#### Other Tools

- This section contains tools to solve some Windows problems and get info about how much debloated the system is.

#### [Customize System Features](src/utils/individual-tweaks.psm1)

- `Enable/Disable Dark Theme`: Apply `Dark Theme` or `Light Theme` on Windows;
- `Enable/Disable Activity History`: Enables or Disables the **Activity History**;
- `Enable/Disable Background Apps`: Enables or Disables _ALL_ the **Background Apps**;
- `Enable/Disable Clipboard History`: Enables or Disables the **Clipboard History**;
- `Enable/Disable Cortana`: Enables or Disables the **Cortana**;
- `Enable/Disable Old Volume Control`: Enables or Disables the **Old Volume Control (Win 7/8.1)**;
- `Enable/Disable Photo Viewer`: [Enables](./src/utils/enable-photo-viewer.reg) or [Disables](src/utils/disable-photo-viewer.reg) the **Photo Viewer (Win 7/8.1)**;
- `Enable/Disable Search App for Unknown Ext.`: When running a unknown extension file, be able to search through **MS Store** for an App that can open it.
- `Enable/Disable Telemetry`: Enables or Disables the **Windows Telemetry**;
- `Enable/Disable WSearch Service`: Enables or Disables the **Windows Search Service**;
- `Enable/Disable Xbox GameBar/DVR`: Enables or Disables the **Xbox GameBar DVR (In-Game)**, that can record clips from games;

#### [Optional Features](src/utils/individual-tweaks.psm1)

- This section can manually adjust `Optional Features` from the system, working as a ON/OFF toggle.

#### [Miscellaneous Features](src/utils/individual-tweaks.psm1)

- `Get H.265 video codec`: Get the missing HEVC support to run **H.265 videos** through MS Store, it's a must have and not stock feature (Free and DIY).
- `Enable/Disable Encrypted DNS`: Sets the DNS Client Servers to **Cloudflare's** and **Google's** (ipv4 and ipv6), and enables **DNS Over HTTPS** on _Windows 11_.
- `Enable/Disable God Mode`: Enables or Disables the hidden Desktop folder **God Mode**;
- `Enable/Disable Take Ownership menu`: [Enables](./src/utils/enable-take-ownership-context-menu.reg) or [Disables](src/utils/disable-take-ownership-context-menu.reg) the **Take Ownership context menu**;
- `Enable/Disable Shutdown PC shortcut`: Enables or Disables the **Shutdown Computer desktop shortcut**;

### Software Install

- `Upgrade All Softwares`: Upgrades all Softwares installed on your machine installed through _Winget_ and _Chocolatey_.
  - WSL will only update itself, not the distros installed.
- `Install Selected`: Install the selected apps by marking the checkbox(es);
- `Uninstall Mode`: Default as OFF, clicking this will switch the `Install Selected` button to `Uninstall Selected` and uninstall every selected apps (**Advice**: Blue colored buttons may not be able to uninstall completely and WSL UWP Apps, but WSL Distros will be unregistered);

</details>

## ☑️ Common Script Features

<details>
  <summary>Click to expand</summary>

- Import all necessary Modules before Executing everything; ([lib folder](./src/lib/))
- Logs both script versions on `C:\Users\Username\AppData\Local\Temp\Win10-SDT-Logs`;
- Make a Restore Point and Backup the Hosts file; ([`backup-system.ps1`](./src/scripts/backup-system.ps1))
- Install _Winget/Chocolatey_ by default; ([`install-package-managers.ps1`](./src/scripts/install-package-managers.ps1))
  - Auto-Update every available software via `Winget` (12:00/day) and `Chocolatey` (13:00/day);
  - Find the Scheduled Job on `Task Scheduler > "Microsoft\Windows\PowerShell\ScheduledJobs\Chocolatey/Winget Daily Upgrade"`;
  - Register daily upgrade logs on `C:\Users\Username\AppData\Local\Temp\Win10-SDT-Logs` and remove old log files;
- Download AdwCleaner and Run the latest version of for Virus/Adware scan; ([`silent-debloat-softwares.ps1`](./src/scripts/silent-debloat-softwares.ps1))
- Download OOShutUp10 and import all Recommended settings;
- Disable Telemetry from Scheduled Tasks and Optimize it; ([`optimize-task-scheduler.ps1`](./src/scripts/optimize-task-scheduler.ps1))
- Disable heavy Services, but enable some on SSDs for optimum performance; ([`optimize-services.ps1`](./src/scripts/optimize-services.ps1))
- Remove Bloatware UWP Apps that comes with Windows 10+, except from my choice; ([`remove-bloatware-apps.ps1`](./src/scripts/remove-bloatware-apps.ps1))
- Optimize Privacy by disabling more telemetry stuff and changing GPOs; ([`optimize-privacy.ps1`](./src/scripts/optimize-privacy.ps1))
- Optimize Performance by changing away from stock configurations that slowdowns the system; ([`optimize-performance.ps1`](./src/scripts/optimize-performance.ps1))
- Apply General Personalization tweaks via Registry and Powershell commands; ([`personal-tweaks.ps1`](./src/scripts/personal-tweaks.ps1))
- Help improve the Security of Windows while maintaining performance; ([`optimize-security.ps1`](./src/scripts/optimize-security.ps1))
- Disable/Enable Windows Features specially for Gaming/Productivity; ([`optimize-windows-features.ps1`](./src/scripts/optimize-windows-features.ps1))

</details>

## ⚡ Troubleshooting Known Issues

> For each issue, expand the issue you're looking for,
> and Open PowerShell as admin to copy + paste it's content:

<details>
  <summary>Fix <code>NVIDIA Control Panel</code></summary>

> Only this time (Recommended - Consumes less RAM after boot)

```Powershell
Get-Service "NVDisplay.ContainerLocalSystem" | Set-Service -StartupType Manual -PassThru | Start-Service
```

> Permanently (Keeps the service running along with the system)

```Powershell
Get-Service "NVDisplay.ContainerLocalSystem" | Set-Service -StartupType Automatic -PassThru | Start-Service
```

</details>

<details>
  <summary>Sysprep will hang (Not Tested).</summary>

> _No solution yet, do a Google search_

</details>

## 🏅 More Debloat Scripts (Community)

<details>
  <summary>Click to expand</summary>
  <p>The scripts are designed to run With/Without (GUI/CLI) any user interaction. Modify them beforehand. If you want a more interactive approach check out:</p>

- [win10script](https://github.com/ChrisTitusTech/win10script) and [winutil](https://github.com/ChrisTitusTech/winutil) (Recommended) from [ChrisTitusTech](https://github.com/ChrisTitusTech);
- [Windows10Debloater](https://github.com/Sycnex/Windows10Debloater) from [Sycnex](https://github.com/Sycnex);
- [Sophia-Script-for-Windows](https://github.com/farag2/Sophia-Script-for-Windows) from [farag2](https://github.com/farag2);
- [Windows-Optimize-Harden-Debloat](https://github.com/simeononsecurity/Windows-Optimize-Harden-Debloat) and [Windows-Optimize-Debloat](https://github.com/simeononsecurity/Windows-Optimize-Debloat) from [SimeonOnSecurity](https://github.com/simeononsecurity);

</details>

## 🔧 Tweak Testers

- All of _my friends and people_ who trusted on me to run the script;
- [yCr-shiddy](https://github.com/yCr-shiddy) - Helped giving more ideas and fixes;

## 🤍 Credits

- Special thanks to [LowSpecGamer](https://youtu.be/IU5F01oOzQQ?t=324), he is the reason i've adapted this script.
- Special thanks to [Fabio Akita](https://youtu.be/sjrW74Hx5Po?t=318), for making this script famous <3
- [W4RH4WK](https://github.com/W4RH4WK) - For his project ^^

## 📚 Used code references

- [Adamx's](https://www.youtube.com/channel/UCjidjWX76LR1g5yx18NSrLA) - by [_this video_](https://youtu.be/hQSkPmZRCjc) (and script);
- [Baboo's](https://www.youtube.com/user/baboo) - by [_this video_](https://youtu.be/qWESrvP_uU8) (and commands);
- [ChrisTitusTech](https://www.youtube.com/channel/UCg6gPGh8HU2U01vaFCAsvmQ) - by having taught how to mess with PowerShell in [this Stream](https://youtu.be/ER27pGt5wH0) (and his _open-source_ debloat script);
- [Daniel Persson](https://www.youtube.com/channel/UCnG-TN23lswO6QbvWhMtxpA) - by [_this video_](https://youtu.be/EfrT_Bvgles) (and script explanation);
- [matthewjberger](https://gist.github.com/matthewjberger) - by [_this script_](https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f).

## ➕ Contributing

If you want to contribute, please check out the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## 📝 License

Licensed under the [MIT](LICENSE.txt) license.

**MalwareBytes AdwCleaner** and **O&O ShutUp10++** have their own licenses.
