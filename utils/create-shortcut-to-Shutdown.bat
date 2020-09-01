@echo off
echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "%USERPROFILE%\Desktop\Desligar PC.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%SYSTEMROOT%\System32\shutdown.exe" >> CreateShortcut.vbs
echo oLink.Arguments = "-s -t 0" >> CreateShortcut.vbs
echo oLink.IconLocation = "%SYSTEMROOT%\System32\SHELL32.dll, 27" >> CreateShortcut.vbs REM 27 ou 215 é o número do ícone de desligar dentro de SHELL32.dll
REM echo "%SYSTEMROOT%\system32\imageres.dll, 2" >> CreateShortcut.vbs REM Ícones do Windows 10
REM echo "%SYSTEMROOT%\system32\pifmgr.dll, 2" >> CreateShortcut.vbs REM Ícones do Windows 95/98
REM echo "%SYSTEMROOT%\explorer.exe, 2" >> CreateShortcut.vbs REM Ícones do Windows Explorer
REM echo "%SYSTEMROOT%\system32\accessibilitycpl.dll, 2" >> CreateShortcut.vbs REM Ícones de Acessibilidade
REM echo "%SYSTEMROOT%\system32\ddores.dll, 2" >> CreateShortcut.vbs REM Ícones de Hardware
REM echo "%SYSTEMROOT%\system32\moricons.dll, 2" >> CreateShortcut.vbs REM Ícones do MS-DOS
REM echo "%SYSTEMROOT%\system32\mmcndmgr.dll, 2" >> CreateShortcut.vbs REM Mais Ícones do Windows 95/98
REM echo "%SYSTEMROOT%\system32\mmres.dll, 2" >> CreateShortcut.vbs REM Ícones de Áudio
REM echo "%SYSTEMROOT%\system32\netshell.dll, 2" >> CreateShortcut.vbs REM Ícones de Rede
REM echo "%SYSTEMROOT%\system32\netcenter.dll, 2" >> CreateShortcut.vbs REM Mais Ícones de Rede
REM echo "%SYSTEMROOT%\system32\networkexplorer.dll, 2" >> CreateShortcut.vbs REM Mais Ícones de Rede e Impressora
REM echo "%SYSTEMROOT%\system32\pnidui.dll, 2" >> CreateShortcut.vbs REM Mais Ícones de Status de Rede
REM echo "%SYSTEMROOT%\system32\sensorscpl.dll, 2" >> CreateShortcut.vbs REM Ícones de diferentes Sensores
REM echo "%SYSTEMROOT%\system32\setupapi.dll, 2" >> CreateShortcut.vbs REM Ícones de Setup Wizard
REM echo "%SYSTEMROOT%\system32\wmploc.dll, 2" >> CreateShortcut.vbs REM Ícones de Multimídia
REM echo "%SYSTEMROOT%\system32\system32\wpdshext.dll, 2" >> CreateShortcut.vbs REM Ícones de Dispositivos portáteis e Bateria
REM echo "%SYSTEMROOT%\system32\compstui.dll, 2" >> CreateShortcut.vbs REM Ícones Clássicos de Impressora, Telefone e Email
REM echo "%SYSTEMROOT%\system32\dmdskres.dll, 2" >> CreateShortcut.vbs REM Ícones do Gerenciamento de Disco
REM echo "%SYSTEMROOT%\system32\dsuiext.dll, 2" >> CreateShortcut.vbs REM Ícones de Serviços de Rede
REM echo "%SYSTEMROOT%\system32\mstscax.dll, 2" >> CreateShortcut.vbs REM Ícones de Conexão Remota
REM echo "%SYSTEMROOT%\system32\wiashext.dll, 2" >> CreateShortcut.vbs REM Ícones de Hardware de Imagem
REM echo "%SYSTEMROOT%\system32\comres.dll, 2" >> CreateShortcut.vbs REM Ícones de Ações
REM echo "%SYSTEMROOT%\system32\comres.dll, 2" >> CreateShortcut.vbs REM Mais Ícones de Rede, Som e logo do Windows 8

echo oLink.Save >> CreateShortcut.vbs
cscript CreateShortcut.vbs
del "%USERPROFILE%\Desktop\CreateShortcut.vbs"