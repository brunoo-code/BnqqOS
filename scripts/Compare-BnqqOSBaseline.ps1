#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ControlReport,
    [Parameter(Mandatory)][string]$BnqqOSReport
)

$ErrorActionPreference = 'Stop'
$control = Get-Content -LiteralPath $ControlReport -Raw | ConvertFrom-Json
$candidate = Get-Content -LiteralPath $BnqqOSReport -Raw | ConvertFrom-Json

foreach ($report in $control, $candidate) {
    foreach ($field in 'Computer', 'Edition', 'Build', 'CpuSamples', 'VisibleRAMMiB',
        'FreeRAMMiB', 'CpuAveragePercent', 'DiskUsedGiB') {
        if ($null -eq $report.$field) { throw "Missing baseline field: $field" }
    }
    if ($report.CpuSamples -lt 60 -or $report.VisibleRAMMiB -le 0 -or
        $report.FreeRAMMiB -lt 0 -or $report.FreeRAMMiB -gt $report.VisibleRAMMiB -or
        $report.CpuAveragePercent -lt 0 -or $report.CpuAveragePercent -gt 100 -or
        $report.DiskUsedGiB -lt 0) {
        throw 'Invalid or incomplete baseline measurement.'
    }
}
if ($control.Computer -eq $candidate.Computer) { throw 'Use reports from two distinct VMs.' }
foreach ($field in 'Edition', 'Build', 'CpuSamples', 'VisibleRAMMiB') {
    if ($control.$field -ne $candidate.$field) { throw "The VM reports disagree on $field." }
}

$controlRam = $control.VisibleRAMMiB - $control.FreeRAMMiB
$candidateRam = $candidate.VisibleRAMMiB - $candidate.FreeRAMMiB
[ordered]@{
    Edition = $control.Edition
    Build = $control.Build
    CpuSamples = $control.CpuSamples
    Control = [ordered]@{
        CpuAveragePercent = $control.CpuAveragePercent
        RamUsedMiB = $controlRam
        DiskUsedGiB = $control.DiskUsedGiB
    }
    BnqqOS = [ordered]@{
        CpuAveragePercent = $candidate.CpuAveragePercent
        RamUsedMiB = $candidateRam
        DiskUsedGiB = $candidate.DiskUsedGiB
    }
    DifferenceBnqqOSMinusControl = [ordered]@{
        CpuPercentagePoints = [math]::Round($candidate.CpuAveragePercent - $control.CpuAveragePercent, 2)
        RamMiB = $candidateRam - $controlRam
        DiskGiB = [math]::Round($candidate.DiskUsedGiB - $control.DiskUsedGiB, 2)
    }
} | ConvertTo-Json -Depth 4
