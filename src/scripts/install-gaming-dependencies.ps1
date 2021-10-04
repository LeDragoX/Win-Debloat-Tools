Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"simple-message-box.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function InstallGamingPackages() {

    # You Choose
    $Ask = "Do you plan to play games on this PC?
  All Gaming Dependencies will be installed.
  + Microsoft DirectX
  + Microsoft .NET Framework
  + Microsoft .NET Runtime
  + Microsoft Visual C++ Packages"

    switch (ShowQuestion -Title "Read carefully" -Message $Ask) {
        'Yes' {

            Write-Host "You choose Yes."
            $ChocoGamingPackages = @(
                "directx"               # DirectX End-User Runtime
                "dotnet-desktopruntime" # (x86-64) Microsoft .NET Desktop Runtime (v5 +)
            )
      
            Title1 -Text "Installing Packages with Chocolatey"

            ForEach ($Package in $ChocoGamingPackages) {
                Title2Counter -Text "Installing: $Package" -MaxNum $ChocoGamingPackages.Length
                choco install -y $Package | Out-Host
            }

            $WingetGamingPackages = @(
                "Microsoft.dotNetFramework"         # Microsoft .NET Framework (v4.8+)
                "Microsoft.dotnet"                  # Microsoft .NET (v5+)
                "Microsoft.VC++2005Redist-x86"      # (x86) Microsoft Visual C++ 2005 SP1 Redistributable Package
                "Microsoft.VC++2008Redist-x86"      # (x86) Microsoft Visual C++ 2008 SP1 Redistributable Package
                "Microsoft.VC++2010Redist-x86"      # (x86) Microsoft Visual C++ 2010 Redistributable Package
                "Microsoft.VC++2012Redist-x86"      # (x86) Microsoft Visual C++ 2012 Redistributable Package
                "Microsoft.VC++2013Redist-x86"      # (x86) Microsoft Visual C++ Redistributable Packages for Visual Studio 2013
                "Microsoft.VC++2015-2019Redist-x86" # (x86) Microsoft Visual C++ Redistributable for Visual Studio 2015-2019
                "Microsoft.VC++2005Redist-x64"      # (x64) Microsoft Visual C++ 2005 SP1 Redistributable Package
                "Microsoft.VC++2008Redist-x64"      # (x64) Microsoft Visual C++ 2008 SP1 Redistributable Package
                "Microsoft.VC++2010Redist-x64"      # (x64) Microsoft Visual C++ 2010 Redistributable Package
                "Microsoft.VC++2012Redist-x64"      # (x64) Microsoft Visual C++ 2012 Redistributable Package
                "Microsoft.VC++2013Redist-x64"      # (x64) Microsoft Visual C++ Redistributable Packages for Visual Studio 2013
                "Microsoft.VC++2015-2019Redist-x64" # (x64) Microsoft Visual C++ Redistributable for Visual Studio 2015-2019
                "Oracle.JavaRuntimeEnvironment"     # Java Runtime Environment
            )
    
            Title1 -Text "Installing Packages with Winget"

            ForEach ($Package in $WingetGamingPackages) {
                Title2Counter -Text "Installing: $Package" -MaxNum $WingetGamingPackages.Length
                winget install --silent $Package | Out-Host
            }

        }
        'No' {
            Write-Host "You choose No. (No = Cancel)"
        }
        'Cancel' {
            # With Yes, No and Cancel, the user can press Esc to exit
            Write-Host "You choose Cancel. (Cancel = No)"
        }
    }
}

function Main() {

    InstallGamingPackages               # Install All Gaming Dependencies

}

Main