Function Title1 {

	[CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
		[String]	$Text = "Title1 Text"
    )

	Write-Host "" # Skip line
	Write-Host "<====================[ $Text ]====================>" -ForegroundColor Cyan
	Write-Host "" # Skip line
}

Function Title2 {

	[CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
		[String]	$Text = "Title2 Text"
    )

	Write-Host "" # Skip line
	Write-Host "<====================< $Text >====================>" -ForegroundColor Yellow
	Write-Host "" # Skip line
}

Function Section1 {

	[CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
		[String]	$Text = "Section1 Text"
    )

	Write-Host "" # Skip line
	Write-Host "<==========[ $Text ]==========>" -ForegroundColor Cyan
	Write-Host "" # Skip line
}


Function Caption1 {

	[CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
		[String]	$Text = "Caption1 Text"
    )

	Write-Host "--> $Text" -ForegroundColor Cyan
	Write-Host "" # Skip line
}

Function Title1Counter {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
		[String]	$Text = "Title1 COUNTER Text", 
		[Int] 		$MaxNum = $Global:MaxNum
    )

	$Global:MaxNum = $MaxNum
	
	If ($null -eq $Counter) {
		# Initialize Global variables
		$Global:Counter = 0
	}
	
	$Global:Counter = $Counter + 1
	Title1 "( $Counter/$MaxNum ) - [$Text]"

	# Reset both when the Counter is the same as MaxNum and different from 0
	If (($Counter -ge $MaxNum) -and !($Counter -eq 0)) {
        $Global:Counter = 0
		$Global:MaxNum	= 0
	}
}

# Demo:
# Title1 -Text "Text"
# Title2 -Text "Text"
# Section1 -Text "Text"
# Caption1 -Text "Text"
# Title1Counter -Text "Text" -MaxNum 100 # First time only insert MaxNum