@echo ---- Preparation ----

@set this=%~dp0
@set thisdrive=%this:~0,2%

%thisdrive%
@cd %this%

@echo This bat drive = %thisdrive%
@echo This bat folder = %this%

@echo off & echo ---- Prepared ----
taskkill /F /IM explorer.exe
explorer.exe

cls
Powershell Write-Output "Removing the annoying message"
Powershell "Get-Service -Name sppsvc | Powershell Set-Service -StartupType Disabled"
sc stop sppsvc

bcdedit -set TESTSIGNING OFF
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\sppsvc" /v "Start" /t REG_DWORD /d 4
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" /v "DisplayNotRet" /t REG_DWORD /d 0
REG ADD "HKEY_CURRENT_USER\Control Panel\Desktop" /v "PaintDesktopVersion" /t REG_DWORD /d 0