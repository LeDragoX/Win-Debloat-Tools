function Set-UnrestrictedPermissions() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    Write-Host "[@] Receiving permissions to run scripts..." -ForegroundColor White
    Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
    Get-ExecutionPolicy -List | Out-Null
}

function Set-RestrictedPermissions() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    Write-Host "[@] Denying permissions to run scripts..." -ForegroundColor White
    Set-ExecutionPolicy Restricted -Scope LocalMachine -Force
    Set-ExecutionPolicy Restricted -Scope CurrentUser -Force
    Get-ExecutionPolicy -List | Out-Null
}

<#
Example:
Set-UnrestrictedPermissions  # to Unlock script usage
Set-RestrictedPermissions    # to Lock script usage
#>