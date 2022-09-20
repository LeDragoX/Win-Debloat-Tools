function Write-Title() {
    [CmdletBinding()]
    param (
        [String] $Text = "No Text"
    )

    Write-Host "`n<•••••••••••••••••••••••••••••••••••••••••••••••••••••••>" -ForegroundColor Blue -BackgroundColor Black
    Write-Host "   $Text" -ForegroundColor White -BackgroundColor Black
    Write-Host "<•••••••••••••••••••••••••••••••••••••••••••••••••••••••>" -ForegroundColor Blue -BackgroundColor Black
}

function Write-Section() {
    [CmdletBinding()]
    param (
        [String] $Text = "No Text"
    )

    Write-Host "`n<••••••••••{ " -NoNewline -ForegroundColor Cyan -BackgroundColor Black
    Write-Host "$Text " -NoNewline -ForegroundColor White -BackgroundColor Black
    Write-Host "}••••••••••>`n" -ForegroundColor Cyan -BackgroundColor Black
}

function Write-Caption() {
    [CmdletBinding()]
    param (
        [String] $Text = "No Text"
    )

    Write-Host "••> " -NoNewline -ForegroundColor Cyan -BackgroundColor Black
    Write-Host "$Text" -ForegroundColor White -BackgroundColor Black
}

function Write-Status() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Array]  $Types,
        [Parameter(Mandatory)]
        [String] $Status,
        [Switch] $Warning
    )

    ForEach ($Type in $Types) {
        Write-Host "[" -NoNewline -ForegroundColor Blue -BackgroundColor Black
        Write-Host "$Type" -NoNewline -ForegroundColor White -BackgroundColor Black
        Write-Host "] " -NoNewline -ForegroundColor Blue -BackgroundColor Black
    }

    If ($Warning) {
        Write-Host "$Status" -ForegroundColor Yellow -BackgroundColor Black
    } Else {
        Write-Host "$Status" -ForegroundColor Green -BackgroundColor Black
    }
}

function Write-TitleCounter() {
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param (
        [String] $Text = "No Text",
        [Int]    $Counter = 0,
        [Int] 	 $MaxLength
    )

    $Counter += 1
    Write-Title -Text "($Counter/$MaxLength) – $Text"

    return $Counter
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
    Write-Host $ASCIIText -ForegroundColor Green -BackgroundColor Black
    Write-Host "`n<•••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••>" -ForegroundColor White -BackgroundColor Black
    Write-Host "                                    It's Time to Debloat Windows!" -ForegroundColor Cyan -BackgroundColor Black
}

<#
Example:
Write-Title -Text "Text" # Used to print Tweak introduction
Write-Section -Text "Text" # Used to print Tweak Section
Write-Caption -Text "Text" # Used to print Tweak Category
Write-Status -Types "?", ... -Status "Doing something"
Write-Status -Types "?", ... -Status "Doing something" -Warning
$Private:Counter = Write-TitleCounter -Text "Text" -Counter $Counter -MaxLenght 100 # Used to print when working with collections # No need to iterate $Counter before, as long it's private
$Private:Counter = Write-TitleCounter -Text "Text" -Counter $Counter -MaxLenght 100 # Used to print when working with collections # No need to iterate $Counter before, as long it's private
Write-ScriptLogo # Used at the start of the Script
#>