### Future

- [ ] Unpin All "mocked" apps (Apps on the Start Menu which are not installed, but are there).
- [ ] Install Winget via Chocolatey as an another option.

### 2023v2

- [x] Rename all powershell scripts to match it's naming convention.
- [x] Add more features do the GUI by category (Scheduled Tasks, Services, Optional Features, Windows Capabilities, etc).
- [x] Improve Remove MS Edge script.
- [x] Improve Remove Xbox script.
- [x] Fix a few hardcoded scripts.
- [x] Fix issue with URL files.
- [x] Remove DELL and SAMSUNG bloatware apps.
- [x] Add Windows 11 specific tweaks.
- [x] Make Winget/Chocolatey/WSL to install manually.
- [x] Do not add Daily Upgrade tasks to Winget/Chocolatey automatically.
- [x] Only install Winget/Chocolatey/WSL on demand, lower startup time and get strict to the point.

### 2023v1

- [x] Remove more Apps
- [x] Change Windows Update automatic download and install behavior.
- [x] Add NEW script icon.
- [x] Optimize all image files to weight a lot less.
- [x] Update OOShutUp10 settings file.
- [x] Improve lib structure, added `debloat-helper` folder for all debloat tweak related lib.
- [x] Add a script to remove Windows Capabilities.
- [x] Refactor overly complex functions.
- [x] Add new lib to manage Folder/Registry Paths.
- [x] Fix all imports.
- [x] Allow usage of wildcards (*) to select a wider range of apps.
- [x] Add autocomplete to most lib functions.
- [x] Fix Winget and Chocolatey installation.
- [x] Fix the UI from GUI version, allowing more resolutions, and window expansion and shrinking.
- [x] Add a lot of effects to console output, helping visually while debloating.
- [x] Refactor the GUI to get colors through a function.
- [x] Change configuration from Microsoft Edge to prevent running in background.

### 2022v3

- [x] Encrypted DNS is NOT enabled anymore, needed OFF when using public Wi-Fi with redirect to login page or Pi-hole.
- [x] Fixed Xbox Game Bar and DVR tweaks.
- [x] Fixed policies related to Phone Linking.
- [x] Finally added a good design to be the script banner.

### 2022v2

- [x] GUI should scale with DPI with 1 monitor.
  - If the hardware has more than 1 monitor, choose the 2nd method to select the screen resolution (doesn't take DPI).
- [x] The **winget package manager** should install manually and wait if any error appeared.
- [x] Clean up `src/utils` to use one file with `individual tweaks`.
  - Also moved some scripts to `src/scripts/other-scripts/`
- [x] When applying performance tweaks, leave no duplicated power plan on the system.
  - Moved that to `src/lib` as a function.
- [x] Fixed all PATHS when selecting a file location on `download-web-file.psm1` and `open-file.psm1`.
- [x] It is now possible to Re-install Xbox (mostly).
  - Removed XBOX apps from `remove-bloatware-apps.ps1`
- [x] It is possible to **recover** or **disable** some system apps and other features that was only applied on the scripts through GUI.
- [x] As prompted, the script does NOT remove OneDrive automatically, it is located on the GUI now.

### 2022v1

- [x] Update the GUI design to finally look like a real "program", not a weird non-symmetrical interface, which allows to add even more tweaks.
- [x] Added CI to scan the PowerShell files, then show warnings and errors to fix.
- [x] Show system specs easily on the Window Title.
- [x] Doesn't need workarounds with a lot of Global Variables anymore, only the essential.
- [x] Revert tweaks now works properly.
- [x] Ease of life to create and import GPG and SSH keys, as setting a git account.
- [x] Added logging to help in debugging.
- [x] Redesign the GUI, improve the color palette and contrast.
- [x] Allow multi software install at the same time.
- [x] Programs can now be properly uninstalled.
- [x] Fix elements inside panel margin
- [x] Adapt GUI to scale with the resolution (following the native DPI)
- [x] Create libs to change status from `scheduled tasks`, `services` and `optional-windows-features`.
- [x] Use tabs to move through pages on GUI.
- [x] Upgrade all apps through GUI

### 2021v2

- [x] Join other scripts that are helpful inside `src/utils` and `src/utils/DIY` folders.
- [x] Use `Winget` and `Chocolatey`, and update softwares daily, using `winget` as the main package manager.
- [x] Refactor the GUI layout until it's easy to maintain.
- [x] Create functions to generate GUI elements.
- [x] Debloating the debloater.
- [x] Keep `SysMain` and `WSearch` enabled if the "C:" device is a SSD.
- [x] Added option to Remove Xbox (mostly).
- [x] Easy full install of WSL2 for Windows 11.

### 2021v1

- [x] Port the remaining W4RH4WK's code into `src/scripts`, then improve what i tought that should've been improved.
- [x] Put the credits to each person from who i collected the scripts.
- [x] Create local libs to:
  - Grab the hardware/system specs ;
  - Show a message box with Ok, Yes and No;
  - Print special sections on the console;
  - Change script policy;
  - Create a GUI layout;
  - Install Softwares easily via package manager;
- [x] Split `all-in-one-tweaks.ps1` to other files, so `Win10Script.ps1` could make more sense.
- [x] Removed some of the _thirdy-party_ software running with the script and only keep AdwCleaner and OOShutUp10 that could be automated.
- [x] Introduced a GUI to the script, fixed most GUI related bugs, this way it make scripts more accessible and Software Installations A LOT easier.

### 2020v1

- [x] Switch to the `main` branch.
- [x] Refactor all possible `Command Prompt/Registry` code into `Powershell` code
- [x] Translate everything from `PT-BR` to `ENG`, to help all the people around the world.
- [x] Make sure every Windows machine will do anything automated, leaving the configurations to the code itself.
- [x] Separate each essential tweak part into a file to understand with ease it's process, making it more reliable and manutenable.
- [x] Make possible reverting almost all the tweaks made by the script with one click.
- [x] Add a great variety of popular software to install with one click.

## 2018/19 v1

- [x] "Fork" W4RH4WK's script and do personal modifications.
- [x] Check if all the code is safe and can evolve.
- [x] Add an shortcut to open `PowerShell` as an Admin in the same folder.
- [x] Join and Run all Scripts from `src/scripts/` folder into one (`Win10Script.ps1`), running one after another.
- [x] Do a system backup before running every script that change a lot of settings.
- [x] Change the terminal window style to be more cool.
- [x] Only change stuff that will not destroy `Windows` and can be safely reverted (manually).
