function Set-ConsoleStyle() {
    [CmdletBinding()] param (
        [Parameter(Position = 0)]
        [ValidateSet(1, 2, 3, 4, 5, 6, 7, 8, 9, 'A', 'B', 'C', 'D', 'E', 'F')]
        [String] $Color = 'A'
    )

    Process {
        cmd /c color $Color
    }
}
