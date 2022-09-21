Import-Module -DisableNameChecking $PSScriptRoot\..\..\lib\"title-templates.psm1"

function New-SystemColor() {
    $ColorHistory = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\History\Colors"
    $HexColor = "{0:X6}" -f (Get-Random -Maximum 0xFFFFFF)
    $HexColorBGR = "$($HexColor[4..5] + $HexColor[2..3] + $HexColor[0..1])".Split(" ") -join ""

    $PathToCUDesktop = "HKCU:\Control Panel\Desktop"
    $PathToCUExplorerAccent = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent"
    $PathToCUThemesColorHistory = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\History\Colors"
    $PathToCUThemesHistory = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\History"
    $PathToCUThemesPersonalize = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $PathToCUWindowsDWM = "HKCU:\SOFTWARE\Microsoft\Windows\DWM"

    $Max = 32
    $RandomBytes = [System.Collections.ArrayList]@()
    ForEach ($i in 1..$Max) {
        $Byte = "0x{0:X2}" -f (Get-Random -Maximum 0xFF)

        If ($i % 4 -eq 0) {
            $Byte = "0xFF"
        }

        If ($i -eq $Max) {
            $Byte = "0x00"
        }

        If ($i -in (1, 5, 9, 13, 17, 21, 25)) {
            $Byte = "0x$($HexColor[0..1])".Split(" ") -join ""
        }

        If ($i -in (2, 6, 10, 14, 18, 22, 26)) {
            $Byte = "0x$($HexColor[2..3])".Split(" ") -join ""
        }

        If ($i -in (3, 7, 11, 15, 19, 23, 27)) {
            $Byte = "0x$($HexColor[4..5])".Split(" ") -join ""
        }

        $RandomBytes.Add($Byte)
    }

    Write-Status -Types "@" -Status "HexColor: #$HexColor, BGR: #$HexColorBGR"
    Write-Verbose "$RandomBytes"

    # Taskbar and Settings color
    Set-ItemProperty -Path "$PathToCUExplorerAccent" -Name "AccentPalette" -Type Binary -Value ([byte[]]($RandomBytes[0], $RandomBytes[1], $RandomBytes[2], $RandomBytes[3], $RandomBytes[4], $RandomBytes[5], $RandomBytes[6], $RandomBytes[7], $RandomBytes[8], $RandomBytes[9], $RandomBytes[10], $RandomBytes[11], $RandomBytes[12], $RandomBytes[13], $RandomBytes[14], $RandomBytes[15], $RandomBytes[16], $RandomBytes[17], $RandomBytes[18], $RandomBytes[19], $RandomBytes[20], $RandomBytes[21], $RandomBytes[22], $RandomBytes[23], $RandomBytes[24], $RandomBytes[25], $RandomBytes[26], $RandomBytes[27], $RandomBytes[28], $RandomBytes[29], $RandomBytes[30], $RandomBytes[31]))

    # Window Top Color
    Set-ItemProperty -Path "$PathToCUWindowsDWM" -Name "AccentColor" -Type DWord -Value 0xff$HexColor
    Set-ItemProperty -Path "$PathToCUWindowsDWM" -Name "ColorizationAfterglow" -Type DWord -Value 0xc4$HexColor
    Set-ItemProperty -Path "$PathToCUWindowsDWM" -Name "ColorizationColor" -Type DWord -Value 0xc4$HexColor

    # Window Border Color
    Set-ItemProperty -Path "$PathToCUExplorerAccent" -Name "AccentColorMenu" -Type DWord -Value 0xff$HexColorBGR
    Set-ItemProperty -Path "$PathToCUExplorerAccent" -Name "StartColorMenu" -Type DWord -Value 0xff$HexColor

    # Start, Taskbar and Action center
    Set-ItemProperty -Path "$PathToCUThemesPersonalize" -Name "ColorPrevalence" -Type DWord -Value 0

    # Title Bars and Windows Borders
    Set-ItemProperty -Path "$PathToCUWindowsDWM" -Name "ColorPrevalence" -Type DWord -Value 1

    # Window Color History
    Set-ItemProperty -Path "$PathToCUThemesColorHistory" -Name "ColorHistory0" -Type DWord -Value 0xff$HexColorBGR
    Set-ItemProperty -Path "$PathToCUThemesColorHistory" -Name "ColorHistory1" -Type DWord -Value $ColorHistory.ColorHistory0
    Set-ItemProperty -Path "$PathToCUThemesColorHistory" -Name "ColorHistory2" -Type DWord -Value $ColorHistory.ColorHistory1
    Set-ItemProperty -Path "$PathToCUThemesColorHistory" -Name "ColorHistory3" -Type DWord -Value $ColorHistory.ColorHistory2
    Set-ItemProperty -Path "$PathToCUThemesColorHistory" -Name "ColorHistory4" -Type DWord -Value $ColorHistory.ColorHistory3
    Set-ItemProperty -Path "$PathToCUThemesColorHistory" -Name "ColorHistory5" -Type DWord -Value $ColorHistory.ColorHistory4

    # Miscellaneous stuff (didn't work)
    Set-ItemProperty -Path "$PathToCUWindowsDWM" -Name "ColorizationAfterglowBalance" -Type DWord -Value 10
    # Set-ItemProperty -Path "$PathToCUWindowsDWM" -Name "ColorizationBlurBalance" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToCUWindowsDWM" -Name "ColorizationColorBalance" -Type DWord -Value 89
    Set-ItemProperty -Path "$PathToCUWindowsDWM" -Name "ColorizationGlassAttribute" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToCUWindowsDWM" -Name "ColorizationGlassAttribute" -Type DWord -Value 1
    Set-ItemProperty -Path "$PathToCUWindowsDWM" -Name "EnableWindowColorization" -Type DWord -Value 1

    Set-ItemProperty -Path "$PathToCUDesktop" -Name "AutoColorization" -Type DWord -Value 0
    Set-ItemProperty -Path "$PathToCUThemesHistory" -Name "AutoColor" -Type DWord -Value 0
}

New-SystemColor