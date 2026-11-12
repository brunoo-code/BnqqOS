#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$LgpoPath,
    [ValidateSet('1920x1080', '3840x2160')]
    [string]$Resolution = '3840x2160'
)

$ErrorActionPreference = 'Stop'
$brand = Join-Path (Split-Path $PSScriptRoot -Parent) 'assets\branding'
$wallpaperSource = Join-Path $brand "bnqqos-wallpaper-$Resolution.jpg"
$avatarSource = Join-Path $brand 'bnqqos-avatar.png'
$accountPictures = Join-Path $env:ProgramData 'Microsoft\User Account Pictures'
$destination = Join-Path $env:ProgramData 'BnqqOS\Branding'
$wallpaper = Join-Path $destination 'wallpaper.jpg'
$backup = Join-Path $destination ('Backup-' + [guid]::NewGuid().ToString('N'))
$lgpo = (Resolve-Path -LiteralPath $LgpoPath).ProviderPath
Get-Item -LiteralPath $wallpaperSource, $avatarSource, $accountPictures | Out-Null
New-Item -ItemType Directory -Path $backup | Out-Null

& $lgpo /b $backup
if ($LASTEXITCODE -ne 0) { throw 'Could not back up Local Group Policy.' }

Add-Type -AssemblyName System.Drawing
$avatar = [Drawing.Image]::FromFile($avatarSource)
try {
    $names = @('user.jpg', 'user.png', 'user.bmp', 'guest.jpg', 'guest.png', 'guest.bmp')
    $sizes = @(32, 40, 48, 192)
    $names += $sizes | ForEach-Object { "user-${_}.png" }
    foreach ($name in $names) {
        $target = Join-Path $accountPictures $name
        if (Test-Path -LiteralPath $target) {
            Copy-Item -LiteralPath $target -Destination $backup
        } elseif ($name -notin @('user.jpg', 'guest.jpg')) {
            continue
        }
        $size = if ($name -match '-(\d+)\.png$') { [int]$Matches[1] } else { 448 }
        $format = switch ([IO.Path]::GetExtension($name)) {
            '.png' { [Drawing.Imaging.ImageFormat]::Png }
            '.bmp' { [Drawing.Imaging.ImageFormat]::Bmp }
            default { [Drawing.Imaging.ImageFormat]::Jpeg }
        }
        $tile = [Drawing.Bitmap]::new($avatar, $size, $size)
        try { $tile.Save($target, $format) } finally { $tile.Dispose() }
    }
} finally { $avatar.Dispose() }

Copy-Item -LiteralPath $wallpaperSource -Destination $wallpaper -Force
$policyFile = Join-Path $destination 'Branding-LGPO.txt'
@"
Computer
Software\Microsoft\Windows\CurrentVersion\Policies\Explorer
UseDefaultTile
DWORD:1

User
Software\Microsoft\Windows\CurrentVersion\Policies\System
Wallpaper
SZ:$wallpaper

User
Software\Microsoft\Windows\CurrentVersion\Policies\System
WallpaperStyle
SZ:4

User
Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop
NoChangingWallPaper
DWORD:1

"@ | Set-Content -LiteralPath $policyFile -Encoding Unicode
& $lgpo /t $policyFile
if ($LASTEXITCODE -ne 0) { throw "Could not import branding policy. Backup: $backup" }
& gpupdate.exe /force
if ($LASTEXITCODE -ne 0) { throw 'Policy imported, but refresh failed.' }
"Branding policy imported. Backup: $backup"
