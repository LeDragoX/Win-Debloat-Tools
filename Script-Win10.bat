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




@pushd scripts\Extra
@PowerShell -NoProfile -ExecutionPolicy Bypass -file .\configurar-janela-cmd.ps1
@popd & cls

@ECHO =========================================================================================
@ECHO       Melhorar e Otimizar o Windows 10 (Feito por Plínio Larrubia A.K.A. LeDragoX)
@ECHO =========================================================================================
@ECHO.

pushd scripts
@PowerShell Set-ExecutionPolicy Unrestricted -Force -Scope CurrentUser
@PowerShell -NoProfile ls -Recurse *.ps*1 Unblock-File
@PowerShell ls
@ECHO.

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
cls && @ECHO ========================================================================================= && @ECHO remove-win10-bloat.ps1 && @ECHO.
PowerShell -NoProfile -ExecutionPolicy Bypass -file .\remove-win10-bloat.ps1
cls && @ECHO ========================================================================================= && @ECHO repair-100%-disk-usage.ps1 && @ECHO.
PowerShell -NoProfile -ExecutionPolicy Bypass -file ".\repair-100%%-disk-usage.ps1"
@REM PowerShell -NoProfile -ExecutionPolicy Bypass -file .\remove-onedrive.ps1

popd
cls && @ECHO ========================================================================================= && @ECHO ///***EXTRA***\\\ && @ECHO.

@echo Bring back F8 for alternative Boot Modes
bcdedit /set {default} bootmenupolicy legacy

@echo Fix Windows Search Bar
pushd "%systemroot%\System32" & Regsvr32.exe /s msimtf.dll & Regsvr32.exe /s msctf.dll & ctfmon.exe & popd

@echo Adicionando Tema Escuro
@pushd utils
regedit /s dark-theme.reg
regedit /s enable-photo-viewer.reg
@popd

@REM SE FOR MUDAR A PASTA DOS PROGRAMAS MEXA AQUI!!!
@pushd "Windows Debloater Programs"

@echo [OPCIONAL] Pesquisas do Windows vão para o navegador principal
@echo [OPCIONAL] "EdgeDeflector_install.exe" /S

@pushd "Winaero Tweaker"
start WinaeroTweaker.exe
@popd

REM ShutUp10 agora é PORTÁTIL
@pushd "ShutUp10"
start OOSU10.exe ooshutup10.cfg REM /quiet
@popd

@PowerShell Set-ExecutionPolicy Restricted -Force

taskkill /F /IM explorer.exe

@popd
@echo Saindo em:
@pushd scripts/Extra
PowerShell -NoProfile -ExecutionPolicy Bypass -file .\count-3-seconds.ps1
@popd
start /wait explorer.exe