#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ControlReport,
    [Parameter(Mandatory)][string]$BnqqOSReport,
    [switch]$SameVm
)

$ErrorActionPreference = 'Stop'
$control = Get-Content -LiteralPath $ControlReport -Raw | ConvertFrom-Json
$candidate = Get-Content -LiteralPath $BnqqOSReport -Raw | ConvertFrom-Json

foreach ($report in $control, $candidate) {
    foreach ($field in 'Computer', 'Edition', 'Build', 'CpuSamples', 'VisibleRAMMiB',
        'FreeRAMMiB', 'CpuAveragePercent', 'DiskUsedGiB') {
        if ($null -eq $report.$field) { throw "Missing baseline field: $field" }
    }
    if ($report.WindowsOldPresent -eq $true) { throw 'A Windows.old folder makes this unsuitable for a clean comparison.' }
    if ($report.CpuSamples -lt 60 -or $report.VisibleRAMMiB -le 0 -or
        $report.FreeRAMMiB -lt 0 -or $report.FreeRAMMiB -gt $report.VisibleRAMMiB -or
        $report.CpuAveragePercent -lt 0 -or $report.CpuAveragePercent -gt 100 -or
        $report.DiskUsedGiB -lt 0) {
        throw 'Invalid or incomplete baseline measurement.'
    }
}
if ($SameVm) {
    if ($control.Computer -ne $candidate.Computer) { throw 'Use reports from the same VM in SameVm mode.' }
    if ([DateTimeOffset]$candidate.CapturedUtc -le [DateTimeOffset]$control.CapturedUtc) {
        throw 'Capture the control report before applying the optimizer.'
    }
} elseif ($control.Computer -eq $candidate.Computer) {
    throw 'Use reports from two distinct VMs, or use SameVm for an optimizer before/after comparison.'
}
foreach ($field in 'Edition', 'Build', 'CpuSamples', 'VisibleRAMMiB') {
    if ($control.$field -ne $candidate.$field) { throw "The VM reports disagree on $field." }
}

foreach ($field in 'LogicalProcessors', 'DiskCapacityGiB') {
    if (($null -ne $control.$field -or $null -ne $candidate.$field) -and
        $control.$field -ne $candidate.$field) {
        throw "The VM reports disagree on $field."
    }
}

$controlRam = $control.VisibleRAMMiB - $control.FreeRAMMiB
$candidateRam = $candidate.VisibleRAMMiB - $candidate.FreeRAMMiB
[ordered]@{
    Comparison = if ($SameVm) { 'OptimizerBeforeAfter' } else { 'CleanIso' }
    Edition = $control.Edition
    Build = $control.Build
    CpuSamples = $control.CpuSamples
    Control = [ordered]@{
        CpuAveragePercent = $control.CpuAveragePercent
        RamUsedMiB = $controlRam
        DiskUsedGiB = $control.DiskUsedGiB
        FreeRAMAverageMiB = $control.FreeRAMAverageMiB
        DiskAverageBytesPerSecond = $control.DiskAverageBytesPerSecond
    }
    BnqqOS = [ordered]@{
        CpuAveragePercent = $candidate.CpuAveragePercent
        RamUsedMiB = $candidateRam
        DiskUsedGiB = $candidate.DiskUsedGiB
        FreeRAMAverageMiB = $candidate.FreeRAMAverageMiB
        DiskAverageBytesPerSecond = $candidate.DiskAverageBytesPerSecond
    }
    DifferenceBnqqOSMinusControl = [ordered]@{
        CpuPercentagePoints = [math]::Round($candidate.CpuAveragePercent - $control.CpuAveragePercent, 2)
        RamMiB = $candidateRam - $controlRam
        DiskGiB = [math]::Round($candidate.DiskUsedGiB - $control.DiskUsedGiB, 2)
        FreeRAMAverageMiB = if ($null -ne $control.FreeRAMAverageMiB -and $null -ne $candidate.FreeRAMAverageMiB) {
            [math]::Round($candidate.FreeRAMAverageMiB - $control.FreeRAMAverageMiB, 2)
        }
        DiskAverageBytesPerSecond = if ($null -ne $control.DiskAverageBytesPerSecond -and $null -ne $candidate.DiskAverageBytesPerSecond) {
            [math]::Round($candidate.DiskAverageBytesPerSecond - $control.DiskAverageBytesPerSecond, 2)
        }
    }
} | ConvertTo-Json -Depth 4
