
# Get all the provisioned packages
$Packages = (get-item 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Applications') | Get-ChildItem

# Filter the list if provided a filter
$PackageFilter = $args[0]
if ([string]::IsNullOrEmpty($PackageFilter))
{
	echo "No filter specified, attempting to re-register all provisioned apps."
}
else
{
	$Packages = $Packages | where {$_.Name -like $PackageFilter} 

	if ($Packages -eq $null)
	{
		echo "No provisioned apps match the specified filter."
		exit
	}
	else
	{
		echo "Registering the provisioned apps that match $PackageFilter"
	}
}

ForEach($Package in $Packages)
{
	# get package name & path
	$PackageName = $Package | Get-ItemProperty | Select-Object -ExpandProperty PSChildName
	$PackagePath = [System.Environment]::ExpandEnvironmentVariables(($Package | Get-ItemProperty | Select-Object -ExpandProperty Path))

	# register the package	
	echo "Attempting to register package: $PackageName"

	Add-AppxPackage -register $PackagePath -DisableDevelopmentMode
}

