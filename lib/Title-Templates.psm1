function Title1 ([String] $Text = "Test Text") {
	Write-Host "" # Skip line
	Write-Host "<====================[ $Text ]====================>" -ForegroundColor Cyan
	Write-Host "" # Skip line
}

function Title2 ([String] $Text = "Test Text") {
	Write-Host "" # Skip line
	Write-Host "<====================< $Text >====================>" -ForegroundColor Cyan
	Write-Host "" # Skip line
}

function Section1 ([String] $Text = "Test Text") {
	Write-Host "" # Skip line
	Write-Host "<==========[ $Text ]==========>" -ForegroundColor Cyan
	Write-Host "" # Skip line
}


function Caption1 ([String] $Text = "Test Text") {
	Write-Host "--> $Text" -ForegroundColor Cyan
	Write-Host "" # Skip line
}

function Title1Counter ([String] $Text = "Test Text COUNTER", [Int] $MaxNum = $Global:MaxNum) {

	$Global:MaxNum = $MaxNum
	
	if ($Counter -eq $null) {
		# Initialize Global variables
		$Global:Counter = 0
	}
	$Global:Counter = $Counter + 1
	Title1 "( $Counter/$MaxNum ) - [$Text]"
}

# Demo:
# Title1 -Text "Text"
# Title2 -Text "Text"
# Section1 -Text "Text"
# Caption1 -Text "Text"
# Title1Counter -Text "Text" -MaxNum 100 # First time only insert MaxNum