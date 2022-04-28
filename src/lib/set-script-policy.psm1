Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Unlock-ScriptUsage() {
    [CmdletBinding()] param ()

    Write-Status -Symbol "@" -Status "Receiving permissions to run scripts as Current User..."
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
}

function Block-ScriptUsage() {
    [CmdletBinding()] param ()

    Write-Status -Symbol "@" -Status "Denying permissions to run scripts as LocalMachine..."
    Set-ExecutionPolicy Restricted -Scope LocalMachine -Force
}

<#
Example:
Unlock-ScriptUsage  # to Unlock script usage
Block-ScriptUsage   # to Lock script usage
#>