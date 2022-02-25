function Write-Title() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [String]	$Text = "Write-Title Text"
    )

    Write-Host "`n<===================={ $Text }====================>`n" -ForegroundColor Cyan
}

function Write-Section() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [String] $Text = "Write-Section Text"
    )

    Write-Host "`n<=========={ $Text }==========>`n" -ForegroundColor Cyan
}

function Write-Caption() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [String] $Text = "Write-Caption Text"
    )

    Write-Host "==> $Text`n" -ForegroundColor Cyan
}

function Write-TitleCounter() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [String] $Text = "TitleCounter Text", 
        [Int] 	 $MaxNum = $Global:MaxNum
    )

    $Global:MaxNum = $MaxNum

    If ($null -eq $Counter) {
        # Initialize Global variables
        $Global:Counter = 0
    }

    $Global:Counter = $Counter + 1
    Write-Host "`n<===================={ ( $Counter/$MaxNum ) - { $Text } }====================>`n" -ForegroundColor Yellow

    # Reset both when the Counter is greater or equal than MaxNum and different from 0
    If (($Counter -ge $MaxNum) -and !($Counter -eq 0)) {
        $Global:Counter = 0
        $Global:MaxNum	= 0
    }
}

function Write-ASCIIScriptName() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param ()

    "
    
    "
    Write-Host '   __        ___         _  ___          ____                       _   ' -ForegroundColor Cyan
    Write-Host '   \ \      / (_)_ __   / |/ _ \   _    / ___| _ __ ___   __ _ _ __| |_ ' -ForegroundColor Cyan
    Write-Host '    \ \ /\ / /| | "_ \  | | | | |_| |_  \___ \| "_ ` _ \ / _` | "__| __|' -ForegroundColor Cyan
    Write-Host '     \ V  V / | | | | | | | |_| |_   _|  ___) | | | | | | (_| | |  | |_ ' -ForegroundColor Cyan
    Write-Host '      \_/\_/  |_|_| |_| |_|\___/  |_|   |____/|_| |_| |_|\__,_|_|   \__|' -ForegroundColor Cyan
    Write-Host '                                                                        ' -ForegroundColor Cyan
    Write-Host '        ____       _     _             _     _____           _          ' -ForegroundColor Cyan
    Write-Host '       |  _ \  ___| |__ | | ___   __ _| |_  |_   _|__   ___ | |___      ' -ForegroundColor Cyan
    Write-Host '       | | | |/ _ \ "_ \| |/ _ \ / _` | __|   | |/ _ \ / _ \| / __|     ' -ForegroundColor Cyan
    Write-Host '       | |_| |  __/ |_) | | (_) | (_| | |_    | | (_) | (_) | \__ \     ' -ForegroundColor Cyan
    Write-Host "       |____/ \___|_.__/|_|\___/ \__,_|\__|   |_|\___/ \___/|_|___/ `n`n" -ForegroundColor Cyan

}

<#
Example:
Write-Title -Text "Text"
Write-Section -Text "Text"
Write-Caption -Text "Text"
Write-TitleCounter -Text "Text" -MaxNum 100 # First time only insert MaxNum
Write-ASCIIScriptName
#>