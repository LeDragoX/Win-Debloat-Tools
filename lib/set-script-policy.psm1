Function UnrestrictPermissions {
    Write-Host "[+] Receiving permissions to run scripts"
    Write-Host "" # Skip Line
    Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
    Get-ExecutionPolicy -List
    Write-Host "" # Skip Line
}

Function RestrictPermissions {
    Write-Host "[-] Denying permissions to run scripts"
    Write-Host "" # Skip Line
    Set-ExecutionPolicy Restricted -Scope LocalMachine -Force   # Reminds HKLM
    Set-ExecutionPolicy Restricted -Scope CurrentUser -Force    # Reminds HKCU
    Get-ExecutionPolicy -List
    Write-Host "" # Skip Line
}

# UnrestrictPermissions     # to Unlock script usage
# RestrictPermissions       # to Lock script usage