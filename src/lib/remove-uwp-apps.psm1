function Remove-UWPApps() {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function
    param (
        [Array] $Apps
    )

    ForEach ($Bloat in $Apps) {

        If ((Get-AppxPackage -AllUsers -Name $Bloat) -or (Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat)) {

            Write-Host "[-][UWP] Trying to remove $Bloat ..."
            Get-AppxPackage -AllUsers -Name $Bloat | Remove-AppxPackage # App
            Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online -AllUsers # Payload

        }
        Else {

            Write-Warning "[?][UWP] $Bloat was already removed or not found."

        }
    }
}
