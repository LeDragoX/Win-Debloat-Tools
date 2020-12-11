Write-Host "Install additional features for Windows..."

# Dism /online /Get-Features # To find all features

Dism /Online /Enable-Feature /All /FeatureName:NetFx3
Dism /Online /Enable-Feature /All /FeatureName:NetFx4-AdvSrvs
Dism /Online /Enable-Feature /All /FeatureName:NetFx4Extended-ASPNET45
Dism /Online /Enable-Feature /All /FeatureName:IIS-ASPNET
Dism /Online /Enable-Feature /All /FeatureName:IIS-ASPNET45
Dism /Online /Enable-Feature /All /FeatureName:DirectPlay