#   Description:
# This script will disable certain scheduled tasks. Work in progress!

$tasks = @(
    # Windows base scheduled tasks
    "\Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319"
    "\Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64"
    "\Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64 Critical"
    "\Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 Critical"

    #"\Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Automated)"
    #"\Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Manual)"

    #"\Microsoft\Windows\AppID\EDP Policy Manager"
    #"\Microsoft\Windows\AppID\PolicyConverter"
    "\Microsoft\Windows\AppID\SmartScreenSpecific"
    #"\Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck"

    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
    #"\Microsoft\Windows\Application Experience\StartupAppTask"

    #"\Microsoft\Windows\ApplicationData\CleanupTemporaryState"
    #"\Microsoft\Windows\ApplicationData\DsSvcCleanup"

    #"\Microsoft\Windows\AppxDeploymentClient\Pre-staged app cleanup"

    "\Microsoft\Windows\Autochk\Proxy"

    #"\Microsoft\Windows\Bluetooth\UninstallDeviceTask"

    #"\Microsoft\Windows\CertificateServicesClient\AikCertEnrollTask"
    #"\Microsoft\Windows\CertificateServicesClient\KeyPreGenTask"
    #"\Microsoft\Windows\CertificateServicesClient\SystemTask"
    #"\Microsoft\Windows\CertificateServicesClient\UserTask"
    #"\Microsoft\Windows\CertificateServicesClient\UserTask-Roam"

    #"\Microsoft\Windows\Chkdsk\ProactiveScan"

    #"\Microsoft\Windows\Clip\License Validation"

    "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask"

    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"

    #"\Microsoft\Windows\Data Integrity Scan\Data Integrity Scan"
    #"\Microsoft\Windows\Data Integrity Scan\Data Integrity Scan for Crash Recovery"

    #"\Microsoft\Windows\Defrag\ScheduledDefrag"

    #"\Microsoft\Windows\Diagnosis\Scheduled"

    #"\Microsoft\Windows\DiskCleanup\SilentCleanup"

    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    #"\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver"

    #"\Microsoft\Windows\DiskFootprint\Diagnostics"

    "\Microsoft\Windows\Feedback\Siuf\DmClient"

    #"\Microsoft\Windows\File Classification Infrastructure\Property Definition Sync"

    #"\Microsoft\Windows\FileHistory\File History (maintenance mode)"

    #"\Microsoft\Windows\LanguageComponentsInstaller\Installation"
    #"\Microsoft\Windows\LanguageComponentsInstaller\Uninstallation"

    #"\Microsoft\Windows\Location\Notifications"
    #"\Microsoft\Windows\Location\WindowsActionDialog"

    #"\Microsoft\Windows\Maintenance\WinSAT"

    #"\Microsoft\Windows\Maps\MapsToastTask"
    #"\Microsoft\Windows\Maps\MapsUpdateTask"

    #"\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents"
    #"\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic"

    "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser"

    #"\Microsoft\Windows\MUI\LPRemove"

    #"\Microsoft\Windows\Multimedia\SystemSoundsService"

    #"\Microsoft\Windows\NetCfg\BindingWorkItemQueueHandler"

    #"\Microsoft\Windows\NetTrace\GatherNetworkInfo"

    #"\Microsoft\Windows\Offline Files\Background Synchronization"
    #"\Microsoft\Windows\Offline Files\Logon Synchronization"

    #"\Microsoft\Windows\PI\Secure-Boot-Update"
    #"\Microsoft\Windows\PI\Sqm-Tasks"

    #"\Microsoft\Windows\Plug and Play\Device Install Group Policy"
    #"\Microsoft\Windows\Plug and Play\Device Install Reboot Required"
    #"\Microsoft\Windows\Plug and Play\Plug and Play Cleanup"
    #"\Microsoft\Windows\Plug and Play\Sysprep Generalize Drivers"

    #"\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"

    #"\Microsoft\Windows\Ras\MobilityManager"

    #"\Microsoft\Windows\RecoveryEnvironment\VerifyWinRE"

    #"\Microsoft\Windows\Registry\RegIdleBackup"

    #"\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask"

    #"\Microsoft\Windows\RemovalTools\MRT_HB"

    #"\Microsoft\Windows\Servicing\StartComponentCleanup"

    #"\Microsoft\Windows\SettingSync\NetworkStateChangeTask"

    #"\Microsoft\Windows\Shell\CreateObjectTask"
    #"\Microsoft\Windows\Shell\FamilySafetyMonitor"
    #"\Microsoft\Windows\Shell\FamilySafetyRefresh"
    #"\Microsoft\Windows\Shell\IndexerAutomaticMaintenance"

    #"\Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTask"
    #"\Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskLogon"
    #"\Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskNetwork"

    #"\Microsoft\Windows\SpacePort\SpaceAgentTask"

    #"\Microsoft\Windows\Sysmain\HybridDriveCachePrepopulate"
    #"\Microsoft\Windows\Sysmain\HybridDriveCacheRebalance"
    #"\Microsoft\Windows\Sysmain\ResPriStaticDbSync"
    #"\Microsoft\Windows\Sysmain\WsSwapAssessmentTask"

    #"\Microsoft\Windows\SystemRestore\SR"

    #"\Microsoft\Windows\Task Manager\Interactive"

    #"\Microsoft\Windows\TextServicesFramework\MsCtfMonitor"

    #"\Microsoft\Windows\Time Synchronization\ForceSynchronizeTime"
    #"\Microsoft\Windows\Time Synchronization\SynchronizeTime"

    #"\Microsoft\Windows\Time Zone\SynchronizeTimeZone"

    #"\Microsoft\Windows\TPM\Tpm-HASCertRetr"
    #"\Microsoft\Windows\TPM\Tpm-Maintenance"

    #"\Microsoft\Windows\UpdateOrchestrator\Maintenance Install"
    #"\Microsoft\Windows\UpdateOrchestrator\Policy Install"
    #"\Microsoft\Windows\UpdateOrchestrator\Reboot"
    #"\Microsoft\Windows\UpdateOrchestrator\Resume On Boot"
    #"\Microsoft\Windows\UpdateOrchestrator\Schedule Scan"
    #"\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_Display"
    #"\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_ReadyToReboot"

    #"\Microsoft\Windows\UPnP\UPnPHostConfig"

    #"\Microsoft\Windows\User Profile Service\HiveUploadTask"

    #"\Microsoft\Windows\WCM\WiFiTask"

    #"\Microsoft\Windows\WDI\ResolutionHost"

    "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance"
    "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup"
    "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan"
    "\Microsoft\Windows\Windows Defender\Windows Defender Verification"

    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"

    #"\Microsoft\Windows\Windows Filtering Platform\BfeOnServiceStartTypeChange"

    #"\Microsoft\Windows\Windows Media Sharing\UpdateLibrary"

    #"\Microsoft\Windows\WindowsColorSystem\Calibration Loader"

    #"\Microsoft\Windows\WindowsUpdate\Automatic App Update"
    #"\Microsoft\Windows\WindowsUpdate\Scheduled Start"
    #"\Microsoft\Windows\WindowsUpdate\sih"
    #"\Microsoft\Windows\WindowsUpdate\sihboot"

    #"\Microsoft\Windows\Wininet\CacheTask"

    #"\Microsoft\Windows\WOF\WIM-Hash-Management"
    #"\Microsoft\Windows\WOF\WIM-Hash-Validation"

    #"\Microsoft\Windows\Work Folders\Work Folders Logon Synchronization"
    #"\Microsoft\Windows\Work Folders\Work Folders Maintenance Work"

    #"\Microsoft\Windows\Workplace Join\Automatic-Device-Join"

    #"\Microsoft\Windows\WS\License Validation"
    #"\Microsoft\Windows\WS\WSTask"

    # Scheduled tasks which cannot be disabled
    #"\Microsoft\Windows\Device Setup\Metadata Refresh"
    #"\Microsoft\Windows\SettingSync\BackgroundUploadTask"
)

foreach ($task in $tasks) {
    $parts = $task.split('\')
    $name = $parts[-1]
    $path = $parts[0..($parts.length-2)] -join '\'

    Disable-ScheduledTask -TaskName "$name" -TaskPath "$path" -ErrorAction SilentlyContinue
}
