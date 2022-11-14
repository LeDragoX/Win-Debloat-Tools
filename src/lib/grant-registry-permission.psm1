Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://www.ipswitch.com/blog/how-to-change-registry-permissions-with-powershell

function Grant-RegistryPermission() {
    [CmdletBinding()]
    param (
        [String] $Key
    )

    Write-Status -Types "@" -Status "Trying to take ownership over the registry key: $Key"
    $Acl = Get-Acl 'HKLM:\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter'

    $IdentityRef = [System.Security.Principal.NTAccount]("$env:COMPUTERNAME\$env:USERNAME") # Identity
    $RegistryRights = [System.Security.AccessControl.RegistryRights]::FullControl # Rights wanted
    $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::None # Inheritance flags type
    $PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None # Propagation flags type
    $AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow # Access control type
    $Rule = New-Object System.Security.AccessControl.RegistryAccessRule ($IdentityRef, $RegistryRights, $InheritanceFlags, $PropagationFlags, $AccessControlType) # Registry access rule

    $Acl.AddAccessRule($Rule) # Add rule
    $Acl | Set-Acl # Apply the Acl changes
}

<#
.EXAMPLE
Grant-RegistryPermission -Key "HKLM:\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter" # Sadly returns an error
#>
