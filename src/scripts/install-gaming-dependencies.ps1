Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"show-dialog-window.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Install-GamingSoftwareRequirement() {
    $ChocoGamingPackages = @(
        "directx"                           # DirectX End-User Runtime
    )
    $WingetGamingPackages = @(
        "Microsoft.dotNetFramework"         # Microsoft .NET Framework (v4.8+)
        "Microsoft.VC++2005Redist-x86"      # Microsoft Visual C++ 2005 Redistributable
        "Microsoft.VC++2005Redist-x64"      # Microsoft Visual C++ 2005 Redistributable (x64)
        "Microsoft.VC++2008Redist-x86"      # Microsoft Visual C++ 2008 Redistributable - x86
        "Microsoft.VC++2008Redist-x64"      # Microsoft Visual C++ 2008 Redistributable - x64
        "Microsoft.VC++2010Redist-x86"      # Microsoft Visual C++ 2010 x86 Redistributable
        "Microsoft.VC++2010Redist-x64"      # Microsoft Visual C++ 2010 x64 Redistributable
        "Microsoft.VC++2012Redist-x86"      # Microsoft Visual C++ 2012 Redistributable (x86)
        "Microsoft.VC++2012Redist-x64"      # Microsoft Visual C++ 2012 Redistributable (x64)
        "Microsoft.VC++2013Redist-x86"      # Microsoft Visual C++ 2013 Redistributable (x86)
        "Microsoft.VC++2013Redist-x64"      # Microsoft Visual C++ 2013 Redistributable (x64)
        "Microsoft.VC++2015-2022Redist-x86" # Microsoft Visual C++ 2015-2022 Redistributable (x86)
        "Microsoft.VC++2015-2022Redist-x64" # Microsoft Visual C++ 2015-2022 Redistributable (x64)
    )

    Write-Title -Text "Installing Packages with Chocolatey"
    Install-Software -Name "Gaming Dependencies (Chocolatey)" -Packages $ChocoGamingPackages -NoDialog -InstallBlock { choco install -y $Package }

    Write-Title -Text "Installing Packages with Winget"
    Install-Software -Name "Gaming Dependencies (Winget)" -Packages $WingetGamingPackages
}

function Main() {
    $Ask = "Do you plan to play games on this PC?`nAll the following Gaming Dependencies will be installed:`n- Microsoft DirectX`n- Microsoft .NET Framework`n- Microsoft Visual C++ Packages (2005-2022)"

    switch (Show-Question -Title "Warning" -Message $Ask) {
        'Yes' {
            Install-GamingSoftwareRequirement # Install All Gaming Dependencies
        }
        'No' {
            Write-Host "Aborting..."
        }
        'Cancel' {
            Write-Host "Aborting..." # With Yes, No and Cancel, the user can press Esc to exit
        }
    }
}

Main