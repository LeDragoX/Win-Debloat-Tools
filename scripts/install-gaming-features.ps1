Write-Host "Install additional features for Windows..."
Write-Host ""

# Dism /online /Get-Features #/Format:Table # To find all features
# Get-WindowsOptionalFeature -Online

$FeatureName = @(
    "NetFx3"
    "NetFx4-AdvSrvs"
    "NetFx4Extended-ASPNET45"
    "IIS-ASPNET"
    "IIS-ASPNET45"
    "DirectPlay"
)

foreach ($Feature in $FeatureName) {
    $FeatureDetails = $(Get-WindowsOptionalFeature -Online -FeatureName $Feature)
    
    Write-Host "Checking if $Feature was already installed..."
    Write-Host "$Feature status:" $FeatureDetails.State
    if ($FeatureDetails.State -like ("Enabled")) {
        Write-Host "$Feature already installed! Skipping..."
    }
    elseif ($FeatureDetails.State -like "Disabled") {
        Write-Host "Installing $Feature..."
        Dism /Online /Enable-Feature /All /FeatureName:$Feature
    }
    Write-Host ""
}