Function UnrestrictPermissions() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    Write-Host "[+] Receiving permissions to run scripts"
    Write-Host ""
    Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
    Get-ExecutionPolicy -List
    Write-Host ""
}

Function RestrictPermissions() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    Write-Host "[-] Denying permissions to run scripts"
    Write-Host ""
    Set-ExecutionPolicy Restricted -Scope LocalMachine -Force   # Reminds HKLM
    Set-ExecutionPolicy Restricted -Scope CurrentUser -Force    # Reminds HKCU
    Get-ExecutionPolicy -List
    Write-Host ""
}

# UnrestrictPermissions     # to Unlock script usage
# RestrictPermissions       # to Lock script usage