
# Get all the provisioned packages
$Packages = (get-item 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Applications') | Get-ChildItem

# Filter the list if provided a filter
$PackageFilter = $args[0]
if ([string]::IsNullOrEmpty($PackageFilter))
{
	Write-Output "No filter specified, attempting to re-register all provisioned apps."
}
else
{
	$Packages = $Packages | Where-Object {$_.Name -like $PackageFilter} 

	if ($null -eq $Packages)
	{
		Write-Output "No provisioned apps match the specified filter."
		exit
	}
	else
	{
		Write-Output "Registering the provisioned apps that match $PackageFilter"
	}
}

ForEach($Package in $Packages)
{
	# get package name & path
	$PackageName = $Package | Get-ItemProperty | Select-Object -ExpandProperty PSChildName
	$PackagePath = [System.Environment]::ExpandEnvironmentVariables(($Package | Get-ItemProperty | Select-Object -ExpandProperty Path))

	# register the package	
	Write-Output "Attempting to register package: $PackageName"

	Add-AppxPackage -register $PackagePath -DisableDevelopmentMode
}

