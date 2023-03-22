Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\Get-HardwareInfo.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\Request-FileDownload.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\debloat-helper\Remove-ItemVerified.psm1"

function Install-ArchWSL() {
    $OSArchList = Get-OSArchitecture

    ForEach ($OSArch in $OSArchList) {
        If ($OSArch -like "x64") {
            $CertOutput = Get-APIFile -URI "https://api.github.com/repos/yuk7/ArchWSL/releases/latest" -ObjectProperty "assets" -FileNameLike "ArchWSL-AppX_*_$OSArch.cer" -PropertyValue "browser_download_url" -OutputFile "ArchWSL.cer"
            Write-Status -Types "+" -Status "Installing ArchWSL Certificate ($OSArch)..."
            Import-Certificate -FilePath $CertOutput -CertStoreLocation Cert:\LocalMachine\Root | Out-Host
            Write-Status -Types "?" -Status "The certificate needs to be installed manually, the cmdlet didn't work for some reason..." -Warning
            Write-Status -Types "@" -Status "Steps: Install Certificate... (Next) > Select Local Machine (Next) > Next > Finish > OK" -Warning
            Start-Process -FilePath "$CertOutput" -Wait
            $ArchWSLOutput = Get-APIFile -URI "https://api.github.com/repos/yuk7/ArchWSL/releases/latest" -ObjectProperty "assets" -FileNameLike "ArchWSL-AppX_*_$OSArch.appx" -PropertyValue "browser_download_url" -OutputFile "ArchWSL.appx"
            Write-Status -Types "+" -Status "Installing ArchWSL ($OSArch)..."
            Add-AppxPackage -Path $ArchWSLOutput
            Write-Status -Types "@" -Status "Removing downloaded files..."
            Remove-ItemVerified -Path $CertOutput
            Remove-ItemVerified -Path $ArchWSLOutput
        } Else {
            Write-Status -Types "?" -Status "$OSArch is NOT supported!" -Warning
            Break
        }
    }
}

Install-ArchWSL
