# Run Rallly on Chrome - bypasses Puro shim to fix web SDK path
$FLUTTER_SDK = "C:\Users\Leyla\.puro\envs\stable\flutter"
$DART        = "$FLUTTER_SDK\bin\cache\dart-sdk\bin\dart.exe"
$TOOLS_DART  = "$FLUTTER_SDK\packages\flutter_tools\bin\flutter_tools.dart"
$PKG_CONFIG  = "$FLUTTER_SDK\packages\flutter_tools\.dart_tool\package_config.json"

$env:FLUTTER_ROOT     = $FLUTTER_SDK
$env:ANDROID_HOME     = "C:\Users\Leyla\AppData\Local\Android\Sdk"
$env:ANDROID_SDK_ROOT = "C:\Users\Leyla\AppData\Local\Android\Sdk"

Set-Location $PSScriptRoot
Write-Output "Starting Rallly on Chrome..."
& $DART "--packages=$PKG_CONFIG" $TOOLS_DART run -d chrome
