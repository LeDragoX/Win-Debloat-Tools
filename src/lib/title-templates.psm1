function Write-Title() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [String]	$Text = "Write-Title Text"
    )

    Write-Host "" # Skip line
    Write-Host "<====================[ $Text ]====================>" -ForegroundColor Cyan
    Write-Host "" # Skip line
}

function Write-Section() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [String] $Text = "Write-Section Text"
    )

    Write-Host "" # Skip line
    Write-Host "<==========[ $Text ]==========>" -ForegroundColor Cyan
    Write-Host "" # Skip line
}

function Write-Caption() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [String] $Text = "Write-Caption Text"
    )

    Write-Host "--> $Text" -ForegroundColor Cyan
    Write-Host "" # Skip line
}

function Write-TitleCounter() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [String] $Text = "Title2 COUNTER Text", 
        [Int] 	 $MaxNum = $Global:MaxNum
    )

    $Global:MaxNum = $MaxNum

    If ($null -eq $Counter) {
        # Initialize Global variables
        $Global:Counter = 0
    }

    $Global:Counter = $Counter + 1
    Write-Host "" # Skip line
    Write-Host "<====================< ( $Counter/$MaxNum ) - [$Text] >====================>" -ForegroundColor Yellow
    Write-Host "" # Skip line

    # Reset both when the Counter is greater or equal than MaxNum and different from 0
    If (($Counter -ge $MaxNum) -and !($Counter -eq 0)) {
        $Global:Counter = 0
        $Global:MaxNum	= 0
    }
}

<#
Example:
Write-Title -Text "Text"
Write-Section -Text "Text"
Write-Caption -Text "Text"
Write-TitleCounter -Text "Text" -MaxNum 100 # First time only insert MaxNum
#>