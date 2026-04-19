# Build Rallly release APK - bypasses Puro shim to fix web SDK path
$FLUTTER_SDK = "C:\Users\Leyla\.puro\envs\stable\flutter"
$DART        = "$FLUTTER_SDK\bin\cache\dart-sdk\bin\dart.exe"
$TOOLS_DART  = "$FLUTTER_SDK\packages\flutter_tools\bin\flutter_tools.dart"
$PKG_CONFIG  = "$FLUTTER_SDK\packages\flutter_tools\.dart_tool\package_config.json"

$env:FLUTTER_ROOT     = $FLUTTER_SDK
$env:ANDROID_HOME     = "C:\Users\Leyla\AppData\Local\Android\Sdk"
$env:ANDROID_SDK_ROOT = "C:\Users\Leyla\AppData\Local\Android\Sdk"
$env:JAVA_HOME        = "C:\Program Files\Android\Android Studio\jbr"

Set-Location $PSScriptRoot
Write-Output "Building Rallly APK (release)..."
& $DART "--packages=$PKG_CONFIG" $TOOLS_DART build apk --release
Write-Output ""
if ($LASTEXITCODE -eq 0) {
    $apk = "$PSScriptRoot\build\app\outputs\flutter-apk\app-release.apk"
    Write-Output "SUCCESS! APK at: $apk"
    $size = [math]::Round((Get-Item $apk).Length / 1MB, 1)
    Write-Output "Size: ${size}MB"
} else {
    Write-Output "Build failed - check errors above"
}
