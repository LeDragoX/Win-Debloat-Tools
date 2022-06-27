Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"download-web-file.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"get-hardware-info.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://github.com/ChrisTitusTech/win10script/blob/master/win10debloat.ps1
# Adapted from: https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/utils/install-basic-software.ps1

function Install-PackageManager() {
    [CmdletBinding()]
    param (
        [String]	  $PackageManagerFullName,
        [ScriptBlock] $CheckExistenceBlock,
        [ScriptBlock] $InstallCommandBlock,
        [Parameter(Mandatory = $false)]
        [String]      $Time,
        [Parameter(Mandatory = $false)]
        [ScriptBlock] $UpdateScriptBlock,
        [Parameter(Mandatory = $false)]
        [ScriptBlock] $PostInstallBlock
    )

    Try {
        $err = $null
        $err = (Invoke-Expression "$CheckExistenceBlock")
        if (($LASTEXITCODE)) { throw $err } # 0 = False, 1 = True
        Write-Status -Types "?" -Status "$PackageManagerFullName is already installed." -Warning
    } Catch {
        Write-Status -Types "?" -Status "$PackageManagerFullName was not found." -Warning
        Write-Status -Types "+" -Status "Downloading and Installing $PackageManagerFullName package manager."

        Invoke-Expression "$InstallCommandBlock"

        If ($PostInstallBlock) {
            Write-Status -Types "+" -Status "Executing post install script: { $("$PostInstallBlock".Trim(' ')) }."
            Invoke-Expression "$PostInstallBlock"
        }
    }

    # Self-reminder, this part stay out of the Try-Catch block
    If ($UpdateScriptBlock) {
        # Adapted from: https://blogs.technet.microsoft.com/heyscriptingguy/2013/11/23/using-scheduled-tasks-and-scheduled-jobs-in-powershell/
        Write-Status -Types "@" -Status "Creating a daily task to automatically upgrade $PackageManagerFullName packages at $Time."
        $JobName = "$PackageManagerFullName Daily Upgrade"
        $ScheduledJob = @{
            Name               = $JobName
            ScriptBlock        = $UpdateScriptBlock
            Trigger            = New-JobTrigger -Daily -At $Time
            ScheduledJobOption = New-ScheduledJobOption -RunElevated -MultipleInstancePolicy StopExisting -RequireNetwork
        }

        If (Get-ScheduledJob -Name $JobName -ErrorAction SilentlyContinue) {
            Write-Status -Types "@" -Status "ScheduledJob: $JobName FOUND!"
            Write-Status -Types "@" -Status "Re-Creating with the command:"
            Write-Host " { $("$UpdateScriptBlock".Trim(' ')) }`n" -ForegroundColor Cyan
            Unregister-ScheduledJob -Name $JobName
            Register-ScheduledJob @ScheduledJob | Out-Null
        } Else {
            Write-Status -Types "@" -Status "Creating Scheduled Job with the command:"
            Write-Host " { $("$UpdateScriptBlock".Trim(' ')) }`n" -ForegroundColor Cyan
            Register-ScheduledJob @ScheduledJob | Out-Null
        }
    }
}

function Install-WingetDependency() {
    # Dependency for Winget: https://docs.microsoft.com/pt-br/troubleshoot/cpp/c-runtime-packages-desktop-bridge#how-to-install-and-update-desktop-framework-packages
    $OSArchList = Get-OSArchitecture

    ForEach ($OSArch in $OSArchList) {
        If ($OSArch -like "x64" -or "x86" -or "arm64" -or "arm") {
            $WingetDepOutput = Request-FileDownload -FileURI "https://aka.ms/Microsoft.VCLibs.$OSArch.14.00.Desktop.appx" -OutputFile "Microsoft.VCLibs.14.00.Desktop.appx"
            Add-AppxPackage -Path $WingetDepOutput
            Remove-Item -Path $WingetDepOutput
        } Else {
            Write-Status -Types "?" -Status "$OSArch is not supported!" -Warning
        }
    }
}

function Main() {
    $WingetParams = @{
        Name                = "Winget"
        CheckExistenceBlock = { winget --version }
        InstallCommandBlock =
        {
            Install-WingetDependency
            $WingetOutput = Get-APIFile -URI "https://api.github.com/repos/microsoft/winget-cli/releases/latest" -ObjectProperty "assets" -FileNameLike "*.msixbundle" -PropertyValue "browser_download_url" -OutputFile "winget-latest.appxbundle"
            Add-AppxPackage -Path $WingetOutput
            Remove-Item -Path $WingetOutput
        }
        Time                = "12:00"
        UpdateScriptBlock   =
        {
            Remove-Item -Path "$env:TEMP\Win10-SDT-Logs\*" -Include "WingetDailyUpgrade_*.log"
            Start-Transcript -Path "$env:TEMP\Win10-SDT-Logs\WingetDailyUpgrade_$(Get-Date -Format "yyyy-MM-dd_HH-mm-ss").log"
            Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force # Only needed to run Winget
            winget upgrade --all --silent | Out-Host
            Stop-Transcript
        }
    }

    $ChocolateyParams = @{
        Name                = "Chocolatey"
        CheckExistenceBlock = { choco --version }
        InstallCommandBlock =
        {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        }
        Time                = "13:00"
        UpdateScriptBlock   =
        {
            Remove-Item -Path "$env:TEMP\Win10-SDT-Logs\*" -Include "ChocolateyDailyUpgrade_*.log"
            Start-Transcript -Path "$env:TEMP\Win10-SDT-Logs\ChocolateyDailyUpgrade_$(Get-Date -Format "yyyy-MM-dd_HH-mm-ss").log"
            choco upgrade all -y | Out-Host
            Stop-Transcript
        }
        PostInstallBlock    = { choco install -y "chocolatey-core.extension" "chocolatey-fastanswers.extension" "dependency-windows10" }
    }

    # Install Winget on Windows
    Install-PackageManager -PackageManagerFullName $WingetParams.Name -CheckExistenceBlock $WingetParams.CheckExistenceBlock -InstallCommandBlock $WingetParams.InstallCommandBlock -Time $WingetParams.Time -UpdateScriptBlock $WingetParams.UpdateScriptBlock
    # Install Chocolatey on Windows
    Install-PackageManager -PackageManagerFullName $ChocolateyParams.Name -CheckExistenceBlock $ChocolateyParams.CheckExistenceBlock -InstallCommandBlock $ChocolateyParams.InstallCommandBlock -Time $ChocolateyParams.Time -UpdateScriptBlock $ChocolateyParams.UpdateScriptBlock -PostInstallBlock $ChocolateyParams.PostInstallBlock
}

Main