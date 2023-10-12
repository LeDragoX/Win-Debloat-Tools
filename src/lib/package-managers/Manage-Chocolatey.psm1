Import-Module -DisableNameChecking "$PSScriptRoot\Install-PackageManager.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\Manage-DailyUpgradeJob.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\ui\Show-MessageDialog.psm1"

$Script:DoneTitle = "Information"
$Script:DoneMessage = "Process Completed!"

function Install-Chocolatey() {
    [CmdletBinding()]
    param (
        [Switch] $Force
    )

    Begin {
        $ChocolateyParams = @{
            Name                = "Chocolatey"
            CheckExistenceBlock = { choco --version }
            InstallCommandBlock =
            {
                Set-ExecutionPolicy Bypass -Scope Process -Force
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
            }
            PostInstallBlock    = { choco install --ignore-dependencies --yes "chocolatey-core.extension" "chocolatey-fastanswers.extension" }
        }
    }

    Process {
        If ($Force) {
            # Install Chocolatey on Windows
            Install-PackageManager -PackageManagerFullName $ChocolateyParams.Name -CheckExistenceBlock $ChocolateyParams.CheckExistenceBlock -InstallCommandBlock $ChocolateyParams.InstallCommandBlock -PostInstallBlock $ChocolateyParams.PostInstallBlock -Force
        } Else {
            Install-PackageManager -PackageManagerFullName $ChocolateyParams.Name -CheckExistenceBlock $ChocolateyParams.CheckExistenceBlock -InstallCommandBlock $ChocolateyParams.InstallCommandBlock -PostInstallBlock $ChocolateyParams.PostInstallBlock
        }

        If (!$Force) {
            Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
        }
    }
}

# Adapted From: https://community.chocolatey.org/courses/installation/uninstalling#script
function Uninstall-Chocolatey() {
    Process {
        $VerbosePreference = 'Continue'
        if (-not $env:ChocolateyInstall) {
            $message = @(
                "The ChocolateyInstall environment variable was not found."
                "Chocolatey is not detected as installed. Nothing to do."
            ) -join "`n"

            Write-Warning $message
            return Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
        }

        if (-not (Test-Path $env:ChocolateyInstall)) {
            $message = @(
                "No Chocolatey installation detected at '$env:ChocolateyInstall'."
                "Nothing to do."
            ) -join "`n"

            Write-Warning $message
            return Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
        }

        <#
            Using the .NET registry calls is necessary here in order to preserve environment variables embedded in PATH values;
            Powershell's registry provider doesn't provide a method of preserving variable references, and we don't want to
            accidentally overwrite them with absolute path values. Where the registry allows us to see "%SystemRoot%" in a PATH
            entry, PowerShell's registry provider only sees "C:\Windows", for example.
        #>
        $userKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
        $userPath = $userKey.GetValue('PATH', [string]::Empty, 'DoNotExpandEnvironmentNames').ToString()

        $machineKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\ControlSet001\Control\Session Manager\Environment\', $true)
        $machinePath = $machineKey.GetValue('PATH', [string]::Empty, 'DoNotExpandEnvironmentNames').ToString()

        $backupPATHs = @(
            "User PATH: $userPath"
            "Machine PATH: $machinePath"
        )
        $backupFile = "C:\PATH_backups_ChocolateyUninstall.txt"
        $backupPATHs | Set-Content -Path $backupFile -Encoding UTF8 -Force

        $warningMessage = @"
            This could cause issues after reboot where nothing is found if something goes wrong.
            In that case, look at the backup file for the original PATH values in '$backupFile'.
"@

        if ($userPath -like "*$env:ChocolateyInstall*") {
            Write-Verbose "Chocolatey Install location found in User Path. Removing..."
            Write-Warning $warningMessage

            $newUserPATH = @(
                $userPath -split [System.IO.Path]::PathSeparator |
                Where-Object { $_ -and $_ -ne "$env:ChocolateyInstall\bin" }
            ) -join [System.IO.Path]::PathSeparator

            # NEVER use [Environment]::SetEnvironmentVariable() for PATH values; see https://github.com/dotnet/corefx/issues/36449
            # This issue exists in ALL released versions of .NET and .NET Core as of 12/19/2019
            $userKey.SetValue('PATH', $newUserPATH, 'ExpandString')
        }

        if ($machinePath -like "*$env:ChocolateyInstall*") {
            Write-Verbose "Chocolatey Install location found in Machine Path. Removing..."
            Write-Warning $warningMessage

            $newMachinePATH = @(
                $machinePath -split [System.IO.Path]::PathSeparator |
                Where-Object { $_ -and $_ -ne "$env:ChocolateyInstall\bin" }
            ) -join [System.IO.Path]::PathSeparator

            # NEVER use [Environment]::SetEnvironmentVariable() for PATH values; see https://github.com/dotnet/corefx/issues/36449
            # This issue exists in ALL released versions of .NET and .NET Core as of 12/19/2019
            $machineKey.SetValue('PATH', $newMachinePATH, 'ExpandString')
        }

        # Adapt for any services running in subfolders of ChocolateyInstall
        $agentService = Get-Service -Name chocolatey-agent -ErrorAction SilentlyContinue
        if ($agentService -and $agentService.Status -eq 'Running') {
            $agentService.Stop()
        }
        # TODO: add other services here

        Remove-Item -Path $env:ChocolateyInstall -Recurse -Force

        'ChocolateyInstall', 'ChocolateyLastPathUpdate' | ForEach-Object {
            foreach ($scope in 'User', 'Machine') {
                [Environment]::SetEnvironmentVariable($_, [string]::Empty, $scope)
            }
        }

        $machineKey.Close()
        $userKey.Close()

        if ($env:ChocolateyToolsLocation -and (Test-Path $env:ChocolateyToolsLocation)) {
            Remove-Item -Path $env:ChocolateyToolsLocation -Recurse -Force
        }

        foreach ($scope in 'User', 'Machine') {
            [Environment]::SetEnvironmentVariable('ChocolateyToolsLocation', [string]::Empty, $scope)
        }

        Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
    }
}

function Register-ChocolateyDailyUpgrade() {
    Begin {
        $ChocolateyJobParams = @{
            Name              = "Chocolatey"
            Time              = "13:00"
            UpdateScriptBlock =
            {
                Remove-Item -Path "$env:TEMP\Win-Debloat-Tools\logs\*" -Include "ChocolateyDailyUpgrade_*.log"
                Start-Transcript -Path "$env:TEMP\Win-Debloat-Tools\logs\ChocolateyDailyUpgrade_$(Get-Date -Format "yyyy-MM-dd_HH-mm-ss").log"
                choco upgrade all --ignore-dependencies --yes | Out-Host
                Stop-Transcript
            }
        }
    }

    Process {
        Register-DailyUpgradeJob -PackageManagerFullName $ChocolateyJobParams.Name -Time $ChocolateyJobParams.Time -UpdateScriptBlock $ChocolateyJobParams.UpdateScriptBlock
        Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
    }
}

function Unregister-ChocolateyDailyUpgrade() {
    Begin {
        $JobName = "Chocolatey Daily Upgrade"
    }

    Process {
        Unregister-DailyUpgradeJob -Name $JobName
        Show-MessageDialog -Title "$DoneTitle" -Message "$DoneMessage"
    }
}

function Remove-AllChocolateyPackage() {
    Begin {
        Import-Module -DisableNameChecking "$PSScriptRoot\Manage-Software.psm1"
        $Ask = "Are you sure you want to remove:`n$((choco list) -match '\w \d.*\d' | ForEach-Object { "`n- $_" })`n`nPress YES to confirm."
        $Question = Show-Question -Title "Remove ALL Chocolatey Packages?" -Message $Ask -BoxIcon "Warning"
    }

    Process {
        switch ($Question) {
            'Yes' {
                Uninstall-Software -Name "All Chocolatey Packages" -Packages @("all") -PackageProvider 'Chocolatey'
            }
            'No' {
                Write-Host "Aborting..."
            }
            'Cancel' {
                Write-Host "Aborting..." # With Yes, No and Cancel, the user can press Esc to exit
            }
        }
    }
}
