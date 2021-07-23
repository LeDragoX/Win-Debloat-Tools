<#
.SYNOPSIS
    Accept accents and console color to green
.DESCRIPTION
    Accept font accents and change the console color to green
.EXAMPLE
    PS C:\> Import-Module .\{FilePath}\setup-console-style.psm1
    PS C:\> SetupConsoleStyle
    Accept font accents and change the console color to green 
#>
Function SetupConsoleStyle() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    chcp 65001
    cmd /c color A
}