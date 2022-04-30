# Adapted From: https://gist.github.com/anthonyeden/0088b07de8951403a643a8485af2709b?permalink_comment_id=3651336#gistcomment-3651336

function Install-Font() {
  [CmdletBinding()]
  param (
    [String] $FontSourceFolder = "$PSScriptRoot\src\tmp\Fonts"
  )

  $SystemFontsPath = "$env:SystemRoot\Fonts"

  ForEach ($FontFile in Get-ChildItem $FontSourceFolder -Include '*.ttf', '*.ttc', '*.otf' -Recurse) {
    $TargetPath = Join-Path $SystemFontsPath $FontFile.Name

    If (!(Test-Path "$TargetPath")) {
      Write-Host "[+] Installing '$($FontFile.Name)' Font on $TargetPath..."

      # Extract Font information for Reqistry
      $ShellFolder = (New-Object -COMObject Shell.Application).Namespace($FontSourceFolder)
      $ShellFile = $ShellFolder.ParseName($FontFile.Name)
      $ShellFileType = $ShellFolder.GetDetailsOf($ShellFile, 2)
      If ($ShellFileType -Like '*TrueType font file*') { $FontType = '(TrueType)' }

      # Update Registry and copy Font to Font directory
      $RegName = $ShellFolder.GetDetailsOf($ShellFile, 21) + ' ' + $FontType
      New-ItemProperty -Name $RegName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType String -Value $FontFile.Name -Force
      Copy-item $FontFile.FullName -Destination $SystemFontsPath
      Remove-Item $FontFile.FullName
    }
    ElseIf (Test-Path "$TargetPath") {
      Write-Host "[?] $($FontFile.Name) is already installed!" -ForegroundColor Yellow -BackgroundColor Black
    }
  }
}