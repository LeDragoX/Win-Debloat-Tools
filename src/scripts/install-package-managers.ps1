Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"check-os-info.psm1"

# Adapted from: https://github.com/ChrisTitusTech/win10script/blob/master/win10debloat.ps1
# Adapted from: https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/utils/install-basic-software.ps1

function InstallPackageManager() {
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
        Write-Warning "[?] $PackageManagerFullName is already installed."

    }
    Catch {
        Write-Warning "[?] $PackageManagerFullName was not found."
        Write-Host "[+] Downloading and Installing $PackageManagerFullName package manager."

        Invoke-Expression "$InstallCommandBlock"

        If ($PostInstallBlock) {
            Write-Host "[+] Executing post install script: $PostInstallBlock."
            Invoke-Expression "$PostInstallBlock"
        }
    }

    # Self-reminder, this part stay out of the Try-Catch block
    If ($UpdateScriptBlock) {
        # Adapted from: https://blogs.technet.microsoft.com/heyscriptingguy/2013/11/23/using-scheduled-tasks-and-scheduled-jobs-in-powershell/
        Write-Host "[@] Creating a daily task to automatically upgrade $PackageManagerFullName packages at $Time."
        $JobName = "$PackageManagerFullName Daily Upgrade"
        $ScheduledJob = @{
            Name               = $JobName
            ScriptBlock        = $UpdateScriptBlock
            Trigger            = New-JobTrigger -Daily -At $Time
            ScheduledJobOption = New-ScheduledJobOption -RunElevated -MultipleInstancePolicy StopExisting -RequireNetwork
        }

        If (Get-ScheduledJob -Name $JobName -ErrorAction SilentlyContinue) {
            Write-Host "[@] ScheduledJob: $JobName FOUND! Re-Creating..."
            Unregister-ScheduledJob -Name $JobName
        }
        Register-ScheduledJob @ScheduledJob | Out-Host
    }
}

function Main() {

    # Winget Dependency: https://docs.microsoft.com/pt-br/troubleshoot/cpp/c-runtime-packages-desktop-bridge#how-to-install-and-update-desktop-framework-packages
    If (!(Get-AppxPackage "*Microsoft.VCLibs.140.00.UWPDesktop*")) {

        Write-Warning "[?] Winget Dependency was not found."
        $OSArch = CheckOSArchitecture

        if (!(Test-Path "$PSScriptRoot\..\tmp")) {
            Write-Host "[+] Folder $PSScriptRoot\..\tmp doesn't exist, creating..."
            mkdir "$PSScriptRoot\..\tmp" | Out-Null
        }

        if ($OSArch -like "x64" -or "x86" -or "arm64" -or "arm") {
            $WingetDepDownload = "https://aka.ms/Microsoft.VCLibs.$OSArch.14.00.Desktop.appx"
        }
        Else {
            Write-Warning "[?] $OSArch is not supported! But trying anyway..."
            $WingetDepDownload = "https://aka.ms/Microsoft.VCLibs.$OSArch.14.00.Desktop.appx"
        }

        $WingetDepOutput = "$PSScriptRoot\..\tmp\Microsoft.VCLibs.14.00.Desktop.appx"
        $WingetDepParams = @(
            "Winget Dependency",
            { throw $err },
            { Write-Host "[+] Downloading Winget Dependency ($OSArch) from: $WingetDepDownload"; Invoke-WebRequest -Uri $WingetDepDownload -OutFile $WingetDepOutput; Add-AppxPackage -Path $WingetDepOutput; Remove-Item -Path $WingetDepOutput }
        )

        # Install Winget Dependency on Windows
        InstallPackageManager -PackageManagerFullName $WingetDepParams[0] -CheckExistenceBlock $WingetDepParams[1] -InstallCommandBlock $WingetDepParams[2]
    }
    Else {
        Write-Warning "[?] Winget Dependency is already installed."
    }

    $GitAsset = Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest" | ForEach-Object assets | Where-Object name -like "*.msixbundle"
    $WingetDownload = $GitAsset.browser_download_url
    $WingetOutput = "$PSScriptRoot\..\tmp\winget-latest.appxbundle"

    $WingetParams = @(
        "Winget",
        { winget --version },
        { Write-Host "[+] Downloading Winget from: $WingetDownload"; Invoke-WebRequest -Uri $WingetDownload -OutFile $WingetOutput; Add-AppxPackage -Path $WingetOutput; Remove-Item -Path $WingetOutput },
        "12:00",
        { winget upgrade --all --silent }
    )

    $ChocolateyParams = @(
        "Chocolatey",
        { choco --version },
        { Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) },
        "13:00",
        { choco upgrade all -y },
        { choco install -y "chocolatey-core.extension" "chocolatey-fastanswers.extension" "dependency-windows10" }
    )

    # Install Winget on Windows
    InstallPackageManager -PackageManagerFullName $WingetParams[0]     -CheckExistenceBlock $WingetParams[1]     -InstallCommandBlock $WingetParams[2]     -Time $WingetParams[3]     -UpdateScriptBlock $WingetParams[4]
    # Install Chocolatey on Windows
    InstallPackageManager -PackageManagerFullName $ChocolateyParams[0] -CheckExistenceBlock $ChocolateyParams[1] -InstallCommandBlock $ChocolateyParams[2] -Time $ChocolateyParams[3] -UpdateScriptBlock $ChocolateyParams[4] -PostInstallBlock $ChocolateyParams[5]

}

Main