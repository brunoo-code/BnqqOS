#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$RunDirectory,
    [Parameter(Mandatory)][string]$ToolkitExe,
    [string[]]$RequiredRemovedApp,
    [switch]$VerifyIsoHash
)
$ErrorActionPreference = 'Stop'
$manifest = Get-Content -LiteralPath (Join-Path $RunDirectory 'manifest.json') -Raw | ConvertFrom-Json
$iso = Get-Item -LiteralPath (Join-Path $RunDirectory 'BnqqOS.iso')
$toolkitHash = (Get-FileHash -LiteralPath $ToolkitExe -Algorithm SHA256).Hash
if ($iso.Length -ne $manifest.BnqqOsIsoBytes) { throw 'ISO size differs from the manifest.' }
if ($manifest.DefaultColorMode -ne 'WindowsDefault') { throw 'The image does not preserve the Windows color-mode default.' }
if ($manifest.ToolkitExeSha256 -ne $toolkitHash) { throw 'The image contains a different Toolkit build.' }
if ($manifest.BnqqOsIsoSha256 -notmatch '^[a-fA-F0-9]{64}$') { throw 'Invalid ISO checksum in the manifest.' }
$before = @($manifest.Before)
$after = @($manifest.After)
$removed = @($manifest.Removed)
if (-not $before.Count -or -not $after.Count -or -not $removed.Count) {
    throw 'Missing package inventory in the release manifest.'
}
$expected = @($before | Where-Object { $_ -notin $removed } | Sort-Object)
if (($expected -join "`n") -cne (($after | Sort-Object) -join "`n") -or
    @($removed | Where-Object { $_ -notin $before }).Count) {
    throw 'The package inventory does not match the declared removals.'
}
foreach ($app in $RequiredRemovedApp) {
    $prefix = '^' + [regex]::Escape($app) + '_'
    if (-not @($removed -match $prefix).Count -or @($after -match $prefix).Count) {
        throw "Required app removal was not confirmed: $app."
    }
}
if ($VerifyIsoHash -and (Get-FileHash -LiteralPath $iso.FullName -Algorithm SHA256).Hash -ne $manifest.BnqqOsIsoSha256) {
    throw 'ISO SHA-256 differs from the manifest.'
}
[pscustomobject]@{
    IsoPath = $iso.FullName
    IsoBytes = $iso.Length
    IsoSha256 = $manifest.BnqqOsIsoSha256
    IsoSha256Rechecked = [bool]$VerifyIsoHash
    ToolkitSha256 = $toolkitHash
    DefaultColorMode = $manifest.DefaultColorMode
    RemovedPackages = $removed
    VerifiedRequiredApps = @($RequiredRemovedApp)
}
