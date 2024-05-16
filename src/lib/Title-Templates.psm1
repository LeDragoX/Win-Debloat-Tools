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
        [System.Object] $Object = ''
    )

    Write-Style "••>" -Style Bold -Color DarkGray -BackColor Cyan -NoNewline
    Write-Style " $Object" -Style Italic -Color White -BackColor DarkGray
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
    Write-Style $ASCIIText -Style Blink -Color Green -BackColor Black
    Write-Style "`n        <•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••>" -Color White -BackColor Black
    Write-Style "                          It's Time to Debloat Windows! By LeDragoX & Community" -Style Blink -Color Cyan
}

function Write-Section() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.Object] $Object = ''
    )

    $Art = @('<••••••••••', '••••••••••>')

    Write-Style "`n$($Art[0])" -Style Bold -Color DarkGray -BackColor Cyan -NoNewline
    Write-Style "{ $Object }" -Style Italic -Color White -BackColor DarkGray -NoNewline
    Write-Style "$($Art[1])" -Style Bold -Color DarkGray -BackColor Cyan
    Write-Host
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

    $TypesDone = ""

    ForEach ($Type in $Types) {
        $TypesDone += "$([char]0x1b)[100m$([char]0x1b)[96m[$([char]0x1b)[97m$Type$([char]0x1b)[96m]$([char]0x1b)[m "
    }

    Write-Style "$TypesDone".Trim() -Style Bold -NoNewline

    If ($Warning) {
        Write-Style " $Status" -Color Yellow
    } Else {
        Write-Style " $Status" -Color Green
    }
}

function Write-Style() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.Object] $Object = '',
        [Parameter(Position = 1)]
        [ValidateSet('Blink', 'Bold', 'Italic', 'Regular', 'Strikethrough', 'Underline')]
        [String]        $Style = 'Regular',
        [Alias('Color')]
        [Parameter(Position = 2)]
        [ValidateSet('Black', 'Blue', 'DarkBlue', 'DarkCyan', 'DarkGray', 'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Cyan', 'Gray', 'Green', 'Red', 'Magenta', 'White', 'Yellow')]
        [String]        $ForeColor = 'White',
        [Parameter(Position = 3)]
        [ValidateSet('Black', 'Blue', 'DarkBlue', 'DarkCyan', 'DarkGray', 'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Cyan', 'Gray', 'Green', 'Red', 'Magenta', 'White', 'Yellow')]
        [String]        $BackColor = 'None',
        [Parameter(Position = 4)]
        [Switch]        $NoNewline
    )

    $BackColors = @{
        "Black"       = "$([char]0x1b)[40m"
        "DarkBlue"    = "$([char]0x1b)[44m"
        "DarkGreen"   = "$([char]0x1b)[42m"
        "DarkCyan"    = "$([char]0x1b)[46m"
        "DarkGray"    = "$([char]0x1b)[100m"
        "DarkRed"     = "$([char]0x1b)[41m"
        "DarkMagenta" = "$([char]0x1b)[45m" # Doesn't work on PowerShell, but works on the Terminal
        "DarkYellow"  = "$([char]0x1b)[43m"
        "Gray"        = "$([char]0x1b)[47m"
        "Blue"        = "$([char]0x1b)[104m"
        "Green"       = "$([char]0x1b)[102m"
        "Cyan"        = "$([char]0x1b)[106m"
        "Red"         = "$([char]0x1b)[101m"
        "Magenta"     = "$([char]0x1b)[105m"
        "Yellow"      = "$([char]0x1b)[103m"
        "White"       = "$([char]0x1b)[107m"
    }

    $ForeColors = @{
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

    $FormattedText = "$($Styles.$Style)$($BackColors.$BackColor)$($ForeColors.$ForeColor)$Object"

    If ($NoNewline) {
        return Write-Host "$FormattedText" -NoNewline
    }

    Write-Host "$FormattedText"
    Write-Verbose "Reference ^^^ S: $Style, F: $ForeColor, B: $BackColor"
}

function Write-Title() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.Object] $Object = ''
    )

    $Art = "<•••••••••••••••••••••••••••••••••••••••••••••••••••••••>"

    Write-Style "`n$([char]0x1b)[94m$Art" -Style Bold -BackColor Black -NoNewline
    Write-Style "`n$([char]0x1b)[97m   $Object" -Style Italic -BackColor Black -NoNewline
    Write-Style "`n$([char]0x1b)[94m$Art" -Style Bold -BackColor Black
}

function Write-TitleCounter() {
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param (
        [Parameter(Position = 0)]
        [System.Object] $Object = '',
        [Parameter(Position = 1)]
        [Int]           $Counter = 0,
        [Parameter(Position = 2)]
        [Int] 	        $MaxLength
    )

    $Counter += 1
    Write-Title "[$Counter/$MaxLength] | $Object"

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
