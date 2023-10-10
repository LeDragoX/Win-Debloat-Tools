Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

# Adapted from: https://github.com/ChrisTitusTech/win10script/blob/master/win10debloat.ps1
# Adapted from: https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/utils/install-basic-software.ps1

function Install-PackageManager() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [String]	  $PackageManagerFullName,
        [Parameter(Position = 1, Mandatory)]
        [ScriptBlock] $CheckExistenceBlock,
        [Parameter(Position = 2, Mandatory)]
        [ScriptBlock] $InstallCommandBlock,
        [ScriptBlock] $PostInstallBlock,
        [Switch]      $Force
    )

    Try {
        $Err = (Invoke-Expression "$CheckExistenceBlock")
        If (($LASTEXITCODE -or $Force)) { throw $Err } # 0 = False, 1 = True
        Write-Status -Types "?", $PackageManagerFullName -Status "$PackageManagerFullName is already installed." -Warning
    } Catch {
        Write-Status -Types "@", $PackageManagerFullName -Status "FORCE INSTALLING $PackageManagerFullName." -Warning
        Write-Status -Types "?", $PackageManagerFullName -Status "$PackageManagerFullName was not found." -Warning
        Write-Status -Types "+", $PackageManagerFullName -Status "Downloading and Installing $PackageManagerFullName package manager."

        Invoke-Expression "$InstallCommandBlock"

        If ($PostInstallBlock) {
            Write-Status -Types "+", $PackageManagerFullName -Status "Executing post install script: { $("$PostInstallBlock".Trim(' ')) }."
            Invoke-Expression "$PostInstallBlock"
        }
    }
}
