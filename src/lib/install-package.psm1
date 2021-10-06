function InstallPackage() {

  [CmdletBinding()] #<<-- This turns a regular function into an advanced function
  param (
    [String]  $Name,
    [Array]   $PackageName,
    [String]  $InstallBlock
  )

  $DoneTitle = "Done"
  $DoneMessage = "$Name installed!"

  Write-Host "Installing: $($Name)." -ForegroundColor Magenta
  # Avoiding a softlock only on the script that occurs if the APP is already installed on Microsoft Store (Blame Spotify)
  If ((Get-AppxPackage).Name -ilike "*$($Name)*") {
    Write-Host "$PackageName already installed on MS Store! Skipping..." -ForegroundColor Cyan
  }
  Else {
    ForEach ($Package in $PackageName) {
      Invoke-Expression "$InstallBlock" | Out-Host
    }
  }

  ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
}

<#
Example:
InstallPackage -Name $InstallParams.Name -PackageName $InstallParams.PackageName -InstallBlock $InstallParams.InstallBlock
#>