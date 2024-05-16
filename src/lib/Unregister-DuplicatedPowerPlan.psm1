Import-Module -DisableNameChecking "$PSScriptRoot\Title-Templates.psm1"

function Unregister-DuplicatedPowerPlan() {
    Begin {
        $ExistingPowerPlans = $((powercfg -L)[3..(powercfg -L).Count])
        # Found on the registry: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\User\Default\PowerSchemes
        $BuiltInPowerPlans = @{
            "Power Saver"            = "a1841308-3541-4fab-bc81-f71556f20b4a"
            "Balanced (recommended)" = "381b4222-f694-41f0-9685-ff5bb260df2e"
            "High Performance"       = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
            "Ultimate Performance"   = "e9a42b02-d5df-448d-aa00-03f14749eb61"
        }
        $UniquePowerPlans = $BuiltInPowerPlans.Clone()
    }

    Process {
        Write-Status -Types "@" -Status "Cleaning up duplicated Power plans..."
        ForEach ($PowerCfgString in $ExistingPowerPlans) {
            $PowerPlanGUID = $PowerCfgString.Split(':')[1].Split('(')[0].Trim()
            $PowerPlanName = $PowerCfgString.Split('(')[-1].Replace(')', '').Trim()

            If (($PowerPlanGUID -in $BuiltInPowerPlans.Values)) {
                Write-Status -Types "@" -Status "The `"$PowerPlanName`" power plan is built-in, skipping $PowerPlanGUID..." -Warning
                Continue
            }

            Try {
                If (($PowerPlanName -notin $UniquePowerPlans.Keys) -and ($PowerPlanGUID -notin $UniquePowerPlans.Values)) {
                    $UniquePowerPlans.Add($PowerPlanName, $PowerPlanGUID)
                } Else {
                    Write-Status -Types "-" -Status "Duplicated `"$PowerPlanName`" power plan found, deleting $PowerPlanGUID..."
                    powercfg -Delete $PowerPlanGUID
                }
            } Catch {
                Write-Status -Types "-" -Status "Duplicated `"$PowerPlanName`" power plan found, deleting $PowerPlanGUID..."
                powercfg -Delete $PowerPlanGUID
            }
        }
    }
}
