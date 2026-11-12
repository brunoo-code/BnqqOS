#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('Before','After')][string]$Phase,
    [Parameter(Mandatory)][string]$OutputPath,
    [ValidateRange(1,3600000)][int]$BootMilliseconds,
    [ValidateRange(1,3600000)][int]$GameLoadMilliseconds,
    [string]$GameScenario
)

$ErrorActionPreference = 'Stop'
if ($PSBoundParameters.ContainsKey('GameLoadMilliseconds') -and -not $GameScenario) {
    throw 'Specify the game, scene and ready-to-play criterion with -GameScenario.'
}
$path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
if (Test-Path -LiteralPath $path) { throw "Report already exists: $path" }

$os = Get-CimInstance Win32_OperatingSystem
$disk = Get-Partition -DriveLetter $os.SystemDrive.TrimEnd(':') | Get-Disk
$compact = @(& compact.exe /CompactOS:query)
$compactCode = $LASTEXITCODE
if (-not $compact.Count) { throw "Compact OS query returned no output (code $compactCode)." }
$baseline = & (Join-Path $PSScriptRoot 'Get-BnqqOSBaseline.ps1') | ConvertFrom-Json
if ($baseline.WindowsOldPresent) { throw 'Windows.old is present. Use a clean test installation.' }
$baseline | Add-Member -NotePropertyMembers @{
    CompactTrialPhase = $Phase
    CompactQueryCode = $compactCode
    CompactQuery = $compact
    SystemDiskBus = [string]$disk.BusType
    LastBootUtc = $os.LastBootUpTime.ToUniversalTime().ToString('o')
    BootMilliseconds = $(if ($PSBoundParameters.ContainsKey('BootMilliseconds')) { $BootMilliseconds })
    GameLoadMilliseconds = $(if ($PSBoundParameters.ContainsKey('GameLoadMilliseconds')) { $GameLoadMilliseconds })
    GameScenario = $GameScenario
}
$baseline | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $path -Encoding UTF8
Write-Host "Saved $Phase report: $path"
