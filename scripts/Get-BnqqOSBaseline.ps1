param([ValidateRange(10,300)][int]$Seconds = 60)
$ErrorActionPreference = 'Stop'
$os = Get-CimInstance Win32_OperatingSystem
$version = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$($os.SystemDrive)'"
$computer = Get-CimInstance Win32_ComputerSystem
$theme = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -ErrorAction SilentlyContinue
$windowsOld = Test-Path -LiteralPath (Join-Path "$($os.SystemDrive)\" 'Windows.old')
$cpu = @(for ($i = 0; $i -lt $Seconds; $i++) {
    (Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'").PercentProcessorTime
    Start-Sleep -Seconds 1
})
[pscustomobject]@{
    Computer = $env:COMPUTERNAME
    CapturedUtc = [DateTime]::UtcNow.ToString('o')
    Edition = $version.EditionID
    Build = "$($version.CurrentBuild).$($version.UBR)"
    VisibleRAMMiB = [math]::Round($os.TotalVisibleMemorySize / 1024)
    FreeRAMMiB = [math]::Round($os.FreePhysicalMemory / 1024)
    DiskUsedGiB = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 2)
    CpuAveragePercent = [math]::Round(($cpu | Measure-Object -Average).Average, 2)
    CpuSamples = $cpu.Count
    LogicalProcessors = $computer.NumberOfLogicalProcessors
    DiskCapacityGiB = [math]::Round($disk.Size / 1GB, 2)
    WindowsOldPresent = $windowsOld
    Theme = @{
        SystemUsesLightTheme = $theme.SystemUsesLightTheme
        AppsUseLightTheme = $theme.AppsUseLightTheme
    }
} | ConvertTo-Json
