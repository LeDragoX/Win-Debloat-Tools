Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"download-web-file.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"install-font.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Install-NerdFont() {
    Push-Location -Path "$PSScriptRoot\..\tmp"
    mkdir "Fonts" | Out-Null

    Write-Status -Symbol "@" -Status "Downloading JetBrains Mono ..."
    Install-JetBrainsMono
    Write-Status -Symbol "@" -Status "Downloading MesloLGS NF ..."
    Install-MesloLGS

    Write-Status -Symbol "+" -Status "Installing downloaded fonts on $pwd\Fonts ..."
    Install-Font -FontSourceFolder "Fonts"
    Write-Status -Symbol "@" -Status "Cleaning up ..."
    Remove-Item -Path "Fonts" -Recurse
    Pop-Location
}

function Install-JetBrainsMono() {
    $JetBrainsOutput = Get-APIFile -URI "https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest" -ObjectProperty "assets" -FileNameLike "JetBrainsMono-*.zip" -PropertyValue "browser_download_url" -OutputFolder "Fonts" -OutputFile "JetBrainsMono.zip"
    Expand-Archive -Path "$JetBrainsOutput" -DestinationPath "Fonts\JetBrainsMono"
    Move-Item -Path "Fonts\JetBrainsMono\fonts\ttf\*" -Include *.ttf -Destination "Fonts"
    Remove-Item -Path "$JetBrainsOutput"
    Remove-Item -Path "Fonts\JetBrainsMono\" -Recurse
}

function Install-MesloLGS() {
    $MesloLgsURI = "https://github.com/romkatv/powerlevel10k-media/raw/master"
    $FontFiles = @("MesloLGS NF Regular.ttf", "MesloLGS NF Bold.ttf", "MesloLGS NF Italic.ttf", "MesloLGS NF Bold Italic.ttf")

    ForEach ($Font in $FontFiles) {
        Request-FileDownload -FileURI "$MesloLgsURI/$Font" -OutputFolder "Fonts" -OutputFile "$Font"
    }
}

function Main() {
    Install-NerdFont
}

Main