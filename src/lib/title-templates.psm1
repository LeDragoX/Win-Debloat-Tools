function Get-AllStyle() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.Object] $Object = "Yay!"
    )

    for ($i = 0; $i -le 110; $i++) {
        <# Action that will repeat until the condition is met #>
        Write-Host "$([char]0x1b)[$i`m [$i] $Object"
    }
}

function Write-Caption() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.Object] $Object = "No Text"
    )

    Write-Style "••> " -Style Bold -Color Cyan -NoNewline
    Write-Style "$Object" -Style Italic -Color White
}

function Write-ScriptLogo() {
    [CmdletBinding()] param ()

    # Font: ANSI FIGlet Fonts > ANSI Shadow
    $ASCIIText = @"
        ██╗    ██╗██╗███╗   ██╗    ██████╗ ███████╗██████╗ ██╗      ██████╗  █████╗ ████████╗
        ██║    ██║██║████╗  ██║    ██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗██╔══██╗╚══██╔══╝
        ██║ █╗ ██║██║██╔██╗ ██║    ██║  ██║█████╗  ██████╔╝██║     ██║   ██║███████║   ██║
        ██║███╗██║██║██║╚██╗██║    ██║  ██║██╔══╝  ██╔══██╗██║     ██║   ██║██╔══██║   ██║
        ╚███╔███╔╝██║██║ ╚████║    ██████╔╝███████╗██████╔╝███████╗╚██████╔╝██║  ██║   ██║
         ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝    ╚═════╝ ╚══════╝╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

                            ████████╗ ██████╗  ██████╗ ██╗     ███████╗
                            ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝
                               ██║   ██║   ██║██║   ██║██║     ███████╗
                               ██║   ██║   ██║██║   ██║██║     ╚════██║
                               ██║   ╚██████╔╝╚██████╔╝███████╗███████║
                               ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
"@
    Write-Style $ASCIIText -Style Blink -Color Green
    Write-Style "`n<•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••>" -Color White
    Write-Style "                                    It's Time to Debloat Windows!" -Style Blink -Color Cyan
}

function Write-Section() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.Object] $Object = "No Text"
    )

    $Art = @('<••••••••••{', '}••••••••••>')

    Write-Style "`n$($Art[0]) " -Style Bold -Color Cyan -NoNewline
    Write-Style "$Object " -Style Italic -Color White -NoNewline
    Write-Style "$($Art[1])`n" -Style Bold -Color Cyan
}

function Write-Status() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [String[]] $Types,
        [Parameter(Position = 1, Mandatory)]
        [String]   $Status,
        [Switch]   $Warning
    )

    ForEach ($Type in $Types) {
        Write-Style "$([char]0x1b)[94m[$([char]0x1b)[97m$Type$([char]0x1b)[94m] " -Style Bold -NoNewline
    }

    If ($Warning) {
        Write-Style "$Status" -Color Yellow
    } Else {
        Write-Style "$Status" -Color Green
    }
}

function Write-Style() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.Object] $Object = "No Text",
        [Parameter(Position = 1)]
        [ValidateSet("Blink", "Bold", "Italic", "Regular", "Strikethrough", "Underline")]
        [String]        $Style = "Regular",
        [Parameter(Position = 2)]
        [ValidateSet("Black", "Blue", "DarkBlue", "DarkCyan", "DarkGray", "DarkGreen", "DarkMagenta", "DarkRed", "DarkYellow", "Cyan", "Gray", "Green", "Red", "Magenta", "White", "Yellow")]
        [String]        $Color = "White",
        [Parameter(Position = 3)]
        [Switch]        $NoNewline
    )

    $Colors = @{
        "Black"       = "$([char]0x1b)[30m"
        "DarkBlue"    = "$([char]0x1b)[34m"
        "DarkGreen"   = "$([char]0x1b)[32m"
        "DarkCyan"    = "$([char]0x1b)[36m"
        "DarkGray"    = "$([char]0x1b)[90m"
        "DarkRed"     = "$([char]0x1b)[31m"
        "DarkMagenta" = "$([char]0x1b)[35m" # Doesn't work on PowerShell, but works on the Terminal
        "DarkYellow"  = "$([char]0x1b)[33m"
        "Gray"        = "$([char]0x1b)[37m"
        "Blue"        = "$([char]0x1b)[94m"
        "Green"       = "$([char]0x1b)[92m"
        "Cyan"        = "$([char]0x1b)[96m"
        "Red"         = "$([char]0x1b)[91m"
        "Magenta"     = "$([char]0x1b)[95m"
        "Yellow"      = "$([char]0x1b)[93m"
        "White"       = "$([char]0x1b)[97m"
    }

    $Styles = @{
        "Blink"         = "$([char]0x1b)[5m"
        "Bold"          = "$([char]0x1b)[1m"
        "Italic"        = "$([char]0x1b)[3m"
        "Regular"       = "$([char]0x1b)[0m"
        "Strikethrough" = "$([char]0x1b)[9m"
        "Underline"     = "$([char]0x1b)[4m"
    }

    If ($NoNewline) {
        return Write-Host "$($Styles.$Style)$($Colors.$Color)$Object" -NoNewline
    }

    Write-Host "$($Styles.$Style)$($Colors.$Color)$Object"
}

function Write-Title() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.Object] $Object = "No Text"
    )

    $Art = "<•••••••••••••••••••••••••••••••••••••••••••••••••••••••>"

    Write-Style "`n$([char]0x1b)[94m$Art" -Style Bold -NoNewline
    Write-Style "`n$([char]0x1b)[97m   $Object" -Style Italic -NoNewline
    Write-Style "`n$([char]0x1b)[94m$Art" -Style Bold
}

function Write-TitleCounter() {
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param (
        [Parameter(Position = 0)]
        [System.Object] $Object = "No Text",
        [Parameter(Position = 1)]
        [Int]           $Counter = 0,
        [Parameter(Position = 2)]
        [Int] 	        $MaxLength
    )

    $Counter += 1
    Write-Title "($Counter/$MaxLength) - $Object"

    return $Counter
}

<#
Example:
Write-Caption -Object "Text" # Used to print Tweak Category
Write-ScriptLogo # Used at the start of the Script
Write-Section -Object "Text" # Used to print Tweak Section
Write-Status -Types "?", ... -Status "Doing something"
Write-Status -Types "?", ... -Status "Doing something" -Warning
Write-Title -Object "Text" # Used to print Tweak introduction

$Private:Counter = Write-TitleCounter -Object "Text" -Counter $Counter -MaxLenght 100 # Used to print when working with collections # No need to iterate $Counter before, as long it's private
$Private:Counter = Write-TitleCounter -Object "Text" -Counter $Counter -MaxLenght 100 # Used to print when working with collections # No need to iterate $Counter before, as long it's private
#>

# [enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Host $_ -ForegroundColor $_ }
