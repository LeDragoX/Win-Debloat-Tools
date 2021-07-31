function SetupConsoleStyle() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    cmd /c color A
}