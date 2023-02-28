function Set-RevertStatus() {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [Bool] $Revert
    )

    $Global:Revert = $Revert

    return $Revert
}
