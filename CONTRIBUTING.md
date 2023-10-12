# ➕ Contributing

⚠ **Warning**: this file is subject to changing without notice.

I would be happy to extend the collection of scripts.
If you want to send me a **PULL REQUEST**, send you PRs to the `develop` branch, select your `local branch (from)` and put into `develop`, i'll check your code, request changes if necessary or approve, and merge directly unless it's a "Draft PR".

## 🖌 Coding Style

These aren't extremely strict rules, just the necessary to keep being productive and not staring at rules the entire time.

You can use [this guide](https://github.com/PoshCode/PowerShellPracticeAndStyle) to help with coding on PowerShell (better than i do).

### VS Code settings (Json)

```json
  "editor.detectIndentation": false,
  "[powershell]": {
    "editor.defaultFormatter": "ms-vscode.powershell",
    "editor.insertSpaces": true,
    "editor.tabSize": 4,
    "files.trimTrailingWhitespace": true
  },
  "powershell.codeFormatting.preset": "OTBS",
```

### 📝 Notes

Follow at least the minimal required to help.

#### General coding style

1. **The most important**: _test first in your PC before sending a script change, i'm not willing to put anyone at risk_.
   1. Scripting means changing a environment, molding the way you want, so please, be careful before seeing some "Optimization Guide" (YT has a bunch of this).
   2. That doesn't mean you can't see it, just means you need to check yourself every tweak done, test in your machine or VM (in this case).
2. Explore the `src/scripts` folder before creating a new file
   1. If you want to apply a tweaks that fits a tweak type that already exists, just add to the end of the function, or section with the appropriate changes.
3. Respect the `CI` rules from `PSSCriptAnalyzer` [here](.github/workflows/powershell-linter.yml).
   1. Avoid using `Global` variables, only use if changing a state that can't be made other way.
      1. Like the `Undo Tweaks`, has a `$Global:Revert` which will be changed to a function parameter in future.
   2. Avoid **Trailing lines and Whitespaces**;
   3. Use `CamelCase` to set variables (e.g. `$ExampleVariable`);
   4. To naming functions, use _"Verb-Noun"_ approach from Microsoft: <https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands>
4. This part is peculiar to this script, if you want to Write (echo) some information at the console, please look at the lib i've made, [title-templates](src/lib/title-templates.psm1).
5. If you want to do something that can be done multiple times, check the `lib` folder to see if the function already exists or create a new one if necessary.

## Cloning the repo

**TIP**: To clone quickly, use this command:

### Via HTTPS

```sh
git clone -b develop --filter=tree:0 https://github.com/LeDragoX/Win-Debloat-Tools.git
```

### Or SSH

```sh
git clone -b develop --filter=tree:0 git@github.com:LeDragoX/Win-Debloat-Tools.git
```

## 🔎 How to find specific Tweaks? (One method)

The most registry tweaks can be easily found on the Internet, but what about the ones no one covered?

<details>
  <summary>Click to expand</summary>

### How To: using SysInternal Suite

      Use the method you find better, there are many ways to find a registry tweak, i've found this way so others can try.

By using [SysInternal Suite](https://docs.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite) `Procmon(64).exe` i could track the `SystemSettings.exe` by filtering per Process Name `(Ctrl + L)`.

- But, not every time filtering the application you want will show the registry tweaks that were applied, so make sure other processes appear.
- Then use `Clearing the list (Ctrl + X)` (But make sure it is `Capturing the Events (Ctrl + E)`) and finally, applying an option of the Windows Configurations
  and searching the Registry Key inside `Procmon(64).exe`.
- Also make sure to disable the Events being captured `(Ctrl + E)` after applying a specific config.

After finding the right register Key, you just need to Right-Click and select `Jump To... (Ctrl + J)` to get on it's directory.

</details>

### 🧊 Note about registry

This may not apply to every registry key found, but can help a lot to understand what something is doing and what is the scope.

When changing the registry on:

- **HKEY_LOCAL_MACHINE**: means that the value applied will affect all users and may **lock** the feature from being changed.
- **HKEY_CURRENT_USER**: means that only the current user will be afected by the value applied.
