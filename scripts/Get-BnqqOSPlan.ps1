#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory, ParameterSetName = 'Inventory')]
    [string]$InventoryPath,

    [Parameter(Mandatory, ParameterSetName = 'Offline')]
    [string]$OfflineImagePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$profilePath = Join-Path (Split-Path -Parent $PSScriptRoot) 'profiles/bnqqos.json'
$profile = Get-Content -LiteralPath $profilePath -Raw | ConvertFrom-Json
if ($profile.schemaVersion -ne 1) { throw 'Unsupported profile version.' }

$allowlist = @{}
foreach ($candidate in $profile.candidates) {
    if ($allowlist.ContainsKey($candidate.displayName)) { throw 'Duplicate profile candidate.' }
    $allowlist.Add($candidate.displayName, $candidate.reason)
}

if ($PSCmdlet.ParameterSetName -eq 'Offline') {
    $mount = Get-Item -LiteralPath $OfflineImagePath
    if (-not $mount.PSIsContainer) { throw 'Expected a mounted image directory.' }
    $mounted = @(Get-WindowsImage -Mounted | Where-Object {
        $_.Path.TrimEnd('\') -eq $mount.FullName.TrimEnd('\') -and $_.MountStatus -eq 'Ok'
    })
    if ($mounted.Count -ne 1) { throw 'Expected an image already mounted with DISM and in Ok state.' }
    $inventory = @(Get-AppxProvisionedPackage -Path $mount.FullName)
} else {
    $inventory = @(Get-Content -LiteralPath $InventoryPath -Raw | ConvertFrom-Json)
}

$plannedPackages = @(foreach ($package in $inventory) {
    if ($allowlist.ContainsKey($package.DisplayName)) {
        [pscustomobject]@{
            DisplayName = $package.DisplayName
            PackageName = $package.PackageName
            Reason = $allowlist[$package.DisplayName]
        }
    }
})
[pscustomobject]@{
    Profile = $profile.name
    Mode = 'ReadOnly'
    PackagesScanned = $inventory.Count
    Candidates = $plannedPackages
}
