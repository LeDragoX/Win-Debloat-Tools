function Unlock-ScriptUsage() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    Write-Host "[@] Receiving permissions to run scripts..." -ForegroundColor White
    Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
    Get-ExecutionPolicy -List | Out-Null
}

function Block-ScriptUsage() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    Write-Host "[@] Denying permissions to run scripts..." -ForegroundColor White
    Set-ExecutionPolicy Restricted -Scope LocalMachine -Force
    Set-ExecutionPolicy Restricted -Scope CurrentUser -Force
    Get-ExecutionPolicy -List | Out-Null
}

<#
Example:
Unlock-ScriptUsage  # to Unlock script usage
Block-ScriptUsage   # to Lock script usage
#>