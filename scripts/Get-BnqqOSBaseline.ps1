param([ValidateRange(10,300)][int]$Seconds = 60,[switch]$ShowProgress)
$ErrorActionPreference = 'Stop'
$os = Get-CimInstance Win32_OperatingSystem -OperationTimeoutSec 10
$version = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
$disk = Get-CimInstance Win32_LogicalDisk -OperationTimeoutSec 10 -Filter "DeviceID='$($os.SystemDrive)'"
$computer = Get-CimInstance Win32_ComputerSystem -OperationTimeoutSec 10
$theme = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -ErrorAction SilentlyContinue
$windowsOld = Test-Path -LiteralPath (Join-Path "$($os.SystemDrive)\" 'Windows.old')
$perfRoot = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib'
$english = (Get-ItemProperty -LiteralPath "$perfRoot\009" -Name Counter).Counter
$localized = (Get-ItemProperty -LiteralPath "$perfRoot\CurrentLanguage" -Name Counter).Counter
$localByIndex = @{}
for ($i = 0; $i + 1 -lt $localized.Count; $i += 2) {
    $localByIndex[$localized[$i]] = $localized[$i + 1]
}
function Resolve-CounterName([string]$Name) {
    for ($index = 1; $index -lt $english.Count; $index += 2) {
        if ($english[$index] -eq $Name) {
            $localName = $localByIndex[$english[$index - 1]]
            if ($localName) { return $localName }
        }
    }
    throw "Windows performance counter is unavailable: $Name."
}
$cpuPath = '\{0}(_Total)\{1}' -f (Resolve-CounterName 'Processor'), (Resolve-CounterName '% Processor Time')
$ramPath = '\{0}\{1}' -f (Resolve-CounterName 'Memory'), (Resolve-CounterName 'Available MBytes')
$diskPath = '\{0}({1})\{2}' -f (Resolve-CounterName 'LogicalDisk'), $os.SystemDrive, (Resolve-CounterName 'Disk Bytes/sec')
$paths = @($cpuPath, $ramPath, $diskPath)
$collected = 0
$measurement = [Diagnostics.Stopwatch]::StartNew()
if ($ShowProgress) { Write-Host 'Opening Windows performance counters...' }
$samples = @(Get-Counter -Counter $paths -SampleInterval 1 -MaxSamples $Seconds -ErrorAction Stop |
    ForEach-Object {
        $byPath = @{}
        foreach ($counter in $_.CounterSamples) {
            if ($counter.Status -notin @(0, 1) -or [double]::IsNaN($counter.CookedValue)) {
                throw "Windows performance counter failed: $($counter.Path) (status $($counter.Status))."
            }
            $relativePath = $counter.Path -replace '^\\\\[^\\]+', ''
            $byPath[$relativePath] = $counter.CookedValue
        }
        foreach ($path in $paths) {
            if (-not $byPath.ContainsKey($path)) { throw "Missing Windows performance counter: $path." }
        }
        $collected++
        if ($ShowProgress -and ($collected -eq 1 -or $collected % 10 -eq 0 -or $collected -eq $Seconds)) {
            Write-Host "Collected $collected/$Seconds samples ($([int]$measurement.Elapsed.TotalSeconds)s)."
        }
        [pscustomobject]@{
            CpuPercent = $byPath[$cpuPath]
            FreeRAMMiB = $byPath[$ramPath]
            DiskBytesPerSecond = $byPath[$diskPath]
        }
    })
if ($samples.Count -ne $Seconds) { throw "Expected $Seconds samples, got $($samples.Count)." }
[pscustomobject]@{
    Computer = $env:COMPUTERNAME
    CapturedUtc = [DateTime]::UtcNow.ToString('o')
    Edition = $version.EditionID
    Build = "$($version.CurrentBuild).$($version.UBR)"
    VisibleRAMMiB = [math]::Round($os.TotalVisibleMemorySize / 1024)
    FreeRAMMiB = [math]::Round($os.FreePhysicalMemory / 1024)
    DiskUsedGiB = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 2)
    CpuAveragePercent = [math]::Round(($samples | Measure-Object CpuPercent -Average).Average, 2)
    FreeRAMAverageMiB = [math]::Round(($samples | Measure-Object FreeRAMMiB -Average).Average, 2)
    DiskAverageBytesPerSecond = [math]::Round(($samples | Measure-Object DiskBytesPerSecond -Average).Average, 2)
    CpuSamples = $samples.Count
    LogicalProcessors = $computer.NumberOfLogicalProcessors
    DiskCapacityGiB = [math]::Round($disk.Size / 1GB, 2)
    WindowsOldPresent = $windowsOld
    Theme = @{
        SystemUsesLightTheme = $theme.SystemUsesLightTheme
        AppsUseLightTheme = $theme.AppsUseLightTheme
    }
} | ConvertTo-Json
