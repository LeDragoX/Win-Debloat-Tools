@echo ---- Preparation ----

@set this=%~dp0
@set thisdrive=%this:~0,2%

%thisdrive%
@cd %this%

@echo This bat drive = %thisdrive%
@echo This bat folder = %this%

@pushd ..\scripts\Extra
@PowerShell -NoProfile -ExecutionPolicy Bypass -file .\configurar-janela-cmd.ps1
@popd


@echo off & echo ---- Prepared ----
taskkill /F /IM explorer.exe
explorer.exe

Powershell Write-Output "Tirando a mensagem irritante"
Powershell "Get-Service -Name sppsvc | Powershell Set-Service -StartupType Disabled"
sc stop sppsvc

bcdedit -set TESTSIGNING OFF
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\sppsvc" /v Start /t REG_DWORD /d 4
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" /v DisplayNotRet /t REG_DWORD /d 0
REG ADD "HKEY_CURRENT_USER\Control Panel\Desktop" /v /t REG_DWORD /d 0

@cd "..\..\Windows Debloater Programs\Activation-alert-remove"

@pushd "My.WCP.W.E"
"My_WCP_Watermark_Editor.exe"
@popd

@pushd "uwd"
"uwd.exe"
@popd