Import-Module -DisableNameChecking "$PSScriptRoot\..\Title-Templates.psm1"

function Set-ServiceStartup() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Automatic', 'Boot', 'Disabled', 'Manual', 'System')]
        [String]      $State,
        [Parameter(Mandatory = $true)]
        [String[]]    $Services,
        [String[]]    $Filter
    )

    Begin {
        $Script:SecurityFilterOnEnable = @("RemoteAccess", "RemoteRegistry")
        $Script:TweakType = "Service"
    }

    Process {
        ForEach ($Service in $Services) {
            If (!(Get-Service $Service -ErrorAction SilentlyContinue)) {
                Write-Status -Types "?", $TweakType -Status "The `"$Service`" service was not found." -Warning
                Continue
            }

            If (($Service -in $SecurityFilterOnEnable) -and (($State -eq 'Automatic') -or ($State -eq 'Manual'))) {
                Write-Status -Types "?", $TweakType -Status "Skipping $Service ($((Get-Service $Service).DisplayName)) to avoid a security vulnerability..." -Warning
                Continue
            }

            If ($Service -in $Filter) {
                Write-Status -Types "?", $TweakType -Status "The $Service ($((Get-Service $Service).DisplayName)) will be skipped as set on Filter..." -Warning
                Continue
            }

            Write-Status -Types "@", $TweakType -Status "Setting $Service ($((Get-Service $Service).DisplayName)) as '$State' on Startup..."
            Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType $State
        }
    }
}

<#
Set-ServiceStartup -State Automatic -Services @("Service1", "Service2", "Service3")
Set-ServiceStartup -State Automatic -Services @("Service1", "Service2", "Service3") -Filter @("Service3")

Set-ServiceStartup -State Disabled -Services @("Service1", "Service2", "Service3")
Set-ServiceStartup -State Disabled -Services @("Service1", "Service2", "Service3") -Filter @("Service3")

Set-ServiceStartup -State Manual -Services @("Service1", "Service2", "Service3")
Set-ServiceStartup -State Manual -Services @("Service1", "Service2", "Service3") -Filter @("Service3")
#>
