function Setup-ConsoleStyle() {
    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    cmd /c color A
}