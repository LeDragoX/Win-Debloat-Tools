Import-Module -DisableNameChecking "$PSScriptRoot\Get-TempScriptFolder.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\Title-Templates.psm1"

# Adapted From: https://gist.github.com/anthonyeden/0088b07de8951403a643a8485af2709b?permalink_comment_id=3651336#gistcomment-3651336

function Install-Font() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [String] $FontSourceFolder = "$(Get-TempScriptFolder)\downloads\fonts"
    )

    $PathToLMWindowsFonts = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
    $SystemFontsPath = "$env:SystemRoot\Fonts"

    ForEach ($FontFile in Get-ChildItem $FontSourceFolder -Include "*.ttf", "*.ttc", "*.otf" -Recurse) {
        $TargetPath = Join-Path $SystemFontsPath $FontFile.Name

        Write-Status -Types "+" -Status "Installing `"$($FontFile.Name)`" Font on $TargetPath ..."

        Try {
            # Extract Font information for Reqistry
            $ShellFolder = (New-Object -COMObject Shell.Application).Namespace($FontSourceFolder)
            $ShellFile = $ShellFolder.ParseName($FontFile.Name)
            $ShellFileType = $ShellFolder.GetDetailsOf($ShellFile, 2)
            If ($ShellFileType -Like "*TrueType font file*") { $FontType = "(TrueType)" }

            # Update Registry and copy Font to Font directory
            $RegName = $ShellFolder.GetDetailsOf($ShellFile, 21) + ' ' + $FontType
        } Catch {
            # This may not be the better way, but this workaround worked
            Write-Status -Types "@" -Status "Got an error, the font type is OpenType" -Warning
            $FontType = '(OpenType)'
            $RegName = ""
            $NameHelper = $FontFile.Name.Replace("-", " ").Replace("_", " ").Trim(" ")
            $NameHelper = $FontFile.Name.Replace("[", " ").Replace("]", " ").Trim(" ")
            $NameHelper = $FontFile.Name.Replace(".ttf", "").Replace(".ttc", "").Replace(".otf", "").Trim(" ")
            $NameHelper = $NameHelper.Replace("Mono", " Mono").Replace("NF", " NF").Replace("NL", " NL").Replace("VF", " VF").Replace("wght", " Variable").Trim(" ")
            $NameHelper = $NameHelper.Replace("Thin", " Thin").Replace("Semi", " Semi").Replace("Medium", " Medium").Replace("Extra", " Extra").Trim(" ")
            $NameHelper = $NameHelper.Replace("Bold", " Bold").Replace("Italic", " Italic").Replace("Light", " Light").Replace("Regular", " Regular").Trim(" ")
            $NameHelper = $NameHelper + " " + $FontType

            ForEach ($Item in $NameHelper.Split(" ")) {
                If (($Item -ne " ") -or ($null -ne $Item)) {
                    $RegName = $RegName.Trim(" ") + " " + $Item.Trim(" ")
                }
            }
        }

        Write-Status -Types "+" -Status "Creating new Registry to $RegName on: $PathToLMWindowsFonts"
        New-ItemProperty -Path "$PathToLMWindowsFonts" -Name $RegName -PropertyType String -Value $FontFile.Name -Force
        Copy-item $FontFile.FullName -Destination $SystemFontsPath
        Remove-Item $FontFile.FullName
    }
}
