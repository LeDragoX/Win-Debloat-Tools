rem Running this script can cause various issues with Explorer, WSL, etc.
rem See https://github.com/W4RH4WK/Debloat-Windows-10/issues/250

taskkill /F /IM ShellExperienceHost.exe
move "%windir%\SystemApps\ShellExperienceHost_cw5n1h2txyewy" "%windir%\SystemApps\ShellExperienceHost_cw5n1h2txyewy.bak"
