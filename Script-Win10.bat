::::::::::::::::::::::::::::::::::::::::::::
:: Elevate.cmd - Version 4
:: Automatically check & get admin rights
::::::::::::::::::::::::::::::::::::::::::::
 @echo off
 CLS
 ECHO.
 ECHO =============================
 ECHO Running Admin shell
 ECHO =============================

:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~0"
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO.
  ECHO **************************************
  ECHO Invoking UAC for Privilege Escalation
  ECHO **************************************

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"

  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

REM #
REM #
REM #
@pushd lib
@PowerShell -NoProfile -ExecutionPolicy Bypass -file .\config-cmd-window.ps1
@popd & cls

@ECHO =========================================================================================
@ECHO       Improve and Optimize Windows 10 (Made by Plínio Larrubia A.K.A. LeDragoX)
@ECHO =========================================================================================
@ECHO.

pushd scripts
@PowerShell Set-ExecutionPolicy Unrestricted -Force -Scope CurrentUser
@PowerShell Set-ExecutionPolicy Unrestricted -Force -Scope LocalMachine
@PowerShell Get-ExecutionPolicy -List
@PowerShell -NoProfile ls -Recurse *.ps*1 Unblock-File
@PowerShell ls
@ECHO.

cls && @ECHO ========================================================================================= && @ECHO all-in-one-tweaks.ps1 && @ECHO.
PowerShell -NoProfile -ExecutionPolicy Bypass -file .\all-in-one-tweaks.ps1
cls && @ECHO ========================================================================================= && @ECHO backup-system.ps1 && @ECHO.
PowerShell -NoProfile -ExecutionPolicy Bypass -file .\backup-system.ps1
cls && @ECHO ========================================================================================= && @ECHO block-telemetry.ps1 && @ECHO.
PowerShell -NoProfile -ExecutionPolicy Bypass -file .\block-telemetry.ps1
cls && @ECHO ========================================================================================= && @ECHO disable-services.ps1 && @ECHO.
PowerShell -NoProfile -ExecutionPolicy Bypass -file .\disable-services.ps1
cls && @ECHO ========================================================================================= && @ECHO fix-privacy-settings.ps1 && @ECHO.
PowerShell -NoProfile -ExecutionPolicy Bypass -file .\fix-privacy-settings.ps1
cls && @ECHO ========================================================================================= && @ECHO optimize-user-interface.ps1 && @ECHO.
PowerShell -NoProfile -ExecutionPolicy Bypass -file .\optimize-user-interface.ps1
cls && @ECHO ========================================================================================= && @ECHO optimize-windows-update.ps1 && @ECHO.
PowerShell -NoProfile -ExecutionPolicy Bypass -file .\optimize-windows-update.ps1
cls && @ECHO ========================================================================================= && @ECHO remove-default-apps.ps1 && @ECHO.
PowerShell -NoProfile -ExecutionPolicy Bypass -file .\remove-default-apps.ps1
cls && @ECHO ========================================================================================= && @ECHO remove-onedrive.ps1 && @ECHO.
PowerShell -NoProfile -ExecutionPolicy Bypass -file .\remove-onedrive.ps1

popd
cls && @ECHO ========================================================================================= && @ECHO ///***EXTRA***\\\ && @ECHO.

@echo Bring back F8 for alternative Boot Modes
bcdedit /set {default} bootmenupolicy legacy

@echo Fix Windows Search Bar
pushd "%systemroot%\System32" & Regsvr32.exe /s msimtf.dll & Regsvr32.exe /s msctf.dll & ctfmon.exe & popd

@echo Adding Dark Theme
@pushd utils
regedit /s dark-theme.reg
regedit /s enable-photo-viewer.reg
@popd

@REM If changing the programs folder move here!!!
@pushd "Windows Debloater Programs"

@echo [OPTIONAL] Windows searches go to the default Web Browser
@echo [OPTIONAL] "EdgeDeflector_install.exe" /S

@pushd "Winaero Tweaker"
start WinaeroTweaker.exe
@popd

REM ShutUp10 is portable now
@pushd "ShutUp10"
start OOSU10.exe ooshutup10.cfg REM /quiet
@popd

@PowerShell Set-ExecutionPolicy Restricted -Force -Scope CurrentUser
@PowerShell Set-ExecutionPolicy Restricted -Force -Scope LocalMachine
@PowerShell Get-ExecutionPolicy -List

taskkill /F /IM explorer.exe

@popd
@echo Quiting in:
@pushd lib
PowerShell -NoProfile -ExecutionPolicy Bypass -file .\count-3-seconds.ps1
@popd
start /wait explorer.exe