#Requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$os = Get-CimInstance Win32_OperatingSystem
$version = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
$cpu = @(Get-CimInstance Win32_Processor)
$services = @('SysMain', 'WSearch', 'DiagTrack', 'wuauserv', 'WinDefend', 'TapiSrv', 'PhoneSvc', 'Fax', 'MapsBroker', 'ehSched', 'Spooler', 'LanmanServer', 'SCardSvr', 'RemoteAccess', 'RemoteRegistry')
$packages = @(Get-AppxPackage | Where-Object { $_.Name -in 'Microsoft.Copilot', 'Microsoft.Windows.Ai.Copilot.Provider' })
$apps = @(Get-AppxPackage | Select-Object -ExpandProperty Name | Sort-Object -Unique)
$startup = @(Get-CimInstance Win32_StartupCommand | Select-Object -ExpandProperty Name | Sort-Object -Unique)
$activePlan = (& powercfg.exe /getactivescheme) -join ' '
if ($LASTEXITCODE -ne 0) { throw 'Could not read the active power plan.' }

[ordered]@{
    CapturedUtc = [DateTime]::UtcNow.ToString('o')
    Edition = $version.EditionID
    Build = "$($version.CurrentBuild).$($version.UBR)"
    CPU = @($cpu | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors)
    RAMMiB = [math]::Round($os.TotalVisibleMemorySize / 1024)
    AvailableRAMMiB = [math]::Round($os.FreePhysicalMemory / 1024)
    ProcessCount = @(Get-Process).Count
    StartupEntries = $startup
    InstalledAppsForCurrentUser = $apps
    AutomaticPageFile = (Get-CimInstance Win32_ComputerSystem).AutomaticManagedPagefile
    PowerPlan = $activePlan.Trim()
    Disks = @(Get-PhysicalDisk | Select-Object MediaType, BusType, Size, HealthStatus)
    Services = @(Get-CimInstance Win32_Service | Where-Object Name -in $services |
        Sort-Object Name | Select-Object Name, StartMode, State)
    CopilotPackagesForCurrentUser = @($packages | Select-Object -ExpandProperty Name)
} | ConvertTo-Json -Depth 5
