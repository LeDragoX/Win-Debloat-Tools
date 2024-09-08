@echo This will enable SysMain/Superfetch

Powershell "Get-Service -Name SysMain | Set-Service -StartupType Automatic"
sc start SysMain

REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 3 /f
