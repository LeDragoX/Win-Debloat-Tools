# disable Memory Compression (requires SysMain (service))
Disable-MMAgent -mc
#Get-MMAgent

echo "Now you can also disable service SysMain (former Superfetch) in case it's not used."
#Get-Service "SysMain" | Set-Service -StartupType Disabled -PassThru | Stop-Service
