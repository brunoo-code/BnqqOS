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
$processes = @(Get-CimInstance Win32_PerfFormattedData_PerfProc_Process |
    Where-Object { $_.Name -notin @('_Total', 'Idle') } |
    Group-Object { $_.Name -replace '#\d+$', '' } |
    ForEach-Object {
        [pscustomobject]@{
            Name = $_.Name
            Instances = $_.Count
            PrivateWorkingSetMiB = [math]::Round(($_.Group | Measure-Object WorkingSetPrivate -Sum).Sum / 1MB, 1)
            CpuPercentOfOneCore = ($_.Group | Measure-Object PercentProcessorTime -Sum).Sum
        }
    })
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
    TopPrivateWorkingSet = @($processes | Sort-Object PrivateWorkingSetMiB -Descending | Select-Object -First 15)
    TopCpuSnapshot = @($processes | Sort-Object CpuPercentOfOneCore -Descending | Select-Object -First 15)
    InstalledAppsForCurrentUser = $apps
    AutomaticPageFile = (Get-CimInstance Win32_ComputerSystem).AutomaticManagedPagefile
    PowerPlan = $activePlan.Trim()
    Disks = @(Get-PhysicalDisk | Select-Object MediaType, BusType, Size, HealthStatus)
    Services = @(Get-CimInstance Win32_Service | Where-Object Name -in $services |
        Sort-Object Name | Select-Object Name, StartMode, State)
    CopilotPackagesForCurrentUser = @($packages | Select-Object -ExpandProperty Name)
} | ConvertTo-Json -Depth 5
