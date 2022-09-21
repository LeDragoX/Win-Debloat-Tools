Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Main() {
    $Ask = "Are you sure you want to remove Microsoft Edge from Windows?`nYou can reinstall it anytime.`nNote: all users logged in will remain."

    switch (Show-Question -Title "Warning" -Message $Ask -BoxIcon "Warning") {
        'Yes' {
            Remove-MSEdge
        }
        'No' {
            Write-Host "Aborting..."
        }
        'Cancel' {
            Write-Host "Aborting..." # With Yes, No and Cancel, the user can press Esc to exit
        }
    }
}

function Remove-MSEdge() {
    $PathToLMEdgeUpdate = "HKLM:\SOFTWARE\Microsoft\EdgeUpdate"

    If ((Test-Path -Path "$env:SystemDrive\Program Files (x86)\Microsoft\Edge\Application") -or (Test-Path -Path "$env:SystemDrive\Program Files (x86)\Microsoft\EdgeWebView\Application")) {
        ForEach ($FullName in (Get-ChildItem -Path "$env:SystemDrive\Program Files (x86)\Microsoft\Edge*\Application\*\Installer\setup.exe").FullName) {
            Write-Status -Types "@" -Status "Uninstalling MS Edge from $FullName..."
            Start-Process -FilePath $FullName -ArgumentList "--uninstall", "--msedgewebview", "--system-level", "--verbose-logging", "--force-uninstall" -Wait
        }
    } Else {
        Write-Status -Types "?" -Status "Edge/EdgeWebView folder does not exist anymore..." -Warning
    }

    If (Test-Path -Path "$env:SystemDrive\Program Files (x86)\Microsoft\EdgeCore") {
        ForEach ($FullName in (Get-ChildItem -Path "$env:SystemDrive\Program Files (x86)\Microsoft\EdgeCore\*\Installer\setup.exe").FullName) {
            Write-Status -Types "@" -Status "Uninstalling MS Edge from $FullName..."
            Start-Process -FilePath $FullName -ArgumentList "--uninstall", "--system-level", "--verbose-logging", "--force-uninstall" -Wait
        }
    } Else {
        Write-Status -Types "?" -Status "EdgeCore folder does not exist anymore..." -Warning
    }

    Write-Status -Types "@" -Status "Preventing Edge from reinstalling..."
    If (!(Test-Path "$PathToLMEdgeUpdate")) {
        New-Item -Path "$PathToLMEdgeUpdate" -Force | Out-Null
    }
    Set-ItemProperty -Path "$PathToLMEdgeUpdate" -Name "DoNotUpdateToEdgeWithChromium" -Type DWord -Value 1

    Write-Status -Types "@" -Status "Deleting Edge appdata\local folders from current user..."
    Remove-Item -Path "$env:LOCALAPPDATA\Packages\Microsoft.MicrosoftEdge*_*" -Recurse -Force | Out-Host

    Write-Status -Types "@" -Status "Deleting Edge from Program Files (x86)..."
    Remove-Item -Path "$env:SystemDrive\Program Files (x86)\Microsoft\Edge*" -Recurse -Force | Out-Host
    Remove-Item -Path "$env:SystemDrive\Program Files (x86)\Microsoft\Temp" -Recurse -Force | Out-Host
}

Main