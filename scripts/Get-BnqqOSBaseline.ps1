param([ValidateRange(10,300)][int]$Seconds = 60)
$ErrorActionPreference = 'Stop'
$os = Get-CimInstance Win32_OperatingSystem
$version = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$($os.SystemDrive)'"
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
} | ConvertTo-Json
