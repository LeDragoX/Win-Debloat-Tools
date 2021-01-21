function SimpleTitleTemplate ([String] $Text = "Test Text") {
	Write-Host "" # Skip line
	Write-Host "<====================< $Text >====================>"
	Write-Host "" # Skip line
}

function BeautyTitleTemplate ([String] $Text = "Test Text") {
	Write-Host "" # Skip line
	Write-Host "<====================[ $Text ]====================>"
	Write-Host "" # Skip line
}

function BeautySectionTemplate ([String] $Text = "Test Text") {
	Write-Host "" # Skip line
	Write-Host "<==========[ $Text ]==========>"
	Write-Host "" # Skip line
}


function CaptionTemplate ([String] $Text = "Test Text") {
	Write-Host "--> $Text"
	Write-Host "" # Skip line
}

function TitleWithContinuousCounter ([String] $Text = "Test Text COUNTER", [Int] $MaxNum = $Global:MaxNum) {

	if (!($null -eq $MaxNum)) {
		# Initialize Global variables
		$Global:MaxNum = $MaxNum
	}
	if ($null -eq $Counter) {
		# Initialize Global variables
		$Global:Counter = 0
	}
	$Global:Counter = $Counter + 1
	SimpleTitleTemplate "( $Counter/$Global:MaxNum ) - [$Text]"
}

# Demo:
# SimpleTitleTemplate -Text "Text"
# BeautyTitleTemplate -Text "Text"
# BeautySectionTemplate -Text "Text"
# CaptionTemplate -Text "Text"
# TitleWithContinuousCounter -Text "Text"