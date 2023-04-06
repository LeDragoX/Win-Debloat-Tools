Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\Get-TempScriptFolder.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\Install-Font.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\Request-FileDownload.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\Title-Templates.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\..\lib\debloat-helper\Remove-ItemVerified.psm1"

$FontsFolder = "fonts"

function Install-NerdFont() {
    Push-Location -Path "$(Get-TempScriptFolder)\downloads"
    New-Item -Path "$FontsFolder" -ItemType Directory | Out-Null

    Write-Status -Types "@" -Status "Downloading Fira Code..."
    Install-FiraCode
    Write-Status -Types "@" -Status "Downloading JetBrains Mono..."
    Install-JetBrainsMono
    Write-Status -Types "@" -Status "Downloading MesloLGS NF..."
    Install-MesloLGS

    Write-Status -Types "+" -Status "Installing downloaded fonts on $pwd\$FontsFolder..."
    Install-Font -FontSourceFolder "$FontsFolder"
    Write-Status -Types "@" -Status "Cleaning up..."
    Remove-ItemVerified -Path "$FontsFolder" -Recurse
    Pop-Location
}

function Install-FiraCode() {
    $FiraCodeOutput = Get-APIFile -URI "https://api.github.com/repos/tonsky/FiraCode/releases/latest" -ObjectProperty "assets" -FileNameLike "Fira*Code*.zip" -PropertyValue "browser_download_url" -OutputFolder "$FontsFolder" -OutputFile "FiraCode.zip"
    Expand-Archive -Path "$FiraCodeOutput" -DestinationPath "$FontsFolder\FiraCode"
    Move-Item -Path "$FontsFolder\FiraCode\ttf\*" -Include *.ttf -Destination "$FontsFolder"
    Move-Item -Path "$FontsFolder\FiraCode\variable*\*" -Include *.ttf -Destination "$FontsFolder"
}

function Install-JetBrainsMono() {
    $JetBrainsOutput = Get-APIFile -URI "https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest" -ObjectProperty "assets" -FileNameLike "JetBrainsMono-*.zip" -PropertyValue "browser_download_url" -OutputFolder "$FontsFolder" -OutputFile "JetBrainsMono.zip"
    Expand-Archive -Path "$JetBrainsOutput" -DestinationPath "$FontsFolder\JetBrainsMono" -Force
    Move-Item -Path "$FontsFolder\JetBrainsMono\fonts\ttf\*" -Include *.ttf -Destination "$FontsFolder"
    Move-Item -Path "$FontsFolder\JetBrainsMono\fonts\variable*\*" -Include *.ttf -Destination "$FontsFolder"
}

function Install-MesloLGS() {
    $MesloLgsURI = "https://github.com/romkatv/powerlevel10k-media/raw/master"
    $FontFiles = @("MesloLGS NF Regular.ttf", "MesloLGS NF Bold.ttf", "MesloLGS NF Italic.ttf", "MesloLGS NF Bold Italic.ttf")

    ForEach ($Font in $FontFiles) {
        Request-FileDownload -FileURI "$MesloLgsURI/$Font" -ExtendFolder "$FontsFolder" -OutputFile "$Font"
    }
}

Install-NerdFont
