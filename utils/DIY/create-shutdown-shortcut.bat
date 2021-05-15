@echo off
echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "%USERPROFILE%\Desktop\Desligar PC.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%SYSTEMROOT%\System32\shutdown.exe" >> CreateShortcut.vbs
echo oLink.Arguments = "-s -f -t 0" >> CreateShortcut.vbs
echo oLink.IconLocation = "%SYSTEMROOT%\System32\SHELL32.dll, 27" >> CreateShortcut.vbs REM 27 or 215 is the number of icon to shutdown in SHELL32.dll
REM echo "%SYSTEMROOT%\system32\imageres.dll, 2" >> CreateShortcut.vbs REM Icons of Windows 10
REM echo "%SYSTEMROOT%\system32\pifmgr.dll, 2" >> CreateShortcut.vbs REM Icons of Windows 95/98
REM echo "%SYSTEMROOT%\explorer.exe, 2" >> CreateShortcut.vbs REM Icons of Windows Explorer
REM echo "%SYSTEMROOT%\system32\accessibilitycpl.dll, 2" >> CreateShortcut.vbs REM Icons of Accessibility
REM echo "%SYSTEMROOT%\system32\ddores.dll, 2" >> CreateShortcut.vbs REM Icons of Hardware
REM echo "%SYSTEMROOT%\system32\moricons.dll, 2" >> CreateShortcut.vbs REM Icons of MS-DOS
REM echo "%SYSTEMROOT%\system32\mmcndmgr.dll, 2" >> CreateShortcut.vbs REM More Icons of Windows 95/98
REM echo "%SYSTEMROOT%\system32\mmres.dll, 2" >> CreateShortcut.vbs REM Icons of Audio
REM echo "%SYSTEMROOT%\system32\netshell.dll, 2" >> CreateShortcut.vbs REM Icons of Network
REM echo "%SYSTEMROOT%\system32\netcenter.dll, 2" >> CreateShortcut.vbs REM More Icons of Network
REM echo "%SYSTEMROOT%\system32\networkexplorer.dll, 2" >> CreateShortcut.vbs REM More Icons of Network and Printer
REM echo "%SYSTEMROOT%\system32\pnidui.dll, 2" >> CreateShortcut.vbs REM More Icons of Status in Network
REM echo "%SYSTEMROOT%\system32\sensorscpl.dll, 2" >> CreateShortcut.vbs REM Icons of Distinct Sensors
REM echo "%SYSTEMROOT%\system32\setupapi.dll, 2" >> CreateShortcut.vbs REM Icons of Setup Wizard
REM echo "%SYSTEMROOT%\system32\wmploc.dll, 2" >> CreateShortcut.vbs REM Icons of Player
REM echo "%SYSTEMROOT%\system32\system32\wpdshext.dll, 2" >> CreateShortcut.vbs REM Icons of Portable devices and Battery
REM echo "%SYSTEMROOT%\system32\compstui.dll, 2" >> CreateShortcut.vbs REM Classic Icons of Printer, Phone and Email
REM echo "%SYSTEMROOT%\system32\dmdskres.dll, 2" >> CreateShortcut.vbs REM Icons of Disk Management
REM echo "%SYSTEMROOT%\system32\dsuiext.dll, 2" >> CreateShortcut.vbs REM Icons of Services in Network
REM echo "%SYSTEMROOT%\system32\mstscax.dll, 2" >> CreateShortcut.vbs REM Icons of Remote Connection
REM echo "%SYSTEMROOT%\system32\wiashext.dll, 2" >> CreateShortcut.vbs REM Icons of Hardware in Image
REM echo "%SYSTEMROOT%\system32\comres.dll, 2" >> CreateShortcut.vbs REM Icons of Actions
REM echo "%SYSTEMROOT%\system32\comres.dll, 2" >> CreateShortcut.vbs REM More Icons of Network, Sound and logo from Windows 8

echo oLink.Save >> CreateShortcut.vbs
cscript CreateShortcut.vbs
del "%USERPROFILE%\Desktop\CreateShortcut.vbs"