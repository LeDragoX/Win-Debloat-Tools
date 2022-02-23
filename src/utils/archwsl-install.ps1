Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"download-web-file.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"get-os-info.psm1"

function ArchWSLInstall() {
    $OSArchList = Get-OSArchitecture

    foreach ($OSArch in $OSArchList) {
        if ($OSArch -like "x64") {    

            $CertOutput = Get-APIFile -URI "https://api.github.com/repos/yuk7/ArchWSL/releases/latest" -APIObjectContainer "assets" -FileNameLike "ArchWSL-AppX_*_$OSArch.cer" -APIProperty "browser_download_url" -OutputFile "ArchWSL.cer"
            Write-Host "[+] Installing ArchWSL Certificate ($OSArch)..."
            Import-Certificate -FilePath $CertOutput -CertStoreLocation Cert:\LocalMachine\Root | Out-Host
            $ArchWSLOutput = Get-APIFile -URI "https://api.github.com/repos/yuk7/ArchWSL/releases/latest" -APIObjectContainer "assets" -FileNameLike "ArchWSL-AppX_*_$OSArch.appx" -APIProperty "browser_download_url" -OutputFile "ArchWSL.appx"
            Write-Host "[+] Installing ArchWSL ($OSArch)..."
            Add-AppxPackage -Path $ArchWSLOutput
            Remove-Item -Path $ArchWSLOutput

        }
        Else {
            Write-Warning "[?] $OSArch is NOT supported!"
            Break
        }
    }
}

function Main() {
    ArchWSLInstall
}

Main