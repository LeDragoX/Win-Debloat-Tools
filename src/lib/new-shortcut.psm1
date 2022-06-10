# Adapted From: https://shellgeek.com/create-shortcuts-on-user-desktop-using-powershell/
# Short circuit code: https://stackoverflow.com/a/26768902

function New-Shortcut() {
    [CmdletBinding()]
    param (
        [String] $SourcePath,
        [String] $ShortcutPath = "$([Environment]::GetFolderPath("Desktop"))\$((Split-Path -Path $SourcePath -Leaf).Split('.')[0]).lnk",
        [Parameter(Mandatory = $false)]
        [String] $Description = "Opens $(Split-Path -Path $SourcePath -Leaf)",
        [Parameter(Mandatory = $false)]
        [String] $IconLocation = "$SourcePath, 0",
        [Parameter(Mandatory = $false)]
        [String] $Arguments = '',
        [Parameter(Mandatory = $false)]
        [String] $Hotkey = '',
        [Parameter(Mandatory = $false)]
        [String] $WindowStyle = 1 # I'm not sure, but i'll take the UI as example: 1 = Normal, 2 = Minimized, 3 = Maximized
    )

    If (!(Test-Path -Path (Split-Path -Path $ShortcutPath))) {
        Write-Status -Types "?" -Status "$((Split-Path -Path $ShortcutPath)) does not exist, creating it..."
        New-Item -Path (Split-Path -Path $ShortcutPath) -ItemType Directory -Force
    }

    $WScriptObj = New-Object -ComObject ("WScript.Shell")
    $Shortcut = $WScriptObj.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $SourcePath

    If ($Hotkey) {
        $Shortcut.Description = "$Description ($Hotkey)"
    } Else {
        $Shortcut.Description = $Description
    }

    $Shortcut.Arguments = $Arguments
    $ShortCut.Hotkey = $Hotkey
    $Shortcut.IconLocation = $IconLocation
    $Shortcut.WindowStyle = $WindowStyle

    $Shortcut.Save()
}

<#
"$env:SystemRoot\System32\shell32.dll, 27"         >>> 27 or 215 is the number of icon to shutdown in SHELL32.dll
"$env:SystemRoot\System32\imageres.dll, 2"         >>> Icons from Windows 10
"$env:SystemRoot\System32\pifmgr.dll, 2"           >>> Icons from Windows 95/98
"$env:SystemRoot\explorer.exe, 2"                  >>> Icons from Windows Explorer
"$env:SystemRoot\System32\accessibilitycpl.dll, 2" >>> Icons from Accessibility
"$env:SystemRoot\System32\ddores.dll, 2"           >>> Icons from Hardware
"$env:SystemRoot\System32\moricons.dll, 2"         >>> Icons from MS-DOS
"$env:SystemRoot\System32\mmcndmgr.dll, 2"         >>> More Icons from Windows 95/98
"$env:SystemRoot\System32\mmres.dll, 2"            >>> Icons from Sound
"$env:SystemRoot\System32\netshell.dll, 2"         >>> Icons from Network
"$env:SystemRoot\System32\netcenter.dll, 2"        >>> More Icons from Network
"$env:SystemRoot\System32\networkexplorer.dll, 2"  >>> More Icons from Network and Printer
"$env:SystemRoot\System32\pnidui.dll, 2"           >>> More Icons from Status in Network
"$env:SystemRoot\System32\sensorscpl.dll, 2"       >>> Icons from Distinct Sensors
"$env:SystemRoot\System32\setupapi.dll, 2"         >>> Icons from Setup Wizard
"$env:SystemRoot\System32\wmploc.dll, 2"           >>> Icons from Player
"$env:SystemRoot\System32\System32\wpdshext.dll, 2">>> Icons from Portable devices and Battery
"$env:SystemRoot\System32\compstui.dll, 2"         >>> Classic Icons from Printer, Phone and Email
"$env:SystemRoot\System32\dmdskres.dll, 2"         >>> Icons from Disk Management
"$env:SystemRoot\System32\dsuiext.dll, 2"          >>> Icons from Services in Network
"$env:SystemRoot\System32\mstscax.dll, 2"          >>> Icons from Remote Connection
"$env:SystemRoot\System32\wiashext.dll, 2"         >>> Icons from Hardware in Image
"$env:SystemRoot\System32\comres.dll, 2"           >>> Icons from Actions
"$env:SystemRoot\System32\comres.dll, 2"           >>> More Icons from Network, Sound and logo from Windows 8
#>