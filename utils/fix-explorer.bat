@echo ---- Preparation ----

@set this=%~dp0
@set thisdrive=%this:~0,2%

%thisdrive%
@cd %this%

@echo This bat drive = %thisdrive%
@echo This bat folder = %this%

@echo off & echo ---- Prepared ----
@Echo ============================================
@Echo Fix windows explorer opening with no reason
@Echo ============================================

@sfc /scannow
@dism.exe /online /cleanup-image /restorehealth

@PowerShell Write-Output 'Restart your Computer!' 'Reinicie seu Computador!' | Msg * /time:3