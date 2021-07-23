Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"count-n-seconds.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"simple-message-box.psm1"

Function RunManualDebloatSoftwares() {

    $Message = "[This is a DIY step]
    1 - If showed click [I AGREE]
    2 - Click on the guide Tools >
    3 - Go on Import/Export Tweaks >
    4 - Import tweaks from a file >
    5 - hit Next > Browse... > Select 'My_Winaero_Profile.ini' >
    6 - Next > Finish (DON'T SPAM)
    7 - Close it then OK"
        
    # If changing the programs folder move here!!!
    Push-Location -Path "..\lib\debloat-softwares\"
    
    Write-Host "+ [DIY] Running WinAero Tweaker..."
    Expand-Archive '.\Winaero Tweaker.zip'
    Push-Location -Path "Winaero Tweaker\"
    Remove-Item ".\Winaero.url" -Force -Recurse # Web page Shortcut
    Start-Process -FilePath ".\WinaeroTweaker.exe" # Could not download it (Tried Start-BitsTransfer and WebClient, but nothing)
    Pop-Location
        
    CountNseconds -Time 2 -Msg "Waiting" # Count 2 seconds then show the Message
    ShowMessage -Title "Close when finished" -Message $Message
    Taskkill /F /IM "WinaeroTweaker.exe"
    Taskkill /F /IM "WinaeroTweakerHelper.exe"
    Remove-Item ".\Winaero Tweaker\" -Exclude "*.ini" -Force -Recurse
    
    Pop-Location
    
}

RunManualDebloatSoftwares   # [DIY] Run WinAeroTweaker.
