function Unrestrict-Permissions() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    Write-Host "[@] Receiving permissions to run scripts..."
    Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
    Get-ExecutionPolicy -List
}

function Restrict-Permissions() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    Write-Host "[@] Denying permissions to run scripts..."
    Set-ExecutionPolicy Restricted -Scope LocalMachine -Force   # Reminds HKLM
    Set-ExecutionPolicy Restricted -Scope CurrentUser -Force    # Reminds HKCU
    Get-ExecutionPolicy -List
}

<#
Example:
Unrestrict-Permissions  # to Unlock script usage
Restrict-Permissions    # to Lock script usage
#>