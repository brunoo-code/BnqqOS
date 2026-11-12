#Requires -Version 5.1
#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$SourceIso,
    [Parameter(Mandatory)][string]$Oscdimg,
    [Parameter(Mandatory)][string]$RunDirectory,
    [ValidatePattern('^[0-9A-Fa-f]{64}$')][string]$ExpectedSha256,
    [string]$Edition = 'Windows 11 Pro',
    [switch]$CreateVMs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$source = (Get-Item -LiteralPath $SourceIso).FullName
$tool = (Get-Item -LiteralPath $Oscdimg).FullName
$run = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($RunDirectory)
if (Test-Path -LiteralPath $run) { throw 'Choose a new run directory.' }

if ($CreateVMs) {
    $vmNames = @('BnqqOS-Control', 'BnqqOS')
    foreach ($name in $vmNames) {
        if (Get-VM -Name $name -ErrorAction SilentlyContinue) {
            throw "VM already exists: $name"
        }
    }
}
New-Item -Path $run -ItemType Directory | Out-Null
$media = New-Item -Path (Join-Path $run 'media') -ItemType Directory
$mount = New-Item -Path (Join-Path $run 'mount') -ItemType Directory
$bnqqIso = Join-Path $run 'BnqqOS.iso'
Start-Transcript -Path (Join-Path $run 'build.log') | Out-Null
try {
    $sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    if ($ExpectedSha256 -and $sourceHash -ne $ExpectedSha256) {
        throw 'Source ISO SHA-256 differs from the expected Microsoft hash.'
    }
    $disk = Get-DiskImage -ImagePath $source
    $attachedHere = -not $disk.Attached
    try {
        if ($attachedHere) { $disk = Mount-DiskImage -ImagePath $source -PassThru }
        $volume = $disk | Get-Volume
        if (-not $volume.DriveLetter) { throw 'ISO has no mounted drive letter.' }
        $mediaRoot = "$($volume.DriveLetter):\"
        & robocopy.exe $mediaRoot $media.FullName /E /R:1 /W:1 /NP
        if ($LASTEXITCODE -ge 8) { throw "Robocopy failed ($LASTEXITCODE)." }
    } finally {
        if ($attachedHere -and (Get-DiskImage -ImagePath $source).Attached) {
            Dismount-DiskImage -ImagePath $source | Out-Null
        }
    }

    $sources = Join-Path $media.FullName 'sources'
    $install = @(Get-ChildItem -LiteralPath $sources -File | Where-Object {
        $_.Name -in 'install.wim', 'install.esd'
    })
    if ($install.Count -ne 1) { throw 'Expected one install.wim or install.esd.' }
    $image = @(Get-WindowsImage -ImagePath $install[0].FullName | Where-Object { $_.ImageName -eq $Edition })
    if ($image.Count -ne 1) { throw "Edition not found exactly once: $Edition" }
    $sourceImage = Get-WindowsImage -ImagePath $install[0].FullName -Index $image[0].ImageIndex
    $build = ([version]$sourceImage.Version).Build
    $releaseByBuild = @{ 26100 = '24H2'; 26200 = '25H2'; 26300 = '26H2'; 28000 = '26H1' }
    $release = $releaseByBuild[$build]
    if (-not $release) { $release = "Build $build" }
    $imageName = "BnqqOS $($Edition -replace '^Windows 11', 'Win11') $release"
    $wim = Join-Path $run 'install.wim'
    Export-WindowsImage -SourceImagePath $install[0].FullName -SourceIndex $image[0].ImageIndex -DestinationImagePath $wim -DestinationName $imageName -CompressionType Max -CheckIntegrity | Out-Null
    $exportedImages = @(Get-WindowsImage -ImagePath $wim)
    if ($exportedImages.Count -ne 1 -or $exportedImages[0].ImageName -ne $imageName) {
        throw 'The exported WIM does not contain the expected single image.'
    }
    $exportedImage = Get-WindowsImage -ImagePath $wim -Index 1
    if ($sourceImage.EditionId -and $exportedImage.EditionId -and
        $exportedImage.EditionId -ne $sourceImage.EditionId) {
        throw 'The exported Windows edition differs from the source.'
    }
    Remove-Item -LiteralPath $install[0].FullName -Force

    Mount-WindowsImage -ImagePath $wim -Index 1 -Path $mount.FullName -CheckIntegrity | Out-Null
    $committed = $false
    try {
        $before = @(Get-AppxProvisionedPackage -Path $mount.FullName)
        $plan = & (Join-Path $PSScriptRoot 'Get-BnqqOSPlan.ps1') -OfflineImagePath $mount.FullName
        if ($plan.Candidates.Count -eq 0) { throw 'No BnqqOS candidates found on this build.' }
        foreach ($item in $plan.Candidates) {
            Remove-AppxProvisionedPackage -Path $mount.FullName -PackageName $item.PackageName | Out-Null
        }
        $after = @(Get-AppxProvisionedPackage -Path $mount.FullName)
        $expected = @($before.PackageName | Where-Object { $_ -notin $plan.Candidates.PackageName } | Sort-Object)
        $actual = @($after.PackageName | Sort-Object)
        if (($expected -join "`n") -ne ($actual -join "`n")) {
            throw 'Unexpected package difference. Discarding image changes.'
        }
        # Seed the user template before Windows creates the first account.
        $profileHive = Join-Path $mount.FullName 'Users\Default\NTUSER.DAT'
        if (-not (Test-Path -LiteralPath $profileHive -PathType Leaf)) {
            throw 'The mounted image does not contain the default user profile hive.'
        }
        $hiveName = 'BnqqOS_' + [guid]::NewGuid().ToString('N')
        $hive = "HKU\$hiveName"
        & reg.exe load $hive $profileHive
        if ($LASTEXITCODE -ne 0) { throw 'Could not load the offline default user profile.' }
        try {
            $themeKey = "$hive\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
            foreach ($setting in 'SystemUsesLightTheme', 'AppsUseLightTheme') {
                & reg.exe add $themeKey /v $setting /t REG_DWORD /d 0 /f
                if ($LASTEXITCODE -ne 0) { throw "Could not write the dark-mode setting $setting." }
                $value = & reg.exe query $themeKey /v $setting
                if ($LASTEXITCODE -ne 0 -or ($value -join ' ') -notmatch 'REG_DWORD\s+0x0\s*$') {
                    throw "Could not verify the dark-mode setting $setting."
                }
            }
        } finally {
            & reg.exe unload $hive
            if ($LASTEXITCODE -ne 0) { throw 'Could not unload the offline default user profile.' }
        }

        Dismount-WindowsImage -Path $mount.FullName -Save -CheckIntegrity | Out-Null
        $committed = $true
    } finally {
        if (-not $committed) { Dismount-WindowsImage -Path $mount.FullName -Discard | Out-Null }
    }

    Move-Item -LiteralPath $wim -Destination (Join-Path $sources 'install.wim')
    $bios = Join-Path $media.FullName 'boot\etfsboot.com'
    $uefi = Join-Path $media.FullName 'efi\microsoft\boot\efisys.bin'
    $temporaryIso = Join-Path $run 'BnqqOS.incomplete.iso'
    & $tool '-m' '-o' '-u2' '-udfver102' "-bootdata:2#p0,e,b$bios#pEF,e,b$uefi" $media.FullName $temporaryIso
    if ($LASTEXITCODE -ne 0) { throw "Oscdimg failed ($LASTEXITCODE)." }
    Move-Item -LiteralPath $temporaryIso -Destination $bnqqIso
    [ordered]@{
        DefaultColorMode = 'Dark'
        Edition = $Edition
        ImageName = $exportedImages[0].ImageName
        SourceIndex = $image[0].ImageIndex
        SourceIsoSha256 = $sourceHash
        BnqqOsIsoSha256 = (Get-FileHash -LiteralPath $bnqqIso -Algorithm SHA256).Hash
        SourceIsoBytes = (Get-Item -LiteralPath $source).Length
        BnqqOsIsoBytes = (Get-Item -LiteralPath $bnqqIso).Length
        Before = @($before.PackageName | Sort-Object)
        After = $actual
        Removed = @($plan.Candidates.PackageName)
    } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $run 'manifest.json') -Encoding UTF8

    if ($CreateVMs) {
        $images = @($source, $bnqqIso)
        for ($i = 0; $i -lt $vmNames.Count; $i++) {
            $name = $vmNames[$i]
            $vmRoot = New-Item -Path (Join-Path $run $name) -ItemType Directory
            $vm = New-VM -Name $name -Generation 2 -MemoryStartupBytes 8GB -NewVHDPath (Join-Path $vmRoot.FullName 'system.vhdx') -NewVHDSizeBytes 80GB -Path $vmRoot.FullName
            Set-VM -VM $vm -AutomaticCheckpointsEnabled $false
            Set-VMProcessor -VM $vm -Count 4
            Set-VMKeyProtector -VMName $name -NewLocalKeyProtector
            Enable-VMTPM -VMName $name
            $defaultSwitch = Get-VMSwitch -Name 'Default Switch' -ErrorAction SilentlyContinue
            if ($defaultSwitch) { Connect-VMNetworkAdapter -VMName $name -SwitchName $defaultSwitch.Name }
            $dvd = Add-VMDvdDrive -VMName $name -Path $images[$i] -Passthru
            Set-VMFirmware -VMName $name -EnableSecureBoot On -FirstBootDevice $dvd
        }
    }
} finally {
    Stop-Transcript | Out-Null
}
