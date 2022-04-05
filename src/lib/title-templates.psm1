function Write-Title() {
    [CmdletBinding()]
    param (
        [String] $Text = "No Text"
    )

    Write-Host "`n<===================={ $Text }====================>" -ForegroundColor Cyan
}

function Write-Section() {
    [CmdletBinding()]
    param (
        [String] $Text = "No Text"
    )

    Write-Host "`n<=========={ $Text }==========>`n" -ForegroundColor Cyan
}

function Write-Caption() {
    [CmdletBinding()]
    param (
        [String] $Text = "No Text"
    )

    Write-Host "=====> $Text" -ForegroundColor Cyan
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
    Write-Host "`n<===================={ ( $Counter/$MaxLength ) - { $Text } }====================>" -ForegroundColor Yellow

    return $Counter
}

function Write-ScriptLogo() {
    [CmdletBinding()] param ()

    Write-Host "<=========================================================================================================>`n" -ForegroundColor White
    Write-Host '888       888 d8b           d888   .d8888b.                .d8888b.                                 888    ' -ForegroundColor Green
    Write-Host '888   o   888 Y8P          d8888  d88P  Y88b              d88P  Y88b                                888    ' -ForegroundColor Green
    Write-Host '888  d8b  888                888  888    888              Y88b.                                     888    ' -ForegroundColor Green
    Write-Host '888 d888b 888 888 88888b.    888  888    888   888         "Y888b.   88888b.d88b.   8888b.  888d888 888888 ' -ForegroundColor Green
    Write-Host '888d88888b888 888 888 "88b   888  888    888 8888888          "Y88b. 888 "888 "88b     "88b 888P"   888    ' -ForegroundColor Green
    Write-Host '88888P Y88888 888 888  888   888  888    888   888              "888 888  888  888 .d888888 888     888    ' -ForegroundColor Green
    Write-Host '8888P   Y8888 888 888  888   888  Y88b  d88P              Y88b  d88P 888  888  888 888  888 888     Y88b.  ' -ForegroundColor Green
    Write-Host '888P     Y888 888 888  888 8888888 "Y8888P"                "Y8888P"  888  888  888 "Y888888 888      "Y888 ' -ForegroundColor Green
    Write-Host '                                                                                                           ' -ForegroundColor Green
    Write-Host '  8888888b.           888      888                   888         88888888888                888            ' -ForegroundColor Green
    Write-Host '  888  "Y88b          888      888                   888             888                    888            ' -ForegroundColor Green
    Write-Host '  888    888          888      888                   888             888                    888            ' -ForegroundColor Green
    Write-Host '  888    888  .d88b.  88888b.  888  .d88b.   8888b.  888888          888   .d88b.   .d88b.  888 .d8888b    ' -ForegroundColor Green
    Write-Host '  888    888 d8P  Y8b 888 "88b 888 d88""88b     "88b 888             888  d88""88b d88""88b 888 88K        ' -ForegroundColor Green
    Write-Host '  888    888 88888888 888  888 888 888  888 .d888888 888             888  888  888 888  888 888 "Y8888b.   ' -ForegroundColor Green
    Write-Host '  888  .d88P Y8b.     888 d88P 888 Y88..88P 888  888 Y88b.           888  Y88..88P Y88..88P 888      X88   ' -ForegroundColor Green
    Write-Host "  8888888P'   'Y8888  88888P'  888  'Y88P'  'Y888888  'Y888          888   'Y88P'   'Y88P'  888  88888P'   `n" -ForegroundColor Green
    Write-Host "<=========================================================================================================>" -ForegroundColor White
    Write-Host "                                        It's Time to Debloat Windows" -ForegroundColor Green
    Write-Host "<=========================================================================================================>" -ForegroundColor White
}

<#
Example:
Write-Title -Text "Text"
Write-Section -Text "Text"
Write-Caption -Text "Text"
$Private:Counter = Write-TitleCounter -Text "Text" -Counter $Counter -MaxLenght 100 # No need to iterate $Counter before, as long it's private
$Private:Counter = Write-TitleCounter -Text "Text" -Counter $Counter -MaxLenght 100 # No need to iterate $Counter before, as long it's private
Write-ScriptLogo
#>