Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Find-Service() {
    [CmdletBinding()]
    [OutputType([Bool])]
    param (
        [Parameter(Mandatory = $true)]
        [String] $Service
    )

    If (Get-Service $Service -ErrorAction SilentlyContinue) {
        return $true
    } Else {
        Write-Status -Types "?", $TweakType -Status "The $Service service was not found." -Warning
        return $false
    }
}

function Set-ServiceStartup() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Switch] $Automatic,
        [Parameter(Mandatory = $false)]
        [Switch] $Disabled,
        [Parameter(Mandatory = $false)]
        [Switch] $Manual,
        [Parameter(Mandatory = $true)]
        [Array] $Services,
        [Parameter(Mandatory = $false)]
        [Array] $Filter,
        [Parameter(Mandatory = $false)]
        [ScriptBlock] $CustomMessage
    )

    $Script:SecurityFilterOnEnable = @("RemoteAccess", "RemoteRegistry")
    $Script:TweakType = "Service"

    ForEach ($Service in $Services) {
        If (Find-Service $Service) {
            If (($Service -in $SecurityFilterOnEnable) -and (($Automatic) -or ($Manual))) {
                Write-Status -Types "?", $TweakType -Status "Skipping $Service ($((Get-Service $Service).DisplayName)) to avoid a security vulnerability..." -Warning
                Continue
            }

            If ($Service -in $Filter) {
                Write-Status -Types "?", $TweakType -Status "The $Service ($((Get-Service $Service).DisplayName)) will be skipped as set on Filter..." -Warning
                Continue
            }

            If (!$CustomMessage) {
                If ($Automatic) {
                    Write-Status -Types "+", $TweakType -Status "Setting $Service ($((Get-Service $Service).DisplayName)) as 'Automatic' on Startup..."
                } ElseIf ($Disabled) {
                    Write-Status -Types "-", $TweakType -Status "Setting $Service ($((Get-Service $Service).DisplayName)) as 'Disabled' on Startup..."
                } ElseIf ($Manual) {
                    Write-Status -Types "-", $TweakType -Status "Setting $Service ($((Get-Service $Service).DisplayName)) as 'Manual' on Startup..."
                } Else {
                    Write-Status -Types "?", $TweakType -Status "No parameter received (valid params: -Automatic, -Disabled or -Manual)" -Warning
                }
            } Else {
                Write-Status -Types "@", $TweakType -Status $(Invoke-Expression "$CustomMessage")
            }

            If ($Automatic) {
                Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic
            } ElseIf ($Disabled) {
                Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
            } ElseIf ($Manual) {
                Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Manual
            }
        }
    }
}

<#
Set-ServiceStartup -Automatic -Services @("Service1", "Service2", "Service3")
Set-ServiceStartup -Automatic -Services @("Service1", "Service2", "Service3") -Filter @("Service3")
Set-ServiceStartup -Automatic -Services @("Service1", "Service2", "Service3") -Filter @("Service3") -CustomMessage { "Setting $Service as Automatic!"}

Set-ServiceStartup -Disabled -Services @("Service1", "Service2", "Service3")
Set-ServiceStartup -Disabled -Services @("Service1", "Service2", "Service3") -Filter @("Service3")
Set-ServiceStartup -Disabled -Services @("Service1", "Service2", "Service3") -Filter @("Service3") -CustomMessage { "Setting $Service as Disabled!"}

Set-ServiceStartup -Manual -Services @("Service1", "Service2", "Service3")
Set-ServiceStartup -Manual -Services @("Service1", "Service2", "Service3") -Filter @("Service3")
Set-ServiceStartup -Manual -Services @("Service1", "Service2", "Service3") -Filter @("Service3") -CustomMessage { "Setting $Service as Manual!"}
#>
