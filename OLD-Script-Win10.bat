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

  cls && @ECHO ========================================================================================= && @ECHO backup-system.ps1 && @ECHO.
  PowerShell -NoProfile -ExecutionPolicy Bypass -file .\backup-system.ps1
  cls && @ECHO ========================================================================================= && @ECHO all-in-one-tweaks.ps1 && @ECHO.
  PowerShell -NoProfile -ExecutionPolicy Bypass -file .\all-in-one-tweaks.ps1
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

  @PowerShell Set-ExecutionPolicy Restricted -Force -Scope CurrentUser
  @PowerShell Set-ExecutionPolicy Restricted -Force -Scope LocalMachine
  @PowerShell Get-ExecutionPolicy -List

@popd
@echo Quiting in:
@pushd lib
  PowerShell -NoProfile -ExecutionPolicy Bypass -file .\count-x-seconds.ps1
@popd