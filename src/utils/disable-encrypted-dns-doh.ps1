Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Disable-EncryptedDNS() {
    # Adapted from: https://stackoverflow.com/questions/64465089/powershell-cmdlet-to-remove-a-statically-configured-dns-addresses-from-a-network
    Write-Status -Types "+" -Status "Resetting DNS server configs..."
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet*" -ResetServerAddresses
    Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi*" -ResetServerAddresses
}

Disable-EncryptedDNS