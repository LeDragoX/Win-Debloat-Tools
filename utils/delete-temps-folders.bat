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

pause