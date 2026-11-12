#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string[]]$Before,
    [Parameter(Mandatory)][string[]]$After
)

$ErrorActionPreference = 'Stop'
if ($Before.Count -lt 3 -or $Before.Count -ne $After.Count) {
    throw 'Provide at least three reports per condition and the same number for Before and After.'
}
$groups = [ordered]@{}
$seenBoots = @{}
$reference = $null
foreach ($phase in 'Before','After') {
    $paths = if ($phase -eq 'Before') { $Before } else { $After }
    $groups[$phase] = @(foreach ($path in $paths) {
        $report = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        if ($report.CompactTrialPhase -ne $phase -or $report.WindowsOldPresent -ne $false -or $report.CpuSamples -lt 60) {
            throw "Invalid clean baseline or phase in $path."
        }
        $boot = ([DateTimeOffset]$report.LastBootUtc).UtcDateTime.Ticks
        if ($seenBoots.ContainsKey($boot)) { throw "Duplicate boot in $path." }
        $seenBoots[$boot] = $true
        if (-not $reference) { $reference = $report }
        foreach ($field in 'Computer','Edition','Build','SystemDiskBus','VisibleRAMMiB','LogicalProcessors','DiskCapacityGiB','GameScenario') {
            if ($report.$field -ne $reference.$field) { throw "Inconsistent $field in $path." }
        }
        foreach ($field in 'DiskUsedGiB','CpuAveragePercent','FreeRAMAverageMiB','DiskAverageBytesPerSecond') {
            if ($null -eq $report.$field -or $report.$field -lt 0) { throw "Missing or invalid $field in $path." }
        }
        $report
    })
}
$beforeStates = @($groups.Before | ForEach-Object { $_.CompactQuery -join ' ' } | Sort-Object -Unique)
$afterStates = @($groups.After | ForEach-Object { $_.CompactQuery -join ' ' } | Sort-Object -Unique)
if ($beforeStates.Count -ne 1 -or $afterStates.Count -ne 1 -or
    -not $beforeStates[0] -or -not $afterStates[0] -or $beforeStates[0] -eq $afterStates[0]) {
    throw 'Confirm a consistent and different Compact OS state for each condition.'
}

$summary = [ordered]@{}
foreach ($phase in 'Before','After') {
    $metrics = [ordered]@{}
    foreach ($field in 'DiskUsedGiB','CpuAveragePercent','FreeRAMAverageMiB','DiskAverageBytesPerSecond','BootMilliseconds','GameLoadMilliseconds') {
        $values = @($groups[$phase] | ForEach-Object { $_.$field } | Where-Object { $null -ne $_ } | Sort-Object)
        if ($values.Count -ne $groups[$phase].Count) { $metrics[$field] = $null; continue }
        $lower = [int][math]::Floor(($values.Count - 1) / 2)
        $upper = [int][math]::Ceiling(($values.Count - 1) / 2)
        $metrics[$field] = [math]::Round(($values[$lower] + $values[$upper]) / 2, 2)
    }
    $summary[$phase] = $metrics
}
$delta = [ordered]@{}
foreach ($key in $summary.Before.Keys) {
    $delta[$key] = if ($null -ne $summary.Before[$key] -and $null -ne $summary.After[$key]) {
        [math]::Round($summary.After[$key] - $summary.Before[$key], 2)
    }
}
[ordered]@{
    RunsPerCondition = $Before.Count
    BeforeState = $beforeStates[0]
    AfterState = $afterStates[0]
    Median = $summary
    DifferenceAfterMinusBefore = $delta
} | ConvertTo-Json -Depth 5
