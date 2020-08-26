@echo off
Powershell Write-Output '---- Preparation ----' ''

@set this=%~dp0
@set thisdrive=%this:~0,2%

%thisdrive%
@cd %this%

Powershell Write-Output '' 'This bat drive = %thisdrive%' ''
Powershell Write-Output '' 'This bat folder = %this%' ''

@pushd ..\Extra
@PowerShell -NoProfile -ExecutionPolicy Bypass -file .\configurar-janela-cmd.ps1
@popd


@echo off & echo ---- Prepared ----
echo ----- Deletar pastas e arquivos Temporários -----

set sdrive=%SystemDrive%
set src1=%SystemRoot%\Temp
set src2=%temp%

echo System Drive = %sdrive%
echo Windows Temp Folder = %src1%
echo User Temp Folder = %src2%
echo.

%sdrive%
cd %src1%
echo Were at = %cd%
echo.
DEL /F/Q/S *.* > NUL

cd %src2%
echo.
echo Were at = %cd%
echo.
DEL /F/Q/S *.* > NUL
echo.


wmic diskdrive get caption,status
@Powershell Start-Sleep 1

Powershell Write-Output '' '----- Desativando serviços que levam a 100% de uso -----' ''
Powershell "Get-Service -Name SysMain | Set-Service -StartupType Disabled"
Powershell "Get-Service -Name DPS | Set-Service -StartupType Disabled"
Powershell "Get-Service -Name BITS | Set-Service -StartupType Disabled"
Powershell "Get-Service -Name DiagTrack | Set-Service -StartupType Disabled"
sc stop DiagTrack
sc stop BITS
sc stop SysMain
sc stop DPS

WPR -cancel
wusa /uninstall /kb:3201845 /quiet /norestart

Powershell Write-Output '' '----- Desativando tarefas agendadas que dão 100% de uso -----' ''
schtasks /CHANGE /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Application Experience\StartupAppTask" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Autochk\Proxy" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /DISABLE

REM Só remover se for extremamente necessário
REM Powershell disable-MMAgent -mc

Powershell Write-Output '' '----- Desativando o Superfetch -----' ''
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f
Powershell Write-Output '' '----- Desativando a Assistência Remota -----' ''
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp /t REG_DWORD /d 0 /f
Powershell Write-Output '' '----- Repara alto uso de Memória/RAM -----' ''
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Ndu" /v Start /t REG_DWORD /d 4 /f
Powershell Write-Output '' '----- Desativando a Cortana -----' ''
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCloudSearch /t REG_DWORD /d 0 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v ConnectedSearchUseWeb /t REG_DWORD /d 0 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v DisableWebSearch /t REG_DWORD /d 1 /f

Powershell Write-Output '' '----- Reinstalando a Microsoft Store -----' ''
wsreset && @PowerShell Write-Output 'Restart your Computer!' 'Reinicie seu Computador!' | Msg * /time:3