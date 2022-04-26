Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Unlock-ScriptUsage() {
    [CmdletBinding()] param ()

    Write-Mandatory "Receiving permissions to run scripts..."
    Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
    Get-ExecutionPolicy -List | Out-Null
}

function Block-ScriptUsage() {
    [CmdletBinding()] param ()

    Write-Mandatory "Denying permissions to run scripts..."
    Set-ExecutionPolicy Restricted -Scope LocalMachine -Force
    Set-ExecutionPolicy Restricted -Scope CurrentUser -Force
    Get-ExecutionPolicy -List | Out-Null
}

<#
Example:
Unlock-ScriptUsage  # to Unlock script usage
Block-ScriptUsage   # to Lock script usage
#>