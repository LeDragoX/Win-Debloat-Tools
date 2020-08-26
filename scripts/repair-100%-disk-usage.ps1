# Made by LeDragoX inspired on Baboo Videos
Write-Output "            ---- Prepared ----"
Write-Output "----- Deletar pastas e arquivos Temporários -----"

$sdrive = cmd /c echo %SystemDrive%
$src1= cmd /c echo %SystemRoot%\Temp
$src2= cmd /c echo %userprofile%\AppData\Local\Temp

Write-Output "System Drive = $sdrive"
Write-Output "Windows Temp Folder = $src1"
Write-Output "User Temp Folder = $src2"
Write-Output ""

Push-Location $src1
ls
Write-Output "Were at = $src1 on drive $sdrive"
Write-Output ""
cmd /c if exist "$src1" DEL "$src1\*.*" /F/Q/S
Pop-Location

Push-Location $src2
ls
Write-Output ""
Write-Output "Were at = $src2 on drive $sdrive"
Write-Output ""
cmd /c if exist "$src2" DEL "$src2\*.*" /F/Q/S
Write-Output ""
Pop-Location

wmic diskdrive get caption,status
Start-Sleep 1

cmd.exe /c echo "Desativando serviços que levam a 100% de uso"
Powershell "Get-Service -Name DiagTrack | Set-Service -StartupType Disabled"
Powershell "Get-Service -Name SysMain | Set-Service -StartupType Disabled"
Powershell "Get-Service -Name DPS | Set-Service -StartupType Automatic" # - DPS: Esse serviço detecta problemas e diagnostica o PC (Importante)
Powershell "Get-Service -Name BITS | Set-Service -StartupType Automatic" # - BITS: Transfere arquivos em segundo plano usando largura de banda de rede ociosa. Se o serviço estiver desabilitado, qualquer aplicativo que dependa do BITS, como o Windows Update ou o MSN Explorer, não poderá baixar programas e outras informações automaticamente.
cmd.exe /c sc stop DiagTrack
cmd.exe /c sc stop SysMain
cmd.exe /c sc start BITS
cmd.exe /c sc start DPS

WPR -cancel
wusa /uninstall /kb:3201845 /quiet /norestart

Write-Output "" "Desativando tarefas agendadas que dão 100% de uso" ""
schtasks /CHANGE /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Application Experience\StartupAppTask" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Autochk\Proxy" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /DISABLE
schtasks /CHANGE /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /DISABLE

# Só remover se for extremamente necessário
# disable-MMAgent -mc

Write-Output "" "Desativando o Superfetch" ""
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f
Write-Output "" "Desativando a Assistência Remota" ""
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp /t REG_DWORD /d 0 /f
Write-Output "" "Repara alto uso de Memória/RAM" ""
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Ndu" /v Start /t REG_DWORD /d 4 /f
Write-Output "" "Desativando a Cortana" ""
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCloudSearch /t REG_DWORD /d 0 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v ConnectedSearchUseWeb /t REG_DWORD /d 0 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v DisableWebSearch /t REG_DWORD /d 1 /f

Start-Process wsreset
# Write-Output 'Restart your Computer!' 'Reinicie seu Computador!' | Msg * /time:3