function Unrestrict-Permissions() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    Write-Host "[@] Receiving permissions to run scripts..." -ForegroundColor White
    Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
    Get-ExecutionPolicy -List | Out-Host
}

function Restrict-Permissions() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    Write-Host "[@] Denying permissions to run scripts..." -ForegroundColor White
    Set-ExecutionPolicy Restricted -Scope LocalMachine -Force
    Set-ExecutionPolicy Restricted -Scope CurrentUser -Force
    Get-ExecutionPolicy -List | Out-Host
}

<#
Example:
Unrestrict-Permissions  # to Unlock script usage
Restrict-Permissions    # to Lock script usage
#>