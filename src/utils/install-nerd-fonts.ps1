Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"download-web-file.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"install-font.psm1"

function Install-NerdFont() {
    $URI = "https://github.com/romkatv/powerlevel10k-media/raw/master"
    $FontFiles = @("MesloLGS NF Regular.ttf", "MesloLGS NF Bold.ttf", "MesloLGS NF Italic.ttf", "MesloLGS NF Bold Italic.ttf")

    ForEach ($Font in $FontFiles) {
        Request-FileDownload -FileURI "$URI/$Font" -OutputFolder "Fonts" -OutputFile "$Font"
    }

    Install-Font -FontSourceFolder "$PSScriptRoot\..\tmp\Fonts"
    Remove-Item -Path "$PSScriptRoot\..\tmp\Fonts" -Recurse
}

function Main {
    Install-NerdFont
}

Main