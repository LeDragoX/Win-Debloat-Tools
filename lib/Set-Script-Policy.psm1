Function UnrestrictPermissions {
    Write-Host "Receiving permissions to run scripts"
    Write-Host "" # Skip Line
    Set-ExecutionPolicy Unrestricted -Scope Process -Force
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
    Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
    Get-ExecutionPolicy -List
    Write-Host "" # Skip Line
}

Function RestrictPermissions {
    Write-Host "Denying permissions to run scripts"
    Write-Host "" # Skip Line
    Set-ExecutionPolicy Restricted -Scope Process -Force
    Set-ExecutionPolicy Restricted -Scope CurrentUser -Force
    Set-ExecutionPolicy Restricted -Scope LocalMachine -Force
    Get-ExecutionPolicy -List
    Write-Host "" # Skip Line
}

# UnrestrictPermissions     # to Unlock script usage
# RestrictPermissions       # to Lock script usage