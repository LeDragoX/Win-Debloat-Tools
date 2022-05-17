Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

function Initialize-ServicesModule() {
    $Script:SecurityFilter = @("RemoteAccess", "RemoteRegistry")
    $Script:TweakType = "Service"
}

function Find-Service() {
    [CmdletBinding()]
    [OutputType([Bool])]
    param (
        [Parameter(Mandatory = $true)]
        [String] $Service
    )

    If (Get-Service $Service -ErrorAction SilentlyContinue) {
        return $true
    }
    Else {
        Write-Status -Symbol "?" -Type $TweakType -Status "The $Service was not found." -Warning
        return $false
    }
}

function Set-ServiceToAutomatic {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Array] $Services,
        [Parameter(Mandatory = $false)]
        [Array] $Filter,
        [Parameter(Mandatory = $false)]
        [ScriptBlock] $CustomMessage
    )

    Initialize-ServicesModule

    ForEach ($Service in $Services) {
        If (Find-Service $Service) {
            If ($Service -in $SecurityFilter) {
                Write-Status -Symbol "?" -Type $TweakType -Status "Skipping $Service ($((Get-Service $Service).DisplayName)) to avoid a security vulnerability ..." -Warning
                Continue
            }

            If ($Service -in $Filter) {
                Write-Status -Symbol "?" -Type $TweakType -Status "The $Service ($((Get-Service $Service).DisplayName)) will be skipped as set on Filter ..." -Warning
                Continue
            }

            If (!$CustomMessage) {
                Write-Status -Symbol "+" -Type $TweakType -Status "Setting $Service ($((Get-Service $Service).DisplayName)) as 'Automatic' on Startup ..."
            }
            Else {
                Write-Status -Symbol "+" -Type $TweakType -Status $(Invoke-Expression "$CustomMessage")
            }
            Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic
        }
    }
}

function Set-ServiceToDisabled {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Array] $Services,
        [Parameter(Mandatory = $false)]
        [Array] $Filter
    )

    Initialize-ServicesModule

    ForEach ($Service in $Services) {
        If (Find-Service $Service) {
            If ($Service -in $Filter) {
                Write-Status -Symbol "?" -Type $TweakType -Status "The $Service ($((Get-Service $Service).DisplayName)) will be skipped as set on Filter ..." -Warning
                Continue
            }

            Write-Status -Symbol "-" -Type $TweakType -Status "Setting $Service ($((Get-Service $Service).DisplayName)) as 'Disabled' on Startup ..."
            Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
        }
    }
}

function Set-ServiceToManual {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Array] $Services,
        [Parameter(Mandatory = $false)]
        [Array] $Filter
    )

    Initialize-ServicesModule

    ForEach ($Service in $Services) {
        If (Find-Service $Service) {
            If ($Service -in $Filter) {
                Write-Status -Symbol "?" -Type $TweakType -Status "The $Service ($((Get-Service $Service).DisplayName)) will be skipped as set on Filter ..." -Warning
                Continue
            }

            Write-Status -Symbol "-" -Type $TweakType -Status "Setting $Service ($((Get-Service $Service).DisplayName)) as 'Manual' on Startup ..."
            Get-Service -Name "$Service" -ErrorAction SilentlyContinue | Set-Service -StartupType Manual
        }
    }
}

<#
Set-ServiceToAutomatic -Services @("Service1", "Service2", "Service3")
Set-ServiceToAutomatic -Services @("Service1", "Service2", "Service3") -Filter @("Service3")
Set-ServiceToAutomatic -Services @("Service1", "Service2", "Service3") -Filter @("Service3") -CustomMessage { "Setting $Service as Automatic!"}
Set-ServiceToDisabled -Services @("Service1", "Service2", "Service3")
Set-ServiceToDisabled -Services @("Service1", "Service2", "Service3") -Filter @("Service3")
Set-ServiceToManual -Services @("Service1", "Service2", "Service3")
Set-ServiceToManual -Services @("Service1", "Service2", "Service3") -Filter @("Service3")
#>