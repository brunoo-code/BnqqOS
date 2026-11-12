#Requires -Version 5.1
#Requires -RunAsAdministrator
[CmdletBinding()]
param([ValidateRange(10,300)][int]$Samples = 60)

$ErrorActionPreference = 'Stop'
$computer = Get-CimInstance Win32_ComputerSystem -OperationTimeoutSec 10
if ($computer.Manufacturer -ne 'Microsoft Corporation' -or $computer.Model -ne 'Virtual Machine') {
    throw 'This service experiment is intended for a Hyper-V guest.'
}
$out = Join-Path $env:LOCALAPPDATA ('BnqqOS\BackgroundQA\' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $out -Force | Out-Null

function Save-Capture {
    param([string]$Name)
    Write-Host "Measuring $Name. Keep the same workload open."
    $report = & (Join-Path $PSScriptRoot 'Get-BnqqOSBaseline.ps1') -Seconds $Samples -ShowProgress
    $report | Set-Content -LiteralPath (Join-Path $out "$Name.json") -Encoding UTF8
}

function Read-CapturePreferences {
    $settings = Get-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' -ErrorAction SilentlyContinue
    $store = Get-ItemProperty -LiteralPath 'HKCU:\System\GameConfigStore' -ErrorAction SilentlyContinue
    [ordered]@{
        HistoricalCaptureEnabled = $settings.HistoricalCaptureEnabled
        AppCaptureEnabled = $settings.AppCaptureEnabled
        GameDVR_Enabled = $store.GameDVR_Enabled
    }
}

function Test-ServiceCondition {
    param([string]$Name)

    $service = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if (-not $service) { Write-Host "$Name unavailable."; return }
    $state = Get-ItemProperty -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\$Name"
    $wasRunning = $service.Status -eq 'Running'
    $startType = $service.StartType.ToString()
    if ($service.Status -notin @('Running','Stopped') -or $startType -notin @('Manual','Automatic','Disabled')) {
        throw "Unexpected state for $Name."
    }
    if (@($service.DependentServices | Where-Object Status -ne 'Stopped').Count) {
        throw "$Name has an active dependent service."
    }

    $backup = Join-Path $out "$Name-original.json"
    @{Name=$Name;StartType=$startType;WasRunning=$wasRunning;Delayed=($state.DelayedAutoStart -eq 1)} |
        ConvertTo-Json | Set-Content -LiteralPath $backup -Encoding UTF8
    try {
        if ($wasRunning) {
            Save-Capture "$Name-running"
            Stop-Service -Name $Name -ErrorAction Stop
            Save-Capture "$Name-stopped"
        } else {
            Save-Capture "$Name-stopped"
            if ($startType -eq 'Disabled') { Set-Service -Name $Name -StartupType Manual -ErrorAction Stop }
            Start-Service -Name $Name -ErrorAction Stop
            Save-Capture "$Name-running"
        }
    } finally {
        if (-not $wasRunning -and (Get-Service -Name $Name).Status -eq 'Running') {
            Stop-Service -Name $Name -ErrorAction Stop
        }
        if ((Get-Service -Name $Name).StartType -ne $startType) {
            Set-Service -Name $Name -StartupType $startType -ErrorAction Stop
        }
        if ($wasRunning -and (Get-Service -Name $Name).Status -ne 'Running') {
            Start-Service -Name $Name -ErrorAction Stop
        }
        $restored = Get-Service -Name $Name
        if ($restored.StartType -ne $startType -or ($restored.Status -eq 'Running') -ne $wasRunning) {
            throw "Could not restore $Name. Original state: $backup"
        }
        Write-Host "$Name restored."
    }
}

try {
    Write-Host 'Collecting guest inventory before changes.'
    Get-CimInstance Win32_Service -OperationTimeoutSec 10 |
        Select-Object Name,DisplayName,StartMode,State,ProcessId |
        ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $out 'services.json') -Encoding UTF8
    & (Join-Path $PSScriptRoot 'Get-BnqqOSOptimizationInventory.ps1') |
        Set-Content -LiteralPath (Join-Path $out 'inventory.json') -Encoding UTF8

    Read-CapturePreferences | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $out 'capture-before-settings.json') -Encoding UTF8
    Save-Capture 'capture-before'
    Start-Process 'ms-settings:gaming-gamedvr'
    $choice = Read-Host 'Turn off background recording if enabled, then enter OFF. Enter skips the capture comparison'
    Read-CapturePreferences | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $out 'capture-after-settings.json') -Encoding UTF8
    if ($choice -eq 'OFF') {
        Save-Capture 'capture-after'
        Write-Host 'Restore the original recording preference in Settings if you use clips.'
    }
    else { Write-Host 'Capture comparison skipped.' }

    Write-Host 'Startup inventory is saved. Startup changes take effect at the next sign-in.'
    $toolkit = Join-Path $PSScriptRoot 'toolkit'
    if (Test-Path -LiteralPath (Join-Path $toolkit 'Startup.ps1')) {
        try {
            . (Join-Path $toolkit 'Core.ps1')
            . (Join-Path $toolkit 'Startup.ps1')
            $plan = Invoke-BnqqStartup -Action plan -Apps OneDrive
            $plan | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $out 'onedrive-plan.json') -Encoding UTF8
            if ($plan.Operations.Count) {
                $applied = Invoke-BnqqStartup -Action apply -Apps OneDrive
                try {
                    $check = Get-BnqqStartupPlan -Apps OneDrive
                    if ($check.Items[0].State -ne 'RunEntryAbsent') { throw 'OneDrive startup entry is still present.' }
                } finally {
                    Invoke-BnqqStartup -Action restore -File $applied.Journal |
                        ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $out 'onedrive-restore.json') -Encoding UTF8
                }
            } else { Write-Host 'No eligible OneDrive startup entry to test.' }
        } catch { Write-Warning "OneDrive - $($_.Exception.Message)" }
    }
    foreach ($name in 'SysMain','WSearch') {
        try { Test-ServiceCondition $name }
        catch { Write-Warning "$name - $($_.Exception.Message)" }
    }
} finally {
    Write-Host "Reports saved in $out"
    Start-Process explorer.exe -ArgumentList ('"' + $out + '"')
}
