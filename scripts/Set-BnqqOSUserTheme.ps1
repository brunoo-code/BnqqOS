$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'assets\branding\bnqqos-wallpaper-3840x2160.jpg'
if (-not (Test-Path -LiteralPath $source)) {
    $source = Join-Path (Split-Path $PSScriptRoot -Parent) 'assets\branding\bnqqos-wallpaper-3840x2160.jpg'
}
$folder = Join-Path $env:LOCALAPPDATA 'BnqqOS\Branding'
New-Item -ItemType Directory -Force -Path $folder | Out-Null
$image = Join-Path $folder 'lock-screen.jpg'
Copy-Item -LiteralPath $source -Destination $image -Force

$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
New-Item -Path $key -Force | Out-Null
foreach ($name in 'AppsUseLightTheme', 'SystemUsesLightTheme', 'EnableTransparency') {
    New-ItemProperty -Path $key -Name $name -Value 0 -PropertyType DWord -Force | Out-Null
}
Write-Host 'Dark mode and opaque surfaces configured for this account.'

Add-Type -AssemblyName System.Runtime.WindowsRuntime
$storageType = [Windows.Storage.StorageFile, Windows.Storage, ContentType=WindowsRuntime]
$lockScreen = [Windows.System.UserProfile.LockScreen, Windows.System.UserProfile, ContentType=WindowsRuntime]
$asTask = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
    $_.Name -eq 'AsTask' -and $_.IsGenericMethodDefinition -and
    $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
} | Select-Object -First 1
$operation = $storageType::GetFileFromPathAsync($image)
$file = $asTask.MakeGenericMethod($storageType).Invoke($null, @($operation)).GetAwaiter().GetResult()
$action = $lockScreen::SetImageFileAsync($file)
$actionType = [Windows.Foundation.IAsyncAction, Windows.Foundation, ContentType=WindowsRuntime]
$asActionTask = [System.WindowsRuntimeSystemExtensions].GetMethod('AsTask', [type[]]@($actionType))
if ($null -eq $asActionTask -or $null -eq $action) {
    throw 'The Windows lock-screen operation could not be monitored.'
}
$task = $asActionTask.Invoke($null, @($action))
$task.GetAwaiter().GetResult()
Write-Host 'Lock-screen image set. Check the sign-in background in Windows Settings.'
